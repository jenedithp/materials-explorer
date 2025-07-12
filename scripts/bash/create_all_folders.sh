#!/bin/bash

echo "Creating complete folder structure for all 784 combinations..."

#List of 28 elements
elements=("Ag" "Au" "Cd" "Ce" "Co" "Cr" "Cu" "Fe" "Hf" "Ir" "Mn" "Nb" "Ni" "Os" "Pd" "Pt" "Re" "Rh" "Ru" "Sc" "Ta" "Ti" "V" "W" "Y" "Zn" "Zr" "Mo")

#Create main directories
mkdir -p TM_28
mkdir -p TM_Rest

echo "Creating TM_28 folders (28 folders - intercalated element varies, doping = Mo)..."

#TM_28: Only intercalated element varies, doping is always Mo
for intercalated in "${elements[@]}"; do
    folder="TM_28/${intercalated}_Mo"
    mkdir -p "$folder"
    echo "Created: $folder"
done

echo ""
echo "Creating TM_Rest folders (756 folders - all other combinations)..."

#TM_Rest: All combinations EXCEPT the 28 where doping = Mo
count=0
for intercalated in "${elements[@]}"; do
    for doping in "${elements[@]}"; do
        #Skip combinations where doping = Mo (those go in TM_28)
        if [[ "$doping" != "Mo" ]]; then
            folder="TM_Rest/${intercalated}_${doping}"
            mkdir -p "$folder"
            count=$((count + 1))
            
            #Print progress every 100 folders
            if (( count % 100 == 0 )); then
                echo "Created $count folders so far... (latest: $folder)"
            fi
        fi
    done
done

echo ""
echo "Folder creation complete!"
echo "TM_28: 28 folders, TM_Rest: $count folders"
echo "Total: $((28 + count)) folders"