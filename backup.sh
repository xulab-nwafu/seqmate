#!/bin/bash

files="/home/xulab/sf /home/xulab/bin /disk/xulab/db /disk/xulab/data/example /home/xulab/.vim* /home/xulab/.zsh* /home/xulab/.bashrc"
datename=$(date +%Y%m%d)
tar -czf backup$datename.tar.gz $files
