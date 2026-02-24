# Software Requirements for Local Development

This document presents the software requirements for developers who want to use their laptop or desktop computer or a custom virtual machine as a development environment instead of using the development container to build, run, and contribute to the website. The following software packages are required to be installed:

1. [GitHub Copilot CLI](#github-copilot-cli)
1. [Fast Node Manager](#fast-node-manager)
1. [Node.js](#nodejs)

## GitHub Copilot CLI

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :grey_question: |
| Linux | :grey_question: |
| Microsoft Windows | :grey_question: |

[GitHub Copilot CLI](https://github.com/features/copilot/cli/) is a terminal version of GitHub Copilot and can be used to use GitHub Copilot and AI to complete tasks from the terminal, outside of Visual Studio Code.

- __Apple macOS or Linux__: GitHub Copilot CLI can be installed using [Homebrew](required_software.md#homebrew). In a terminal, run:

```shell
brew install copilot-cli
```

- __Microsoft Windows__: GitHub Copilot CLI can be installed using [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/). In Windows Terminal, run:

```powershell
winget install GitHub.Copilot
```

## Fast Node Manager

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :white_check_mark: |
| Linux | :white_check_mark: |
| Microsoft Windows | :white_check_mark: |

[Fast Node Manager](https://github.com/Schniz/fnm) is a version manager for [Node.js](https://nodejs.org). By using Fast Node Manager, you can install multiple versions of Node.js on your machine and quickly switch between versions for different projects that you are working on. When Fast Node Manager is integrated into your shell, Fast Node Manager will recognize the presence of [`.node-version`](../../.node-version) files in working directories and will automatically switch to (and install if necessary) the version of Node.js specified in that file.

- __Apple macOS or Linux__: Fast Node Manager can be installed using [Homebrew](required_software.md#homebrew). In a terminal, run:

```shell
curl -fsSL https://fnm.vercel.app/install | bash
```

This installation script will recognize the presence of Homebrew and will use it to download and install Fast Node Manager.

- __Microsoft Windows__: Fast Node Manager can be installed using [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/). In Windows Terminal, run:

```powershell
winget install Schniz.fnm
```

## Node.js

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :white_check_mark: |
| Linux | :white_check_mark: |
| Microsoft Windows | :white_check_mark: |

[Node.js](https://nodejs.org) is a JavaScript runtime environment. Node.js is popular for creating command line tools, websites, web servers, and microservices. It is recommended that you use [Fast Node Manager](#fast-node-manager) to install and manage Node.js for you.

To install Node.js using Fast Node Manager, open a terminal and navigate to the repository directory. If Fast Node Manager is integrated into your shell, it should find the [`.node-version`](../../.node-version) file and try to load that version of Node.js. If the version of Node.js is not yet installed on your machine, Fast Node Manager will prompt you for permission to install it.

If Fast Node Manager did not automatically switch to the correct version, you can run:

```shell
fnm use
```

The `fnm use` command will install (if necessary) and switch to the correct version of Node.js.
