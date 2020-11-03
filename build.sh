#! /bin/bash
set -e

if [ $# -eq 0 ]
  then
    echo ""
    echo "build.sh script"
    echo ""
    echo "Usage:"
    echo "  build.sh <version>"
    echo ""
    echo "Example:"
    echo "  build.sh 0.0.1"
    echo ""
    exit 1
fi

# clear build folder
rm -rf build && mkdir build

# copy source code
cp lambda/* build

# install dependencies
pip install -r requirements_runtime.txt --target build

# zip the code
cd build
zip segredo-app-api-$1.zip *
aws s3 cp segredo-app-api-$1.zip s3://segredo-app-api-code
cd ..