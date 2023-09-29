#!/bin/bash

# Declare an array of string with type, these are the EL drift vel values to run
PRESSURE=15
GAS=depletedXe
STEP_LENGTH=0.1
ENERGY=1.5
N_EVENTS=25

# Iterate the string array using for loop
mkdir -p Pressure_${PRESSURE}bar/gas_$GAS/${N_EVENTS}k/${ENERGY}MeV/${STEP_LENGTH}mm
cd  Pressure_${PRESSURE}bar/gas_$GAS/${N_EVENTS}k/${ENERGY}MeV/${STEP_LENGTH}mm


cp ../../../../../Enakshi_Nexus.sh .

sed -i "s#.*STEP_LENGTH=.*#STEP_LENGTH=${STEP_LENGTH} #" Enakshi_Nexus.sh
sed -i "s#.*PRESSURE=.*#PRESSURE=${PRESSURE} #" Enakshi_Nexus.sh
sed -i "s#.*ENERGY=.*#ENERGY=${ENERGY}#" Enakshi_Nexus.sh
sed -i "s#.*GAS=.*#GAS=${GAS}#" Enakshi_Nexus.sh 
sed -i "s#.*N_EVENTS=.*#N_EVENTS=${N_EVENTS} #" Enakshi_Nexus.sh 

sbatch --array=1-40 Enakshi_Nexus.sh