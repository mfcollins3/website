# Required Software for All Developers

This document lists the software that must be installed locally for all developers when working with the source code for the website project. The following software packages are required:

1. [Homebrew](#homebrew)
1. [PowerShell](#powershell)
1. [Git](#git)
1. [Git LFS](#git-lfs)
1. [GitHub CLI](#github-cli)

## Homebrew

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :white_check_mark: |
| Linux | :white_check_mark: |
| Microsoft Windows | :x: |

[Homebrew](https://brew.sh) is a popular package manager for Apple macOS and Linux. Homebrew makes it easy to install many popular programs, software development tools, and libraries, and keep them up to date when new versions become available.

To install Homebrew, open a terminal and run:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It is necessary to restart your terminal after installing Homebrew so that the environmental changes can take effect.

## PowerShell

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :grey_question: |
| Linux | :grey_question: |
| Microsoft Windows | :white_check_mark: |

[PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview) is a task automation solution based on .NET. PowerShell includes a command line shell, scripting language, and a configuration management framework.

- __Apple macOS or Linux__: PowerShell can be installed using [Homebrew](#homebrew). In a terminal, run:

```shell
brew install --cask powershell
```

- __Microsoft Windows__: PowerShell can be installed using [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/). In Windows Terminal, run:

```powershell
winget install --id Microsoft.PowerShell --source winget
```

## Git

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :white_check_mark: |
| Linux | :white_check_mark: |
| Microsoft Windows | :white_check_mark: |

[Git](https://git-scm.com) is a popular version control system that is used to track changes to software projects. Git is a distributed version control system where each developer maintains their own clone of the repository and can work in isolation from other developers. Git makes it easy for developers to share their changes with each other either directory or by using a shared repository such as a repository on [GitHub](https://github.com).

- __Apple macOS or Linux__: Git can be installed using [Homebrew](#homebrew). In a terminal, run:

```shell
brew install git
```

- __Microsoft Windows__: Git can be installed using [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/). In Windows Terminal, run:

```powershell
winget install --id Git.Git -e --source winget
```

## Git LFS

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :white_check_mark: |
| Linux | :white_check_mark: |
| Microsoft Windows | :white_check_mark: |

[Git LFS](https://git-ls.com) is an extension for [Git](#git) that enables the storage of large files outside of the Git repository in a large file storage. Certain types of files such as executable code, images, PDFs, documents, and other large files that are not able to be versioned are better served by storing them in LFS instead of in the repository. The reduction in large files keeps the Git repository size low.

- __Apple macOS or Linux__: Git LFS can be installed using [Homebrew](#homebrew). In a terminal, run:

```shell
brew install git-lfs
```

- __Microsoft Windows__: Git LFS is installed automatically by [Git for Windows](#git) and does not need to be installed separately.

## GitHub CLI

| Operating System | Required? |
| ---------------- | --------- |
| Apple macOS | :white_check_mark: |
| Linux | :white_check_mark: |
| Microsoft Windows | :white_check_mark: |

[GitHub CLI](https://cli.github.com) is a command line interface for [GitHub](https://github.com). GitHub CLI can be used to clone repositories hosted on GitHub, create issues, manage projects, run GitHub Actions workflows, or perform one-off administrative tasks.

- __Apple macOS or Linux__: GitHub CLI can be installed using [Homebrew](#homebrew). In a terminal, run:

```shell
brew install gh
```

- __Microsoft Windows__: GitHub CLI can be installed using [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/). In Windows Terminal, run:

```powershell
winget install --id GitHub.cli
```
