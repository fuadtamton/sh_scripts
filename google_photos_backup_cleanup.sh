#!/bin/bash

folder_path="/"

# move all files in nested folders to folder_path
find "$folder_path" -mindepth 2 -type f -exec mv {} "$folder_path" \;

# Loop through all JSON files in the folder 
# and rename media file with the creation date in the json
for json_file in "$folder_path"/*.json
do
    echo "Processing $json_file..."

    # Extract the image name and created date from the JSON file
    created_date=$(jq -r '.photoTakenTime.formatted' "$json_file")

    if [ -n "$created_date" ]; then
        # Define the corresponding image file name (assuming it's a .jpg)
        image_file=$(jq -r '.title' "$json_file")
        formatted_date=$(TZ=UTC date -jf "%d %b %Y, %H:%M:%S %Z" "$created_date" +"%Y%m%d %H:%M:%S")
        echo "Looking for $image_file..."

        if [ -f "$image_file" ] && [ -n "$formatted_date" ]; then
            # Define the new image file path
            new_image_file="$folder_path/$formatted_date.$image_file"

            # Rename the image file
            mv "$image_file" "$new_image_file"
            echo "Renamed $image_file to $new_image_file"

            # Set the created date metadata
            # exiftool -CreateDate="$created_date" "$new_image_file"
            # echo "Set created date to $created_date for $new_image_file"
        else
            echo "Image file or date not found for $json_file $created_date"
        fi
    else
        echo "Image name or created date not found in $json_file"
    fi
done

# Cleanup to remove the backup files created by exiftool
# rm "$folder_path"/*_original

echo "Renaming process and metadata setting completed."

# delete all json files in the folder
find . -type f -name "*.json" -exec rm -f {} \;
echo "Deleted all json file. now pls remove the unwanted folders manually..."
