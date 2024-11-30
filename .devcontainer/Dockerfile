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

FROM mcr.microsoft.com/devcontainers/base:1.0.17-bookworm

RUN apt-get update && apt-get install gnupg -y
RUN apt-get -qq -y install bison \
    flex \
    libffi-dev \
    libxml2-dev \
    libgdk-pixbuf2.0-dev \
    libcairo2-dev \
    libpango1.0-dev \
    fonts-lyx \
    cmake
RUN apt update && apt install -y chromium graphviz
RUN apt-get update && apt-get install -y gnuplot
RUN apt update && apt install -y lilypond
RUN apt update && apt install -y build-essential \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    imagemagick
RUN apt update && apt install -y mscgen
RUN apt upgrade -y