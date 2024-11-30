#!/usr/bin/env bash

# Copyright 2024 Michael F. Collins, III
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and association documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

# postCreateCommand.sh
#
# This program automates the steps required to finish setting up the development
# container. This program is run after the development container is created, but
# before the user is logged in. This program is run as the root user.

npm ci

bundle install

pip install -r requirements.txt

# Install diagram generators for asciidoctor-diagram
go install github.com/asciitosvg/asciitosvg/cmd/a2s@latest
curl -fsSL https://d2lang.com/install.sh | sh -s --

mkdir -p /tmp/pikchr
pushd /tmp/pikchr > /dev/null
wget -O pikchr.c https://pikchr.org/home/raw/85e65b968651b342c46e6334f4772b45d6cbb4317c5cbaa95d207779a50c6709?at=pikchr.c
gcc -DPIKCHR_SHELL -o pikchr pikchr.c -lm
sudo mv pikchr /usr/local/bin
popd > /dev/null
rm -rf /tmp/pikchr

ROOT_DIR=$(pwd)
mkdir -p bin/structurizr-cli
mkdir -p /tmp/structurizr-cli
pushd /tmp/structurizr-cli > /dev/null
wget https://github.com/structurizr/cli/releases/download/v2024.11.04/structurizr-cli.zip
unzip -d $ROOT_DIR/bin/structurizr-cli -o -qq structurizr-cli.zip
popd > /dev/null
rm -rf /tmp/structurizr-cli

pushd /tmp > /dev/null
git clone --depth 1 --branch 7.1.1-41 https://github.com/ImageMagick/ImageMagick.git ImageMagick-7.1.1
cd ImageMagick-7.1.1
./configure
make
sudo make install
sudo ldconfig /usr/local/lib
popd > /dev/null
rm -rf /tmp/ImageMagick-7.1.1

pushd /tmp > /dev/null
wget https://github.com/atp-mipt/jsyntrax/releases/download/1.38/jsyntrax-1.38-syntrax.zip
unzip -d $ROOT_DIR/bin -o -qq jsyntrax-1.38-syntrax.zip
popd > /dev/null
rm -rf /tmp/jsyntrax-1.38-syntrax.zip