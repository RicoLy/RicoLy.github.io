#!/bin/bash

app="dejavuzhou.github.io"
pkill $app
rm -rf $app
go build
nohup ./$app >> ./gitpage.log 2>&1 &
ps -ef | grep $app

