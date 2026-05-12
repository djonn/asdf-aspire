<div align="center">

# asdf-aspire [![Build](https://github.com/djonn/asdf-aspire/actions/workflows/build.yml/badge.svg)](https://github.com/djonn/asdf-aspire/actions/workflows/build.yml) [![Lint](https://github.com/djonn/asdf-aspire/actions/workflows/lint.yml/badge.svg)](https://github.com/djonn/asdf-aspire/actions/workflows/lint.yml)

[aspire](https://github.com/dotnet/aspire) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar` (or `unzip` on Windows), and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `sha512sum` or `shasum` for checksum validation.

# Install

Plugin:

```shell
asdf plugin add aspire
# or
asdf plugin add aspire https://github.com/djonn/asdf-aspire.git
```

aspire:

```shell
# Show all installable versions
asdf list-all aspire

# Install specific version
asdf install aspire latest

# Set a version globally (on your ~/.tool-versions file)
asdf global aspire latest

# Now aspire commands are available
aspire --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.
