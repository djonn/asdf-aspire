# asdf-aspire

Install and manage the [aspire](https://github.com/dotnet/aspire) cli using the [asdf version manager](https://asdf-vm.com) or [mise](https://mise.jdx.dev/).

# Dependencies

- `bash`, `curl`, `tar` (or `unzip` on Windows), and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `sha512sum` or `shasum` for checksum validation.

# Install

If using mise just replace `asdf` with `mise` in any of the commands.

Plugin:

```shell
asdf plugin add aspire
# or
asdf plugin add aspire https://github.com/djonn/asdf-aspire.git
```

Install and manage:

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

Check [asdf](https://github.com/asdf-vm/asdf) or [mise](https://github.com/jdx/mise) readme for more instructions on how to install & manage versions.
