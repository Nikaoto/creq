#! /bin/bash

if [[ "$OSTYPE" == "darwin"* ]]
then
    DYLD_FALLBACK_LIBRARY_PATH="$PWD/example/clibs/osx:$DYLD_FALLBACK_LIBRARY_PATH" love example $@
else
    LD_LIBRARY_PATH="$PWD/example/clibs/linux:$LD_LIBRARY_PATH" love example $@
fi
