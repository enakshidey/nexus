# Set the path to the Geant4 Installation
export G4INSTALL=/home/argon/Software/Geant4/geant4-v11.0.3/install
export PATH=$G4INSTALL/bin:$PATH;
export LD_LIBRARY_PATH=$G4INSTALL/lib:$LD_LIBRARY_PATH;

source $G4INSTALL/bin/geant4.sh;


export HDF5_PATH=/home/argon/anaconda3/pkgs/hdf5-1.10.6-hb1b8bf9_0/
export HDF5_LIB=/home/argon/anaconda3/pkgs/hdf5-1.10.6-hb1b8bf9_0/lib/;
export HDF5_INC=/home/argon/anaconda3/pkgs/hdf5-1.10.6-hb1b8bf9_0/include/;
export LD_LIBRARY_PATH=$HDF5_LIB:$LD_LIBRARY_PATH;
export HDF5_DIR=$HDF5_PATH

export PATH=$PATH:/home/argon/Projects/Enakshi/nexus/bin

echo "Setup Nexus is complete!!"
