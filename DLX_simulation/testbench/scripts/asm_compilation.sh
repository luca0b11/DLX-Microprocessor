#!/bin/bash

if [ -z "$1" ]; then
  echo "No file name provided. Usage: $0 <file_name>"
  exit 1
fi


FILE=$1

./testbench/scripts/dlxasm.pl testbench/files/asm/$FILE -o testbench/files/exe/${FILE::-4}.exe
./testbench/scripts/conv2memory testbench/files/exe/${FILE::-4}.exe > testbench/files/mem/${FILE::-4}.mem