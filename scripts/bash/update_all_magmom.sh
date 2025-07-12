#!/bin/bash

echo "Updating MAGMOM values for all folders..."

#Define magnetic moments for each element
declare -A magmom=(
    ["Mo"]=0.000 ["S"]=0.000 ["Nb"]=0.196 ["W"]=0.257 ["Ni"]=0.578 ["Co"]=1.56
    ["Ir"]=0.500 ["Zr"]=0.000 ["Hf"]=0.000 ["Cd"]=0.000 ["Rh"]=0.859 ["Ti"]=0.317
    ["Cr"]=1.000 ["Ta"]=0.000 ["Pt"]=0.000 ["Ce"]=0.825 ["Pd"]=0.159 ["Ru"]=0.32
    ["Re"]=0.199 ["Sc"]=0.052 ["Cu"]=0.003 ["V"]=2.283 ["Fe"]=2.831 ["Y"]=0.000
    ["Zn"]=0.000 ["Au"]=0.000 ["Os"]=0.117 ["Ag"]=0.000 ["Mn"]=3.998
)

#INCAR template (optimized parameters for MoS2 intercalation)
INCAR_TEMPLATE="ALGO = Fast
EDIFF = 1e-05
EDIFFG = -0.05
ENCUT = 400
IBRION = 2
ISIF = 2
ISMEAR = 1
ISPIN = 2
LREAL = Auto
LWAVE = False
LCHARG = False
NELM = 300
NSW = 150
POTIM = 0.05
PREC = Normal
MAGMOM = 58*0 INTERCALATED_MAGMOM DOPING_MAGMOM 31*0"

#Function to update MAGMOM in a folder
update_folder_magmom() {
    local folder_path="$1"
    local intercalated_element="$2"
    local doping_element="$3"
    
    #Get magnetic moments
    local intercalated_magmom=${magmom[$intercalated_element]}
    local doping_magmom=${magmom[$doping_element]}
    
    echo "Processing: $(basename "$folder_path")"
    echo "   Intercalated: $intercalated_element (magmom: $intercalated_magmom)"
    echo "   Doping: $doping_element (magmom: $doping_magmom)"
    
    #Create the MAGMOM string: 58 S atoms + 1 intercalated + 1 doping + 31 Mo atoms
    local magmom_string="58*0 1*${intercalated_magmom} 1*${doping_magmom} 31*0"
    echo "   MAGMOM: $magmom_string"
    
    #Create INCAR with updated MAGMOM
    local incar_content="${INCAR_TEMPLATE//INTERCALATED_MAGMOM/1*${intercalated_magmom}}"
    incar_content="${incar_content//DOPING_MAGMOM/1*${doping_magmom}}"
    
    #Write INCAR file
    echo "$incar_content" > "$folder_path/INCAR"
    echo "   Updated INCAR"
    echo ""
}

#Process TM_28 folders (intercalated varies, doping = Mo)
if [[ -d "TM_28" ]]; then
    echo "Processing TM_28 folders..."
    for folder in TM_28/*; do
        if [[ -d "$folder" ]]; then
            folder_name=$(basename "$folder")
            intercalated_element="${folder_name%_Mo}"
            doping_element="Mo"
            update_folder_magmom "$folder" "$intercalated_element" "$doping_element"
        fi
    done
fi

#Process TM_Rest folders (both elements vary)
if [[ -d "TM_Rest" ]]; then
    echo "Processing TM_Rest folders..."
    count=0
    for folder in TM_Rest/*; do
        if [[ -d "$folder" ]]; then
            folder_name=$(basename "$folder")
            intercalated_element="${folder_name%_*}"
            doping_element="${folder_name#*_}"
            update_folder_magmom "$folder" "$intercalated_element" "$doping_element"
            
            count=$((count + 1))
            if (( count % 100 == 0 )); then
                echo "Processed $count TM_Rest folders so far..."
            fi
        fi
    done
fi

echo "MAGMOM update complete!"