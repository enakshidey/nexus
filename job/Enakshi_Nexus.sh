#!/bin/bash
#SBATCH -J NEXT100_Energy_Step # A single job name for the array
#SBATCH --nodes=1
#SBATCH --mem 2000 # Memory request (6Gb)
#SBATCH -t 0-6:00 # Maximum execution time (D-HH:MM)
#SBATCH -o NEXT100_Energy_Step_%A_%a.out # Standard output
#SBATCH -e NEXT100_Energy_Step_%A_%a.err # Standard error

# To run the job you run sbatch in the terminal:
# sbatch --array=1-10 <this script name>.sh
# The array is the range of jobs to run e.g. this runs 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
# Copy the files over
# Create the directory

# Set the configurable variables
STEP_LENGTH=1
ENERGY=2
JOBNAME="NEXT100_Energy_Step"
FILES_PER_JOB=1
N_EVENTS=400
CONFIG=NEXT100.config.mac 
INIT=NEXT100.init.mac 
MODE="e-"
PRESSURE=10

#Create the working area
cd /media/argon/HDD_8tb/Enakshi/IC_job/
mkdir -p $JOBNAME/$ENERGY/$STEP_LENGTH/jobid_"${SLURM_ARRAY_TASK_ID}"
cd $JOBNAME/$ENERGY/$STEP_LENGTH/jobid_"${SLURM_ARRAY_TASK_ID}"

# ---
cp /home/argon/Projects/Enakshi/nexus/macros/NEXT100.config.mac .
cp /home/argon/Projects/Enakshi/nexus/macros/NEXT100.init.mac .
cp /home/argon/Projects/Enakshi/nexus/config/*.conf .




echo "Initialising environment" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
start=`date +%s`


# Replace the particle if mode is set to electron
sed -i "s#.*max_step_size.*#/Geometry/Next100/max_step_size ${STEP_LENGTH} mm#" ${CONFIG}
sed -i "s#.*pressure.*#/Geometry/Next100/pressure ${PRESSURE} bar#" ${CONFIG}
sed -i "s#.*min_energy.*#//Generator/SingleParticle/min_energy ${ENERGY} MeV#" ${CONFIG}
sed -i "s#.*max_energy.*#//Generator/SingleParticle/max_energy ${ENERGY} MeV#" ${CONFIG}
sed -i "s#.*config.mac.*#/nexus/RegisterMacro NEXT100.config.mac#" ${INIT}

# ---


# Setup nexus and run
echo "Setting Up NEXUS" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
source ~/Projects/Enakshi/nexus/setup_cluster.sh

# Also setup IC
source /home/argon/Software/IC/setup_IC.sh


for i in $(eval echo "{1..${FILES_PER_JOB}}"); do

	# Replace the seed in the file	
	SEED=$((${N_EVENTS}*${FILES_PER_JOB}*(${SLURM_ARRAY_TASK_ID} - 1) + ${N_EVENTS}*${i}))
	echo "The seed number is: ${SEED}" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	sed -i "s#.*random_seed.*#/nexus/random_seed ${SEED}#" ${CONFIG}
	sed -i "s#.*start_id.*#/nexus/persistency/start_id ${SEED}#" ${CONFIG}
	# sed -i "s#.*file_out.*#file_out = \"NEW_${MODE}_ACTIVE_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_${i}_ELDrift${ELDrift}.next.h5\"#" esmeralda.conf
	
	# NEXUS
	echo "Running NEXUS" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	nexus -n $N_EVENTS ${INIT} 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	
	# IC
	echo "Running IC Detsim"  2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city detsim detsim.conf   2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

	mv NEXT100.next.h5 NEXT100_${N_EVENTS}k_${ENERGY}MeV_${STEP_LENGTH}mm_${PRESSURE}bar.next.h5
	
	echo "Running IC Hypathia"  2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city hypathia hypathia.conf   2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt	
	
	echo "Running IC Penthesilea"     2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city penthesilea penthesilea.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	
	echo "Running IC Esmeralda"     2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city esmeralda esmeralda.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	
	echo "Running IC Beersheba"  2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city beersheba beersheba.conf   2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	
	echo "Running IC Isaura"  2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	city isaura isaura.conf   2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	
	
# ​
	# Rename files
	# mv NEW_Tl208_ACTIVE_penthesilea.next.h5 NEW_${MODE}_ACTIVE_penthesilea_jobid_${SLURM_ARRAY_TASK_ID}_${i}_ELDrift${ELDrift}.next.h5
	# mv NEW_Tl208_ACTIVE_esmeralda.next.h5 NEW_${MODE}_ACTIVE_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_${i}_ELDrift${ELDrift}.next.h5

	echo; echo; echo;
done

# Merge the files into one
# mkdir temp_penthesilea 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
# mv *penthesilea*.h5 temp_penthesilea 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
# python ~/packages/NEWDiffusion/tools/merge_h5.py -i temp_penthesilea -o NEW_${MODE}_ACTIVE_penthesilea_jobid_${SLURM_ARRAY_TASK_ID}_merged_ELDrift${ELDrift}.next.h5 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# mkdir temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
# mv *esmeralda*.h5 temp_esmeralda 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
# python ~/packages/NEWDiffusion/tools/merge_h5.py -i temp_esmeralda -o NEW_${MODE}_ACTIVE_esmeralda_jobid_${SLURM_ARRAY_TASK_ID}_merged_ELDrift${ELDrift}.next.h5 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Count the events in the file and write to an output file
# file="NEW_${MODE}_ACTIVE_penthesilea_jobid_${SLURM_ARRAY_TASK_ID}_merged_ELDrift${ELDrift}.next.h5"
# echo "$(ptdump -d $file:/Run/events | sed 1,2d | wc -l | xargs)" > NumEvents.txt
# echo "Total events generated: $(ptdump -d $file:/Run/events | sed 1,2d | wc -l | xargs)" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Cleaning up
rm -v *detsim_out.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *beersheba_out.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *penthesilea_out.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
rm -v *hypathia_out.next.h5* 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt

# Remove the config files if not the first jobid
if [ ${SLURM_ARRAY_TASK_ID} -ne 1 ]; then
	rm -v *.conf 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
	rm -v *.mac 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
fi

echo "FINISHED....EXITING" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt
end=`date +%s`
runtime=$((end-start))
echo "$runtime s" 2>&1 | tee -a log_nexus_"${SLURM_ARRAY_TASK_ID}".txt