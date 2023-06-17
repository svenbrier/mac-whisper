#!/bin/bash
TIMEZONE="Europe/Berlin"
start_time=$(date +%s)  # Record the start time in seconds since the Unix epoch

# Installing dependencies
# Check if brew command exists
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew is installed."
else
    echo "Homebrew is not installed. Installing ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check if Python is installed
if brew ls --versions python > /dev/null; then
    echo "Python is installed."
else
    echo "Python is not installed. Installing ..."
    brew install python
fi

# Check if FFmpeg is installed
if brew ls --versions ffmpeg > /dev/null; then
    echo "FFmpeg is installed."
else
    echo "FFmpeg is not installed. Installing ..."
    brew install ffmpeg
fi

# Creating folders
grandparent_folder=~/Skripte
parent_folder=whisper

# Create the grandparent folder if it doesn't exist
if [ ! -d "$grandparent_folder" ]; then
    mkdir "$grandparent_folder"
    echo "Grandparent folder '$grandparent_folder' created."
else
    echo "Grandparent folder '$grandparent_folder' already exists."
fi

# Create the parent folder inside the grandparent folder if it doesn't exist
if [ ! -d "$grandparent_folder/$parent_folder" ]; then
    mkdir "$grandparent_folder/$parent_folder"
    echo "Parent folder '$parent_folder' created inside '$grandparent_folder'."
else
    echo "Parent folder '$parent_folder' already exists inside '$grandparent_folder'."
fi

# Copy script to parent folder
if [ -f $grandparent_folder/$parent_folder/$(basename $0) ]; then
    echo "$grandparent_folder/$parent_folder/$(basename $0) already exists."
else
    echo "Copying file ..."
    cp $0 $grandparent_folder/$parent_folder/
fi

# Episodes folder
episodes_folder=~/Episoden

# Create the episodes folder if it doesn't exist
if [ ! -d $episodes_folder ]; then
    mkdir $episodes_folder
    echo "Episodes folder '$episodes_folder' created."
else
    echo "Episodes folder '$episodes_folder' already exists."
fi

# Transcriptions folder
transcriptions_folder=~/Documents/Transkripte

# Create the transcriptions folder if it doesn't exist
if [ ! -d $transcriptions_folder ]; then
    mkdir $transcriptions_folder
    echo "Transcriptions folder '$transcriptions_folder' created."
else
    echo "Transcriptions folder '$transcriptions_folder' already exists."
fi

# Create/activate virtual environment and install whisper.
cd $grandparent_folder/$parent_folder
python3 -m venv .venv
source $grandparent_folder/$parent_folder/.venv/bin/activate
pip3 install git+https://github.com/openai/whisper.git
pip3 install --upgrade pip

# Set language, model and device and loop over audio files
language=de
# models: tiny, base, small, medium, large, large-v2
model=large-v2
device=cpu

for file in "$episodes_folder"/*; do
    # Check for audio files
    if [[ -f "$file" && ( "$file" == *.mp3 || "$file" == *.wav || "$file" == *.flac || "$file" == *.m4a || "$file" == *.aac ) ]]; then
        # Transcribe and rename file
        echo "Transcribing '$file'."
        timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
        whisper --model_dir "$grandparent_folder/$parent_folder/.venv/models" --model "$model" --output_dir "$transcriptions_folder/${timestamp}_${model}_${device}_$(basename $file)" --language "$language" --device "$device" $file
        mv $file $file.transcribed
    fi
done

echo "All files have been transcribed."

end_time=$(date +%s)  # Record the end time in seconds since the Unix epoch
runtime_minutes=$(( (end_time - start_time) / 60 ))  # Calculate the runtime in minutes

echo "Script runtime: $runtime_minutes minutes"
