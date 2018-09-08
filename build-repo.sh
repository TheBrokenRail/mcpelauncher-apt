#!/bin/bash

set -e

mkdir repo
cp -r mcpe-build/out/* repo
dpkg-scanpackages repo /dev/null | gzip -9c > repo/Packages.gz
