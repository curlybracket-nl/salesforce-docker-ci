#!/bin/bash
umask 0000

if [[ $# -eq 0 ]] ; then
    exec /bin/bash
else
    exec "$@"
fi
