#!/usr/bin/env sh

# Copyright 2024 Michael F. Collins, III
#
# Michael Collins's Website © 2024 by Michael F. Collins, III is licensed
# under CC BY 4.0. To view a copy of this license, visit 
# http://creativecommons.org/licenses/by/4.0/

gem install bundler
bundle install

ASCIIDOCTOR_PATH=$(bundle info --path asciidoctor)
echo "ASCIIDOCTOR_PATH = $ASCIIDOCTOR_PATH"
export PATH=$ASCIIDOCTOR_PATH/bin:$PATH
