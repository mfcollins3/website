---
title: Building Multi-Platform Container Images with GitHub Actions
date: 2025-03-17
cover_attribution: >
    https://unsplash.com/photos/3d-rendering-cpu-processor-on-black-background-6Sk-qRRq31Y
description: >
    With Apple Silicon and the emergence of ARM support for Windows, runtime
    architecture is becoming more important as software that we produce must be
    able on running on different machine architectures. This post shows how to
    build multi-platform Docker container images to allow users to pull a
    container image that supports whatever architecture they are running on.
summary: >
    While working on a different blog post, I ran into a scenario where I needed
    to produce a Docker container of a microservice that I was creating. This
    made me remember that my production architecture is different from my
    development architecture and I needed to produce a Docker container image
    that supported both architectures. In this post, I share with you how I
    ended up getting this to work in my GitHub Actions pipeline and publishing
    to the GitHub Package Registry.
---
Things were really nice for a few years. Apple had given up the Power PC platform and had migrated to Intel x64 chips and for a while everybody was on the same architecture. But then in 2020, Apple introduced their M1 chip which threw things back into a tizzy. Apple's M1 chip adopted the [ARM architecture](https://en.wikipedia.org/wiki/ARM_architecture_family) for their Mac computer line and began the migration away from Intel. Since then, ARM has been growing as there's now a Microsoft Windows version that runs on ARM and Linux runs on ARM.

For software developers, the adoption of ARM has complicated how we package and deliver software. Whereas before we could assume for a few years that our software would always be deployed to x64 architecture, now we cannot make that assumption. Some users or production environments are running Intel. Other users and environments are ARM. If you don't release your software so that it can run on both, some users may not be able to run your software. For others, they may be able to run it using an emulator such as [Rosetta](https://en.wikipedia.org/wiki/Rosetta_(software)), but performance could suffer.

Earlier today, I was writing a microservice for another blog post when I got inspired to package it in a Docker container. It was at that moment when it occurred to me that architecture mattered. I was building and testing the Docker container on my MacBook Pro M3, but then I automated the build process using GitHub Actions and I realized that GitHub Actions was building the Docker container for x64. This was going to be a problem if I wanted to pull down the Docker container and test it locally. That realization led me down the rabbit hole of discovering how to build a multi-platform Docker container, and do it with GitHub Actions.

## The Goal

The objective of this post is that I need to build a docker container containing a Go microservice that I am creating. For production use, I want the footprint of the Docker container to be as small as possible, so I am basing the container on the [Alpine Linux](https://www.alpinelinux.org/) operating system. Alpine Linux is a slimmed down version of Linux that even lacks a shell. It's perfect for a Docker container because it just needs to be able to run your program.

The microservice that I am building is written in [Go](https://go.dev). Go compiles programs into a single executable. For deployment into the Docker container, I only need to build the executable and copy it into the location in the container's file system where I want to host it. Then I can configure the Docker container to run my microservice.

## Building the Microservice

The first step is to figure out how I am going to build my microservice to support both Intel and ARM architectures. Fortunately, in this circumstance, the Go compiler can perform cross-compiling. At build time, I can specify the target operating system (Linux) and target architecture (Intel or ARM), and the Go compiler will produce an executable that will run on that platform. This is handled by specifying environment variables when running the `go build` command.

There is a problem though when building for Alpine Linux. Most Linux distributions use the libc library when they compile C code. When building a Go application, the Go compiler will, by default, link against libc and make it required when the program is loaded. Unfortunately, Alpine Linux does not use libc, but there's a workaround. We can turn off CGo, and by extension, remove the dependency on the libc library so that we can build the program on a different version of Linux, but get it to run on Alpine Linux. This can be done byp assing the `CGO_ENABLED` environment variable to the `go build` command setting its value to `0`. I haven't been able to find a better solution for this, so this is what I am doing.

On [Docker Hub](https://hub.docker.com/_/golang), there is a Go base container image that is based on Alpine Linux and includes the development tools to produce Alpine Linux executables with CGo enabled. I could implement a multi-stage Docker container that builds in the Go Alpine container and then copies the executable to an Alpine base container image. But by not doing that, I can speed up my build process by caching dependencies using GitHub Actions. I'll save that for later in case I run into problems with this approach.

So I can perform cross compiling using the Go compiler by specifying three environment variables:

- `CGO_ENABLED=0`: this disabled CGo so that I can build executables that will run on Alpine Linux.
- `GOOS=linux`: `GOOS` specifies the target operating system to build for. In this case, my target is always going to be Linux.
- `GOARCH=(amd64|arm64)`: `GOARCH` specifies the target architecture and for my needs will be either `arm64` or `amd64`. There are other architectures that I can build for, but these will be my primary focus. `amd64` will produce an executable that will run on Intel architectures. `arm64` will produce an executable that will work on ARM architectures like Raspberry Pi or Apple Silicon.

My Go build command will look like this:

```shell
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -v ./cmd/authorization
```

This command will build a program whose `main.go` file is in the `cmd/authorization` subdirectory of the current directory. This command will produce an executable that will run on ARM architecture. I can switch it to `amd64` to build for Intel architecture.

## Defining the Container

The `Dockerfile` is pretty simple. Because I am going to cross-compile the program outside of the container to improve performance of the GitHub Actions workflow via caching, I'm not going to mess with a multi-stage build. I'm simply going to use an Alpine Linux base container and then copy my program into the file system:

{{< highlight docker >}}
FROM alpine:3.21.3

WORKDIR /opt/authorization

COPY build/authorization bin/

EXPOSE 80
ENTRYPOINT ["bin/authorization"]
CMD ["server"]
{{< /highlight >}}

I am storing my program in the `/opt/authorization` folder. Following the typical convention, I'm putting the executable in the `/opt/authorization/bin` subdirectory. I may in the future have additional resources or configuration files, so I'm kind of planning ahead a little. Because Alpine Linux does not include a shell, I'm setting my executable as the default executable using the `ENTRYPOINT` directive and setting the default execution mode to run my program in server mode. I know I haven't shown the actual program that I'm building yet, but I will in a future post.

## Building the Platform-Specific Containers

Now that I'm able to cross-compile my program and then build a Docker container, it's time to automate this using GitHub Actions. I'm not an expert on these multi-platform containers, but what I believe is happening is that I'm producing two container images that each target a specific platform. Then I'm creating a third container image that references the platform-specific containers. At runtime, Docker will pull the third container image, use the metadata inside of it to match the host platform, and then will download the correct platform-specific image. So the build process mirrors this:

1. Build the platform-specific containers
1. Create the metadata container that references the platform-specific containers

The first job in my GitHub Actions workflow uses the matrix capabilities of GitHub Actions to run the same job concurrently while varying the architectures. Since my target operating system is always going to be Linux, I just need to vary the architectures between `amd64` and `arm64`:

{{< highlight yaml >}}
  build_and_test:
    name: Build and Test
    runs-on: ubuntu-24.04
    strategy:
      fail-fast: false
      matrix:
        architecture:
          - amd64
          - arm64
    steps:
{{< /highlight >}}

The first step is obviously going to be to clone my repository and check out the branch that I'm building. The branch will either be the `main` branch or a pull request branch.

{{< highlight yaml >}}
      - name: Checkout the repository
        uses: actions/checkout@v4
{{< /highlight >}}

Next, I will install and activate the version of Go that I want to build with. I can use the [setup-go](https://github.com/actions/setup-go) action to do this:

{{< highlight yaml >}}
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version-file: 'src/authorization/go.mod'
          cache-dependency-path: 'src/authorization/go.sum'
{{< /highlight >}}

The `setup-go` action has a couple of very cool features. First, instead of having to hard code the version number for Go in my workflow, I can instead point `setup-go` to either a `go.work` file for a workspace or a `go.mod` file for a Go module and `setup-go` will extract the Go version number from there. That's nice, because I can keep the workflow generic. The other feature is the `cache-dependency-path` parameter. This is where the performance boost comes in because my program has a number of dependencies that have to be downloaded. `setup-go` will cache the dependencies after the build and will reload them from cache instead of downloading them again for each build, speeding the build. As long as the referenced `go.sum` file hasn't changed, the cached dependencies will be reloaded. If the `go.sum` file is updated with new or updated dependencies, the cache will be rebuilt.

I will next install the Docker Buildx tool that I will be using for building the Docker container and publishing it to GitHub Package Registry:

{{< highlight yaml >}}
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3
{{< /highlight >}}

Now it is time to build the program that I am going to copy into the Docker container. This is going to use the cross-compiling environment variables that I discussed in the [building section](#building-the-container).

{{< highlight yaml >}}
      - name: Build Authorization Service
        run: go build -v -o build/ ./cmd/authorization
        working-directory: src/authorization
        env:
          GCO_ENABLED: 0
          GOOS: linux
          GOARCH: ${{ matrix.architecture }}
{{< /highlight >}}

Notice the `GOARCH` environment variable. Here I'm referencing the `matrix.architecture` value. When the build runs, GitHub Actions will run this specific `build` job for each variant of the paraeters in the `matrix` section. Referencing `matrix.architecture` gives me the architecture variant for the current execution of the `build` job. For one job, `matrix.architecture` will be `amd64`. For the other job, it will be `arm64`.

Normally, my next step would be to run the automated unit test suite before going any further. But at the moment, my program is a simple shell program that just launches an HTTP server, so there's nothing really ot test yet. I'll add that in the future.

Now that the program is built, we're going to start the process of building and publishing the Docker container to GitHub Package Registry. The first move is that we need to log into GitHub Package Registry's Docker Hub endpoint. We can use a GitHub Action provided by Docker to do this:

{{< highlight yaml >}}
      - name: Log into GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY}}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
{{< /highlight >}}

The `env.REGISTRY` environment variable is defined as `ghcr.io`, which is the base URL for GitHub Package Registry. I'll show the full workflow at the end of the article. `github.actor` is the username of the user that triggered the GitHub Actions workflow. `secrets.GITHUB_TOKEN` is an access token that GitHub generated for the GitHub Action workflow to use to access the GitHub API and services. I customize the access token at the beginning of the workflow with additional permissions for publishing to GitHub Package Registry:

{{< highlight yaml >}}
permissions:
  contents: read
  packages: write
  attestations: write
  id-token: write
{{< /highlight >}}

After logging in successfully, there's another Docker action that we'll call to extract metadata from Git and GitHub for the repository being built. The `docker/metadata-action` action will generate tags and version numbers that will be used to label the Docker container that gets built. For example, if the GitHub Actions workflow is running for a pull request, `docker/metadata-action` will label the built Docker container with `pr-4` indicating that the build is correlated with the pull request with id 4.

{{< highlight yaml >}}
      - name: Get Docker Metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}
{{< /highlight >}}

With the metadata, we can now build the Docker container image. Docker provides the GitHub Action `docker/build-push-action` that uses Buildx to build the container image and then push it to a container registry (GitHub Package Registry). We'll pass it the metadata output by the `docker/metadata-action` action:

{{< highlight yaml >}}
      - name: Build Docker Container
        id: push
        uses: docker/build-push-action@v6
        with:
          context: src/authorization
          platforms: linux/${{ matrix.architecture }}
          labels: ${{ steps.meta.outputs.labels}}
          tags: ${{ steps.meta.outputs.tags }}
          push: true
{{< /highlight >}}

When Dockerx builds a container image, it will generate a cryptographic hash, called the digest, that is used to uniquely identify the container image. The digest is calculated from the data inside of the image, so if something changes in the image, the digest will no longer match. This digest uniquely identifies the platform image. When we build the multi-platform container image, we need to store the platform-specific image digest in the multi-platform container image so that Docker can find the matching container image for the runtime platform. Because we're building each platform in their own job, we're going to write the digest to a file and export it as a workflow artifact that we can use in the second job in the build process that runs after all of the platform images are created.

{{< highlight yaml >}}
      - name: Export digest
        run: |
          mkdir -p ${{ runner.temp }}/digests
          digest="${{ steps.push.outputs.digest }}"
          touch "${{ runner.temp }}/digests/${digest#sha256:}"
      - name: Upload digest
        uses: actions/upload-artifact@v4
        with:
          name: digests-linux-${{ matrix.architecture }}
          path: ${{ runner.temp }}/digests/*
          if-no-files-found: error
          retention-days: 1
{{< /highlight >}}

At the end of this job, we will have produced platform-specific Docker container images for `amd64` and `arm64` running on Linux.

## Building the Multi-Platform Container Image

We have our platform-specific container images. Now we need to generate the generic container image that references the platform-specific container images. We want consumers to reference the multi-platform container image so that they don't need to worry about finding and keeping track of the platform-specific container images. At the end of the previous job, we generated and exported digests that uniquely identified our platform-specific containers, and then we uploaded these digests in text files as artifacts to the GitHub Actions workflow. We're going to start by downloading these artifacts into the new job:

{{< highlight yaml >}}
      - name: Download Digests
        uses: actions/download-artifact@v4
        with:
          path: ${{ runner.temp }}/digests
          pattern: digests-*
          merge-multiple: true
{{< /highlight >}}

Because we're running in a new job on a different build agent, we need to log into GitHub Package Registry again and set up Docker Buildx:

{{< highlight yaml >}}
      - name: Log into GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY}}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3
{{< /highlight >}}

We next generate more metadata that will be used for the new multi-platform container image:

{{< highlight yaml >}}
      - name: Get Docker Metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
{{< /highlight >}}

We then create the multi-platform container image that references our platform-specific container images and publish that to GitHub Package Registry:

{{< highlight yaml >}}
      - name: Create manifest list and push
        working-directory: ${{ runner.temp }}/digests
        run: |
          docker buildx imagetools create $(jq -cr '.tags | map("-t " + .) | join(" ")' <<< "$DOCKER_METADATA_OUTPUT_JSON") \
            $(printf '${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}@sha256:%s ' *)
{{< /highlight >}}

And, while not necessary, we can use the `docker` command to pull metadata from the GitHub Package Registry for our container and log it to the build output for reporting purposes so that we can inspect it later if there's any problems:

{{< highlight yaml >}}
      - name: Inspect Image
        run: |
          docker buildx imagetools inspect ${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}:${{ steps.meta.outputs.version }}
{{< /highlight >}}

This is an example of the output generated by this step that shows the contents of the multi-platform container image:

{{< highlight plain >}}
Run docker buildx imagetools inspect ghcr.io/mfcollins3/authorization-service:pr-3
  docker buildx imagetools inspect ghcr.io/mfcollins3/authorization-service:pr-3
  shell: /usr/bin/bash -e {0}
  env:
    REGISTRY: ghcr.io
    REGISTRY_IMAGE: mfcollins3/authorization-service
    DOCKER_METADATA_OUTPUT_VERSION: pr-3
    DOCKER_METADATA_OUTPUT_TAGS: ghcr.io/mfcollins3/authorization-service:pr-3
    DOCKER_METADATA_OUTPUT_LABELS: org.opencontainers.image.created=2025-03-16T05:05:28.871Z
  org.opencontainers.image.description=Authorization Service performs user identity management and application authorization services for websites and software products or cloud services using OAuth 2, OpenID Connect, and WebAuthn.
  org.opencontainers.image.licenses=NOASSERTION
  org.opencontainers.image.revision=7c1d75b32ba9f2b9162bd01f452fbbb508ab0634
  org.opencontainers.image.source=https://github.com/mfcollins3/authorization-service
  org.opencontainers.image.title=authorization-service
  org.opencontainers.image.url=https://github.com/mfcollins3/authorization-service
  org.opencontainers.image.version=pr-3
    DOCKER_METADATA_OUTPUT_ANNOTATIONS: manifest:org.opencontainers.image.created=2025-03-16T05:05:28.871Z
  manifest:org.opencontainers.image.description=Authorization Service performs user identity management and application authorization services for websites and software products or cloud services using OAuth 2, OpenID Connect, and WebAuthn.
  manifest:org.opencontainers.image.licenses=NOASSERTION
  manifest:org.opencontainers.image.revision=7c1d75b32ba9f2b9162bd01f452fbbb508ab0634
  manifest:org.opencontainers.image.source=https://github.com/mfcollins3/authorization-service
  manifest:org.opencontainers.image.title=authorization-service
  manifest:org.opencontainers.image.url=https://github.com/mfcollins3/authorization-service
  manifest:org.opencontainers.image.version=pr-3
    DOCKER_METADATA_OUTPUT_JSON: {"tags":["ghcr.io/mfcollins3/authorization-service:pr-3"],"labels":{"org.opencontainers.image.created":"2025-03-16T05:05:28.871Z","org.opencontainers.image.description":"Authorization Service performs user identity management and application authorization services for websites and software products or cloud services using OAuth 2, OpenID Connect, and WebAuthn.","org.opencontainers.image.licenses":"NOASSERTION","org.opencontainers.image.revision":"7c1d75b32ba9f2b9162bd01f452fbbb508ab0634","org.opencontainers.image.source":"https://github.com/mfcollins3/authorization-service","org.opencontainers.image.title":"authorization-service","org.opencontainers.image.url":"https://github.com/mfcollins3/authorization-service","org.opencontainers.image.version":"pr-3"},"annotations":["manifest:org.opencontainers.image.created=2025-03-16T05:05:28.871Z","manifest:org.opencontainers.image.description=Authorization Service performs user identity management and application authorization services for websites and software products or cloud services using OAuth 2, OpenID Connect, and WebAuthn.","manifest:org.opencontainers.image.licenses=NOASSERTION","manifest:org.opencontainers.image.revision=7c1d75b32ba9f2b9162bd01f452fbbb508ab0634","manifest:org.opencontainers.image.source=https://github.com/mfcollins3/authorization-service","manifest:org.opencontainers.image.title=authorization-service","manifest:org.opencontainers.image.url=https://github.com/mfcollins3/authorization-service","manifest:org.opencontainers.image.version=pr-3"]}
    DOCKER_METADATA_OUTPUT_BAKE_FILE_TAGS: /home/runner/work/_temp/docker-actions-toolkit-zNgsMq/docker-metadata-action-bake-tags.json
    DOCKER_METADATA_OUTPUT_BAKE_FILE_LABELS: /home/runner/work/_temp/docker-actions-toolkit-zNgsMq/docker-metadata-action-bake-labels.json
    DOCKER_METADATA_OUTPUT_BAKE_FILE_ANNOTATIONS: /home/runner/work/_temp/docker-actions-toolkit-zNgsMq/docker-metadata-action-bake-annotations.json
    DOCKER_METADATA_OUTPUT_BAKE_FILE: /home/runner/work/_temp/docker-actions-toolkit-zNgsMq/docker-metadata-action-bake.json
Name:      ghcr.io/mfcollins3/authorization-service:pr-3
MediaType: application/vnd.oci.image.index.v1+json
Digest:    sha256:b67ea466fc42eae57f3c17c9b124343f34b89562b7d34ba83ed7906aa4a72784
           
Manifests: 
  Name:        ghcr.io/mfcollins3/authorization-service:pr-3@sha256:554e913f6d2dee77c999fbf3b5ce60ed271078fe66814e4faa31b5284c89a705
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/arm64
               
  Name:        ghcr.io/mfcollins3/authorization-service:pr-3@sha256:579f330480e0e9925171db67ecb24247ec268a90db7a63b70644f0eb9b694745
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    unknown/unknown
  Annotations: 
    vnd.docker.reference.digest: sha256:554e913f6d2dee77c999fbf3b5ce60ed271078fe66814e4faa31b5284c89a705
    vnd.docker.reference.type:   attestation-manifest
               
  Name:        ghcr.io/mfcollins3/authorization-service:pr-3@sha256:e215d4e9ca82cd5091f99999c0e09f1dc091355af0c124c5275028f9b54560d6
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    linux/amd64
               
  Name:        ghcr.io/mfcollins3/authorization-service:pr-3@sha256:eb543a1d0066cd0bcf9994448105e0df14fc7634a9c46e9c50ed6ddececc6199
  MediaType:   application/vnd.oci.image.manifest.v1+json
  Platform:    unknown/unknown
  Annotations: 
    vnd.docker.reference.digest: sha256:e215d4e9ca82cd5091f99999c0e09f1dc091355af0c124c5275028f9b54560d6
    vnd.docker.reference.type:   attestation-manifest
{{< /highlight >}}

And that's it! We're done!

## What Did We Do?

To summarize what we did in this post:

1. We built a program using cross-compilation that will run in Apline Linux on either Intel/AMD x64 architecture or ARM architecture (Raspberry Pi, Apple Silicon, other ARM-based computers).
2. We created Docker container images based on Alpine Linux for the target architecture and copied the program into the container for execution.
3. We created a multi-platform Docker container image that references the platform-specific container images.
4. We published the multi-platform container image and the platform-specific container images to GitHub Package Registry.

The end result now is that a consumer, if they wanted to download and run my Docker container, can run:

    docker pull ghcr.io/mfcollins3/authorization-service

and they will get the Docker container that matches the machine architecture that they are running on.

## For More Information...

In writing this article, I relied heavily on documentation and examples in the Docker documentation. I took the examples here and modified them to work with GitHub Package Registry instead of using [Docker Hub](https://hub.docker.com).

- [Multi-platform builds](https://docs.docker.com/build/building/multi-platform/): This document describes the concepts around multi-platform builds in more detail and their importance. It also has a section on strategies for implementing multi-platform builds.
- [Multi-platform image with GitHub Actions](https://docs.docker.com/build/ci/github-actions/multi-platform/#distribute-build-across-multiple-runners): Shows example GitHub Actions workflows for creating multi-platform images.
    - [Distribute build across multiple runners](https://docs.docker.com/build/ci/github-actions/multi-platform/#distribute-build-across-multiple-runners): I modeled by GitHub Actions workflow after this section that showed using `matrix` to distribute each platform across a different runner for concurrent builds.

## The Complete Source Code

Here is the complete GitHub Actions workflow that I ended up with:

{{< highlight yaml >}}
# authorization_service.yaml
#
# This GitHub Actions workflow will build and package Authorization Service
# for deployment using Docker.

name: Authorization Service

on:
  push:
    branches:
      - main
    paths:
      - '.github/workflows/authorization_service.yaml'
      - 'src/authorization/**'
  pull_request:
    branches:
      - main
    paths:
      - '.github/workflows/authorization_service.yaml'
      - 'src/authorization/**'

env:
  REGISTRY: ghcr.io
  REGISTRY_IMAGE: ${{ github.repository_owner }}/authorization-service

permissions:
  contents: read
  packages: write
  attestations: write
  id-token: write

jobs:
  build_and_test:
    name: Build and Test
    runs-on: ubuntu-24.04
    strategy:
      fail-fast: false
      matrix:
        architecture:
          - amd64
          - arm64
    steps:
      - name: Checkout the repository
        uses: actions/checkout@v4
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version-file: 'src/authorization/go.mod'
          cache-dependency-path: 'src/authorization/go.sum'
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Build Authorization Service
        run: go build -v -o build/ ./cmd/authorization
        working-directory: src/authorization
        env:
          GCO_ENABLED: 0
          GOOS: linux
          GOARCH: ${{ matrix.architecture }}
      - name: Log into GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY}}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Get Docker Metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}
      - name: Build Docker Container
        id: push
        uses: docker/build-push-action@v6
        with:
          context: src/authorization
          platforms: linux/${{ matrix.architecture }}
          labels: ${{ steps.meta.outputs.labels}}
          tags: ${{ steps.meta.outputs.tags }}
          push: true
      - name: Generate Artifact Attestation
        uses: actions/attest-build-provenance@v2
        with:
          subject-name: ${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}
          subject-digest: ${{ steps.push.outputs.digest }}
          push-to-registry: true
      - name: Export digest
        run: |
          mkdir -p ${{ runner.temp }}/digests
          digest="${{ steps.push.outputs.digest }}"
          touch "${{ runner.temp }}/digests/${digest#sha256:}"
      - name: Upload digest
        uses: actions/upload-artifact@v4
        with:
          name: digests-linux-${{ matrix.architecture }}
          path: ${{ runner.temp }}/digests/*
          if-no-files-found: error
          retention-days: 1

  merge_platform_containers:
    name: Merge Platform Containers
    runs-on: ubuntu-24.04
    needs: build_and_test
    steps:
      - name: Download Digests
        uses: actions/download-artifact@v4
        with:
          path: ${{ runner.temp }}/digests
          pattern: digests-*
          merge-multiple: true
      - name: Log into GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY}}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Get Docker Metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
      - name: Create manifest list and push
        working-directory: ${{ runner.temp }}/digests
        run: |
          docker buildx imagetools create $(jq -cr '.tags | map("-t " + .) | join(" ")' <<< "$DOCKER_METADATA_OUTPUT_JSON") \
            $(printf '${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}@sha256:%s ' *)
      - name: Inspect Image
        run: |
          docker buildx imagetools inspect ${{ env.REGISTRY }}/${{ env.REGISTRY_IMAGE }}:${{ steps.meta.outputs.version }}
{{< /highlight >}}