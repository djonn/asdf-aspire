#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/dotnet/aspire"
TOOL_NAME="aspire"
TOOL_TEST="aspire --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if aspire is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

get_platform() {
	local os arch

	case "$(uname -s)" in
	Darwin*) os="osx" ;;
	Linux*)
		if command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -q musl; then
			os="linux-musl"
		else
			os="linux"
		fi
		;;
	CYGWIN* | MINGW* | MSYS*) os="win" ;;
	*) fail "Unsupported operating system: $(uname -s)" ;;
	esac

	case "$(uname -m)" in
	x86_64 | amd64) arch="x64" ;;
	aarch64 | arm64) arch="arm64" ;;
	*) fail "Unsupported architecture: $(uname -m)" ;;
	esac

	echo "${os}-${arch}"
}

get_download_url() {
	local version="$1"
	local platform="$2"
	local extension

	if [[ "$platform" == win-* ]]; then
		extension="zip"
	else
		extension="tar.gz"
	fi

	echo "${GH_REPO}/releases/download/v${version}/aspire-cli-${platform}-${version}.${extension}"
}

get_checksum_url() {
	local version="$1"
	local platform="$2"
	local extension

	if [[ "$platform" == win-* ]]; then
		extension="zip"
	else
		extension="tar.gz"
	fi

	echo "${GH_REPO}/releases/download/v${version}/aspire-cli-${platform}-${version}.${extension}.sha512"
}

download_release() {
	local version filename platform url checksum_url
	version="$1"
	filename="$2"

	platform=$(get_platform)
	url=$(get_download_url "$version" "$platform")
	checksum_url=$(get_checksum_url "$version" "$platform")

	echo "* Downloading $TOOL_NAME release $version for $platform..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"

	# Download and validate checksum
	local checksum_file="${filename}.sha512"
	echo "* Downloading checksum..."
	curl "${curl_opts[@]}" -o "$checksum_file" "$checksum_url" || fail "Could not download checksum from $checksum_url"

	echo "* Validating checksum..."
	validate_checksum "$filename" "$checksum_file"
}

validate_checksum() {
	local archive_file="$1"
	local checksum_file="$2"

	local checksum_cmd=""
	if command -v sha512sum >/dev/null 2>&1; then
		checksum_cmd="sha512sum"
	elif command -v shasum >/dev/null 2>&1; then
		checksum_cmd="shasum -a 512"
	else
		fail "Neither sha512sum nor shasum is available. Please install one of them to validate checksums."
	fi

	local expected_checksum
	expected_checksum=$(tr -d '\n\r' <"$checksum_file" | tr '[:upper:]' '[:lower:]')

	local actual_checksum
	actual_checksum=$(${checksum_cmd} "$archive_file" | cut -d' ' -f1)

	if [[ "$expected_checksum" != "$actual_checksum" ]]; then
		fail "Checksum validation failed! Expected: $expected_checksum, Got: $actual_checksum"
	fi

	echo "* Checksum validated successfully"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"

		local platform
		platform=$(get_platform)

		echo "* Installing $TOOL_NAME $version..."

		# Extract the archive based on platform
		if [[ "$platform" == win-* ]]; then
			# Windows uses zip
			if ! command -v unzip >/dev/null 2>&1; then
				fail "unzip command not found. Please install unzip."
			fi
			unzip -o "$ASDF_DOWNLOAD_PATH"/*.zip -d "$install_path" || fail "Failed to extract archive"
		else
			# Unix/Linux/macOS uses tar.gz
			tar -xzf "$ASDF_DOWNLOAD_PATH"/*.tar.gz -C "$install_path" || fail "Failed to extract archive"
		fi

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
