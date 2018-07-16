#!/bin/sh
if [ -f peachclient ]
then
    chmod a+x peachclient
    ./peachclient $*
else
    chmod a+x peachclient.app/Contents/MacOS/peachclient
    peachclient.app/Contents/MacOS/peachclient $*
fi