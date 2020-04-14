#!/bin/sh

/usr/bin/lua /usr/local/bin/generate-alias-files.lua
exec /usr/bin/chasquid
