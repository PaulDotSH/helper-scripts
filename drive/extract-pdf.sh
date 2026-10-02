#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <folder_path>"
  exit 1
fi

input_folder="$1"

if [ ! -d "$input_folder" ]; then
  echo "Error: Folder '$input_folder' does not exist."
  exit 1
fi

process_pdf() {
  input_folder="$1"
  pdf="$2"
  pdf_name=$(basename "$pdf" .pdf)
  output_folder="$input_folder/$pdf_name"

  mkdir -p "$output_folder"

  pdftohtml -c -hidden "$pdf" "$output_folder/$(basename "$pdf_name")".html

  mv "$output_folder"/*.png "$output_folder/"
  mv "$output_folder"/*.jpg "$output_folder/"
  mv "$output_folder"/*.jpeg "$output_folder/"

  parallel cwebp -q 90 {} -o {.}.webp ::: "$output_folder"/*.png "$output_folder"/*.jpg "$output_folder"/*.jpeg "$output_folder"/*.PNG "$output_folder"/*.JPG "$output_folder"/*.JPEG
  rm -f "$output_folder"/*.html "$output_folder"/*.png

  echo "Finished processing '$pdf_name'. Converted images are in '$output_folder'."
}

export -f process_pdf

parallel process_pdf "$input_folder" ::: "$input_folder"/*.pdf
