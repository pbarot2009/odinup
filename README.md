# OdinUP: Native Odin Version Manager

OdinUP is a version manager for Odin and Ols written in ON.

## Script Installation

Script Installation is recommanded way if you just want to use **OdinUP**.

Kindly follow below steps:

### Linux & macOS

Open your terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/pbarot2009/odinup/main/install.sh | bash
```

After installation, restart your terminal or run:

```bash
source ~/.bashrc
```

Then verify it works:

```bash
odinup help
```

### Windows (PowerShell)

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/pbarot2009/odinup/main/install.ps1 | iex
```

Then open a new terminal and verify:

```powershell
odinup help
```

### Updating OdinUP

To update **OdinUP** do run installer script. Installer will handle updating itself.

---

## Installation from Source

**REQUREMENTS:** An Existing Odin Compiler and Clang.

## Step 1: Clone and Build

Open terminal and run:

```bash
git clone https://github.com/prathmesh-barot/odinup.git
cd odinup
odin build . -o:speed 
```

### Step 2: Initialize

Run the executable once. This generates the hidden `.odinup` directory structure on your machine.

```bash
./odinup help
```

### Step 3: Configure Your Shell

For Linux and macOS, open your shell profile (`~/.bashrc` or `~/.zshrc`) and append:

```bash
export PATH="$HOME/.odinup/bin:$PATH"
```

Reload your shell.

For Windows, add `%USERPROFILE%\.odinup\bin` to your System PATH variables via the Environment Variables GUI.

## Cmds References

The CLI is colorful and readable.

### odinup help

Prints the Help Menu of **OdinUP**.

```bash
odinup help
```

### odinup list-remote (lr)

Fetchs the official Odin and Ols repos, then prints the versions list.

To list-remote odin:

```bash
odinup lr
```

To list-remote Ols:

```bash
odinup lr -ols
```

### odinup install `<version>` (i)

Install the specific version of Odin and Ols acording to your System.

To Install Odin:

```bash
odinup i dev-2026-04
```

To Install Ols:

```bash
odinup i -ols dev-2026-04
```

### odinup use `<version>` (u)

Use the Specific version of Odin and Ols from installed versions.

To use Odin:

```bash
odinup use dev-2026-04
```

To use Ols: 

```bash
odinup use -ols dev-2026-04
```

### odinup env

Prints the exact path string required your system enviroment variables.

```bash
odinup env
```

---

## Project Tree

* [main.odin](main.odin)
* [cli.odin](cli.odin)
* [config.odin](config.odin)
* [remote.odin](remote.odin)
* [local.odin](local.odin)
* [install.odin](install.odin)
* [install.sh](install.sh)
* [install.ps1](install.ps1)
* [download.odin](download.odin)
* [utils.odin](utils.odin)

## License

OdinUP is released under the **Apache 2.0 License**.

See the [LICENSE](LICENSE)