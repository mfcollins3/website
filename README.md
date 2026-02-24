# My Website

## About My Website

This Git repository contains the source code for my personal and professional website that is hosted at https://michaelfcollins3.dev using [GitHub Pages](https://docs.github.com/en/pages). My website is the cornerstone of my personal and professional brand. The primary feature of my website is a blog where I write and publish articles frequently about my work and interests as a software developer. I often write about what I am learning or projects that I am developing for my own use or to share with others.

## Getting Started

Before cloning the repository, please review the [software requirements](docs/software_requirements/README.md) and ensure that the required software is installed and your development environment is prepared.

## Using the Development Container

Using the [development container](https://code.visualstudio.com/docs/devcontainers/containers) is the preferred and recommended way to build, run, and develop for the website. The development container is preconfigured will all of the development tools you will need to build and run the website, and it provides a stable and isolated development environment.

To run the development container, follow these steps:

1. Run Visual Studio Code.
2. Open the Command Palette using <kbd>COMMAND</kbd> + <kbd>SHIFT</kbd> + <kbd>P</kbd> (Apple macOS) or <kbd>CTRL</kbd> + <kbd>SHIFT</kbd> + <kbd>P</kbd> (Linux or Microsoft Windows).
3. Search for the `Dev Containers: Clone Repository in Container Volume...` command.
4. Enter `https://github.com/mfcollins3/website` into the field for the URL of the repository to clone or choose `Clone a repository from GitHub in a Container Volume` and enter `mfcollins3/website` as the name of the repository to clone.

Visual Studio Code will create a new Docker volume to hold the source code, will clone the GitHub repository into the volume, and will build and run the development container attached to the volume.

## Developing Locally

Once your development environment is ready, you can clone the GitHub repository. In a terminal, navigate to the location in your file system where you want to store the Git repository and run:

```shell
gh repo clone mfcollins3/website
```

The `gh repo clone` command will clone the `mfcollins3/website` Git repository from GitHub and will check out the default branch in the `website` subdirectory.

Before you can build and run the website, you will need to set up your local project workspace for development. Setting up the project workspace installs dependencies and tools that are needed to build and run the website. The steps required to set up the project workspace have been automated and placed in the `setup.sh` script (Apple macOS or Linux developers) or `Setup.ps1` script (PowerShell users, Microsoft Windows developers).

- __Apple macOS or Linux__: In the terminal, run:

```shell
cd website
./setup.sh
```

- __PowerShell or Microsoft Windows__: In the terminal, run:

```powershell
cd website
&"./Setup.ps1"
```

After the `setup.sh` or `Setup.ps1` script completes successfully, your local project workspace is ready and you can build and run the website locally. Running `setup.sh` or `Setup.ps1` is only required once, immediately after cloning the Git repository.
