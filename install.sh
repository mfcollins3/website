#!/usr/bin/env sh

# Copyright 2024 Michael F. Collins, III
#
# Michael Collins's Website © 2024 by Michael F. Collins, III is licensed
# under CC BY 4.0. To view a copy of this license, visit 
# http://creativecommons.org/licenses/by/4.0/

. ${NVM_DIR}/nvm.sh

if [ ! -d "node_modules"]; then
    npm ci
fi

bundle install

npm install -g @azure/static-web-apps-cli
npm i -g azure-functions-core-tools@4 --unsafe-perm true
