# Scripts Configuration

**Before using these scripts, you MUST edit the following:**

## copy_job_scripts_template.sh
- Line ~37: Set your VASP binary path
- Line ~38: Set your Intel OneAPI path  
- Line ~12: Set your SLURM account name

## generate_potcar_template.sh
- Line 6: Set your VASP pseudopotential directory path

## Example Configurations:
```bash
# For typical academic clusters:
export PATH=${HOME}/vasp/bin:$PATH
source /opt/intel/oneapi/setvars.sh

# For NERSC:
module load vasp
export POTCAR_PATH=$VASP_PSEUDOPOTENTIALS

---

#Scripts
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
