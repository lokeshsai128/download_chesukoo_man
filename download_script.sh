#!/bin/bash

# Ensure correct usage
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <youtube_url> <download_type> <quality>"
    exit 1
fi

youtube_url=$1
download_type=$2
quality=$3

# Define directories
download_dir="/var/www/samplewebsite/Downloads"
yt_dl_dir="/var/www/samplewebsite/yt-dl"
current_date=$(date +%Y-%m-%d)
target_directory="$yt_dl_dir/$current_date"

echo "Download Directory: $download_dir"
echo "YT-DL Directory: $yt_dl_dir"
echo "Target Directory: $target_directory"

# Ensure yt-dlp is installed
if ! /var/www/samplewebsite/venv/bin/yt-dlp --version &> /dev/null; then
    echo "yt-dlp could not be found. Please install yt-dlp manually."
    exit 1
fi

# Determine format
if [ "$download_type" == "video" ]; then
    case $quality in
        "480")
            format="bestvideo[height<=480]+bestaudio/best[height<=480]"
            ;;
        "720")
            format="bestvideo[height<=720]+bestaudio/best[height<=720]"
            ;;
        "1080")
            format="bestvideo[height<=1080]+bestaudio/best[height<=1080]"
            ;;
        "2k")
            format="bestvideo[height<=1440]+bestaudio/best[height<=1440]"
            ;;
        "4k")
            format="bestvideo[height<=2160]+bestaudio/best[height<=2160]"
            ;;
        *)
            echo "Invalid video quality specified."
            exit 1
            ;;
    esac
else
    case $quality in
        "128kbps")
            format="bestaudio[ext=m4a]/bestaudio[ext=mp3]"
            ;;
        "256kbps")
            format="bestaudio[ext=m4a]/bestaudio[ext=mp3]"
            ;;
        *)
            echo "Invalid audio quality specified."
            exit 1
            ;;
    esac
fi

# Download the file
echo "Downloading from $youtube_url with quality $quality..."
if ! /var/www/samplewebsite/venv/bin/yt-dlp -f "$format" --no-playlist -o "$download_dir/%(title)s.%(ext)s" "$youtube_url"; then
    echo "Failed to download."
    exit 1
fi

# Find the latest downloaded file
file_path=$(ls -t "$download_dir"/*.{mp4,webm,m4a,mp3} 2>/dev/null | head -n 1)
if [ -z "$file_path" ]; then
    echo "No file found in $download_dir. Download may have failed."
    exit 1
fi

file_name=$(basename "$file_path")

# Create target directory if it doesn't exist
if [ ! -d "$target_directory" ]; then
    echo "Creating target directory..."
    if ! mkdir -p "$target_directory"; then
        echo "Failed to create target directory."
        exit 1
    fi
fi

# Move file to target directory
echo "Moving file to $target_directory..."
if ! mv "$file_path" "$target_directory/$file_name"; then
    echo "Failed to move file to $target_directory."
    exit 1
fi

# Log file information
file_size=$(du -h "$target_directory/$file_name" | cut -f1)
download_date=$(date '+%Y-%m-%d %H:%M:%S')
file_location="$target_directory/$file_name"

log_file="$yt_dl_dir/list.txt"
{
  echo "Title: $(/var/www/samplewebsite/venv/bin/yt-dlp --get-title "$youtube_url")"
  echo "File Name: $file_name"
  echo "Size: $file_size"
  echo "Download Date: $download_date"
  echo "File Location: $file_location"
  echo "--------------------------------------------"
} | tee -a "$log_file" >/dev/null

echo "File downloaded and moved to $target_directory"
