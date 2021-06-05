#!/usr/bin/env bash

dune build @all --profile=release
SOURCE=_build/default/game_server_js
cp $SOURCE/main.bc.js cached/
cp $SOURCE/index.html cached/
