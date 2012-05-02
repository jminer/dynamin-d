#!/bin/bash

source ./build-paths.sh

ARGS="-DCPATH$DMD_DIR/bin -T$OUT_FILE -full -clean -op"
MODE_ARGS="-debug -g -unittest"

echo $BUD_DIR/bud $MAIN_FILE $ARGS $MODE_ARGS

$BUD_DIR/bud $MAIN_FILE $ARGS $MODE_ARGS

# have to call bud twice...
# the first time to compile, using the -op switch
# the second time to build docs, without the -op switch

echo $BUD_DIR/bud $MAIN_FILE -obj -o- -D -Dd$PWD/docs

$BUD_DIR/bud $MAIN_FILE -obj -o- -D -Dd$PWD/docs

