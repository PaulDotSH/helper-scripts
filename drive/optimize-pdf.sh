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
parallel qpdf --optimize-images --linearize {} -- {.}-optimized.pdf ::: *.pdf
