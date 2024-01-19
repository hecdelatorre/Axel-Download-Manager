#!/bin/bash

# Function to ask the user for the number of downloads
get_download_count() {
  while true; do
    read -p "How many downloads do you want to perform? " count

    if [[ "$count" =~ ^[1-9][0-9]*$ ]]; then
      break
    fi

    echo "Invalid input. Please enter a positive number."
  done
}

# Function to ask the user for the download directory and validate it
get_download_directory() {
  while true; do
    read -p "Enter the download directory (default: ~/Downloads/): " input_directory

    # If the user did not provide a directory, use the default
    if [ -z "$input_directory" ]; then
      directory="$HOME/Downloads"
      break
    fi

    if [ -d "$input_directory" ]; then
      directory="$input_directory"
      break
    fi

    echo "Invalid directory. Please enter a valid directory."
  done

  cd "$directory" || exit
}

# Function to ask the user if they want to create a new folder and get the folder name
get_new_folder() {
  while true; do
    read -p "Do you want to create a new folder in the download directory? [y/n] " answer

    if [ "$answer" == "y" ] || [ "$answer" == "n" ]; then
      break
    fi

    echo "Invalid input. Please enter either 'y' or 'n'."
  done

  if [ "$answer" == "y" ]; then
    while true; do
      read -p "Enter the name of the new folder: " folder

      if [ ! -d "$directory/$folder" ]; then
        mkdir "$directory/$folder"
        directory="$directory/$folder"
        cd "$directory" || exit
        break
      fi

      echo "A folder with that name already exists. Please enter a different name."
    done
  fi
}

# Function to ask the user for the links and validate them
get_links() {
  echo -e "\n"
  for ((i=0; i<count; i++)); do
    while true; do
      read -p "Enter link $((i + 1)): " link

      if [[ "$link" =~ ^https?://.* || "$link" =~ ^ftp://.* ]]; then
        links+=( "$link" )
        break
      fi

      echo "Invalid link. Please enter a valid HTTP or FTP link."
    done
  done
}

# Function to download the files using axel and record the download time
download_files() {
  start_time=$(date +%s)
  echo -e "\n"
  for ((i=0; i<count; i++)); do
    link="${links[$i]}"
    echo "Downloading file $((i + 1)) of $count..."
    axel -q -n 10 "$link"
  done

  end_time=$(date +%s)
  total_time=$((end_time - start_time))
}

# Function to display a summary of the downloaded files and the download time
show_summary() {
  echo -e "\nDownloads complete."
  echo "Downloaded files are stored in $directory."
  echo "Download time: $total_time seconds."
}

# Main function to call all the functions
main() {
  get_download_count
  get_download_directory
  get_new_folder
  get_links
  download_files
  show_summary
}

# Call the main function
main
