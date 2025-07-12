#!/bin/bash

echo "Generating POTCAR files for all folders..."

#Set POTCAR path (adjust as needed)
# User Configuration - Edit this path for your system
export POTCAR_PATH="/path/to/your/vasp/pseudopotentials"
# Example: export POTCAR_PATH="${HOME}/vasp_pseudopotentials"
# Example: export POTCAR_PATH="/opt/vasp/potcar"

#Function to generate POTCAR for a folder
generate_potcar() {
    local folder_path="$1"
    local folder_name=$(basename "$folder_path")
    
    #Extract elements from folder name
    if [[ "$folder_name" == *"_"* ]]; then
        intercalated_element="${folder_name%_*}"
        doping_element="${folder_name#*_}"
    else
        echo "Warning: Cannot parse folder name $folder_name"
        return 1
    fi
    
    echo "Processing: $folder_name (intercalated: $intercalated_element, doping: $doping_element)"
    
    #Check if POSCAR exists
    if [[ ! -f "$folder_path/POSCAR" ]]; then
        echo "  Warning: No POSCAR found in $folder_path"
        return 1
    fi
    
    #Change to folder directory
    cd "$folder_path" || return 1
    
    #Generate POTCAR using vaspkit (option 103)
    echo "103" | vaspkit > vaspkit.out 2>&1
    
    #Check if POTCAR was created
    if [[ -f "POTCAR" ]]; then
        echo "  POTCAR created successfully"
    else
        echo "  Error: POTCAR creation failed"
        echo "  Check vaspkit.out for details"
    fi
    
    # Return to original directory
    cd - > /dev/null
}

#Process TM_28 folders
if [[ -d "TM_28" ]]; then
    echo "Processing TM_28 folders..."
    count=0
    for folder in TM_28/*; do
        if [[ -d "$folder" ]]; then
            generate_potcar "$folder"
            count=$((count + 1))
        fi
    done
    echo "Processed $count TM_28 folders"
fi

#Process TM_Rest folders
if [[ -d "TM_Rest" ]]; then
    echo "Processing TM_Rest folders..."
    count=0
    for folder in TM_Rest/*; do
        if [[ -d "$folder" ]]; then
            generate_potcar "$folder"
            count=$((count + 1))
            
            if (( count % 100 == 0 )); then
                echo "  Processed $count TM_Rest folders so far..."
            fi
        fi
    done
    echo "Processed $count TM_Rest folders"
fi

echo "POTCAR generation complete!"
