#!/bin/bash

mkdir -p \
    bash \
    bash/lib \
    bash/bin \
    bash/module \
    config \
    doc \
    doc/design \
    json \
    json/schema \
    skeleton \
    skeleton/custom \
    test \
    tool

touch \
    .gitignore \
    package.json \
    LICENSE.txt \
    README.md \
    bash/bin/custom.bash \
    bash/lib/custom.lib.bash \
    bash/module/custom.module.bash \
    doc/DESIGN.md \
    json/namespace.json \
    tool/build.bash \
    tool/test.bash

touch \
    bash/.gitignore \
    bash/lib/.gitignore \
    bash/bin/.gitignore \
    bash/module/.gitignore \
    config/.gitignore \
    doc/.gitignore \
    doc/design/.gitignore \
    json/.gitignore \
    json/schema/.gitignore \
    skeleton/.gitignore \
    test/.gitignore \
    tool/.gitignore


