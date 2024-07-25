#!/bin/sh

echo "Started ansible container"

# start indefinitely 
tail -f /dev/null 

exec "$@"