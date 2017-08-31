#!/bin/bash

dir=/home/xulab
rm -rf $dir/bin
mkdir $dir/bin
ln -s $dir/sf/*/current/bin/* $dir/bin/
