# Scripts

## Bash Scripts

### update_all_magmom.sh
Automatically updates MAGMOM values in VASP INCAR files for transition metal intercalation studies.

**Features:**
- Predefined magnetic moments for 28 transition metals
- Optimized VASP parameters for MoS2 intercalation calculations
- Processes both TM_28 (fixed Mo doping) and TM_Rest (variable doping) folder structures
- Automatically generates INCAR files with correct MAGMOM strings

**Usage:**
```bash
./update_all_magmom.sh
