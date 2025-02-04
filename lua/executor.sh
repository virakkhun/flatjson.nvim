#!/bin/sh

VALUE=$(lua/flatjson $1)
echo "$VALUE"
