#!/bin/bash

echo "Copying job scripts to all folders..."

#job script template
JOB_SCRIPT='#!/bin/bash
#SBATCH --job-name=opt # job name
#SBATCH --partition=shared # partition (debug, compute, shared)
#SBATCH --nodes=1 # number of nodes
#SBATCH --account=YOUR_ACCOUNT # account name - change this
#SBATCH --ntasks-per-node=32 # number of tasks per node
#SBATCH --cpus-per-task=1 # number of CPUs per task
#SBATCH --time=08:00:00 # time limit (HH:MM:SS)
#SBATCH --output=vasp.o%j.%N # output file
#SBATCH --error=vasp.e%j.%N # separate error file
#SBATCH --export=ALL # export all environment variables
#SBATCH --mem=100G # memory limit

#Print job information
echo "=========================================="
echo "Job started at: $(date)"
echo "Job ID: $SLURM_JOBID"
echo "Running on node: $SLURM_NODELIST"
echo "Working directory: $PWD"
echo "Folder: $(basename $PWD)"
echo "=========================================="

#Load modules
module purge
module load slurm
module load cpu/0.17.3b
module load ucx/1.10.1/wla3unl
module load cm-pmix3/3.1.7

#Set environment variables
export I_MPI_PMI_LIBRARY=/cm/shared/apps/slurm/current/lib64/libpmi.so
# User Configuration - Edit these paths for your system
export PATH=/path/to/your/vasp/bin:$PATH
source /path/to/your/intel/oneapi/setvars.sh

# Examples:
# export PATH=${HOME}/vasp/bin:$PATH
# source /opt/intel/oneapi/setvars.sh
# export PATH=/usr/local/vasp/bin:$PATH

#Check if all required files exist
echo "Checking input files..."
for file in POSCAR POTCAR KPOINTS INCAR; do
    if [[ -f "$file" ]]; then
        echo "$file found"
    else
        echo "$file missing!"
        exit 1
    fi
done

#Print some system info
echo "Number of atoms: $(sed -n '\''7p'\'' POSCAR | awk '\''{for(i=1;i<=NF;i++) sum+=$i} END{print sum}'\'')"
echo "System: $(head -1 POSCAR)"

#Run VASP
echo "Starting VASP calculation at $(date)"
srun vasp_gam >vasp.out 2>vasp.err

#Check if calculation completed
if [[ -f "CONTCAR" ]]; then
    echo "VASP calculation completed successfully at $(date)"
    
    # Quick convergence check
    if grep -q "reached required accuracy" OUTCAR 2>/dev/null; then
        echo "Electronic convergence achieved"
    else
        echo "Check electronic convergence in OUTCAR"
    fi
    
    if tail -1 vasp.out | grep -q "General timing"; then
        echo "Ionic relaxation completed normally"
    else
        echo "Check ionic convergence"
    fi
    
else
    echo "VASP calculation may have failed - no CONTCAR found"
    exit 1
fi

echo "=========================================="
echo "Job finished at: $(date)"
echo "=========================================="'

#Copy to TM_28 folders
if [[ -d "TM_28" ]]; then
    echo "Copying to TM_28 folders..."
    count=0
    for folder in TM_28/*; do
        if [[ -d "$folder" ]]; then
            echo "$JOB_SCRIPT" > "$folder/job_script.sb"
            chmod +x "$folder/job_script.sb"
            count=$((count + 1))
        fi
    done
    echo "Copied job script to $count TM_28 folders"
fi

#Copy to TM_Rest folders
if [[ -d "TM_Rest" ]]; then
    echo "Copying to TM_Rest folders..."
    count=0
    for folder in TM_Rest/*; do
        if [[ -d "$folder" ]]; then
            echo "$JOB_SCRIPT" > "$folder/job_script.sb"
            chmod +x "$folder/job_script.sb"
            count=$((count + 1))
            
            if (( count % 200 == 0 )); then
                echo "   $count folders done..."
            fi
        fi
    done
    echo "Copied job script to $count TM_Rest folders"
fi

echo "Done! Job script copied to all folders."
