#!/bin/bash

# Declare an array of string with type, these are the EL drift vel values to run
PRESSURE=10
GAS=enrichedXe

# Iterate the string array using for loop
mkdir -p Pressure_${PRESSURE}bar/gas_$GAS/${N_EVENTS}k/${ENERGY}MeV/${STEP_LENGTH}mm
cd  Pressure_${PRESSURE}bar/gas_$GAS/${N_EVENTS}k/${ENERGY}MeV/${STEP_LENGTH}mm


cp ../Enakshi_Nexus.sh .
sed -i "s#.*SBATCH -J.*#\#SBATCH -J NEW_MC208_${ELDrift}ELDrift \# A single job name for the array#" Enakshi_Nexus.sh
 sbatch --array=1-500 Enakshi_Nexus.sh
cd ..