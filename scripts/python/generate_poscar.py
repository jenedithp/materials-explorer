#!/usr/bin/env python3

from ase.io import read, write
import numpy as np
import os

#Read the base structure
atoms = read('CONTCAR.cif', format='cif')
print(f"Loaded structure with {len(atoms)} atoms")

#Define the 28 elements
elements = ['Ag', 'Au', 'Cd', 'Ce', 'Co', 'Cr', 'Cu', 'Fe', 'Hf', 'Ir',
           'Mn', 'Nb', 'Ni', 'Os', 'Pd', 'Pt', 'Re', 'Rh', 'Ru', 'Sc',
           'Ta', 'Ti', 'V', 'W', 'Y', 'Zn', 'Zr', 'Mo']

#Atom indices (Python uses 0-based indexing)
#These correspond to atoms 59 and 71 in the visualization (subtract 1 for Python)
intercalated_idx = 58  # Atom 59 - intercalated position
doping_idx = 70        # Atom 71 - doping position

symbols = atoms.get_chemical_symbols()
print(f"Current intercalated atom (index {intercalated_idx}): {symbols[intercalated_idx]}")
print(f"Current doping atom (index {doping_idx}): {symbols[doping_idx]}")
print()

#Generate TM_28 structures (intercalated varies, doping = Mo)
print("Generating TM_28 POSCAR files...")
tm28_count = 0

for intercalated in elements:
    folder_name = f"{intercalated}_Mo"
    folder_path = os.path.join("TM_28", folder_name)
    
    if not os.path.exists(folder_path):
        print(f"Folder {folder_path} doesn't exist. Skipping.")
        continue
    
    #Create new structure
    new_atoms = atoms.copy()
    new_symbols = new_atoms.get_chemical_symbols()
    
    #Set intercalated and doping atoms
    new_symbols[intercalated_idx] = intercalated  #Intercalated element varies
    new_symbols[doping_idx] = 'Mo'                #Doping is always Mo
    
    new_atoms.set_chemical_symbols(new_symbols)
    
    #Write POSCAR file
    poscar_path = os.path.join(folder_path, "POSCAR")
    write(poscar_path, new_atoms, format='vasp')
    
    tm28_count += 1
    print(f"TM_28: {intercalated}_Mo -> {poscar_path}")

print(f"Generated {tm28_count} POSCAR files for TM_28")
print()

#Generate TM_Rest structures (all combinations except doping = Mo)
print("Generating TM_Rest POSCAR files...")
rest_count = 0

for intercalated in elements:
    for doping in elements:
        #Skip combinations where doping = Mo (those are in TM_28)
        if doping == 'Mo':
            continue
            
        folder_name = f"{intercalated}_{doping}"
        folder_path = os.path.join("TM_Rest", folder_name)
        
        if not os.path.exists(folder_path):
            print(f"Folder {folder_path} doesn't exist. Skipping.")
            continue
        
        #Create new structure
        new_atoms = atoms.copy()
        new_symbols = new_atoms.get_chemical_symbols()
        
        #Set intercalated and doping atoms
        new_symbols[intercalated_idx] = intercalated  # Intercalated element
        new_symbols[doping_idx] = doping              # Doping element
        
        new_atoms.set_chemical_symbols(new_symbols)
        
        #Write POSCAR file
        poscar_path = os.path.join(folder_path, "POSCAR")
        write(poscar_path, new_atoms, format='vasp')
        
        rest_count += 1
        
        #Print progress every 100 files
        if rest_count % 100 == 0:
            print(f"Generated {rest_count} TM_Rest files so far... (latest: {intercalated}_{doping})")

print(f"Generated {rest_count} POSCAR files for TM_Rest")
print(f"Total: {tm28_count + rest_count} POSCAR files")