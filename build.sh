#! /bin/bash
set -e

# clear build folder
rm -rf build && mkdir build

# copy source code
cp lambda/* build

# install dependencies
pip install -r requirements_runtime.txt --target build

# zip the code
cd build
zip segredo-app-api.zip *
cd ..