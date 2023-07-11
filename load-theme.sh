#!/bin/sh
# This file will take the preloaded jekyll theme and load all the "invisible" files so they are available to edit
# Makes the theme editable 
echo "Copying theme files..."

# Define color codes
red='\033[0;31m'
green='\033[0;32m'
reset='\033[0m' # Reset color

config_file="_config.yml"

# Check if the _config.yml file exists
if [ ! -f "$config_file" ]; then
  echo  "${red}Error:${reset} $config_file not found."
  exit 1
fi

# locate the theme name
theme_name=$(awk '/^theme:/ {print $2}' "$config_file")

# Check if the theme is specified
if [ -z "$theme_name" ]; then
  echo "${red}Error:${reset} Theme not specified in $config_file."
  exit 1
fi

echo "${green}Theme found:${reset} $theme_name"

# locate the theme files
source_dir=$(bundle info --path "$theme_name")


# Check if the source directory exists
if [ ! -d "$source_dir" ]; then
  echo "${red}Error:${reset} Source directory $source_dir not found."
  exit 1
fi

echo "${green}Source dir:${reset} $source_dir"

# Check if files being copied already exist in the destination directory
overwrite=false
for file in "$source_dir"/*; do
  destination_file="./$(basename "$file")"
  if [ -f "$destination_file" ]; then
    overwrite=true
    break
  fi
done

# Prompt user for confirmation if files are being overwritten
if [ "$overwrite" = true ]; then
  read -p "Files already exist in the current directory. Do you want to overwrite them? (y/n): " overwrite_confirmation

  if [ "$overwrite_confirmation" != "y" ] && [ "$overwrite_confirmation" != "Y" ]; then
    echo "Aborted. No files will be overwritten."
    exit 0
  fi
fi

# 1. /. don't copy the folder, just the contents
# 2.  . copy into root
# 3. -p bring over attributes
# 4. -r recursive
if ! cp -rnp "$source_dir"/. .; then
  echo "${red}Error:${reset} Failed to copy theme files."
  exit 1
fi

echo "${green}Theme files copied successfully!${reset}"