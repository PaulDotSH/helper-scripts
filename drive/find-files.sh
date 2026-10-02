#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

if [ ! -d "$1" ]; then
  echo "Error: The provided path '$1' is not a valid directory."
  exit 1
fi

cd "$1"

find . -type f \( \
  -iname "*.dll" -o \
  -iname "*.o" -o \
  -iname "*.exe" -o \
  -iname "*.pkg" -o \
  -iname "*.tmp" -o \
  -iname "*.wav" \)
