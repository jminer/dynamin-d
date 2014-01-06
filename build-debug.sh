#!/bin/bash

source ./build-paths.sh

ARGS="-allinst -of$OUT_FILE -od$PWD/obj -D -Dd$PWD/docs -I$TANGO_DIR $TANGO_DIR/libtango.a"
MODE_ARGS="-debug -g -unittest"

echo $DMD_DIR/osx/bin/rdmd --build-only $ARGS $MODE_ARGS $MAIN_FILE standard.dd

$DMD_DIR/osx/bin/rdmd --build-only $ARGS $MODE_ARGS $MAIN_FILE standard.dd


