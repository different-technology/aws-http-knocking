#!/bin/bash

# First:
# cd lambda/Firewall

# Run TypeScript compiler
tsc

# create build dir if not exists
mkdir -p build
# Remove old build file
rm -f build/build.zip
# Add files to build file
zip build/build.zip -ur node_modules/@types
zip build/build.zip -ur package.json
find . -type f -name "*.js" -not -path "*/node_modules/*" | zip build/build.zip -ur -@
