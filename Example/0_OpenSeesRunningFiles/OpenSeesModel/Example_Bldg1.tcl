####################################################################################################
####################################################################################################
#                                        17-story MRF Building
####################################################################################################
####################################################################################################

####### MODEL FEATURES #######;
# UNITS:                     kip, in
# Generation:                Pre_Northridge
# Composite beams:           True
# Fracturing fiber sections: True
# Gravity system stiffness:  True
# Column splices included:   True
# Rigid diaphragm:           False
# Plastic hinge type:        non_RBS
# Backbone type:             ASCE41
# Cyclic degradation:        False
# Web connection type:       Bolted
# Panel zone model:          Elkady2021

# BUILD MODEL (2D - 3 DOF/node)
wipe all
model basic -ndm 2 -ndf 3

####################################################################################################
#                                      SOURCING HELPER FUNCTIONS                                   #
####################################################################################################

source ConstructPanel_Rectangle.tcl;
source PanelZoneSpring.tcl;
source fracSectionBolted.tcl;
source hingeBeamColumnFracture.tcl;
source sigCrNIST2017.tcl;
source fracSectionWelded.tcl;
source fracSectionSplice.tcl;
source hingeBeamColumnSpliceZLS.tcl;
source matSplice.tcl;
source hingeBeamColumn.tcl;
source matHysteretic.tcl;
source matIMKBilin.tcl;
source matBilin02.tcl;
source Spring_Pinching.tcl;
source modalAnalysis.tcl;

####################################################################################################
#                                              INPUT                                               #
####################################################################################################

# GENERAL CONSTANTS
set g 386.100;
set pi [expr 2.0*asin(1.0)];
set n 10.0; # stiffness multiplier for CPH elements
set addBasicRecorders 1
set addDetailedRecorders 0

# FRAME CENTERLINE DIMENSIONS
set num_stories 17;
set NBay  9;

# MATERIAL PROPERTIES
set Es  29000.000; 
set mu  0.300; 
set FyBeam  47.300;
set FyCol  47.300;

# RIGID MATERIAL FOR ZERO LENGTH ELEMENT STIFF DOF
set rigMatTag 99
uniaxialMaterial Elastic  $rigMatTag [expr 50*50*29000];  #Rigid Material [using axial stiffness of a 500in2 steel element] 

# RAYLEIGH DAMPING PARAMETERS
set  DampModeI 1;
set  DampModeJ 3;
set  zeta 0.020;

# GRAVITY FRAME MODEL
set gap 0.08; # Gap to consider binding in gravity frame beam connections

# GEOMETRIC TRANSFORMATIONS IDs
geomTransf Linear 		 1;
geomTransf PDelta 		 2;
geomTransf Corotational 3;
set trans_Linear 	1;
set trans_PDelta 	2;
set trans_Corot  	3;
set trans_selected  2;

# STIFF ELEMENTS FOR PANEL ZONE MODEL PROPERTY
set A_Stiff [expr 50*50]; # [using 500in2 section as a reference]
set I_Stiff [expr 50*pow(50,3)]; # [using second moment of area of a large rectangle as a reference]

# PANEL ZONE MODELING
set SH_PZ 0.015;
set pzModelTag 4;

# BACKBONE FACTORS FOR COMPOSITE BEAM
set Composite 1; # Consider composite action
set Comp_I       1.400; # stiffness factor for MR frame beams
set Comp_I_GC    1.400; # stiffness factor for EGF beams
set trib        3.000;
set tslab       3.250;
set bslab       36.000;
set AslabSteel  15.000;
# compBackboneFactors {MpP/Mp MpN/Mp Mc/MpP Mc/MpN Mr/MpP Mr/MpN D_P D_N theta_p_P_comp theta_p_N_comp theta_pc_P_comp theta_pc_P_comp};
set compBackboneFactors {1.350 1.100 1.150 1.050 0.300 0.200 1.150 1.000 1.800 0.950 1.350 0.950};
# slabFiberMaterials {fc epsc0 epsU fy degrad};
set slabFiberMaterials {-3.000 -0.002 -0.010 60.000 -0.100};

# DEGRADATION IN PLASTIC HINGEs
set degradation 0;
set c 0.000; # Exponent for degradation in plastic hinges

# COLUMN SPLICES
set spliceLoc        24.000;

# MATERIAL PROPERTIES FOR FRACURING FIBER-SECTIONS
set alpha 7.6; # Calibration constant to compute KIC (Stillmaker et al. 2017)
set T_service_F 70; # Temperature at service [F]
set FyWeld 70; # Yielding strength for sigCr calculations (Use 70ksi to be consistent with Galvis et al. 2021 calibrations)
# fracSecMaterials {FyFiber EsFiber betaC_B betaC_T sigMin FuBolt FyTab FuTab};
set fracSecMaterials {150.000 29000.000 0.500 0.800 18.920 68.000 47.000 70.000};

# FRACTURE INDEX LIMIT FOR FRACTURE PER FLANGE AND CONNECTION
# Left-Bottom                       Left-Top                            Right-Bottom                       Right-Top
set FI_limB_bay1_floor2_i 1.000;	set FI_limT_bay1_floor2_i 1.000;	set FI_limB_bay1_floor2_j 1.000;	set FI_limT_bay1_floor2_j 1.000;	
set FI_limB_bay2_floor2_i 1.000;	set FI_limT_bay2_floor2_i 1.000;	set FI_limB_bay2_floor2_j 1.000;	set FI_limT_bay2_floor2_j 1.000;	
set FI_limB_bay3_floor2_i 1.000;	set FI_limT_bay3_floor2_i 1.000;	set FI_limB_bay3_floor2_j 1.000;	set FI_limT_bay3_floor2_j 1.000;	
set FI_limB_bay4_floor2_i 1.000;	set FI_limT_bay4_floor2_i 1.000;	set FI_limB_bay4_floor2_j 1.000;	set FI_limT_bay4_floor2_j 1.000;	
set FI_limB_bay5_floor2_i 1.000;	set FI_limT_bay5_floor2_i 1.000;	set FI_limB_bay5_floor2_j 1.000;	set FI_limT_bay5_floor2_j 1.000;	
set FI_limB_bay7_floor2_i 1.000;	set FI_limT_bay7_floor2_i 1.000;	set FI_limB_bay7_floor2_j 1.000;	set FI_limT_bay7_floor2_j 1.000;	
set FI_limB_bay8_floor2_i 1.000;	set FI_limT_bay8_floor2_i 1.000;	set FI_limB_bay8_floor2_j 1.000;	set FI_limT_bay8_floor2_j 1.000;	
set FI_limB_bay9_floor2_i 1.000;	set FI_limT_bay9_floor2_i 1.000;	set FI_limB_bay9_floor2_j 1.000;	set FI_limT_bay9_floor2_j 1.000;	
set FI_limB_bay1_floor3_i 1.000;	set FI_limT_bay1_floor3_i 1.000;	set FI_limB_bay1_floor3_j 1.000;	set FI_limT_bay1_floor3_j 1.000;	
set FI_limB_bay2_floor3_i 1.000;	set FI_limT_bay2_floor3_i 1.000;	set FI_limB_bay2_floor3_j 1.000;	set FI_limT_bay2_floor3_j 1.000;	
set FI_limB_bay3_floor3_i 1.000;	set FI_limT_bay3_floor3_i 1.000;	set FI_limB_bay3_floor3_j 1.000;	set FI_limT_bay3_floor3_j 1.000;	
set FI_limB_bay4_floor3_i 1.000;	set FI_limT_bay4_floor3_i 1.000;	set FI_limB_bay4_floor3_j 1.000;	set FI_limT_bay4_floor3_j 1.000;	
set FI_limB_bay5_floor3_i 1.000;	set FI_limT_bay5_floor3_i 1.000;	set FI_limB_bay5_floor3_j 1.000;	set FI_limT_bay5_floor3_j 1.000;	
set FI_limB_bay6_floor3_i 1.000;	set FI_limT_bay6_floor3_i 1.000;	set FI_limB_bay6_floor3_j 1.000;	set FI_limT_bay6_floor3_j 1.000;	
set FI_limB_bay7_floor3_i 1.000;	set FI_limT_bay7_floor3_i 1.000;	set FI_limB_bay7_floor3_j 1.000;	set FI_limT_bay7_floor3_j 1.000;	
set FI_limB_bay8_floor3_i 1.000;	set FI_limT_bay8_floor3_i 1.000;	set FI_limB_bay8_floor3_j 1.000;	set FI_limT_bay8_floor3_j 1.000;	
set FI_limB_bay9_floor3_i 1.000;	set FI_limT_bay9_floor3_i 1.000;	set FI_limB_bay9_floor3_j 1.000;	set FI_limT_bay9_floor3_j 1.000;	
set FI_limB_bay1_floor4_i 1.000;	set FI_limT_bay1_floor4_i 1.000;	set FI_limB_bay1_floor4_j 1.000;	set FI_limT_bay1_floor4_j 1.000;	
set FI_limB_bay2_floor4_i 1.000;	set FI_limT_bay2_floor4_i 1.000;	set FI_limB_bay2_floor4_j 1.000;	set FI_limT_bay2_floor4_j 1.000;	
set FI_limB_bay3_floor4_i 1.000;	set FI_limT_bay3_floor4_i 1.000;	set FI_limB_bay3_floor4_j 1.000;	set FI_limT_bay3_floor4_j 1.000;	
set FI_limB_bay4_floor4_i 1.000;	set FI_limT_bay4_floor4_i 1.000;	set FI_limB_bay4_floor4_j 1.000;	set FI_limT_bay4_floor4_j 1.000;	
set FI_limB_bay5_floor4_i 1.000;	set FI_limT_bay5_floor4_i 1.000;	set FI_limB_bay5_floor4_j 1.000;	set FI_limT_bay5_floor4_j 1.000;	
set FI_limB_bay6_floor4_i 1.000;	set FI_limT_bay6_floor4_i 1.000;	set FI_limB_bay6_floor4_j 1.000;	set FI_limT_bay6_floor4_j 1.000;	
set FI_limB_bay7_floor4_i 1.000;	set FI_limT_bay7_floor4_i 1.000;	set FI_limB_bay7_floor4_j 1.000;	set FI_limT_bay7_floor4_j 1.000;	
set FI_limB_bay8_floor4_i 1.000;	set FI_limT_bay8_floor4_i 1.000;	set FI_limB_bay8_floor4_j 1.000;	set FI_limT_bay8_floor4_j 1.000;	
set FI_limB_bay9_floor4_i 1.000;	set FI_limT_bay9_floor4_i 1.000;	set FI_limB_bay9_floor4_j 1.000;	set FI_limT_bay9_floor4_j 1.000;	
set FI_limB_bay1_floor5_i 1.000;	set FI_limT_bay1_floor5_i 1.000;	set FI_limB_bay1_floor5_j 1.000;	set FI_limT_bay1_floor5_j 1.000;	
set FI_limB_bay2_floor5_i 1.000;	set FI_limT_bay2_floor5_i 1.000;	set FI_limB_bay2_floor5_j 1.000;	set FI_limT_bay2_floor5_j 1.000;	
set FI_limB_bay3_floor5_i 1.000;	set FI_limT_bay3_floor5_i 1.000;	set FI_limB_bay3_floor5_j 1.000;	set FI_limT_bay3_floor5_j 1.000;	
set FI_limB_bay4_floor5_i 1.000;	set FI_limT_bay4_floor5_i 1.000;	set FI_limB_bay4_floor5_j 1.000;	set FI_limT_bay4_floor5_j 1.000;	
set FI_limB_bay5_floor5_i 1.000;	set FI_limT_bay5_floor5_i 1.000;	set FI_limB_bay5_floor5_j 1.000;	set FI_limT_bay5_floor5_j 1.000;	
set FI_limB_bay6_floor5_i 1.000;	set FI_limT_bay6_floor5_i 1.000;	set FI_limB_bay6_floor5_j 1.000;	set FI_limT_bay6_floor5_j 1.000;	
set FI_limB_bay7_floor5_i 1.000;	set FI_limT_bay7_floor5_i 1.000;	set FI_limB_bay7_floor5_j 1.000;	set FI_limT_bay7_floor5_j 1.000;	
set FI_limB_bay8_floor5_i 1.000;	set FI_limT_bay8_floor5_i 1.000;	set FI_limB_bay8_floor5_j 1.000;	set FI_limT_bay8_floor5_j 1.000;	
set FI_limB_bay9_floor5_i 1.000;	set FI_limT_bay9_floor5_i 1.000;	set FI_limB_bay9_floor5_j 1.000;	set FI_limT_bay9_floor5_j 1.000;	
set FI_limB_bay1_floor6_i 1.000;	set FI_limT_bay1_floor6_i 1.000;	set FI_limB_bay1_floor6_j 1.000;	set FI_limT_bay1_floor6_j 1.000;	
set FI_limB_bay2_floor6_i 1.000;	set FI_limT_bay2_floor6_i 1.000;	set FI_limB_bay2_floor6_j 1.000;	set FI_limT_bay2_floor6_j 1.000;	
set FI_limB_bay3_floor6_i 1.000;	set FI_limT_bay3_floor6_i 1.000;	set FI_limB_bay3_floor6_j 1.000;	set FI_limT_bay3_floor6_j 1.000;	
set FI_limB_bay4_floor6_i 1.000;	set FI_limT_bay4_floor6_i 1.000;	set FI_limB_bay4_floor6_j 1.000;	set FI_limT_bay4_floor6_j 1.000;	
set FI_limB_bay5_floor6_i 1.000;	set FI_limT_bay5_floor6_i 1.000;	set FI_limB_bay5_floor6_j 1.000;	set FI_limT_bay5_floor6_j 1.000;	
set FI_limB_bay6_floor6_i 1.000;	set FI_limT_bay6_floor6_i 1.000;	set FI_limB_bay6_floor6_j 1.000;	set FI_limT_bay6_floor6_j 1.000;	
set FI_limB_bay7_floor6_i 1.000;	set FI_limT_bay7_floor6_i 1.000;	set FI_limB_bay7_floor6_j 1.000;	set FI_limT_bay7_floor6_j 1.000;	
set FI_limB_bay8_floor6_i 1.000;	set FI_limT_bay8_floor6_i 1.000;	set FI_limB_bay8_floor6_j 1.000;	set FI_limT_bay8_floor6_j 1.000;	
set FI_limB_bay9_floor6_i 1.000;	set FI_limT_bay9_floor6_i 1.000;	set FI_limB_bay9_floor6_j 1.000;	set FI_limT_bay9_floor6_j 1.000;	
set FI_limB_bay1_floor7_i 1.000;	set FI_limT_bay1_floor7_i 1.000;	set FI_limB_bay1_floor7_j 1.000;	set FI_limT_bay1_floor7_j 1.000;	
set FI_limB_bay2_floor7_i 1.000;	set FI_limT_bay2_floor7_i 1.000;	set FI_limB_bay2_floor7_j 1.000;	set FI_limT_bay2_floor7_j 1.000;	
set FI_limB_bay3_floor7_i 1.000;	set FI_limT_bay3_floor7_i 1.000;	set FI_limB_bay3_floor7_j 1.000;	set FI_limT_bay3_floor7_j 1.000;	
set FI_limB_bay4_floor7_i 1.000;	set FI_limT_bay4_floor7_i 1.000;	set FI_limB_bay4_floor7_j 1.000;	set FI_limT_bay4_floor7_j 1.000;	
set FI_limB_bay5_floor7_i 1.000;	set FI_limT_bay5_floor7_i 1.000;	set FI_limB_bay5_floor7_j 1.000;	set FI_limT_bay5_floor7_j 1.000;	
set FI_limB_bay6_floor7_i 1.000;	set FI_limT_bay6_floor7_i 1.000;	set FI_limB_bay6_floor7_j 1.000;	set FI_limT_bay6_floor7_j 1.000;	
set FI_limB_bay7_floor7_i 1.000;	set FI_limT_bay7_floor7_i 1.000;	set FI_limB_bay7_floor7_j 1.000;	set FI_limT_bay7_floor7_j 1.000;	
set FI_limB_bay8_floor7_i 1.000;	set FI_limT_bay8_floor7_i 1.000;	set FI_limB_bay8_floor7_j 1.000;	set FI_limT_bay8_floor7_j 1.000;	
set FI_limB_bay9_floor7_i 1.000;	set FI_limT_bay9_floor7_i 1.000;	set FI_limB_bay9_floor7_j 1.000;	set FI_limT_bay9_floor7_j 1.000;	
set FI_limB_bay1_floor8_i 1.000;	set FI_limT_bay1_floor8_i 1.000;	set FI_limB_bay1_floor8_j 1.000;	set FI_limT_bay1_floor8_j 1.000;	
set FI_limB_bay2_floor8_i 1.000;	set FI_limT_bay2_floor8_i 1.000;	set FI_limB_bay2_floor8_j 1.000;	set FI_limT_bay2_floor8_j 1.000;	
set FI_limB_bay3_floor8_i 1.000;	set FI_limT_bay3_floor8_i 1.000;	set FI_limB_bay3_floor8_j 1.000;	set FI_limT_bay3_floor8_j 1.000;	
set FI_limB_bay4_floor8_i 1.000;	set FI_limT_bay4_floor8_i 1.000;	set FI_limB_bay4_floor8_j 1.000;	set FI_limT_bay4_floor8_j 1.000;	
set FI_limB_bay5_floor8_i 1.000;	set FI_limT_bay5_floor8_i 1.000;	set FI_limB_bay5_floor8_j 1.000;	set FI_limT_bay5_floor8_j 1.000;	
set FI_limB_bay6_floor8_i 1.000;	set FI_limT_bay6_floor8_i 1.000;	set FI_limB_bay6_floor8_j 1.000;	set FI_limT_bay6_floor8_j 1.000;	
set FI_limB_bay7_floor8_i 1.000;	set FI_limT_bay7_floor8_i 1.000;	set FI_limB_bay7_floor8_j 1.000;	set FI_limT_bay7_floor8_j 1.000;	
set FI_limB_bay8_floor8_i 1.000;	set FI_limT_bay8_floor8_i 1.000;	set FI_limB_bay8_floor8_j 1.000;	set FI_limT_bay8_floor8_j 1.000;	
set FI_limB_bay9_floor8_i 1.000;	set FI_limT_bay9_floor8_i 1.000;	set FI_limB_bay9_floor8_j 1.000;	set FI_limT_bay9_floor8_j 1.000;	
set FI_limB_bay1_floor9_i 1.000;	set FI_limT_bay1_floor9_i 1.000;	set FI_limB_bay1_floor9_j 1.000;	set FI_limT_bay1_floor9_j 1.000;	
set FI_limB_bay2_floor9_i 1.000;	set FI_limT_bay2_floor9_i 1.000;	set FI_limB_bay2_floor9_j 1.000;	set FI_limT_bay2_floor9_j 1.000;	
set FI_limB_bay3_floor9_i 1.000;	set FI_limT_bay3_floor9_i 1.000;	set FI_limB_bay3_floor9_j 1.000;	set FI_limT_bay3_floor9_j 1.000;	
set FI_limB_bay4_floor9_i 1.000;	set FI_limT_bay4_floor9_i 1.000;	set FI_limB_bay4_floor9_j 1.000;	set FI_limT_bay4_floor9_j 1.000;	
set FI_limB_bay5_floor9_i 1.000;	set FI_limT_bay5_floor9_i 1.000;	set FI_limB_bay5_floor9_j 1.000;	set FI_limT_bay5_floor9_j 1.000;	
set FI_limB_bay6_floor9_i 1.000;	set FI_limT_bay6_floor9_i 1.000;	set FI_limB_bay6_floor9_j 1.000;	set FI_limT_bay6_floor9_j 1.000;	
set FI_limB_bay7_floor9_i 1.000;	set FI_limT_bay7_floor9_i 1.000;	set FI_limB_bay7_floor9_j 1.000;	set FI_limT_bay7_floor9_j 1.000;	
set FI_limB_bay8_floor9_i 1.000;	set FI_limT_bay8_floor9_i 1.000;	set FI_limB_bay8_floor9_j 1.000;	set FI_limT_bay8_floor9_j 1.000;	
set FI_limB_bay9_floor9_i 1.000;	set FI_limT_bay9_floor9_i 1.000;	set FI_limB_bay9_floor9_j 1.000;	set FI_limT_bay9_floor9_j 1.000;	
set FI_limB_bay1_floor10_i 1.000;	set FI_limT_bay1_floor10_i 1.000;	set FI_limB_bay1_floor10_j 1.000;	set FI_limT_bay1_floor10_j 1.000;	
set FI_limB_bay2_floor10_i 1.000;	set FI_limT_bay2_floor10_i 1.000;	set FI_limB_bay2_floor10_j 1.000;	set FI_limT_bay2_floor10_j 1.000;	
set FI_limB_bay3_floor10_i 1.000;	set FI_limT_bay3_floor10_i 1.000;	set FI_limB_bay3_floor10_j 1.000;	set FI_limT_bay3_floor10_j 1.000;	
set FI_limB_bay4_floor10_i 1.000;	set FI_limT_bay4_floor10_i 1.000;	set FI_limB_bay4_floor10_j 1.000;	set FI_limT_bay4_floor10_j 1.000;	
set FI_limB_bay5_floor10_i 1.000;	set FI_limT_bay5_floor10_i 1.000;	set FI_limB_bay5_floor10_j 1.000;	set FI_limT_bay5_floor10_j 1.000;	
set FI_limB_bay6_floor10_i 1.000;	set FI_limT_bay6_floor10_i 1.000;	set FI_limB_bay6_floor10_j 1.000;	set FI_limT_bay6_floor10_j 1.000;	
set FI_limB_bay7_floor10_i 1.000;	set FI_limT_bay7_floor10_i 1.000;	set FI_limB_bay7_floor10_j 1.000;	set FI_limT_bay7_floor10_j 1.000;	
set FI_limB_bay8_floor10_i 1.000;	set FI_limT_bay8_floor10_i 1.000;	set FI_limB_bay8_floor10_j 1.000;	set FI_limT_bay8_floor10_j 1.000;	
set FI_limB_bay9_floor10_i 1.000;	set FI_limT_bay9_floor10_i 1.000;	set FI_limB_bay9_floor10_j 1.000;	set FI_limT_bay9_floor10_j 1.000;	
set FI_limB_bay2_floor11_i 1.000;	set FI_limT_bay2_floor11_i 1.000;	set FI_limB_bay2_floor11_j 1.000;	set FI_limT_bay2_floor11_j 1.000;	
set FI_limB_bay3_floor11_i 1.000;	set FI_limT_bay3_floor11_i 1.000;	set FI_limB_bay3_floor11_j 1.000;	set FI_limT_bay3_floor11_j 1.000;	
set FI_limB_bay4_floor11_i 1.000;	set FI_limT_bay4_floor11_i 1.000;	set FI_limB_bay4_floor11_j 1.000;	set FI_limT_bay4_floor11_j 1.000;	
set FI_limB_bay5_floor11_i 1.000;	set FI_limT_bay5_floor11_i 1.000;	set FI_limB_bay5_floor11_j 1.000;	set FI_limT_bay5_floor11_j 1.000;	
set FI_limB_bay6_floor11_i 1.000;	set FI_limT_bay6_floor11_i 1.000;	set FI_limB_bay6_floor11_j 1.000;	set FI_limT_bay6_floor11_j 1.000;	
set FI_limB_bay7_floor11_i 1.000;	set FI_limT_bay7_floor11_i 1.000;	set FI_limB_bay7_floor11_j 1.000;	set FI_limT_bay7_floor11_j 1.000;	
set FI_limB_bay8_floor11_i 1.000;	set FI_limT_bay8_floor11_i 1.000;	set FI_limB_bay8_floor11_j 1.000;	set FI_limT_bay8_floor11_j 1.000;	
set FI_limB_bay9_floor11_i 1.000;	set FI_limT_bay9_floor11_i 1.000;	set FI_limB_bay9_floor11_j 1.000;	set FI_limT_bay9_floor11_j 1.000;	
set FI_limB_bay3_floor12_i 1.000;	set FI_limT_bay3_floor12_i 1.000;	set FI_limB_bay3_floor12_j 1.000;	set FI_limT_bay3_floor12_j 1.000;	
set FI_limB_bay4_floor12_i 1.000;	set FI_limT_bay4_floor12_i 1.000;	set FI_limB_bay4_floor12_j 1.000;	set FI_limT_bay4_floor12_j 1.000;	
set FI_limB_bay5_floor12_i 1.000;	set FI_limT_bay5_floor12_i 1.000;	set FI_limB_bay5_floor12_j 1.000;	set FI_limT_bay5_floor12_j 1.000;	
set FI_limB_bay6_floor12_i 1.000;	set FI_limT_bay6_floor12_i 1.000;	set FI_limB_bay6_floor12_j 1.000;	set FI_limT_bay6_floor12_j 1.000;	
set FI_limB_bay7_floor12_i 1.000;	set FI_limT_bay7_floor12_i 1.000;	set FI_limB_bay7_floor12_j 1.000;	set FI_limT_bay7_floor12_j 1.000;	
set FI_limB_bay8_floor12_i 1.000;	set FI_limT_bay8_floor12_i 1.000;	set FI_limB_bay8_floor12_j 1.000;	set FI_limT_bay8_floor12_j 1.000;	
set FI_limB_bay9_floor12_i 1.000;	set FI_limT_bay9_floor12_i 1.000;	set FI_limB_bay9_floor12_j 1.000;	set FI_limT_bay9_floor12_j 1.000;	
set FI_limB_bay4_floor13_i 1.000;	set FI_limT_bay4_floor13_i 1.000;	set FI_limB_bay4_floor13_j 1.000;	set FI_limT_bay4_floor13_j 1.000;	
set FI_limB_bay5_floor13_i 1.000;	set FI_limT_bay5_floor13_i 1.000;	set FI_limB_bay5_floor13_j 1.000;	set FI_limT_bay5_floor13_j 1.000;	
set FI_limB_bay6_floor13_i 1.000;	set FI_limT_bay6_floor13_i 1.000;	set FI_limB_bay6_floor13_j 1.000;	set FI_limT_bay6_floor13_j 1.000;	
set FI_limB_bay7_floor13_i 1.000;	set FI_limT_bay7_floor13_i 1.000;	set FI_limB_bay7_floor13_j 1.000;	set FI_limT_bay7_floor13_j 1.000;	
set FI_limB_bay8_floor13_i 1.000;	set FI_limT_bay8_floor13_i 1.000;	set FI_limB_bay8_floor13_j 1.000;	set FI_limT_bay8_floor13_j 1.000;	
set FI_limB_bay9_floor13_i 1.000;	set FI_limT_bay9_floor13_i 1.000;	set FI_limB_bay9_floor13_j 1.000;	set FI_limT_bay9_floor13_j 1.000;	
set FI_limB_bay6_floor14_i 1.000;	set FI_limT_bay6_floor14_i 1.000;	set FI_limB_bay6_floor14_j 1.000;	set FI_limT_bay6_floor14_j 1.000;	
set FI_limB_bay7_floor14_i 1.000;	set FI_limT_bay7_floor14_i 1.000;	set FI_limB_bay7_floor14_j 1.000;	set FI_limT_bay7_floor14_j 1.000;	
set FI_limB_bay8_floor14_i 1.000;	set FI_limT_bay8_floor14_i 1.000;	set FI_limB_bay8_floor14_j 1.000;	set FI_limT_bay8_floor14_j 1.000;	
set FI_limB_bay9_floor14_i 1.000;	set FI_limT_bay9_floor14_i 1.000;	set FI_limB_bay9_floor14_j 1.000;	set FI_limT_bay9_floor14_j 1.000;	
set FI_limB_bay6_floor15_i 1.000;	set FI_limT_bay6_floor15_i 1.000;	set FI_limB_bay6_floor15_j 1.000;	set FI_limT_bay6_floor15_j 1.000;	
set FI_limB_bay7_floor15_i 1.000;	set FI_limT_bay7_floor15_i 1.000;	set FI_limB_bay7_floor15_j 1.000;	set FI_limT_bay7_floor15_j 1.000;	
set FI_limB_bay8_floor15_i 1.000;	set FI_limT_bay8_floor15_i 1.000;	set FI_limB_bay8_floor15_j 1.000;	set FI_limT_bay8_floor15_j 1.000;	
set FI_limB_bay9_floor15_i 1.000;	set FI_limT_bay9_floor15_i 1.000;	set FI_limB_bay9_floor15_j 1.000;	set FI_limT_bay9_floor15_j 1.000;	
set FI_limB_bay6_floor16_i 1.000;	set FI_limT_bay6_floor16_i 1.000;	set FI_limB_bay6_floor16_j 1.000;	set FI_limT_bay6_floor16_j 1.000;	
set FI_limB_bay7_floor16_i 1.000;	set FI_limT_bay7_floor16_i 1.000;	set FI_limB_bay7_floor16_j 1.000;	set FI_limT_bay7_floor16_j 1.000;	
set FI_limB_bay8_floor16_i 1.000;	set FI_limT_bay8_floor16_i 1.000;	set FI_limB_bay8_floor16_j 1.000;	set FI_limT_bay8_floor16_j 1.000;	
set FI_limB_bay9_floor16_i 1.000;	set FI_limT_bay9_floor16_i 1.000;	set FI_limB_bay9_floor16_j 1.000;	set FI_limT_bay9_floor16_j 1.000;	
set FI_limB_bay6_floor17_i 1.000;	set FI_limT_bay6_floor17_i 1.000;	set FI_limB_bay6_floor17_j 1.000;	set FI_limT_bay6_floor17_j 1.000;	
set FI_limB_bay7_floor17_i 1.000;	set FI_limT_bay7_floor17_i 1.000;	set FI_limB_bay7_floor17_j 1.000;	set FI_limT_bay7_floor17_j 1.000;	
set FI_limB_bay8_floor17_i 1.000;	set FI_limT_bay8_floor17_i 1.000;	set FI_limB_bay8_floor17_j 1.000;	set FI_limT_bay8_floor17_j 1.000;	
set FI_limB_bay9_floor17_i 1.000;	set FI_limT_bay9_floor17_i 1.000;	set FI_limB_bay9_floor17_j 1.000;	set FI_limT_bay9_floor17_j 1.000;	
set FI_limB_bay6_floor18_i 1.000;	set FI_limT_bay6_floor18_i 1.000;	set FI_limB_bay6_floor18_j 1.000;	set FI_limT_bay6_floor18_j 1.000;	
set FI_limB_bay7_floor18_i 1.000;	set FI_limT_bay7_floor18_i 1.000;	set FI_limB_bay7_floor18_j 1.000;	set FI_limT_bay7_floor18_j 1.000;	
set FI_limB_bay8_floor18_i 1.000;	set FI_limT_bay8_floor18_i 1.000;	set FI_limB_bay8_floor18_j 1.000;	set FI_limT_bay8_floor18_j 1.000;	
set FI_limB_bay9_floor18_i 1.000;	set FI_limT_bay9_floor18_i 1.000;	set FI_limB_bay9_floor18_j 1.000;	set FI_limT_bay9_floor18_j 1.000;	

# CVN PER FLANGE AND CONNECTION
# Left connection               Right connection
set cvn_bay1_floor2_i 12.000;	set cvn_bay1_floor2_j 12.000;	
set cvn_bay2_floor2_i 12.000;	set cvn_bay2_floor2_j 12.000;	
set cvn_bay3_floor2_i 12.000;	set cvn_bay3_floor2_j 12.000;	
set cvn_bay4_floor2_i 12.000;	set cvn_bay4_floor2_j 12.000;	
set cvn_bay5_floor2_i 12.000;	set cvn_bay5_floor2_j 12.000;	
set cvn_bay7_floor2_i 12.000;	set cvn_bay7_floor2_j 12.000;	
set cvn_bay8_floor2_i 12.000;	set cvn_bay8_floor2_j 12.000;	
set cvn_bay9_floor2_i 12.000;	set cvn_bay9_floor2_j 12.000;	
set cvn_bay1_floor3_i 12.000;	set cvn_bay1_floor3_j 12.000;	
set cvn_bay2_floor3_i 12.000;	set cvn_bay2_floor3_j 12.000;	
set cvn_bay3_floor3_i 12.000;	set cvn_bay3_floor3_j 12.000;	
set cvn_bay4_floor3_i 12.000;	set cvn_bay4_floor3_j 12.000;	
set cvn_bay5_floor3_i 12.000;	set cvn_bay5_floor3_j 12.000;	
set cvn_bay6_floor3_i 12.000;	set cvn_bay6_floor3_j 12.000;	
set cvn_bay7_floor3_i 12.000;	set cvn_bay7_floor3_j 12.000;	
set cvn_bay8_floor3_i 12.000;	set cvn_bay8_floor3_j 12.000;	
set cvn_bay9_floor3_i 12.000;	set cvn_bay9_floor3_j 12.000;	
set cvn_bay1_floor4_i 12.000;	set cvn_bay1_floor4_j 12.000;	
set cvn_bay2_floor4_i 12.000;	set cvn_bay2_floor4_j 12.000;	
set cvn_bay3_floor4_i 12.000;	set cvn_bay3_floor4_j 12.000;	
set cvn_bay4_floor4_i 12.000;	set cvn_bay4_floor4_j 12.000;	
set cvn_bay5_floor4_i 12.000;	set cvn_bay5_floor4_j 12.000;	
set cvn_bay6_floor4_i 12.000;	set cvn_bay6_floor4_j 12.000;	
set cvn_bay7_floor4_i 12.000;	set cvn_bay7_floor4_j 12.000;	
set cvn_bay8_floor4_i 12.000;	set cvn_bay8_floor4_j 12.000;	
set cvn_bay9_floor4_i 12.000;	set cvn_bay9_floor4_j 12.000;	
set cvn_bay1_floor5_i 12.000;	set cvn_bay1_floor5_j 12.000;	
set cvn_bay2_floor5_i 12.000;	set cvn_bay2_floor5_j 12.000;	
set cvn_bay3_floor5_i 12.000;	set cvn_bay3_floor5_j 12.000;	
set cvn_bay4_floor5_i 12.000;	set cvn_bay4_floor5_j 12.000;	
set cvn_bay5_floor5_i 12.000;	set cvn_bay5_floor5_j 12.000;	
set cvn_bay6_floor5_i 12.000;	set cvn_bay6_floor5_j 12.000;	
set cvn_bay7_floor5_i 12.000;	set cvn_bay7_floor5_j 12.000;	
set cvn_bay8_floor5_i 12.000;	set cvn_bay8_floor5_j 12.000;	
set cvn_bay9_floor5_i 12.000;	set cvn_bay9_floor5_j 12.000;	
set cvn_bay1_floor6_i 12.000;	set cvn_bay1_floor6_j 12.000;	
set cvn_bay2_floor6_i 12.000;	set cvn_bay2_floor6_j 12.000;	
set cvn_bay3_floor6_i 12.000;	set cvn_bay3_floor6_j 12.000;	
set cvn_bay4_floor6_i 12.000;	set cvn_bay4_floor6_j 12.000;	
set cvn_bay5_floor6_i 12.000;	set cvn_bay5_floor6_j 12.000;	
set cvn_bay6_floor6_i 12.000;	set cvn_bay6_floor6_j 12.000;	
set cvn_bay7_floor6_i 12.000;	set cvn_bay7_floor6_j 12.000;	
set cvn_bay8_floor6_i 12.000;	set cvn_bay8_floor6_j 12.000;	
set cvn_bay9_floor6_i 12.000;	set cvn_bay9_floor6_j 12.000;	
set cvn_bay1_floor7_i 12.000;	set cvn_bay1_floor7_j 12.000;	
set cvn_bay2_floor7_i 12.000;	set cvn_bay2_floor7_j 12.000;	
set cvn_bay3_floor7_i 12.000;	set cvn_bay3_floor7_j 12.000;	
set cvn_bay4_floor7_i 12.000;	set cvn_bay4_floor7_j 12.000;	
set cvn_bay5_floor7_i 12.000;	set cvn_bay5_floor7_j 12.000;	
set cvn_bay6_floor7_i 12.000;	set cvn_bay6_floor7_j 12.000;	
set cvn_bay7_floor7_i 12.000;	set cvn_bay7_floor7_j 12.000;	
set cvn_bay8_floor7_i 12.000;	set cvn_bay8_floor7_j 12.000;	
set cvn_bay9_floor7_i 12.000;	set cvn_bay9_floor7_j 12.000;	
set cvn_bay1_floor8_i 12.000;	set cvn_bay1_floor8_j 12.000;	
set cvn_bay2_floor8_i 12.000;	set cvn_bay2_floor8_j 12.000;	
set cvn_bay3_floor8_i 12.000;	set cvn_bay3_floor8_j 12.000;	
set cvn_bay4_floor8_i 12.000;	set cvn_bay4_floor8_j 12.000;	
set cvn_bay5_floor8_i 12.000;	set cvn_bay5_floor8_j 12.000;	
set cvn_bay6_floor8_i 12.000;	set cvn_bay6_floor8_j 12.000;	
set cvn_bay7_floor8_i 12.000;	set cvn_bay7_floor8_j 12.000;	
set cvn_bay8_floor8_i 12.000;	set cvn_bay8_floor8_j 12.000;	
set cvn_bay9_floor8_i 12.000;	set cvn_bay9_floor8_j 12.000;	
set cvn_bay1_floor9_i 12.000;	set cvn_bay1_floor9_j 12.000;	
set cvn_bay2_floor9_i 12.000;	set cvn_bay2_floor9_j 12.000;	
set cvn_bay3_floor9_i 12.000;	set cvn_bay3_floor9_j 12.000;	
set cvn_bay4_floor9_i 12.000;	set cvn_bay4_floor9_j 12.000;	
set cvn_bay5_floor9_i 12.000;	set cvn_bay5_floor9_j 12.000;	
set cvn_bay6_floor9_i 12.000;	set cvn_bay6_floor9_j 12.000;	
set cvn_bay7_floor9_i 12.000;	set cvn_bay7_floor9_j 12.000;	
set cvn_bay8_floor9_i 12.000;	set cvn_bay8_floor9_j 12.000;	
set cvn_bay9_floor9_i 12.000;	set cvn_bay9_floor9_j 12.000;	
set cvn_bay1_floor10_i 12.000;	set cvn_bay1_floor10_j 12.000;	
set cvn_bay2_floor10_i 12.000;	set cvn_bay2_floor10_j 12.000;	
set cvn_bay3_floor10_i 12.000;	set cvn_bay3_floor10_j 12.000;	
set cvn_bay4_floor10_i 12.000;	set cvn_bay4_floor10_j 12.000;	
set cvn_bay5_floor10_i 12.000;	set cvn_bay5_floor10_j 12.000;	
set cvn_bay6_floor10_i 12.000;	set cvn_bay6_floor10_j 12.000;	
set cvn_bay7_floor10_i 12.000;	set cvn_bay7_floor10_j 12.000;	
set cvn_bay8_floor10_i 12.000;	set cvn_bay8_floor10_j 12.000;	
set cvn_bay9_floor10_i 12.000;	set cvn_bay9_floor10_j 12.000;	
set cvn_bay2_floor11_i 12.000;	set cvn_bay2_floor11_j 12.000;	
set cvn_bay3_floor11_i 12.000;	set cvn_bay3_floor11_j 12.000;	
set cvn_bay4_floor11_i 12.000;	set cvn_bay4_floor11_j 12.000;	
set cvn_bay5_floor11_i 12.000;	set cvn_bay5_floor11_j 12.000;	
set cvn_bay6_floor11_i 12.000;	set cvn_bay6_floor11_j 12.000;	
set cvn_bay7_floor11_i 12.000;	set cvn_bay7_floor11_j 12.000;	
set cvn_bay8_floor11_i 12.000;	set cvn_bay8_floor11_j 12.000;	
set cvn_bay9_floor11_i 12.000;	set cvn_bay9_floor11_j 12.000;	
set cvn_bay3_floor12_i 12.000;	set cvn_bay3_floor12_j 12.000;	
set cvn_bay4_floor12_i 12.000;	set cvn_bay4_floor12_j 12.000;	
set cvn_bay5_floor12_i 12.000;	set cvn_bay5_floor12_j 12.000;	
set cvn_bay6_floor12_i 12.000;	set cvn_bay6_floor12_j 12.000;	
set cvn_bay7_floor12_i 12.000;	set cvn_bay7_floor12_j 12.000;	
set cvn_bay8_floor12_i 12.000;	set cvn_bay8_floor12_j 12.000;	
set cvn_bay9_floor12_i 12.000;	set cvn_bay9_floor12_j 12.000;	
set cvn_bay4_floor13_i 12.000;	set cvn_bay4_floor13_j 12.000;	
set cvn_bay5_floor13_i 12.000;	set cvn_bay5_floor13_j 12.000;	
set cvn_bay6_floor13_i 12.000;	set cvn_bay6_floor13_j 12.000;	
set cvn_bay7_floor13_i 12.000;	set cvn_bay7_floor13_j 12.000;	
set cvn_bay8_floor13_i 12.000;	set cvn_bay8_floor13_j 12.000;	
set cvn_bay9_floor13_i 12.000;	set cvn_bay9_floor13_j 12.000;	
set cvn_bay6_floor14_i 12.000;	set cvn_bay6_floor14_j 12.000;	
set cvn_bay7_floor14_i 12.000;	set cvn_bay7_floor14_j 12.000;	
set cvn_bay8_floor14_i 12.000;	set cvn_bay8_floor14_j 12.000;	
set cvn_bay9_floor14_i 12.000;	set cvn_bay9_floor14_j 12.000;	
set cvn_bay6_floor15_i 12.000;	set cvn_bay6_floor15_j 12.000;	
set cvn_bay7_floor15_i 12.000;	set cvn_bay7_floor15_j 12.000;	
set cvn_bay8_floor15_i 12.000;	set cvn_bay8_floor15_j 12.000;	
set cvn_bay9_floor15_i 12.000;	set cvn_bay9_floor15_j 12.000;	
set cvn_bay6_floor16_i 12.000;	set cvn_bay6_floor16_j 12.000;	
set cvn_bay7_floor16_i 12.000;	set cvn_bay7_floor16_j 12.000;	
set cvn_bay8_floor16_i 12.000;	set cvn_bay8_floor16_j 12.000;	
set cvn_bay9_floor16_i 12.000;	set cvn_bay9_floor16_j 12.000;	
set cvn_bay6_floor17_i 12.000;	set cvn_bay6_floor17_j 12.000;	
set cvn_bay7_floor17_i 12.000;	set cvn_bay7_floor17_j 12.000;	
set cvn_bay8_floor17_i 12.000;	set cvn_bay8_floor17_j 12.000;	
set cvn_bay9_floor17_i 12.000;	set cvn_bay9_floor17_j 12.000;	
set cvn_bay6_floor18_i 12.000;	set cvn_bay6_floor18_j 12.000;	
set cvn_bay7_floor18_i 12.000;	set cvn_bay7_floor18_j 12.000;	
set cvn_bay8_floor18_i 12.000;	set cvn_bay8_floor18_j 12.000;	
set cvn_bay9_floor18_i 12.000;	set cvn_bay9_floor18_j 12.000;	

# a0 PER FLANGE AND CONNECTION
# Left connection           Right connection
set a0_bay1_floor2_i 0.138;	set a0_bay1_floor2_j 0.138;	
set a0_bay2_floor2_i 0.138;	set a0_bay2_floor2_j 0.138;	
set a0_bay3_floor2_i 0.138;	set a0_bay3_floor2_j 0.138;	
set a0_bay4_floor2_i 0.138;	set a0_bay4_floor2_j 0.138;	
set a0_bay5_floor2_i 0.138;	set a0_bay5_floor2_j 0.138;	
set a0_bay7_floor2_i 0.138;	set a0_bay7_floor2_j 0.138;	
set a0_bay8_floor2_i 0.138;	set a0_bay8_floor2_j 0.138;	
set a0_bay9_floor2_i 0.138;	set a0_bay9_floor2_j 0.138;	
set a0_bay1_floor3_i 0.138;	set a0_bay1_floor3_j 0.138;	
set a0_bay2_floor3_i 0.138;	set a0_bay2_floor3_j 0.138;	
set a0_bay3_floor3_i 0.138;	set a0_bay3_floor3_j 0.138;	
set a0_bay4_floor3_i 0.138;	set a0_bay4_floor3_j 0.138;	
set a0_bay5_floor3_i 0.138;	set a0_bay5_floor3_j 0.138;	
set a0_bay6_floor3_i 0.138;	set a0_bay6_floor3_j 0.138;	
set a0_bay7_floor3_i 0.138;	set a0_bay7_floor3_j 0.138;	
set a0_bay8_floor3_i 0.138;	set a0_bay8_floor3_j 0.138;	
set a0_bay9_floor3_i 0.138;	set a0_bay9_floor3_j 0.138;	
set a0_bay1_floor4_i 0.138;	set a0_bay1_floor4_j 0.138;	
set a0_bay2_floor4_i 0.138;	set a0_bay2_floor4_j 0.138;	
set a0_bay3_floor4_i 0.138;	set a0_bay3_floor4_j 0.138;	
set a0_bay4_floor4_i 0.138;	set a0_bay4_floor4_j 0.138;	
set a0_bay5_floor4_i 0.138;	set a0_bay5_floor4_j 0.138;	
set a0_bay6_floor4_i 0.138;	set a0_bay6_floor4_j 0.138;	
set a0_bay7_floor4_i 0.138;	set a0_bay7_floor4_j 0.138;	
set a0_bay8_floor4_i 0.138;	set a0_bay8_floor4_j 0.138;	
set a0_bay9_floor4_i 0.138;	set a0_bay9_floor4_j 0.138;	
set a0_bay1_floor5_i 0.156;	set a0_bay1_floor5_j 0.156;	
set a0_bay2_floor5_i 0.156;	set a0_bay2_floor5_j 0.156;	
set a0_bay3_floor5_i 0.156;	set a0_bay3_floor5_j 0.156;	
set a0_bay4_floor5_i 0.156;	set a0_bay4_floor5_j 0.156;	
set a0_bay5_floor5_i 0.156;	set a0_bay5_floor5_j 0.156;	
set a0_bay6_floor5_i 0.156;	set a0_bay6_floor5_j 0.156;	
set a0_bay7_floor5_i 0.156;	set a0_bay7_floor5_j 0.156;	
set a0_bay8_floor5_i 0.156;	set a0_bay8_floor5_j 0.156;	
set a0_bay9_floor5_i 0.156;	set a0_bay9_floor5_j 0.156;	
set a0_bay1_floor6_i 0.138;	set a0_bay1_floor6_j 0.138;	
set a0_bay2_floor6_i 0.138;	set a0_bay2_floor6_j 0.138;	
set a0_bay3_floor6_i 0.138;	set a0_bay3_floor6_j 0.138;	
set a0_bay4_floor6_i 0.138;	set a0_bay4_floor6_j 0.138;	
set a0_bay5_floor6_i 0.138;	set a0_bay5_floor6_j 0.138;	
set a0_bay6_floor6_i 0.138;	set a0_bay6_floor6_j 0.138;	
set a0_bay7_floor6_i 0.138;	set a0_bay7_floor6_j 0.138;	
set a0_bay8_floor6_i 0.138;	set a0_bay8_floor6_j 0.138;	
set a0_bay9_floor6_i 0.138;	set a0_bay9_floor6_j 0.138;	
set a0_bay1_floor7_i 0.138;	set a0_bay1_floor7_j 0.138;	
set a0_bay2_floor7_i 0.138;	set a0_bay2_floor7_j 0.138;	
set a0_bay3_floor7_i 0.138;	set a0_bay3_floor7_j 0.138;	
set a0_bay4_floor7_i 0.138;	set a0_bay4_floor7_j 0.138;	
set a0_bay5_floor7_i 0.138;	set a0_bay5_floor7_j 0.138;	
set a0_bay6_floor7_i 0.138;	set a0_bay6_floor7_j 0.138;	
set a0_bay7_floor7_i 0.138;	set a0_bay7_floor7_j 0.138;	
set a0_bay8_floor7_i 0.138;	set a0_bay8_floor7_j 0.138;	
set a0_bay9_floor7_i 0.138;	set a0_bay9_floor7_j 0.138;	
set a0_bay1_floor8_i 0.138;	set a0_bay1_floor8_j 0.138;	
set a0_bay2_floor8_i 0.138;	set a0_bay2_floor8_j 0.138;	
set a0_bay3_floor8_i 0.138;	set a0_bay3_floor8_j 0.138;	
set a0_bay4_floor8_i 0.138;	set a0_bay4_floor8_j 0.138;	
set a0_bay5_floor8_i 0.138;	set a0_bay5_floor8_j 0.138;	
set a0_bay6_floor8_i 0.138;	set a0_bay6_floor8_j 0.138;	
set a0_bay7_floor8_i 0.138;	set a0_bay7_floor8_j 0.138;	
set a0_bay8_floor8_i 0.138;	set a0_bay8_floor8_j 0.138;	
set a0_bay9_floor8_i 0.138;	set a0_bay9_floor8_j 0.138;	
set a0_bay1_floor9_i 0.138;	set a0_bay1_floor9_j 0.138;	
set a0_bay2_floor9_i 0.138;	set a0_bay2_floor9_j 0.138;	
set a0_bay3_floor9_i 0.138;	set a0_bay3_floor9_j 0.138;	
set a0_bay4_floor9_i 0.138;	set a0_bay4_floor9_j 0.138;	
set a0_bay5_floor9_i 0.138;	set a0_bay5_floor9_j 0.138;	
set a0_bay6_floor9_i 0.138;	set a0_bay6_floor9_j 0.138;	
set a0_bay7_floor9_i 0.138;	set a0_bay7_floor9_j 0.138;	
set a0_bay8_floor9_i 0.138;	set a0_bay8_floor9_j 0.138;	
set a0_bay9_floor9_i 0.138;	set a0_bay9_floor9_j 0.138;	
set a0_bay1_floor10_i 0.239;	set a0_bay1_floor10_j 0.239;	
set a0_bay2_floor10_i 0.239;	set a0_bay2_floor10_j 0.239;	
set a0_bay3_floor10_i 0.239;	set a0_bay3_floor10_j 0.239;	
set a0_bay4_floor10_i 0.239;	set a0_bay4_floor10_j 0.239;	
set a0_bay5_floor10_i 0.239;	set a0_bay5_floor10_j 0.239;	
set a0_bay6_floor10_i 0.239;	set a0_bay6_floor10_j 0.239;	
set a0_bay7_floor10_i 0.239;	set a0_bay7_floor10_j 0.239;	
set a0_bay8_floor10_i 0.239;	set a0_bay8_floor10_j 0.239;	
set a0_bay9_floor10_i 0.239;	set a0_bay9_floor10_j 0.239;	
set a0_bay2_floor11_i 0.239;	set a0_bay2_floor11_j 0.239;	
set a0_bay3_floor11_i 0.239;	set a0_bay3_floor11_j 0.239;	
set a0_bay4_floor11_i 0.239;	set a0_bay4_floor11_j 0.239;	
set a0_bay5_floor11_i 0.239;	set a0_bay5_floor11_j 0.239;	
set a0_bay6_floor11_i 0.239;	set a0_bay6_floor11_j 0.239;	
set a0_bay7_floor11_i 0.239;	set a0_bay7_floor11_j 0.239;	
set a0_bay8_floor11_i 0.239;	set a0_bay8_floor11_j 0.239;	
set a0_bay9_floor11_i 0.239;	set a0_bay9_floor11_j 0.239;	
set a0_bay3_floor12_i 0.239;	set a0_bay3_floor12_j 0.239;	
set a0_bay4_floor12_i 0.239;	set a0_bay4_floor12_j 0.239;	
set a0_bay5_floor12_i 0.239;	set a0_bay5_floor12_j 0.239;	
set a0_bay6_floor12_i 0.239;	set a0_bay6_floor12_j 0.239;	
set a0_bay7_floor12_i 0.239;	set a0_bay7_floor12_j 0.239;	
set a0_bay8_floor12_i 0.239;	set a0_bay8_floor12_j 0.239;	
set a0_bay9_floor12_i 0.239;	set a0_bay9_floor12_j 0.239;	
set a0_bay4_floor13_i 0.239;	set a0_bay4_floor13_j 0.239;	
set a0_bay5_floor13_i 0.239;	set a0_bay5_floor13_j 0.239;	
set a0_bay6_floor13_i 0.239;	set a0_bay6_floor13_j 0.239;	
set a0_bay7_floor13_i 0.239;	set a0_bay7_floor13_j 0.239;	
set a0_bay8_floor13_i 0.239;	set a0_bay8_floor13_j 0.239;	
set a0_bay9_floor13_i 0.239;	set a0_bay9_floor13_j 0.239;	
set a0_bay6_floor14_i 0.215;	set a0_bay6_floor14_j 0.215;	
set a0_bay7_floor14_i 0.215;	set a0_bay7_floor14_j 0.215;	
set a0_bay8_floor14_i 0.215;	set a0_bay8_floor14_j 0.215;	
set a0_bay9_floor14_i 0.215;	set a0_bay9_floor14_j 0.215;	
set a0_bay6_floor15_i 0.215;	set a0_bay6_floor15_j 0.215;	
set a0_bay7_floor15_i 0.215;	set a0_bay7_floor15_j 0.215;	
set a0_bay8_floor15_i 0.215;	set a0_bay8_floor15_j 0.215;	
set a0_bay9_floor15_i 0.215;	set a0_bay9_floor15_j 0.215;	
set a0_bay6_floor16_i 0.215;	set a0_bay6_floor16_j 0.215;	
set a0_bay7_floor16_i 0.215;	set a0_bay7_floor16_j 0.215;	
set a0_bay8_floor16_i 0.215;	set a0_bay8_floor16_j 0.215;	
set a0_bay9_floor16_i 0.215;	set a0_bay9_floor16_j 0.215;	
set a0_bay6_floor17_i 0.215;	set a0_bay6_floor17_j 0.215;	
set a0_bay7_floor17_i 0.215;	set a0_bay7_floor17_j 0.215;	
set a0_bay8_floor17_i 0.215;	set a0_bay8_floor17_j 0.215;	
set a0_bay9_floor17_i 0.215;	set a0_bay9_floor17_j 0.215;	
set a0_bay6_floor18_i 0.215;	set a0_bay6_floor18_j 0.215;	
set a0_bay7_floor18_i 0.215;	set a0_bay7_floor18_j 0.215;	
set a0_bay8_floor18_i 0.215;	set a0_bay8_floor18_j 0.215;	
set a0_bay9_floor18_i 0.215;	set a0_bay9_floor18_j 0.215;	

####################################################################################################
#                                          PRE-CALCULATIONS                                        #
####################################################################################################

# FRAME GRID LINES
set Floor1 0.0;
set Floor2  168.00;
set Floor3  324.00;
set Floor4  480.00;
set Floor5  636.00;
set Floor6  792.00;
set Floor7  948.00;
set Floor8  1104.00;
set Floor9  1224.00;
set Floor10  1344.00;
set Floor11  1464.00;
set Floor12  1584.00;
set Floor13  1704.00;
set Floor14  1824.00;
set Floor15  1944.00;
set Floor16  2064.00;
set Floor17  2191.00;
set Floor18  2341.00;

set Axis1 0.0;
set Axis2 360.00;
set Axis3 720.00;
set Axis4 1080.00;
set Axis5 1440.00;
set Axis6 1800.00;
set Axis7 2160.00;
set Axis8 2520.00;
set Axis9 2880.00;
set Axis10 3240.00;
set Axis11 3600.00;
set Axis12 3960.00;

set HBuilding 2341.00;
set WFrame 3240.00;

# SIGMA CRITICAL PER FLANGE AND CONNECTION
set sigCrB_bay1_floor2_i [sigCrNIST2017 "bottom" $cvn_bay1_floor2_i $a0_bay1_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor2_i [sigCrNIST2017 "top" $cvn_bay1_floor2_i $a0_bay1_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor2_j [sigCrNIST2017 "bottom" $cvn_bay1_floor2_j $a0_bay1_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor2_j [sigCrNIST2017 "top" $cvn_bay1_floor2_j $a0_bay1_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor2_i [sigCrNIST2017 "bottom" $cvn_bay2_floor2_i $a0_bay2_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor2_i [sigCrNIST2017 "top" $cvn_bay2_floor2_i $a0_bay2_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor2_j [sigCrNIST2017 "bottom" $cvn_bay2_floor2_j $a0_bay2_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor2_j [sigCrNIST2017 "top" $cvn_bay2_floor2_j $a0_bay2_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor2_i [sigCrNIST2017 "bottom" $cvn_bay3_floor2_i $a0_bay3_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor2_i [sigCrNIST2017 "top" $cvn_bay3_floor2_i $a0_bay3_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor2_j [sigCrNIST2017 "bottom" $cvn_bay3_floor2_j $a0_bay3_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor2_j [sigCrNIST2017 "top" $cvn_bay3_floor2_j $a0_bay3_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor2_i [sigCrNIST2017 "bottom" $cvn_bay4_floor2_i $a0_bay4_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor2_i [sigCrNIST2017 "top" $cvn_bay4_floor2_i $a0_bay4_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor2_j [sigCrNIST2017 "bottom" $cvn_bay4_floor2_j $a0_bay4_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor2_j [sigCrNIST2017 "top" $cvn_bay4_floor2_j $a0_bay4_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor2_i [sigCrNIST2017 "bottom" $cvn_bay5_floor2_i $a0_bay5_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor2_i [sigCrNIST2017 "top" $cvn_bay5_floor2_i $a0_bay5_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor2_j [sigCrNIST2017 "bottom" $cvn_bay5_floor2_j $a0_bay5_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor2_j [sigCrNIST2017 "top" $cvn_bay5_floor2_j $a0_bay5_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor2_i [sigCrNIST2017 "bottom" $cvn_bay7_floor2_i $a0_bay7_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor2_i [sigCrNIST2017 "top" $cvn_bay7_floor2_i $a0_bay7_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor2_j [sigCrNIST2017 "bottom" $cvn_bay7_floor2_j $a0_bay7_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor2_j [sigCrNIST2017 "top" $cvn_bay7_floor2_j $a0_bay7_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor2_i [sigCrNIST2017 "bottom" $cvn_bay8_floor2_i $a0_bay8_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor2_i [sigCrNIST2017 "top" $cvn_bay8_floor2_i $a0_bay8_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor2_j [sigCrNIST2017 "bottom" $cvn_bay8_floor2_j $a0_bay8_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor2_j [sigCrNIST2017 "top" $cvn_bay8_floor2_j $a0_bay8_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor2_i [sigCrNIST2017 "bottom" $cvn_bay9_floor2_i $a0_bay9_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor2_i [sigCrNIST2017 "top" $cvn_bay9_floor2_i $a0_bay9_floor2_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor2_j [sigCrNIST2017 "bottom" $cvn_bay9_floor2_j $a0_bay9_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor2_j [sigCrNIST2017 "top" $cvn_bay9_floor2_j $a0_bay9_floor2_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor3_i [sigCrNIST2017 "bottom" $cvn_bay1_floor3_i $a0_bay1_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor3_i [sigCrNIST2017 "top" $cvn_bay1_floor3_i $a0_bay1_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor3_j [sigCrNIST2017 "bottom" $cvn_bay1_floor3_j $a0_bay1_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor3_j [sigCrNIST2017 "top" $cvn_bay1_floor3_j $a0_bay1_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor3_i [sigCrNIST2017 "bottom" $cvn_bay2_floor3_i $a0_bay2_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor3_i [sigCrNIST2017 "top" $cvn_bay2_floor3_i $a0_bay2_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor3_j [sigCrNIST2017 "bottom" $cvn_bay2_floor3_j $a0_bay2_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor3_j [sigCrNIST2017 "top" $cvn_bay2_floor3_j $a0_bay2_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor3_i [sigCrNIST2017 "bottom" $cvn_bay3_floor3_i $a0_bay3_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor3_i [sigCrNIST2017 "top" $cvn_bay3_floor3_i $a0_bay3_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor3_j [sigCrNIST2017 "bottom" $cvn_bay3_floor3_j $a0_bay3_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor3_j [sigCrNIST2017 "top" $cvn_bay3_floor3_j $a0_bay3_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor3_i [sigCrNIST2017 "bottom" $cvn_bay4_floor3_i $a0_bay4_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor3_i [sigCrNIST2017 "top" $cvn_bay4_floor3_i $a0_bay4_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor3_j [sigCrNIST2017 "bottom" $cvn_bay4_floor3_j $a0_bay4_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor3_j [sigCrNIST2017 "top" $cvn_bay4_floor3_j $a0_bay4_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor3_i [sigCrNIST2017 "bottom" $cvn_bay5_floor3_i $a0_bay5_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor3_i [sigCrNIST2017 "top" $cvn_bay5_floor3_i $a0_bay5_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor3_j [sigCrNIST2017 "bottom" $cvn_bay5_floor3_j $a0_bay5_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor3_j [sigCrNIST2017 "top" $cvn_bay5_floor3_j $a0_bay5_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor3_i [sigCrNIST2017 "bottom" $cvn_bay6_floor3_i $a0_bay6_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor3_i [sigCrNIST2017 "top" $cvn_bay6_floor3_i $a0_bay6_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor3_j [sigCrNIST2017 "bottom" $cvn_bay6_floor3_j $a0_bay6_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor3_j [sigCrNIST2017 "top" $cvn_bay6_floor3_j $a0_bay6_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor3_i [sigCrNIST2017 "bottom" $cvn_bay7_floor3_i $a0_bay7_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor3_i [sigCrNIST2017 "top" $cvn_bay7_floor3_i $a0_bay7_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor3_j [sigCrNIST2017 "bottom" $cvn_bay7_floor3_j $a0_bay7_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor3_j [sigCrNIST2017 "top" $cvn_bay7_floor3_j $a0_bay7_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor3_i [sigCrNIST2017 "bottom" $cvn_bay8_floor3_i $a0_bay8_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor3_i [sigCrNIST2017 "top" $cvn_bay8_floor3_i $a0_bay8_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor3_j [sigCrNIST2017 "bottom" $cvn_bay8_floor3_j $a0_bay8_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor3_j [sigCrNIST2017 "top" $cvn_bay8_floor3_j $a0_bay8_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor3_i [sigCrNIST2017 "bottom" $cvn_bay9_floor3_i $a0_bay9_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor3_i [sigCrNIST2017 "top" $cvn_bay9_floor3_i $a0_bay9_floor3_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor3_j [sigCrNIST2017 "bottom" $cvn_bay9_floor3_j $a0_bay9_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor3_j [sigCrNIST2017 "top" $cvn_bay9_floor3_j $a0_bay9_floor3_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor4_i [sigCrNIST2017 "bottom" $cvn_bay1_floor4_i $a0_bay1_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor4_i [sigCrNIST2017 "top" $cvn_bay1_floor4_i $a0_bay1_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor4_j [sigCrNIST2017 "bottom" $cvn_bay1_floor4_j $a0_bay1_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor4_j [sigCrNIST2017 "top" $cvn_bay1_floor4_j $a0_bay1_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor4_i [sigCrNIST2017 "bottom" $cvn_bay2_floor4_i $a0_bay2_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor4_i [sigCrNIST2017 "top" $cvn_bay2_floor4_i $a0_bay2_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor4_j [sigCrNIST2017 "bottom" $cvn_bay2_floor4_j $a0_bay2_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor4_j [sigCrNIST2017 "top" $cvn_bay2_floor4_j $a0_bay2_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor4_i [sigCrNIST2017 "bottom" $cvn_bay3_floor4_i $a0_bay3_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor4_i [sigCrNIST2017 "top" $cvn_bay3_floor4_i $a0_bay3_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor4_j [sigCrNIST2017 "bottom" $cvn_bay3_floor4_j $a0_bay3_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor4_j [sigCrNIST2017 "top" $cvn_bay3_floor4_j $a0_bay3_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor4_i [sigCrNIST2017 "bottom" $cvn_bay4_floor4_i $a0_bay4_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor4_i [sigCrNIST2017 "top" $cvn_bay4_floor4_i $a0_bay4_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor4_j [sigCrNIST2017 "bottom" $cvn_bay4_floor4_j $a0_bay4_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor4_j [sigCrNIST2017 "top" $cvn_bay4_floor4_j $a0_bay4_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor4_i [sigCrNIST2017 "bottom" $cvn_bay5_floor4_i $a0_bay5_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor4_i [sigCrNIST2017 "top" $cvn_bay5_floor4_i $a0_bay5_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor4_j [sigCrNIST2017 "bottom" $cvn_bay5_floor4_j $a0_bay5_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor4_j [sigCrNIST2017 "top" $cvn_bay5_floor4_j $a0_bay5_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor4_i [sigCrNIST2017 "bottom" $cvn_bay6_floor4_i $a0_bay6_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor4_i [sigCrNIST2017 "top" $cvn_bay6_floor4_i $a0_bay6_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor4_j [sigCrNIST2017 "bottom" $cvn_bay6_floor4_j $a0_bay6_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor4_j [sigCrNIST2017 "top" $cvn_bay6_floor4_j $a0_bay6_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor4_i [sigCrNIST2017 "bottom" $cvn_bay7_floor4_i $a0_bay7_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor4_i [sigCrNIST2017 "top" $cvn_bay7_floor4_i $a0_bay7_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor4_j [sigCrNIST2017 "bottom" $cvn_bay7_floor4_j $a0_bay7_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor4_j [sigCrNIST2017 "top" $cvn_bay7_floor4_j $a0_bay7_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor4_i [sigCrNIST2017 "bottom" $cvn_bay8_floor4_i $a0_bay8_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor4_i [sigCrNIST2017 "top" $cvn_bay8_floor4_i $a0_bay8_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor4_j [sigCrNIST2017 "bottom" $cvn_bay8_floor4_j $a0_bay8_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor4_j [sigCrNIST2017 "top" $cvn_bay8_floor4_j $a0_bay8_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor4_i [sigCrNIST2017 "bottom" $cvn_bay9_floor4_i $a0_bay9_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor4_i [sigCrNIST2017 "top" $cvn_bay9_floor4_i $a0_bay9_floor4_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor4_j [sigCrNIST2017 "bottom" $cvn_bay9_floor4_j $a0_bay9_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor4_j [sigCrNIST2017 "top" $cvn_bay9_floor4_j $a0_bay9_floor4_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor5_i [sigCrNIST2017 "bottom" $cvn_bay1_floor5_i $a0_bay1_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor5_i [sigCrNIST2017 "top" $cvn_bay1_floor5_i $a0_bay1_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor5_j [sigCrNIST2017 "bottom" $cvn_bay1_floor5_j $a0_bay1_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor5_j [sigCrNIST2017 "top" $cvn_bay1_floor5_j $a0_bay1_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor5_i [sigCrNIST2017 "bottom" $cvn_bay2_floor5_i $a0_bay2_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor5_i [sigCrNIST2017 "top" $cvn_bay2_floor5_i $a0_bay2_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor5_j [sigCrNIST2017 "bottom" $cvn_bay2_floor5_j $a0_bay2_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor5_j [sigCrNIST2017 "top" $cvn_bay2_floor5_j $a0_bay2_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor5_i [sigCrNIST2017 "bottom" $cvn_bay3_floor5_i $a0_bay3_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor5_i [sigCrNIST2017 "top" $cvn_bay3_floor5_i $a0_bay3_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor5_j [sigCrNIST2017 "bottom" $cvn_bay3_floor5_j $a0_bay3_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor5_j [sigCrNIST2017 "top" $cvn_bay3_floor5_j $a0_bay3_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor5_i [sigCrNIST2017 "bottom" $cvn_bay4_floor5_i $a0_bay4_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor5_i [sigCrNIST2017 "top" $cvn_bay4_floor5_i $a0_bay4_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor5_j [sigCrNIST2017 "bottom" $cvn_bay4_floor5_j $a0_bay4_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor5_j [sigCrNIST2017 "top" $cvn_bay4_floor5_j $a0_bay4_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor5_i [sigCrNIST2017 "bottom" $cvn_bay5_floor5_i $a0_bay5_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor5_i [sigCrNIST2017 "top" $cvn_bay5_floor5_i $a0_bay5_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor5_j [sigCrNIST2017 "bottom" $cvn_bay5_floor5_j $a0_bay5_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor5_j [sigCrNIST2017 "top" $cvn_bay5_floor5_j $a0_bay5_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor5_i [sigCrNIST2017 "bottom" $cvn_bay6_floor5_i $a0_bay6_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor5_i [sigCrNIST2017 "top" $cvn_bay6_floor5_i $a0_bay6_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor5_j [sigCrNIST2017 "bottom" $cvn_bay6_floor5_j $a0_bay6_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor5_j [sigCrNIST2017 "top" $cvn_bay6_floor5_j $a0_bay6_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor5_i [sigCrNIST2017 "bottom" $cvn_bay7_floor5_i $a0_bay7_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor5_i [sigCrNIST2017 "top" $cvn_bay7_floor5_i $a0_bay7_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor5_j [sigCrNIST2017 "bottom" $cvn_bay7_floor5_j $a0_bay7_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor5_j [sigCrNIST2017 "top" $cvn_bay7_floor5_j $a0_bay7_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor5_i [sigCrNIST2017 "bottom" $cvn_bay8_floor5_i $a0_bay8_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor5_i [sigCrNIST2017 "top" $cvn_bay8_floor5_i $a0_bay8_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor5_j [sigCrNIST2017 "bottom" $cvn_bay8_floor5_j $a0_bay8_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor5_j [sigCrNIST2017 "top" $cvn_bay8_floor5_j $a0_bay8_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor5_i [sigCrNIST2017 "bottom" $cvn_bay9_floor5_i $a0_bay9_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor5_i [sigCrNIST2017 "top" $cvn_bay9_floor5_i $a0_bay9_floor5_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor5_j [sigCrNIST2017 "bottom" $cvn_bay9_floor5_j $a0_bay9_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor5_j [sigCrNIST2017 "top" $cvn_bay9_floor5_j $a0_bay9_floor5_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor6_i [sigCrNIST2017 "bottom" $cvn_bay1_floor6_i $a0_bay1_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor6_i [sigCrNIST2017 "top" $cvn_bay1_floor6_i $a0_bay1_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor6_j [sigCrNIST2017 "bottom" $cvn_bay1_floor6_j $a0_bay1_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor6_j [sigCrNIST2017 "top" $cvn_bay1_floor6_j $a0_bay1_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor6_i [sigCrNIST2017 "bottom" $cvn_bay2_floor6_i $a0_bay2_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor6_i [sigCrNIST2017 "top" $cvn_bay2_floor6_i $a0_bay2_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor6_j [sigCrNIST2017 "bottom" $cvn_bay2_floor6_j $a0_bay2_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor6_j [sigCrNIST2017 "top" $cvn_bay2_floor6_j $a0_bay2_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor6_i [sigCrNIST2017 "bottom" $cvn_bay3_floor6_i $a0_bay3_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor6_i [sigCrNIST2017 "top" $cvn_bay3_floor6_i $a0_bay3_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor6_j [sigCrNIST2017 "bottom" $cvn_bay3_floor6_j $a0_bay3_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor6_j [sigCrNIST2017 "top" $cvn_bay3_floor6_j $a0_bay3_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor6_i [sigCrNIST2017 "bottom" $cvn_bay4_floor6_i $a0_bay4_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor6_i [sigCrNIST2017 "top" $cvn_bay4_floor6_i $a0_bay4_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor6_j [sigCrNIST2017 "bottom" $cvn_bay4_floor6_j $a0_bay4_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor6_j [sigCrNIST2017 "top" $cvn_bay4_floor6_j $a0_bay4_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor6_i [sigCrNIST2017 "bottom" $cvn_bay5_floor6_i $a0_bay5_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor6_i [sigCrNIST2017 "top" $cvn_bay5_floor6_i $a0_bay5_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor6_j [sigCrNIST2017 "bottom" $cvn_bay5_floor6_j $a0_bay5_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor6_j [sigCrNIST2017 "top" $cvn_bay5_floor6_j $a0_bay5_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor6_i [sigCrNIST2017 "bottom" $cvn_bay6_floor6_i $a0_bay6_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor6_i [sigCrNIST2017 "top" $cvn_bay6_floor6_i $a0_bay6_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor6_j [sigCrNIST2017 "bottom" $cvn_bay6_floor6_j $a0_bay6_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor6_j [sigCrNIST2017 "top" $cvn_bay6_floor6_j $a0_bay6_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor6_i [sigCrNIST2017 "bottom" $cvn_bay7_floor6_i $a0_bay7_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor6_i [sigCrNIST2017 "top" $cvn_bay7_floor6_i $a0_bay7_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor6_j [sigCrNIST2017 "bottom" $cvn_bay7_floor6_j $a0_bay7_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor6_j [sigCrNIST2017 "top" $cvn_bay7_floor6_j $a0_bay7_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor6_i [sigCrNIST2017 "bottom" $cvn_bay8_floor6_i $a0_bay8_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor6_i [sigCrNIST2017 "top" $cvn_bay8_floor6_i $a0_bay8_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor6_j [sigCrNIST2017 "bottom" $cvn_bay8_floor6_j $a0_bay8_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor6_j [sigCrNIST2017 "top" $cvn_bay8_floor6_j $a0_bay8_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor6_i [sigCrNIST2017 "bottom" $cvn_bay9_floor6_i $a0_bay9_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor6_i [sigCrNIST2017 "top" $cvn_bay9_floor6_i $a0_bay9_floor6_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor6_j [sigCrNIST2017 "bottom" $cvn_bay9_floor6_j $a0_bay9_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor6_j [sigCrNIST2017 "top" $cvn_bay9_floor6_j $a0_bay9_floor6_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor7_i [sigCrNIST2017 "bottom" $cvn_bay1_floor7_i $a0_bay1_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor7_i [sigCrNIST2017 "top" $cvn_bay1_floor7_i $a0_bay1_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor7_j [sigCrNIST2017 "bottom" $cvn_bay1_floor7_j $a0_bay1_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor7_j [sigCrNIST2017 "top" $cvn_bay1_floor7_j $a0_bay1_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor7_i [sigCrNIST2017 "bottom" $cvn_bay2_floor7_i $a0_bay2_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor7_i [sigCrNIST2017 "top" $cvn_bay2_floor7_i $a0_bay2_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor7_j [sigCrNIST2017 "bottom" $cvn_bay2_floor7_j $a0_bay2_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor7_j [sigCrNIST2017 "top" $cvn_bay2_floor7_j $a0_bay2_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor7_i [sigCrNIST2017 "bottom" $cvn_bay3_floor7_i $a0_bay3_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor7_i [sigCrNIST2017 "top" $cvn_bay3_floor7_i $a0_bay3_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor7_j [sigCrNIST2017 "bottom" $cvn_bay3_floor7_j $a0_bay3_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor7_j [sigCrNIST2017 "top" $cvn_bay3_floor7_j $a0_bay3_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor7_i [sigCrNIST2017 "bottom" $cvn_bay4_floor7_i $a0_bay4_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor7_i [sigCrNIST2017 "top" $cvn_bay4_floor7_i $a0_bay4_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor7_j [sigCrNIST2017 "bottom" $cvn_bay4_floor7_j $a0_bay4_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor7_j [sigCrNIST2017 "top" $cvn_bay4_floor7_j $a0_bay4_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor7_i [sigCrNIST2017 "bottom" $cvn_bay5_floor7_i $a0_bay5_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor7_i [sigCrNIST2017 "top" $cvn_bay5_floor7_i $a0_bay5_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor7_j [sigCrNIST2017 "bottom" $cvn_bay5_floor7_j $a0_bay5_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor7_j [sigCrNIST2017 "top" $cvn_bay5_floor7_j $a0_bay5_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor7_i [sigCrNIST2017 "bottom" $cvn_bay6_floor7_i $a0_bay6_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor7_i [sigCrNIST2017 "top" $cvn_bay6_floor7_i $a0_bay6_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor7_j [sigCrNIST2017 "bottom" $cvn_bay6_floor7_j $a0_bay6_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor7_j [sigCrNIST2017 "top" $cvn_bay6_floor7_j $a0_bay6_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor7_i [sigCrNIST2017 "bottom" $cvn_bay7_floor7_i $a0_bay7_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor7_i [sigCrNIST2017 "top" $cvn_bay7_floor7_i $a0_bay7_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor7_j [sigCrNIST2017 "bottom" $cvn_bay7_floor7_j $a0_bay7_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor7_j [sigCrNIST2017 "top" $cvn_bay7_floor7_j $a0_bay7_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor7_i [sigCrNIST2017 "bottom" $cvn_bay8_floor7_i $a0_bay8_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor7_i [sigCrNIST2017 "top" $cvn_bay8_floor7_i $a0_bay8_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor7_j [sigCrNIST2017 "bottom" $cvn_bay8_floor7_j $a0_bay8_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor7_j [sigCrNIST2017 "top" $cvn_bay8_floor7_j $a0_bay8_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor7_i [sigCrNIST2017 "bottom" $cvn_bay9_floor7_i $a0_bay9_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor7_i [sigCrNIST2017 "top" $cvn_bay9_floor7_i $a0_bay9_floor7_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor7_j [sigCrNIST2017 "bottom" $cvn_bay9_floor7_j $a0_bay9_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor7_j [sigCrNIST2017 "top" $cvn_bay9_floor7_j $a0_bay9_floor7_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor8_i [sigCrNIST2017 "bottom" $cvn_bay1_floor8_i $a0_bay1_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor8_i [sigCrNIST2017 "top" $cvn_bay1_floor8_i $a0_bay1_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor8_j [sigCrNIST2017 "bottom" $cvn_bay1_floor8_j $a0_bay1_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor8_j [sigCrNIST2017 "top" $cvn_bay1_floor8_j $a0_bay1_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor8_i [sigCrNIST2017 "bottom" $cvn_bay2_floor8_i $a0_bay2_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor8_i [sigCrNIST2017 "top" $cvn_bay2_floor8_i $a0_bay2_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor8_j [sigCrNIST2017 "bottom" $cvn_bay2_floor8_j $a0_bay2_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor8_j [sigCrNIST2017 "top" $cvn_bay2_floor8_j $a0_bay2_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor8_i [sigCrNIST2017 "bottom" $cvn_bay3_floor8_i $a0_bay3_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor8_i [sigCrNIST2017 "top" $cvn_bay3_floor8_i $a0_bay3_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor8_j [sigCrNIST2017 "bottom" $cvn_bay3_floor8_j $a0_bay3_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor8_j [sigCrNIST2017 "top" $cvn_bay3_floor8_j $a0_bay3_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor8_i [sigCrNIST2017 "bottom" $cvn_bay4_floor8_i $a0_bay4_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor8_i [sigCrNIST2017 "top" $cvn_bay4_floor8_i $a0_bay4_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor8_j [sigCrNIST2017 "bottom" $cvn_bay4_floor8_j $a0_bay4_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor8_j [sigCrNIST2017 "top" $cvn_bay4_floor8_j $a0_bay4_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor8_i [sigCrNIST2017 "bottom" $cvn_bay5_floor8_i $a0_bay5_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor8_i [sigCrNIST2017 "top" $cvn_bay5_floor8_i $a0_bay5_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor8_j [sigCrNIST2017 "bottom" $cvn_bay5_floor8_j $a0_bay5_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor8_j [sigCrNIST2017 "top" $cvn_bay5_floor8_j $a0_bay5_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor8_i [sigCrNIST2017 "bottom" $cvn_bay6_floor8_i $a0_bay6_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor8_i [sigCrNIST2017 "top" $cvn_bay6_floor8_i $a0_bay6_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor8_j [sigCrNIST2017 "bottom" $cvn_bay6_floor8_j $a0_bay6_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor8_j [sigCrNIST2017 "top" $cvn_bay6_floor8_j $a0_bay6_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor8_i [sigCrNIST2017 "bottom" $cvn_bay7_floor8_i $a0_bay7_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor8_i [sigCrNIST2017 "top" $cvn_bay7_floor8_i $a0_bay7_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor8_j [sigCrNIST2017 "bottom" $cvn_bay7_floor8_j $a0_bay7_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor8_j [sigCrNIST2017 "top" $cvn_bay7_floor8_j $a0_bay7_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor8_i [sigCrNIST2017 "bottom" $cvn_bay8_floor8_i $a0_bay8_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor8_i [sigCrNIST2017 "top" $cvn_bay8_floor8_i $a0_bay8_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor8_j [sigCrNIST2017 "bottom" $cvn_bay8_floor8_j $a0_bay8_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor8_j [sigCrNIST2017 "top" $cvn_bay8_floor8_j $a0_bay8_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor8_i [sigCrNIST2017 "bottom" $cvn_bay9_floor8_i $a0_bay9_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor8_i [sigCrNIST2017 "top" $cvn_bay9_floor8_i $a0_bay9_floor8_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor8_j [sigCrNIST2017 "bottom" $cvn_bay9_floor8_j $a0_bay9_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor8_j [sigCrNIST2017 "top" $cvn_bay9_floor8_j $a0_bay9_floor8_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor9_i [sigCrNIST2017 "bottom" $cvn_bay1_floor9_i $a0_bay1_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor9_i [sigCrNIST2017 "top" $cvn_bay1_floor9_i $a0_bay1_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor9_j [sigCrNIST2017 "bottom" $cvn_bay1_floor9_j $a0_bay1_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor9_j [sigCrNIST2017 "top" $cvn_bay1_floor9_j $a0_bay1_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor9_i [sigCrNIST2017 "bottom" $cvn_bay2_floor9_i $a0_bay2_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor9_i [sigCrNIST2017 "top" $cvn_bay2_floor9_i $a0_bay2_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor9_j [sigCrNIST2017 "bottom" $cvn_bay2_floor9_j $a0_bay2_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor9_j [sigCrNIST2017 "top" $cvn_bay2_floor9_j $a0_bay2_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor9_i [sigCrNIST2017 "bottom" $cvn_bay3_floor9_i $a0_bay3_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor9_i [sigCrNIST2017 "top" $cvn_bay3_floor9_i $a0_bay3_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor9_j [sigCrNIST2017 "bottom" $cvn_bay3_floor9_j $a0_bay3_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor9_j [sigCrNIST2017 "top" $cvn_bay3_floor9_j $a0_bay3_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor9_i [sigCrNIST2017 "bottom" $cvn_bay4_floor9_i $a0_bay4_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor9_i [sigCrNIST2017 "top" $cvn_bay4_floor9_i $a0_bay4_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor9_j [sigCrNIST2017 "bottom" $cvn_bay4_floor9_j $a0_bay4_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor9_j [sigCrNIST2017 "top" $cvn_bay4_floor9_j $a0_bay4_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor9_i [sigCrNIST2017 "bottom" $cvn_bay5_floor9_i $a0_bay5_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor9_i [sigCrNIST2017 "top" $cvn_bay5_floor9_i $a0_bay5_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor9_j [sigCrNIST2017 "bottom" $cvn_bay5_floor9_j $a0_bay5_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor9_j [sigCrNIST2017 "top" $cvn_bay5_floor9_j $a0_bay5_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor9_i [sigCrNIST2017 "bottom" $cvn_bay6_floor9_i $a0_bay6_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor9_i [sigCrNIST2017 "top" $cvn_bay6_floor9_i $a0_bay6_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor9_j [sigCrNIST2017 "bottom" $cvn_bay6_floor9_j $a0_bay6_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor9_j [sigCrNIST2017 "top" $cvn_bay6_floor9_j $a0_bay6_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor9_i [sigCrNIST2017 "bottom" $cvn_bay7_floor9_i $a0_bay7_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor9_i [sigCrNIST2017 "top" $cvn_bay7_floor9_i $a0_bay7_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor9_j [sigCrNIST2017 "bottom" $cvn_bay7_floor9_j $a0_bay7_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor9_j [sigCrNIST2017 "top" $cvn_bay7_floor9_j $a0_bay7_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor9_i [sigCrNIST2017 "bottom" $cvn_bay8_floor9_i $a0_bay8_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor9_i [sigCrNIST2017 "top" $cvn_bay8_floor9_i $a0_bay8_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor9_j [sigCrNIST2017 "bottom" $cvn_bay8_floor9_j $a0_bay8_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor9_j [sigCrNIST2017 "top" $cvn_bay8_floor9_j $a0_bay8_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor9_i [sigCrNIST2017 "bottom" $cvn_bay9_floor9_i $a0_bay9_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor9_i [sigCrNIST2017 "top" $cvn_bay9_floor9_i $a0_bay9_floor9_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor9_j [sigCrNIST2017 "bottom" $cvn_bay9_floor9_j $a0_bay9_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor9_j [sigCrNIST2017 "top" $cvn_bay9_floor9_j $a0_bay9_floor9_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor10_i [sigCrNIST2017 "bottom" $cvn_bay1_floor10_i $a0_bay1_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor10_i [sigCrNIST2017 "top" $cvn_bay1_floor10_i $a0_bay1_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay1_floor10_j [sigCrNIST2017 "bottom" $cvn_bay1_floor10_j $a0_bay1_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay1_floor10_j [sigCrNIST2017 "top" $cvn_bay1_floor10_j $a0_bay1_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor10_i [sigCrNIST2017 "bottom" $cvn_bay2_floor10_i $a0_bay2_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor10_i [sigCrNIST2017 "top" $cvn_bay2_floor10_i $a0_bay2_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor10_j [sigCrNIST2017 "bottom" $cvn_bay2_floor10_j $a0_bay2_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor10_j [sigCrNIST2017 "top" $cvn_bay2_floor10_j $a0_bay2_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor10_i [sigCrNIST2017 "bottom" $cvn_bay3_floor10_i $a0_bay3_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor10_i [sigCrNIST2017 "top" $cvn_bay3_floor10_i $a0_bay3_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor10_j [sigCrNIST2017 "bottom" $cvn_bay3_floor10_j $a0_bay3_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor10_j [sigCrNIST2017 "top" $cvn_bay3_floor10_j $a0_bay3_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor10_i [sigCrNIST2017 "bottom" $cvn_bay4_floor10_i $a0_bay4_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor10_i [sigCrNIST2017 "top" $cvn_bay4_floor10_i $a0_bay4_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor10_j [sigCrNIST2017 "bottom" $cvn_bay4_floor10_j $a0_bay4_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor10_j [sigCrNIST2017 "top" $cvn_bay4_floor10_j $a0_bay4_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor10_i [sigCrNIST2017 "bottom" $cvn_bay5_floor10_i $a0_bay5_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor10_i [sigCrNIST2017 "top" $cvn_bay5_floor10_i $a0_bay5_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor10_j [sigCrNIST2017 "bottom" $cvn_bay5_floor10_j $a0_bay5_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor10_j [sigCrNIST2017 "top" $cvn_bay5_floor10_j $a0_bay5_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor10_i [sigCrNIST2017 "bottom" $cvn_bay6_floor10_i $a0_bay6_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor10_i [sigCrNIST2017 "top" $cvn_bay6_floor10_i $a0_bay6_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor10_j [sigCrNIST2017 "bottom" $cvn_bay6_floor10_j $a0_bay6_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor10_j [sigCrNIST2017 "top" $cvn_bay6_floor10_j $a0_bay6_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor10_i [sigCrNIST2017 "bottom" $cvn_bay7_floor10_i $a0_bay7_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor10_i [sigCrNIST2017 "top" $cvn_bay7_floor10_i $a0_bay7_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor10_j [sigCrNIST2017 "bottom" $cvn_bay7_floor10_j $a0_bay7_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor10_j [sigCrNIST2017 "top" $cvn_bay7_floor10_j $a0_bay7_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor10_i [sigCrNIST2017 "bottom" $cvn_bay8_floor10_i $a0_bay8_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor10_i [sigCrNIST2017 "top" $cvn_bay8_floor10_i $a0_bay8_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor10_j [sigCrNIST2017 "bottom" $cvn_bay8_floor10_j $a0_bay8_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor10_j [sigCrNIST2017 "top" $cvn_bay8_floor10_j $a0_bay8_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor10_i [sigCrNIST2017 "bottom" $cvn_bay9_floor10_i $a0_bay9_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor10_i [sigCrNIST2017 "top" $cvn_bay9_floor10_i $a0_bay9_floor10_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor10_j [sigCrNIST2017 "bottom" $cvn_bay9_floor10_j $a0_bay9_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor10_j [sigCrNIST2017 "top" $cvn_bay9_floor10_j $a0_bay9_floor10_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor11_i [sigCrNIST2017 "bottom" $cvn_bay2_floor11_i $a0_bay2_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor11_i [sigCrNIST2017 "top" $cvn_bay2_floor11_i $a0_bay2_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay2_floor11_j [sigCrNIST2017 "bottom" $cvn_bay2_floor11_j $a0_bay2_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay2_floor11_j [sigCrNIST2017 "top" $cvn_bay2_floor11_j $a0_bay2_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor11_i [sigCrNIST2017 "bottom" $cvn_bay3_floor11_i $a0_bay3_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor11_i [sigCrNIST2017 "top" $cvn_bay3_floor11_i $a0_bay3_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor11_j [sigCrNIST2017 "bottom" $cvn_bay3_floor11_j $a0_bay3_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor11_j [sigCrNIST2017 "top" $cvn_bay3_floor11_j $a0_bay3_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor11_i [sigCrNIST2017 "bottom" $cvn_bay4_floor11_i $a0_bay4_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor11_i [sigCrNIST2017 "top" $cvn_bay4_floor11_i $a0_bay4_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor11_j [sigCrNIST2017 "bottom" $cvn_bay4_floor11_j $a0_bay4_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor11_j [sigCrNIST2017 "top" $cvn_bay4_floor11_j $a0_bay4_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor11_i [sigCrNIST2017 "bottom" $cvn_bay5_floor11_i $a0_bay5_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor11_i [sigCrNIST2017 "top" $cvn_bay5_floor11_i $a0_bay5_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor11_j [sigCrNIST2017 "bottom" $cvn_bay5_floor11_j $a0_bay5_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor11_j [sigCrNIST2017 "top" $cvn_bay5_floor11_j $a0_bay5_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor11_i [sigCrNIST2017 "bottom" $cvn_bay6_floor11_i $a0_bay6_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor11_i [sigCrNIST2017 "top" $cvn_bay6_floor11_i $a0_bay6_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor11_j [sigCrNIST2017 "bottom" $cvn_bay6_floor11_j $a0_bay6_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor11_j [sigCrNIST2017 "top" $cvn_bay6_floor11_j $a0_bay6_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor11_i [sigCrNIST2017 "bottom" $cvn_bay7_floor11_i $a0_bay7_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor11_i [sigCrNIST2017 "top" $cvn_bay7_floor11_i $a0_bay7_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor11_j [sigCrNIST2017 "bottom" $cvn_bay7_floor11_j $a0_bay7_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor11_j [sigCrNIST2017 "top" $cvn_bay7_floor11_j $a0_bay7_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor11_i [sigCrNIST2017 "bottom" $cvn_bay8_floor11_i $a0_bay8_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor11_i [sigCrNIST2017 "top" $cvn_bay8_floor11_i $a0_bay8_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor11_j [sigCrNIST2017 "bottom" $cvn_bay8_floor11_j $a0_bay8_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor11_j [sigCrNIST2017 "top" $cvn_bay8_floor11_j $a0_bay8_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor11_i [sigCrNIST2017 "bottom" $cvn_bay9_floor11_i $a0_bay9_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor11_i [sigCrNIST2017 "top" $cvn_bay9_floor11_i $a0_bay9_floor11_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor11_j [sigCrNIST2017 "bottom" $cvn_bay9_floor11_j $a0_bay9_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor11_j [sigCrNIST2017 "top" $cvn_bay9_floor11_j $a0_bay9_floor11_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor12_i [sigCrNIST2017 "bottom" $cvn_bay3_floor12_i $a0_bay3_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor12_i [sigCrNIST2017 "top" $cvn_bay3_floor12_i $a0_bay3_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay3_floor12_j [sigCrNIST2017 "bottom" $cvn_bay3_floor12_j $a0_bay3_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay3_floor12_j [sigCrNIST2017 "top" $cvn_bay3_floor12_j $a0_bay3_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor12_i [sigCrNIST2017 "bottom" $cvn_bay4_floor12_i $a0_bay4_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor12_i [sigCrNIST2017 "top" $cvn_bay4_floor12_i $a0_bay4_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor12_j [sigCrNIST2017 "bottom" $cvn_bay4_floor12_j $a0_bay4_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor12_j [sigCrNIST2017 "top" $cvn_bay4_floor12_j $a0_bay4_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor12_i [sigCrNIST2017 "bottom" $cvn_bay5_floor12_i $a0_bay5_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor12_i [sigCrNIST2017 "top" $cvn_bay5_floor12_i $a0_bay5_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor12_j [sigCrNIST2017 "bottom" $cvn_bay5_floor12_j $a0_bay5_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor12_j [sigCrNIST2017 "top" $cvn_bay5_floor12_j $a0_bay5_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor12_i [sigCrNIST2017 "bottom" $cvn_bay6_floor12_i $a0_bay6_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor12_i [sigCrNIST2017 "top" $cvn_bay6_floor12_i $a0_bay6_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor12_j [sigCrNIST2017 "bottom" $cvn_bay6_floor12_j $a0_bay6_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor12_j [sigCrNIST2017 "top" $cvn_bay6_floor12_j $a0_bay6_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor12_i [sigCrNIST2017 "bottom" $cvn_bay7_floor12_i $a0_bay7_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor12_i [sigCrNIST2017 "top" $cvn_bay7_floor12_i $a0_bay7_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor12_j [sigCrNIST2017 "bottom" $cvn_bay7_floor12_j $a0_bay7_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor12_j [sigCrNIST2017 "top" $cvn_bay7_floor12_j $a0_bay7_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor12_i [sigCrNIST2017 "bottom" $cvn_bay8_floor12_i $a0_bay8_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor12_i [sigCrNIST2017 "top" $cvn_bay8_floor12_i $a0_bay8_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor12_j [sigCrNIST2017 "bottom" $cvn_bay8_floor12_j $a0_bay8_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor12_j [sigCrNIST2017 "top" $cvn_bay8_floor12_j $a0_bay8_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor12_i [sigCrNIST2017 "bottom" $cvn_bay9_floor12_i $a0_bay9_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor12_i [sigCrNIST2017 "top" $cvn_bay9_floor12_i $a0_bay9_floor12_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor12_j [sigCrNIST2017 "bottom" $cvn_bay9_floor12_j $a0_bay9_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor12_j [sigCrNIST2017 "top" $cvn_bay9_floor12_j $a0_bay9_floor12_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor13_i [sigCrNIST2017 "bottom" $cvn_bay4_floor13_i $a0_bay4_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor13_i [sigCrNIST2017 "top" $cvn_bay4_floor13_i $a0_bay4_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay4_floor13_j [sigCrNIST2017 "bottom" $cvn_bay4_floor13_j $a0_bay4_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay4_floor13_j [sigCrNIST2017 "top" $cvn_bay4_floor13_j $a0_bay4_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor13_i [sigCrNIST2017 "bottom" $cvn_bay5_floor13_i $a0_bay5_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor13_i [sigCrNIST2017 "top" $cvn_bay5_floor13_i $a0_bay5_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay5_floor13_j [sigCrNIST2017 "bottom" $cvn_bay5_floor13_j $a0_bay5_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay5_floor13_j [sigCrNIST2017 "top" $cvn_bay5_floor13_j $a0_bay5_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor13_i [sigCrNIST2017 "bottom" $cvn_bay6_floor13_i $a0_bay6_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor13_i [sigCrNIST2017 "top" $cvn_bay6_floor13_i $a0_bay6_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor13_j [sigCrNIST2017 "bottom" $cvn_bay6_floor13_j $a0_bay6_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor13_j [sigCrNIST2017 "top" $cvn_bay6_floor13_j $a0_bay6_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor13_i [sigCrNIST2017 "bottom" $cvn_bay7_floor13_i $a0_bay7_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor13_i [sigCrNIST2017 "top" $cvn_bay7_floor13_i $a0_bay7_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor13_j [sigCrNIST2017 "bottom" $cvn_bay7_floor13_j $a0_bay7_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor13_j [sigCrNIST2017 "top" $cvn_bay7_floor13_j $a0_bay7_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor13_i [sigCrNIST2017 "bottom" $cvn_bay8_floor13_i $a0_bay8_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor13_i [sigCrNIST2017 "top" $cvn_bay8_floor13_i $a0_bay8_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor13_j [sigCrNIST2017 "bottom" $cvn_bay8_floor13_j $a0_bay8_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor13_j [sigCrNIST2017 "top" $cvn_bay8_floor13_j $a0_bay8_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor13_i [sigCrNIST2017 "bottom" $cvn_bay9_floor13_i $a0_bay9_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor13_i [sigCrNIST2017 "top" $cvn_bay9_floor13_i $a0_bay9_floor13_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor13_j [sigCrNIST2017 "bottom" $cvn_bay9_floor13_j $a0_bay9_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor13_j [sigCrNIST2017 "top" $cvn_bay9_floor13_j $a0_bay9_floor13_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor14_i [sigCrNIST2017 "bottom" $cvn_bay6_floor14_i $a0_bay6_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor14_i [sigCrNIST2017 "top" $cvn_bay6_floor14_i $a0_bay6_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor14_j [sigCrNIST2017 "bottom" $cvn_bay6_floor14_j $a0_bay6_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor14_j [sigCrNIST2017 "top" $cvn_bay6_floor14_j $a0_bay6_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor14_i [sigCrNIST2017 "bottom" $cvn_bay7_floor14_i $a0_bay7_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor14_i [sigCrNIST2017 "top" $cvn_bay7_floor14_i $a0_bay7_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor14_j [sigCrNIST2017 "bottom" $cvn_bay7_floor14_j $a0_bay7_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor14_j [sigCrNIST2017 "top" $cvn_bay7_floor14_j $a0_bay7_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor14_i [sigCrNIST2017 "bottom" $cvn_bay8_floor14_i $a0_bay8_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor14_i [sigCrNIST2017 "top" $cvn_bay8_floor14_i $a0_bay8_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor14_j [sigCrNIST2017 "bottom" $cvn_bay8_floor14_j $a0_bay8_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor14_j [sigCrNIST2017 "top" $cvn_bay8_floor14_j $a0_bay8_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor14_i [sigCrNIST2017 "bottom" $cvn_bay9_floor14_i $a0_bay9_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor14_i [sigCrNIST2017 "top" $cvn_bay9_floor14_i $a0_bay9_floor14_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor14_j [sigCrNIST2017 "bottom" $cvn_bay9_floor14_j $a0_bay9_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor14_j [sigCrNIST2017 "top" $cvn_bay9_floor14_j $a0_bay9_floor14_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor15_i [sigCrNIST2017 "bottom" $cvn_bay6_floor15_i $a0_bay6_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor15_i [sigCrNIST2017 "top" $cvn_bay6_floor15_i $a0_bay6_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor15_j [sigCrNIST2017 "bottom" $cvn_bay6_floor15_j $a0_bay6_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor15_j [sigCrNIST2017 "top" $cvn_bay6_floor15_j $a0_bay6_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor15_i [sigCrNIST2017 "bottom" $cvn_bay7_floor15_i $a0_bay7_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor15_i [sigCrNIST2017 "top" $cvn_bay7_floor15_i $a0_bay7_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor15_j [sigCrNIST2017 "bottom" $cvn_bay7_floor15_j $a0_bay7_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor15_j [sigCrNIST2017 "top" $cvn_bay7_floor15_j $a0_bay7_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor15_i [sigCrNIST2017 "bottom" $cvn_bay8_floor15_i $a0_bay8_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor15_i [sigCrNIST2017 "top" $cvn_bay8_floor15_i $a0_bay8_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor15_j [sigCrNIST2017 "bottom" $cvn_bay8_floor15_j $a0_bay8_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor15_j [sigCrNIST2017 "top" $cvn_bay8_floor15_j $a0_bay8_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor15_i [sigCrNIST2017 "bottom" $cvn_bay9_floor15_i $a0_bay9_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor15_i [sigCrNIST2017 "top" $cvn_bay9_floor15_i $a0_bay9_floor15_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor15_j [sigCrNIST2017 "bottom" $cvn_bay9_floor15_j $a0_bay9_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor15_j [sigCrNIST2017 "top" $cvn_bay9_floor15_j $a0_bay9_floor15_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor16_i [sigCrNIST2017 "bottom" $cvn_bay6_floor16_i $a0_bay6_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor16_i [sigCrNIST2017 "top" $cvn_bay6_floor16_i $a0_bay6_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor16_j [sigCrNIST2017 "bottom" $cvn_bay6_floor16_j $a0_bay6_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor16_j [sigCrNIST2017 "top" $cvn_bay6_floor16_j $a0_bay6_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor16_i [sigCrNIST2017 "bottom" $cvn_bay7_floor16_i $a0_bay7_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor16_i [sigCrNIST2017 "top" $cvn_bay7_floor16_i $a0_bay7_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor16_j [sigCrNIST2017 "bottom" $cvn_bay7_floor16_j $a0_bay7_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor16_j [sigCrNIST2017 "top" $cvn_bay7_floor16_j $a0_bay7_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor16_i [sigCrNIST2017 "bottom" $cvn_bay8_floor16_i $a0_bay8_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor16_i [sigCrNIST2017 "top" $cvn_bay8_floor16_i $a0_bay8_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor16_j [sigCrNIST2017 "bottom" $cvn_bay8_floor16_j $a0_bay8_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor16_j [sigCrNIST2017 "top" $cvn_bay8_floor16_j $a0_bay8_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor16_i [sigCrNIST2017 "bottom" $cvn_bay9_floor16_i $a0_bay9_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor16_i [sigCrNIST2017 "top" $cvn_bay9_floor16_i $a0_bay9_floor16_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor16_j [sigCrNIST2017 "bottom" $cvn_bay9_floor16_j $a0_bay9_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor16_j [sigCrNIST2017 "top" $cvn_bay9_floor16_j $a0_bay9_floor16_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor17_i [sigCrNIST2017 "bottom" $cvn_bay6_floor17_i $a0_bay6_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor17_i [sigCrNIST2017 "top" $cvn_bay6_floor17_i $a0_bay6_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor17_j [sigCrNIST2017 "bottom" $cvn_bay6_floor17_j $a0_bay6_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor17_j [sigCrNIST2017 "top" $cvn_bay6_floor17_j $a0_bay6_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor17_i [sigCrNIST2017 "bottom" $cvn_bay7_floor17_i $a0_bay7_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor17_i [sigCrNIST2017 "top" $cvn_bay7_floor17_i $a0_bay7_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor17_j [sigCrNIST2017 "bottom" $cvn_bay7_floor17_j $a0_bay7_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor17_j [sigCrNIST2017 "top" $cvn_bay7_floor17_j $a0_bay7_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor17_i [sigCrNIST2017 "bottom" $cvn_bay8_floor17_i $a0_bay8_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor17_i [sigCrNIST2017 "top" $cvn_bay8_floor17_i $a0_bay8_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor17_j [sigCrNIST2017 "bottom" $cvn_bay8_floor17_j $a0_bay8_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor17_j [sigCrNIST2017 "top" $cvn_bay8_floor17_j $a0_bay8_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor17_i [sigCrNIST2017 "bottom" $cvn_bay9_floor17_i $a0_bay9_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor17_i [sigCrNIST2017 "top" $cvn_bay9_floor17_i $a0_bay9_floor17_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor17_j [sigCrNIST2017 "bottom" $cvn_bay9_floor17_j $a0_bay9_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor17_j [sigCrNIST2017 "top" $cvn_bay9_floor17_j $a0_bay9_floor17_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor18_i [sigCrNIST2017 "bottom" $cvn_bay6_floor18_i $a0_bay6_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor18_i [sigCrNIST2017 "top" $cvn_bay6_floor18_i $a0_bay6_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay6_floor18_j [sigCrNIST2017 "bottom" $cvn_bay6_floor18_j $a0_bay6_floor18_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay6_floor18_j [sigCrNIST2017 "top" $cvn_bay6_floor18_j $a0_bay6_floor18_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor18_i [sigCrNIST2017 "bottom" $cvn_bay7_floor18_i $a0_bay7_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor18_i [sigCrNIST2017 "top" $cvn_bay7_floor18_i $a0_bay7_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay7_floor18_j [sigCrNIST2017 "bottom" $cvn_bay7_floor18_j $a0_bay7_floor18_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay7_floor18_j [sigCrNIST2017 "top" $cvn_bay7_floor18_j $a0_bay7_floor18_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor18_i [sigCrNIST2017 "bottom" $cvn_bay8_floor18_i $a0_bay8_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor18_i [sigCrNIST2017 "top" $cvn_bay8_floor18_i $a0_bay8_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay8_floor18_j [sigCrNIST2017 "bottom" $cvn_bay8_floor18_j $a0_bay8_floor18_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay8_floor18_j [sigCrNIST2017 "top" $cvn_bay8_floor18_j $a0_bay8_floor18_j $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor18_i [sigCrNIST2017 "bottom" $cvn_bay9_floor18_i $a0_bay9_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor18_i [sigCrNIST2017 "top" $cvn_bay9_floor18_i $a0_bay9_floor18_i $alpha $T_service_F $Es $FyWeld];
set sigCrB_bay9_floor18_j [sigCrNIST2017 "bottom" $cvn_bay9_floor18_j $a0_bay9_floor18_j $alpha $T_service_F $Es $FyWeld];
set sigCrT_bay9_floor18_j [sigCrNIST2017 "top" $cvn_bay9_floor18_j $a0_bay9_floor18_j $alpha $T_service_F $Es $FyWeld];

####################################################################################################
#                                                  NODES                                           #
####################################################################################################

# COMMAND SYNTAX 
# node $NodeID  $X-Coordinate  $Y-Coordinate;

# SUPPORT NODES
node 10100   $Axis1  $Floor1;
node 10200   $Axis2  $Floor1;
node 10300   $Axis3  $Floor1;
node 10400   $Axis4  $Floor1;
node 10500   $Axis5  $Floor1;
node 10600   $Axis6  $Floor1;
node 10700   $Axis7  $Floor1;
node 10800   $Axis8  $Floor1;
node 10900   $Axis9  $Floor1;
node 11000   $Axis10  $Floor1;

# EGF COLUMN GRID NODES
node 11100   $Axis11  $Floor1; node 11200   $Axis12  $Floor1; 
node 21100   $Axis11  $Floor2; node 21200   $Axis12  $Floor2; 
node 31100   $Axis11  $Floor3; node 31200   $Axis12  $Floor3; 
node 41100   $Axis11  $Floor4; node 41200   $Axis12  $Floor4; 
node 51100   $Axis11  $Floor5; node 51200   $Axis12  $Floor5; 
node 61100   $Axis11  $Floor6; node 61200   $Axis12  $Floor6; 
node 71100   $Axis11  $Floor7; node 71200   $Axis12  $Floor7; 
node 81100   $Axis11  $Floor8; node 81200   $Axis12  $Floor8; 
node 91100   $Axis11  $Floor9; node 91200   $Axis12  $Floor9; 
node 101100   $Axis11  $Floor10; node 101200   $Axis12  $Floor10; 
node 111100   $Axis11  $Floor11; node 111200   $Axis12  $Floor11; 
node 121100   $Axis11  $Floor12; node 121200   $Axis12  $Floor12; 
node 131100   $Axis11  $Floor13; node 131200   $Axis12  $Floor13; 
node 141100   $Axis11  $Floor14; node 141200   $Axis12  $Floor14; 
node 151100   $Axis11  $Floor15; node 151200   $Axis12  $Floor15; 
node 161100   $Axis11  $Floor16; node 161200   $Axis12  $Floor16; 
node 171100   $Axis11  $Floor17; node 171200   $Axis12  $Floor17; 
node 181100   $Axis11  $Floor18; node 181200   $Axis12  $Floor18; 

# EGF BEAM NODES
node 21104  $Axis11  $Floor2; node 21202  $Axis12  $Floor2; 
node 31104  $Axis11  $Floor3; node 31202  $Axis12  $Floor3; 
node 41104  $Axis11  $Floor4; node 41202  $Axis12  $Floor4; 
node 51104  $Axis11  $Floor5; node 51202  $Axis12  $Floor5; 
node 61104  $Axis11  $Floor6; node 61202  $Axis12  $Floor6; 
node 71104  $Axis11  $Floor7; node 71202  $Axis12  $Floor7; 
node 81104  $Axis11  $Floor8; node 81202  $Axis12  $Floor8; 
node 91104  $Axis11  $Floor9; node 91202  $Axis12  $Floor9; 
node 101104  $Axis11  $Floor10; node 101202  $Axis12  $Floor10; 
node 111104  $Axis11  $Floor11; node 111202  $Axis12  $Floor11; 
node 121104  $Axis11  $Floor12; node 121202  $Axis12  $Floor12; 
node 131104  $Axis11  $Floor13; node 131202  $Axis12  $Floor13; 
node 141104  $Axis11  $Floor14; node 141202  $Axis12  $Floor14; 
node 151104  $Axis11  $Floor15; node 151202  $Axis12  $Floor15; 
node 161104  $Axis11  $Floor16; node 161202  $Axis12  $Floor16; 
node 171104  $Axis11  $Floor17; node 171202  $Axis12  $Floor17; 
node 181104  $Axis11  $Floor18; node 181202  $Axis12  $Floor18; 

###################################################################################################
#                                  PANEL ZONE NODES & ELEMENTS                                    #
###################################################################################################

# PANEL ZONE NODES AND ELASTIC ELEMENTS
# Command Syntax; 
# ConstructPanel_Rectangle Axis Floor X_Axis Y_Floor E A_Panel I_Panel d_Col d_Beam transfTag 

# Panel zones floor2
ConstructPanel_Rectangle  1 2 $Axis1 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  2 2 $Axis2 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  3 2 $Axis3 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  4 2 $Axis4 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  5 2 $Axis5 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  6 2 $Axis6 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  7 2 $Axis7 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  8 2 $Axis8 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  9 2 $Axis9 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  10 2 $Axis10 $Floor2 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;

# Panel zones floor3
ConstructPanel_Rectangle  1 3 $Axis1 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  2 3 $Axis2 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  3 3 $Axis3 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  4 3 $Axis4 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  5 3 $Axis5 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  6 3 $Axis6 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  7 3 $Axis7 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  8 3 $Axis8 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  9 3 $Axis9 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  10 3 $Axis10 $Floor3 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;

# Panel zones floor4
ConstructPanel_Rectangle  1 4 $Axis1 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  2 4 $Axis2 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  3 4 $Axis3 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  4 4 $Axis4 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  5 4 $Axis5 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  6 4 $Axis6 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  7 4 $Axis7 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  8 4 $Axis8 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  9 4 $Axis9 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;
ConstructPanel_Rectangle  10 4 $Axis10 $Floor4 $Es $A_Stiff $I_Stiff 18.70 22.10 $trans_selected;

# Panel zones floor5
ConstructPanel_Rectangle  1 5 $Axis1 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  2 5 $Axis2 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  3 5 $Axis3 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  4 5 $Axis4 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  5 5 $Axis5 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  6 5 $Axis6 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  7 5 $Axis7 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  8 5 $Axis8 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  9 5 $Axis9 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;
ConstructPanel_Rectangle  10 5 $Axis10 $Floor5 $Es $A_Stiff $I_Stiff 18.30 30.80 $trans_selected;

# Panel zones floor6
ConstructPanel_Rectangle  1 6 $Axis1 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  2 6 $Axis2 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  3 6 $Axis3 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  4 6 $Axis4 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  5 6 $Axis5 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  6 6 $Axis6 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  7 6 $Axis7 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  8 6 $Axis8 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  9 6 $Axis9 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;
ConstructPanel_Rectangle  10 6 $Axis10 $Floor6 $Es $A_Stiff $I_Stiff 18.30 30.60 $trans_selected;

# Panel zones floor7
ConstructPanel_Rectangle  1 7 $Axis1 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  2 7 $Axis2 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  3 7 $Axis3 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  4 7 $Axis4 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  5 7 $Axis5 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  6 7 $Axis6 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  7 7 $Axis7 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  8 7 $Axis8 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  9 7 $Axis9 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  10 7 $Axis10 $Floor7 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;

# Panel zones floor8
ConstructPanel_Rectangle  1 8 $Axis1 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  2 8 $Axis2 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  3 8 $Axis3 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  4 8 $Axis4 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  5 8 $Axis5 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  6 8 $Axis6 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  7 8 $Axis7 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  8 8 $Axis8 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  9 8 $Axis9 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;
ConstructPanel_Rectangle  10 8 $Axis10 $Floor8 $Es $A_Stiff $I_Stiff 17.90 30.60 $trans_selected;

# Panel zones floor9
ConstructPanel_Rectangle  1 9 $Axis1 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  2 9 $Axis2 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  3 9 $Axis3 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  4 9 $Axis4 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  5 9 $Axis5 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  6 9 $Axis6 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  7 9 $Axis7 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  8 9 $Axis8 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  9 9 $Axis9 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;
ConstructPanel_Rectangle  10 9 $Axis10 $Floor9 $Es $A_Stiff $I_Stiff 17.50 30.60 $trans_selected;

# Panel zones floor10
ConstructPanel_Rectangle  1 10 $Axis1 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  2 10 $Axis2 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  3 10 $Axis3 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  4 10 $Axis4 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  5 10 $Axis5 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  6 10 $Axis6 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  7 10 $Axis7 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  8 10 $Axis8 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  9 10 $Axis9 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  10 10 $Axis10 $Floor10 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;

# Panel zones floor11
ConstructPanel_Rectangle  2 11 $Axis2 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  3 11 $Axis3 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  4 11 $Axis4 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  5 11 $Axis5 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  6 11 $Axis6 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  7 11 $Axis7 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  8 11 $Axis8 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  9 11 $Axis9 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  10 11 $Axis10 $Floor11 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;

# Panel zones floor12
ConstructPanel_Rectangle  3 12 $Axis3 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  4 12 $Axis4 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  5 12 $Axis5 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  6 12 $Axis6 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  7 12 $Axis7 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  8 12 $Axis8 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  9 12 $Axis9 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  10 12 $Axis10 $Floor12 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;

# Panel zones floor13
ConstructPanel_Rectangle  4 13 $Axis4 $Floor13 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  5 13 $Axis5 $Floor13 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  6 13 $Axis6 $Floor13 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  7 13 $Axis7 $Floor13 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  8 13 $Axis8 $Floor13 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  9 13 $Axis9 $Floor13 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;
ConstructPanel_Rectangle  10 13 $Axis10 $Floor13 $Es $A_Stiff $I_Stiff 17.50 23.70 $trans_selected;

# Panel zones floor14
ConstructPanel_Rectangle  6 14 $Axis6 $Floor14 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  7 14 $Axis7 $Floor14 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  8 14 $Axis8 $Floor14 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  9 14 $Axis9 $Floor14 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  10 14 $Axis10 $Floor14 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;

# Panel zones floor15
ConstructPanel_Rectangle  6 15 $Axis6 $Floor15 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  7 15 $Axis7 $Floor15 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  8 15 $Axis8 $Floor15 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  9 15 $Axis9 $Floor15 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  10 15 $Axis10 $Floor15 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;

# Panel zones floor16
ConstructPanel_Rectangle  6 16 $Axis6 $Floor16 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  7 16 $Axis7 $Floor16 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  8 16 $Axis8 $Floor16 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  9 16 $Axis9 $Floor16 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  10 16 $Axis10 $Floor16 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;

# Panel zones floor17
ConstructPanel_Rectangle  6 17 $Axis6 $Floor17 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  7 17 $Axis7 $Floor17 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  8 17 $Axis8 $Floor17 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  9 17 $Axis9 $Floor17 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  10 17 $Axis10 $Floor17 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;

# Panel zones floor18
ConstructPanel_Rectangle  6 18 $Axis6 $Floor18 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  7 18 $Axis7 $Floor18 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  8 18 $Axis8 $Floor18 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  9 18 $Axis9 $Floor18 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;
ConstructPanel_Rectangle  10 18 $Axis10 $Floor18 $Es $A_Stiff $I_Stiff 17.10 23.40 $trans_selected;


####################################################################################################
#                                          PANEL ZONE SPRINGS                                      #
####################################################################################################

# COMMAND SYNTAX 
# PanelZoneSpring    eleID NodeI NodeJ Es mu Fy dc bc tcf tcw tdp db Ic Acol alpha Pr trib ts pzModelTag isExterior Composite
# Panel zones floor2
PanelZoneSpring 9020100 4020109 4020110 $Es $mu $FyCol 18.70 16.70  3.04  1.88  0.00 22.10 6600.00 125.000 $SH_PZ 374.264 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9020200 4020209 4020210 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 415.612 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020300 4020309 4020310 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 456.489 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020400 4020409 4020410 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 496.772 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020500 4020509 4020510 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 496.772 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020600 4020609 4020610 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 725.341 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9020700 4020709 4020710 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 725.341 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9020800 4020809 4020810 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 725.341 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9020900 4020909 4020910 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 725.341 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9021000 4021009 4021010 $Es $mu $FyCol 18.70 16.70  3.04  1.88  0.00 22.10 6600.00 125.000 $SH_PZ 725.341 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor3
PanelZoneSpring 9030100 4030109 4030110 $Es $mu $FyCol 18.70 16.70  3.04  1.88  0.00 22.10 6600.00 125.000 $SH_PZ 332.485 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9030200 4030209 4030210 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 373.833 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030300 4030309 4030310 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 414.710 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030400 4030409 4030410 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 454.993 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030500 4030509 4030510 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 454.993 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030600 4030609 4030610 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 683.562 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030700 4030709 4030710 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 683.562 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030800 4030809 4030810 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 683.562 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9030900 4030909 4030910 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 683.562 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9031000 4031009 4031010 $Es $mu $FyCol 18.70 16.70  3.04  1.88  0.00 22.10 6600.00 125.000 $SH_PZ 683.562 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor4
PanelZoneSpring 9040100 4040109 4040110 $Es $mu $FyCol 18.70 16.70  3.04  1.88  0.00 22.10 6600.00 125.000 $SH_PZ 290.876 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9040200 4040209 4040210 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 332.223 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040300 4040309 4040310 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 373.101 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040400 4040409 4040410 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 413.383 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040500 4040509 4040510 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 413.383 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040600 4040609 4040610 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 641.953 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040700 4040709 4040710 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 641.953 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040800 4040809 4040810 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 641.953 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9040900 4040909 4040910 $Es $mu $FyCol 18.70 16.70  3.04  1.88  1.00 22.10 6600.00 125.000 $SH_PZ 641.953 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9041000 4041009 4041010 $Es $mu $FyCol 18.70 16.70  3.04  1.88  0.00 22.10 6600.00 125.000 $SH_PZ 641.953 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor5
PanelZoneSpring 9050100 4050109 4050110 $Es $mu $FyCol 18.30 16.60  2.85  1.77  0.00 30.80 6000.00 117.000 $SH_PZ 249.266 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9050200 4050209 4050210 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 290.614 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050300 4050309 4050310 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 331.492 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050400 4050409 4050410 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 371.774 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050500 4050509 4050510 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 371.774 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050600 4050609 4050610 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 600.344 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050700 4050709 4050710 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 600.344 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050800 4050809 4050810 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 600.344 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9050900 4050909 4050910 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.80 6000.00 117.000 $SH_PZ 600.344 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9051000 4051009 4051010 $Es $mu $FyCol 18.30 16.60  2.85  1.77  0.00 30.80 6000.00 117.000 $SH_PZ 600.344 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor6
PanelZoneSpring 9060100 4060109 4060110 $Es $mu $FyCol 18.30 16.60  2.85  1.77  0.00 30.60 6000.00 117.000 $SH_PZ 207.657 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9060200 4060209 4060210 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 249.005 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060300 4060309 4060310 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 289.882 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060400 4060409 4060410 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 330.165 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060500 4060509 4060510 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 330.165 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060600 4060609 4060610 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 558.734 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060700 4060709 4060710 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 558.734 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060800 4060809 4060810 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 558.734 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9060900 4060909 4060910 $Es $mu $FyCol 18.30 16.60  2.85  1.77  1.00 30.60 6000.00 117.000 $SH_PZ 558.734 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9061000 4061009 4061010 $Es $mu $FyCol 18.30 16.60  2.85  1.77  0.00 30.60 6000.00 117.000 $SH_PZ 558.734 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor7
PanelZoneSpring 9070100 4070109 4070110 $Es $mu $FyCol 17.90 16.50  2.66  1.66  0.00 30.60 5440.00 109.000 $SH_PZ 166.048 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9070200 4070209 4070210 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 207.395 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070300 4070309 4070310 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 248.273 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070400 4070409 4070410 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 288.555 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070500 4070509 4070510 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 288.555 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070600 4070609 4070610 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 517.125 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070700 4070709 4070710 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 517.125 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070800 4070809 4070810 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 517.125 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9070900 4070909 4070910 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 517.125 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9071000 4071009 4071010 $Es $mu $FyCol 17.90 16.50  2.66  1.66  0.00 30.60 5440.00 109.000 $SH_PZ 517.125 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor8
PanelZoneSpring 9080100 4080109 4080110 $Es $mu $FyCol 17.90 16.50  2.66  1.66  0.00 30.60 5440.00 109.000 $SH_PZ 124.438 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9080200 4080209 4080210 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 165.786 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080300 4080309 4080310 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 206.664 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080400 4080409 4080410 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 246.946 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080500 4080509 4080510 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 246.946 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080600 4080609 4080610 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 475.516 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080700 4080709 4080710 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 475.516 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080800 4080809 4080810 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 475.516 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9080900 4080909 4080910 $Es $mu $FyCol 17.90 16.50  2.66  1.66  1.00 30.60 5440.00 109.000 $SH_PZ 475.516 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9081000 4081009 4081010 $Es $mu $FyCol 17.90 16.50  2.66  1.66  0.00 30.60 5440.00 109.000 $SH_PZ 475.516 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor9
PanelZoneSpring 9090100 4090109 4090110 $Es $mu $FyCol 17.50 16.40  2.47  1.54  0.00 30.60 4900.00 101.000 $SH_PZ 82.829 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9090200 4090209 4090210 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 124.177 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090300 4090309 4090310 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 165.054 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090400 4090409 4090410 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 205.337 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090500 4090509 4090510 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 205.337 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090600 4090609 4090610 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 433.906 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090700 4090709 4090710 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 433.906 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090800 4090809 4090810 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 433.906 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9090900 4090909 4090910 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 30.60 4900.00 101.000 $SH_PZ 433.906 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9091000 4091009 4091010 $Es $mu $FyCol 17.50 16.40  2.47  1.54  0.00 30.60 4900.00 101.000 $SH_PZ 433.906 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor10
PanelZoneSpring 9100100 4100109 4100110 $Es $mu $FyCol 17.50 16.40  2.47  1.54  0.00 23.70 4900.00 101.000 $SH_PZ 41.728 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9100200 4100209 4100210 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 83.076 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9100300 4100309 4100310 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 123.953 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9100400 4100409 4100410 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 164.236 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9100500 4100509 4100510 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 164.236 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9100600 4100609 4100610 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 392.806 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9100700 4100709 4100710 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 392.806 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9100800 4100809 4100810 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 392.806 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9100900 4100909 4100910 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 392.806 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9101000 4101009 4101010 $Es $mu $FyCol 17.50 16.40  2.47  1.54  0.00 23.70 4900.00 101.000 $SH_PZ 392.806 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor11
PanelZoneSpring 9110200 4110209 4110210 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 41.348 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9110300 4110309 4110310 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 82.225 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9110400 4110409 4110410 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 122.508 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9110500 4110509 4110510 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 122.508 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9110600 4110609 4110610 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 351.077 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9110700 4110709 4110710 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 351.077 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9110800 4110809 4110810 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 351.077 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9110900 4110909 4110910 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 351.077 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9111000 4111009 4111010 $Es $mu $FyCol 17.50 16.40  2.47  1.54  0.00 23.70 4900.00 101.000 $SH_PZ 351.077 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor12
PanelZoneSpring 9120300 4120309 4120310 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 40.877 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9120400 4120409 4120410 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 81.160 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9120500 4120509 4120510 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 81.160 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9120600 4120609 4120610 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 309.730 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9120700 4120709 4120710 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 309.730 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9120800 4120809 4120810 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 309.730 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9120900 4120909 4120910 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 309.730 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9121000 4121009 4121010 $Es $mu $FyCol 17.50 16.40  2.47  1.54  0.00 23.70 4900.00 101.000 $SH_PZ 309.730 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor13
PanelZoneSpring 9130400 4130409 4130410 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 40.282 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9130500 4130509 4130510 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 40.282 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9130600 4130609 4130610 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 268.852 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9130700 4130709 4130710 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 268.852 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9130800 4130809 4130810 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 268.852 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9130900 4130909 4130910 $Es $mu $FyCol 17.50 16.40  2.47  1.54  1.00 23.70 4900.00 101.000 $SH_PZ 268.852 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9131000 4131009 4131010 $Es $mu $FyCol 17.50 16.40  2.47  1.54  0.00 23.70 4900.00 101.000 $SH_PZ 268.852 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor14
PanelZoneSpring 9140600 4140609 4140610 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 228.570 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9140700 4140709 4140710 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 228.570 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9140800 4140809 4140810 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 228.570 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9140900 4140909 4140910 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 228.570 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9141000 4141009 4141010 $Es $mu $FyCol 17.10 16.20  2.26  1.41  0.00 23.40 4330.00 91.400 $SH_PZ 228.570 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor15
PanelZoneSpring 9150600 4150609 4150610 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 190.099 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9150700 4150709 4150710 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 190.099 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9150800 4150809 4150810 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 190.099 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9150900 4150909 4150910 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 190.099 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9151000 4151009 4151010 $Es $mu $FyCol 17.10 16.20  2.26  1.41  0.00 23.40 4330.00 91.400 $SH_PZ 190.099 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor16
PanelZoneSpring 9160600 4160609 4160610 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 151.628 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9160700 4160709 4160710 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 151.628 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9160800 4160809 4160810 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 151.628 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9160900 4160909 4160910 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 151.628 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9161000 4161009 4161010 $Es $mu $FyCol 17.10 16.20  2.26  1.41  0.00 23.40 4330.00 91.400 $SH_PZ 151.628 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor17
PanelZoneSpring 9170600 4170609 4170610 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 113.157 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9170700 4170709 4170710 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 113.157 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9170800 4170809 4170810 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 113.157 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9170900 4170909 4170910 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 113.157 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9171000 4171009 4171010 $Es $mu $FyCol 17.10 16.20  2.26  1.41  0.00 23.40 4330.00 91.400 $SH_PZ 113.157 $trib $tslab $pzModelTag 1 $Composite;
# Panel zones floor18
PanelZoneSpring 9180600 4180609 4180610 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 74.486 $trib $tslab $pzModelTag 1 $Composite;
PanelZoneSpring 9180700 4180709 4180710 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 74.486 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9180800 4180809 4180810 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 74.486 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9180900 4180909 4180910 $Es $mu $FyCol 17.10 16.20  2.26  1.41  1.00 23.40 4330.00 91.400 $SH_PZ 74.486 $trib $tslab $pzModelTag 0 $Composite;
PanelZoneSpring 9181000 4181009 4181010 $Es $mu $FyCol 17.10 16.20  2.26  1.41  0.00 23.40 4330.00 91.400 $SH_PZ 74.486 $trib $tslab $pzModelTag 1 $Composite;


####################################################################################################
#                                             BEAM ELEMENTS                                        #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# (Welded web) fracSecGeometry  d, bf, tf, ttab, tabLength, dtab
# (Bolted web) fracSecGeometry  d, bf, tf, ttab, tabLength, str, boltDiameter, Lc
# hingeBeamColumnFracture  ElementID node_i node_j eleDir, ... A, Ieff, ... webConnection
# hingeBeamColumn  ElementID node_i node_j eleDir, ... A, Ieff

# Beams at floor 2 bay 1
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020100 4020104 4020202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor2_i] [expr $kTL*$sigCrT_bay1_floor2_i] [expr $kBR*$sigCrB_bay1_floor2_j] [expr $kTR*$sigCrT_bay1_floor2_j] $FI_limB_bay1_floor2_i $FI_limT_bay1_floor2_i $FI_limB_bay1_floor2_j $FI_limT_bay1_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 2 bay 2
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020200 4020204 4020302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor2_i] [expr $kTL*$sigCrT_bay2_floor2_i] [expr $kBR*$sigCrB_bay2_floor2_j] [expr $kTR*$sigCrT_bay2_floor2_j] $FI_limB_bay2_floor2_i $FI_limT_bay2_floor2_i $FI_limB_bay2_floor2_j $FI_limT_bay2_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 2 bay 3
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020300 4020304 4020402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor2_i] [expr $kTL*$sigCrT_bay3_floor2_i] [expr $kBR*$sigCrB_bay3_floor2_j] [expr $kTR*$sigCrT_bay3_floor2_j] $FI_limB_bay3_floor2_i $FI_limT_bay3_floor2_i $FI_limB_bay3_floor2_j $FI_limT_bay3_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 2 bay 4
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020400 4020404 4020502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor2_i] [expr $kTL*$sigCrT_bay4_floor2_i] [expr $kBR*$sigCrB_bay4_floor2_j] [expr $kTR*$sigCrT_bay4_floor2_j] $FI_limB_bay4_floor2_i $FI_limT_bay4_floor2_i $FI_limB_bay4_floor2_j $FI_limT_bay4_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 2 bay 5
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0324   0.0109   0.0469   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020500 4020504 4020602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor2_i] [expr $kTL*$sigCrT_bay5_floor2_i] [expr $kBR*$sigCrB_bay5_floor2_j] [expr $kTR*$sigCrT_bay5_floor2_j] $FI_limB_bay5_floor2_i $FI_limT_bay5_floor2_i $FI_limB_bay5_floor2_j $FI_limT_bay5_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 2 bay 7
set secInfo_i {373.0000   1.1238   0.2000   0.0324   0.0109   0.0469   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020700 4020704 4020802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor2_i] [expr $kTL*$sigCrT_bay7_floor2_i] [expr $kBR*$sigCrB_bay7_floor2_j] [expr $kTR*$sigCrT_bay7_floor2_j] $FI_limB_bay7_floor2_i $FI_limT_bay7_floor2_i $FI_limB_bay7_floor2_j $FI_limT_bay7_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 2 bay 8
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020800 4020804 4020902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor2_i] [expr $kTL*$sigCrT_bay8_floor2_i] [expr $kBR*$sigCrB_bay8_floor2_j] [expr $kTR*$sigCrT_bay8_floor2_j] $FI_limB_bay8_floor2_i $FI_limT_bay8_floor2_i $FI_limB_bay8_floor2_j $FI_limT_bay8_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 2 bay 9
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1020900 4020904 4021002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor2_i] [expr $kTL*$sigCrT_bay9_floor2_i] [expr $kBR*$sigCrB_bay9_floor2_j] [expr $kTR*$sigCrT_bay9_floor2_j] $FI_limB_bay9_floor2_i $FI_limT_bay9_floor2_i $FI_limB_bay9_floor2_j $FI_limT_bay9_floor2_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 1
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030100 4030104 4030202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor3_i] [expr $kTL*$sigCrT_bay1_floor3_i] [expr $kBR*$sigCrB_bay1_floor3_j] [expr $kTR*$sigCrT_bay1_floor3_j] $FI_limB_bay1_floor3_i $FI_limT_bay1_floor3_i $FI_limB_bay1_floor3_j $FI_limT_bay1_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 2
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030200 4030204 4030302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor3_i] [expr $kTL*$sigCrT_bay2_floor3_i] [expr $kBR*$sigCrB_bay2_floor3_j] [expr $kTR*$sigCrT_bay2_floor3_j] $FI_limB_bay2_floor3_i $FI_limT_bay2_floor3_i $FI_limB_bay2_floor3_j $FI_limT_bay2_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 3
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030300 4030304 4030402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor3_i] [expr $kTL*$sigCrT_bay3_floor3_i] [expr $kBR*$sigCrB_bay3_floor3_j] [expr $kTR*$sigCrT_bay3_floor3_j] $FI_limB_bay3_floor3_i $FI_limT_bay3_floor3_i $FI_limB_bay3_floor3_j $FI_limT_bay3_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 4
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030400 4030404 4030502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor3_i] [expr $kTL*$sigCrT_bay4_floor3_i] [expr $kBR*$sigCrB_bay4_floor3_j] [expr $kTR*$sigCrT_bay4_floor3_j] $FI_limB_bay4_floor3_i $FI_limT_bay4_floor3_i $FI_limB_bay4_floor3_j $FI_limT_bay4_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 5
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030500 4030504 4030602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor3_i] [expr $kTL*$sigCrT_bay5_floor3_i] [expr $kBR*$sigCrB_bay5_floor3_j] [expr $kTR*$sigCrT_bay5_floor3_j] $FI_limB_bay5_floor3_i $FI_limT_bay5_floor3_i $FI_limB_bay5_floor3_j $FI_limT_bay5_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 6
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030600 4030604 4030702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor3_i] [expr $kTL*$sigCrT_bay6_floor3_i] [expr $kBR*$sigCrB_bay6_floor3_j] [expr $kTR*$sigCrT_bay6_floor3_j] $FI_limB_bay6_floor3_i $FI_limT_bay6_floor3_i $FI_limB_bay6_floor3_j $FI_limT_bay6_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 7
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030700 4030704 4030802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor3_i] [expr $kTL*$sigCrT_bay7_floor3_i] [expr $kBR*$sigCrB_bay7_floor3_j] [expr $kTR*$sigCrT_bay7_floor3_j] $FI_limB_bay7_floor3_i $FI_limT_bay7_floor3_i $FI_limB_bay7_floor3_j $FI_limT_bay7_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 8
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030800 4030804 4030902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor3_i] [expr $kTL*$sigCrT_bay8_floor3_i] [expr $kBR*$sigCrB_bay8_floor3_j] [expr $kTR*$sigCrT_bay8_floor3_j] $FI_limB_bay8_floor3_i $FI_limT_bay8_floor3_i $FI_limB_bay8_floor3_j $FI_limT_bay8_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 3 bay 9
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1030900 4030904 4031002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor3_i] [expr $kTL*$sigCrT_bay9_floor3_i] [expr $kBR*$sigCrB_bay9_floor3_j] [expr $kTR*$sigCrT_bay9_floor3_j] $FI_limB_bay9_floor3_i $FI_limT_bay9_floor3_i $FI_limB_bay9_floor3_j $FI_limT_bay9_floor3_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 1
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040100 4040104 4040202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor4_i] [expr $kTL*$sigCrT_bay1_floor4_i] [expr $kBR*$sigCrB_bay1_floor4_j] [expr $kTR*$sigCrT_bay1_floor4_j] $FI_limB_bay1_floor4_i $FI_limT_bay1_floor4_i $FI_limB_bay1_floor4_j $FI_limT_bay1_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 2
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040200 4040204 4040302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor4_i] [expr $kTL*$sigCrT_bay2_floor4_i] [expr $kBR*$sigCrB_bay2_floor4_j] [expr $kTR*$sigCrT_bay2_floor4_j] $FI_limB_bay2_floor4_i $FI_limT_bay2_floor4_i $FI_limB_bay2_floor4_j $FI_limT_bay2_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 3
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040300 4040304 4040402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor4_i] [expr $kTL*$sigCrT_bay3_floor4_i] [expr $kBR*$sigCrB_bay3_floor4_j] [expr $kTR*$sigCrT_bay3_floor4_j] $FI_limB_bay3_floor4_i $FI_limT_bay3_floor4_i $FI_limB_bay3_floor4_j $FI_limT_bay3_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 4
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040400 4040404 4040502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor4_i] [expr $kTL*$sigCrT_bay4_floor4_i] [expr $kBR*$sigCrB_bay4_floor4_j] [expr $kTR*$sigCrT_bay4_floor4_j] $FI_limB_bay4_floor4_i $FI_limT_bay4_floor4_i $FI_limB_bay4_floor4_j $FI_limT_bay4_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 5
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040500 4040504 4040602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor4_i] [expr $kTL*$sigCrT_bay5_floor4_i] [expr $kBR*$sigCrB_bay5_floor4_j] [expr $kTR*$sigCrT_bay5_floor4_j] $FI_limB_bay5_floor4_i $FI_limT_bay5_floor4_i $FI_limB_bay5_floor4_j $FI_limT_bay5_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 6
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040600 4040604 4040702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor4_i] [expr $kTL*$sigCrT_bay6_floor4_i] [expr $kBR*$sigCrB_bay6_floor4_j] [expr $kTR*$sigCrT_bay6_floor4_j] $FI_limB_bay6_floor4_i $FI_limT_bay6_floor4_i $FI_limB_bay6_floor4_j $FI_limT_bay6_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 7
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040700 4040704 4040802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor4_i] [expr $kTL*$sigCrT_bay7_floor4_i] [expr $kBR*$sigCrB_bay7_floor4_j] [expr $kTR*$sigCrT_bay7_floor4_j] $FI_limB_bay7_floor4_i $FI_limT_bay7_floor4_i $FI_limB_bay7_floor4_j $FI_limT_bay7_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 8
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040800 4040804 4040902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor4_i] [expr $kTL*$sigCrT_bay8_floor4_i] [expr $kBR*$sigCrB_bay8_floor4_j] [expr $kTR*$sigCrT_bay8_floor4_j] $FI_limB_bay8_floor4_i $FI_limT_bay8_floor4_i $FI_limB_bay8_floor4_j $FI_limT_bay8_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 4 bay 9
set secInfo_i {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set secInfo_j {373.0000   1.1238   0.2000   0.0405   0.0136   0.0586   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 22.1000  12.5000   1.1500   0.7200   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1040900 4040904 4041002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 43.200 [expr 3527.517*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor4_i] [expr $kTL*$sigCrT_bay9_floor4_i] [expr $kBR*$sigCrB_bay9_floor4_j] [expr $kTR*$sigCrT_bay9_floor4_j] $FI_limB_bay9_floor4_i $FI_limT_bay9_floor4_i $FI_limB_bay9_floor4_j $FI_limT_bay9_floor4_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 1
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050100 4050104 4050202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor5_i] [expr $kTL*$sigCrT_bay1_floor5_i] [expr $kBR*$sigCrB_bay1_floor5_j] [expr $kTR*$sigCrT_bay1_floor5_j] $FI_limB_bay1_floor5_i $FI_limT_bay1_floor5_i $FI_limB_bay1_floor5_j $FI_limT_bay1_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 2
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050200 4050204 4050302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor5_i] [expr $kTL*$sigCrT_bay2_floor5_i] [expr $kBR*$sigCrB_bay2_floor5_j] [expr $kTR*$sigCrT_bay2_floor5_j] $FI_limB_bay2_floor5_i $FI_limT_bay2_floor5_i $FI_limB_bay2_floor5_j $FI_limT_bay2_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 3
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050300 4050304 4050402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor5_i] [expr $kTL*$sigCrT_bay3_floor5_i] [expr $kBR*$sigCrB_bay3_floor5_j] [expr $kTR*$sigCrT_bay3_floor5_j] $FI_limB_bay3_floor5_i $FI_limT_bay3_floor5_i $FI_limB_bay3_floor5_j $FI_limT_bay3_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 4
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050400 4050404 4050502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor5_i] [expr $kTL*$sigCrT_bay4_floor5_i] [expr $kBR*$sigCrB_bay4_floor5_j] [expr $kTR*$sigCrT_bay4_floor5_j] $FI_limB_bay4_floor5_i $FI_limT_bay4_floor5_i $FI_limB_bay4_floor5_j $FI_limT_bay4_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 5
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050500 4050504 4050602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor5_i] [expr $kTL*$sigCrT_bay5_floor5_i] [expr $kBR*$sigCrB_bay5_floor5_j] [expr $kTR*$sigCrT_bay5_floor5_j] $FI_limB_bay5_floor5_i $FI_limT_bay5_floor5_i $FI_limB_bay5_floor5_j $FI_limT_bay5_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 6
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050600 4050604 4050702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor5_i] [expr $kTL*$sigCrT_bay6_floor5_i] [expr $kBR*$sigCrB_bay6_floor5_j] [expr $kTR*$sigCrT_bay6_floor5_j] $FI_limB_bay6_floor5_i $FI_limT_bay6_floor5_i $FI_limB_bay6_floor5_j $FI_limT_bay6_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 7
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050700 4050704 4050802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor5_i] [expr $kTL*$sigCrT_bay7_floor5_i] [expr $kBR*$sigCrB_bay7_floor5_j] [expr $kTR*$sigCrT_bay7_floor5_j] $FI_limB_bay7_floor5_i $FI_limT_bay7_floor5_i $FI_limB_bay7_floor5_j $FI_limT_bay7_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 8
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050800 4050804 4050902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor5_i] [expr $kTL*$sigCrT_bay8_floor5_i] [expr $kBR*$sigCrB_bay8_floor5_j] [expr $kTR*$sigCrT_bay8_floor5_j] $FI_limB_bay8_floor5_i $FI_limT_bay8_floor5_i $FI_limB_bay8_floor5_j $FI_limT_bay8_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 5 bay 9
set secInfo_i {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set secInfo_j {732.1687   1.1274   0.2000   0.0192   0.0070   0.0286   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.8000  15.1000   1.3000   0.7700   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.391
set kTL 1.303
set kBR 1.391
set kTR 1.303
hingeBeamColumnFracture 1050900 4050904 4051002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 61.100 [expr 9613.522*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor5_i] [expr $kTL*$sigCrT_bay9_floor5_i] [expr $kBR*$sigCrB_bay9_floor5_j] [expr $kTR*$sigCrT_bay9_floor5_j] $FI_limB_bay9_floor5_i $FI_limT_bay9_floor5_i $FI_limB_bay9_floor5_j $FI_limT_bay9_floor5_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 1
set secInfo_i {646.1660   1.1272   0.2000   0.0242   0.0089   0.0360   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060100 4060104 4060202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor6_i] [expr $kTL*$sigCrT_bay1_floor6_i] [expr $kBR*$sigCrB_bay1_floor6_j] [expr $kTR*$sigCrT_bay1_floor6_j] $FI_limB_bay1_floor6_i $FI_limT_bay1_floor6_i $FI_limB_bay1_floor6_j $FI_limT_bay1_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 2
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060200 4060204 4060302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor6_i] [expr $kTL*$sigCrT_bay2_floor6_i] [expr $kBR*$sigCrB_bay2_floor6_j] [expr $kTR*$sigCrT_bay2_floor6_j] $FI_limB_bay2_floor6_i $FI_limT_bay2_floor6_i $FI_limB_bay2_floor6_j $FI_limT_bay2_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 3
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060300 4060304 4060402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor6_i] [expr $kTL*$sigCrT_bay3_floor6_i] [expr $kBR*$sigCrB_bay3_floor6_j] [expr $kTR*$sigCrT_bay3_floor6_j] $FI_limB_bay3_floor6_i $FI_limT_bay3_floor6_i $FI_limB_bay3_floor6_j $FI_limT_bay3_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 4
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060400 4060404 4060502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor6_i] [expr $kTL*$sigCrT_bay4_floor6_i] [expr $kBR*$sigCrB_bay4_floor6_j] [expr $kTR*$sigCrT_bay4_floor6_j] $FI_limB_bay4_floor6_i $FI_limT_bay4_floor6_i $FI_limB_bay4_floor6_j $FI_limT_bay4_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 5
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060500 4060504 4060602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor6_i] [expr $kTL*$sigCrT_bay5_floor6_i] [expr $kBR*$sigCrB_bay5_floor6_j] [expr $kTR*$sigCrT_bay5_floor6_j] $FI_limB_bay5_floor6_i $FI_limT_bay5_floor6_i $FI_limB_bay5_floor6_j $FI_limT_bay5_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 6
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060600 4060604 4060702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor6_i] [expr $kTL*$sigCrT_bay6_floor6_i] [expr $kBR*$sigCrB_bay6_floor6_j] [expr $kTR*$sigCrT_bay6_floor6_j] $FI_limB_bay6_floor6_i $FI_limT_bay6_floor6_i $FI_limB_bay6_floor6_j $FI_limT_bay6_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 7
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060700 4060704 4060802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor6_i] [expr $kTL*$sigCrT_bay7_floor6_i] [expr $kBR*$sigCrB_bay7_floor6_j] [expr $kTR*$sigCrT_bay7_floor6_j] $FI_limB_bay7_floor6_i $FI_limT_bay7_floor6_i $FI_limB_bay7_floor6_j $FI_limT_bay7_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 8
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060800 4060804 4060902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor6_i] [expr $kTL*$sigCrT_bay8_floor6_i] [expr $kBR*$sigCrB_bay8_floor6_j] [expr $kTR*$sigCrT_bay8_floor6_j] $FI_limB_bay8_floor6_i $FI_limT_bay8_floor6_i $FI_limB_bay8_floor6_j $FI_limT_bay8_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 6 bay 9
set secInfo_i {646.1660   1.1272   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1272   0.2000   0.0242   0.0089   0.0360   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1060900 4060904 4061002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8402.181*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor6_i] [expr $kTL*$sigCrT_bay9_floor6_i] [expr $kBR*$sigCrB_bay9_floor6_j] [expr $kTR*$sigCrT_bay9_floor6_j] $FI_limB_bay9_floor6_i $FI_limT_bay9_floor6_i $FI_limB_bay9_floor6_j $FI_limT_bay9_floor6_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 1
set secInfo_i {646.1660   1.1270   0.2000   0.0242   0.0089   0.0360   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070100 4070104 4070202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor7_i] [expr $kTL*$sigCrT_bay1_floor7_i] [expr $kBR*$sigCrB_bay1_floor7_j] [expr $kTR*$sigCrT_bay1_floor7_j] $FI_limB_bay1_floor7_i $FI_limT_bay1_floor7_i $FI_limB_bay1_floor7_j $FI_limT_bay1_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 2
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070200 4070204 4070302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor7_i] [expr $kTL*$sigCrT_bay2_floor7_i] [expr $kBR*$sigCrB_bay2_floor7_j] [expr $kTR*$sigCrT_bay2_floor7_j] $FI_limB_bay2_floor7_i $FI_limT_bay2_floor7_i $FI_limB_bay2_floor7_j $FI_limT_bay2_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 3
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070300 4070304 4070402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor7_i] [expr $kTL*$sigCrT_bay3_floor7_i] [expr $kBR*$sigCrB_bay3_floor7_j] [expr $kTR*$sigCrT_bay3_floor7_j] $FI_limB_bay3_floor7_i $FI_limT_bay3_floor7_i $FI_limB_bay3_floor7_j $FI_limT_bay3_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 4
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070400 4070404 4070502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor7_i] [expr $kTL*$sigCrT_bay4_floor7_i] [expr $kBR*$sigCrB_bay4_floor7_j] [expr $kTR*$sigCrT_bay4_floor7_j] $FI_limB_bay4_floor7_i $FI_limT_bay4_floor7_i $FI_limB_bay4_floor7_j $FI_limT_bay4_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 5
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070500 4070504 4070602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor7_i] [expr $kTL*$sigCrT_bay5_floor7_i] [expr $kBR*$sigCrB_bay5_floor7_j] [expr $kTR*$sigCrT_bay5_floor7_j] $FI_limB_bay5_floor7_i $FI_limT_bay5_floor7_i $FI_limB_bay5_floor7_j $FI_limT_bay5_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 6
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070600 4070604 4070702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor7_i] [expr $kTL*$sigCrT_bay6_floor7_i] [expr $kBR*$sigCrB_bay6_floor7_j] [expr $kTR*$sigCrT_bay6_floor7_j] $FI_limB_bay6_floor7_i $FI_limT_bay6_floor7_i $FI_limB_bay6_floor7_j $FI_limT_bay6_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 7
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070700 4070704 4070802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor7_i] [expr $kTL*$sigCrT_bay7_floor7_i] [expr $kBR*$sigCrB_bay7_floor7_j] [expr $kTR*$sigCrT_bay7_floor7_j] $FI_limB_bay7_floor7_i $FI_limT_bay7_floor7_i $FI_limB_bay7_floor7_j $FI_limT_bay7_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 8
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070800 4070804 4070902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor7_i] [expr $kTL*$sigCrT_bay8_floor7_i] [expr $kBR*$sigCrB_bay8_floor7_j] [expr $kTR*$sigCrT_bay8_floor7_j] $FI_limB_bay8_floor7_i $FI_limT_bay8_floor7_i $FI_limB_bay8_floor7_j $FI_limT_bay8_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 7 bay 9
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0242   0.0089   0.0360   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1070900 4070904 4071002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor7_i] [expr $kTL*$sigCrT_bay9_floor7_i] [expr $kBR*$sigCrB_bay9_floor7_j] [expr $kTR*$sigCrT_bay9_floor7_j] $FI_limB_bay9_floor7_i $FI_limT_bay9_floor7_i $FI_limB_bay9_floor7_j $FI_limT_bay9_floor7_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 1
set secInfo_i {646.1660   1.1270   0.2000   0.0242   0.0089   0.0360   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080100 4080104 4080202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor8_i] [expr $kTL*$sigCrT_bay1_floor8_i] [expr $kBR*$sigCrB_bay1_floor8_j] [expr $kTR*$sigCrT_bay1_floor8_j] $FI_limB_bay1_floor8_i $FI_limT_bay1_floor8_i $FI_limB_bay1_floor8_j $FI_limT_bay1_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 2
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080200 4080204 4080302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor8_i] [expr $kTL*$sigCrT_bay2_floor8_i] [expr $kBR*$sigCrB_bay2_floor8_j] [expr $kTR*$sigCrT_bay2_floor8_j] $FI_limB_bay2_floor8_i $FI_limT_bay2_floor8_i $FI_limB_bay2_floor8_j $FI_limT_bay2_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 3
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080300 4080304 4080402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor8_i] [expr $kTL*$sigCrT_bay3_floor8_i] [expr $kBR*$sigCrB_bay3_floor8_j] [expr $kTR*$sigCrT_bay3_floor8_j] $FI_limB_bay3_floor8_i $FI_limT_bay3_floor8_i $FI_limB_bay3_floor8_j $FI_limT_bay3_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 4
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080400 4080404 4080502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor8_i] [expr $kTL*$sigCrT_bay4_floor8_i] [expr $kBR*$sigCrB_bay4_floor8_j] [expr $kTR*$sigCrT_bay4_floor8_j] $FI_limB_bay4_floor8_i $FI_limT_bay4_floor8_i $FI_limB_bay4_floor8_j $FI_limT_bay4_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 5
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080500 4080504 4080602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor8_i] [expr $kTL*$sigCrT_bay5_floor8_i] [expr $kBR*$sigCrB_bay5_floor8_j] [expr $kTR*$sigCrT_bay5_floor8_j] $FI_limB_bay5_floor8_i $FI_limT_bay5_floor8_i $FI_limB_bay5_floor8_j $FI_limT_bay5_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 6
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080600 4080604 4080702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor8_i] [expr $kTL*$sigCrT_bay6_floor8_i] [expr $kBR*$sigCrB_bay6_floor8_j] [expr $kTR*$sigCrT_bay6_floor8_j] $FI_limB_bay6_floor8_i $FI_limT_bay6_floor8_i $FI_limB_bay6_floor8_j $FI_limT_bay6_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 7
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080700 4080704 4080802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor8_i] [expr $kTL*$sigCrT_bay7_floor8_i] [expr $kBR*$sigCrB_bay7_floor8_j] [expr $kTR*$sigCrT_bay7_floor8_j] $FI_limB_bay7_floor8_i $FI_limT_bay7_floor8_i $FI_limB_bay7_floor8_j $FI_limT_bay7_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 8
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080800 4080804 4080902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor8_i] [expr $kTL*$sigCrT_bay8_floor8_i] [expr $kBR*$sigCrB_bay8_floor8_j] [expr $kTR*$sigCrT_bay8_floor8_j] $FI_limB_bay8_floor8_i $FI_limT_bay8_floor8_i $FI_limB_bay8_floor8_j $FI_limT_bay8_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 8 bay 9
set secInfo_i {646.1660   1.1270   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1270   0.2000   0.0242   0.0089   0.0360   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1080900 4080904 4081002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8403.225*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor8_i] [expr $kTL*$sigCrT_bay9_floor8_i] [expr $kBR*$sigCrB_bay9_floor8_j] [expr $kTR*$sigCrT_bay9_floor8_j] $FI_limB_bay9_floor8_i $FI_limT_bay9_floor8_i $FI_limB_bay9_floor8_j $FI_limT_bay9_floor8_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 1
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090100 4090104 4090202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor9_i] [expr $kTL*$sigCrT_bay1_floor9_i] [expr $kBR*$sigCrB_bay1_floor9_j] [expr $kTR*$sigCrT_bay1_floor9_j] $FI_limB_bay1_floor9_i $FI_limT_bay1_floor9_i $FI_limB_bay1_floor9_j $FI_limT_bay1_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 2
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090200 4090204 4090302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor9_i] [expr $kTL*$sigCrT_bay2_floor9_i] [expr $kBR*$sigCrB_bay2_floor9_j] [expr $kTR*$sigCrT_bay2_floor9_j] $FI_limB_bay2_floor9_i $FI_limT_bay2_floor9_i $FI_limB_bay2_floor9_j $FI_limT_bay2_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 3
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090300 4090304 4090402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor9_i] [expr $kTL*$sigCrT_bay3_floor9_i] [expr $kBR*$sigCrB_bay3_floor9_j] [expr $kTR*$sigCrT_bay3_floor9_j] $FI_limB_bay3_floor9_i $FI_limT_bay3_floor9_i $FI_limB_bay3_floor9_j $FI_limT_bay3_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 4
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090400 4090404 4090502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor9_i] [expr $kTL*$sigCrT_bay4_floor9_i] [expr $kBR*$sigCrB_bay4_floor9_j] [expr $kTR*$sigCrT_bay4_floor9_j] $FI_limB_bay4_floor9_i $FI_limT_bay4_floor9_i $FI_limB_bay4_floor9_j $FI_limT_bay4_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 5
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090500 4090504 4090602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor9_i] [expr $kTL*$sigCrT_bay5_floor9_i] [expr $kBR*$sigCrB_bay5_floor9_j] [expr $kTR*$sigCrT_bay5_floor9_j] $FI_limB_bay5_floor9_i $FI_limT_bay5_floor9_i $FI_limB_bay5_floor9_j $FI_limT_bay5_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 6
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090600 4090604 4090702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor9_i] [expr $kTL*$sigCrT_bay6_floor9_i] [expr $kBR*$sigCrB_bay6_floor9_j] [expr $kTR*$sigCrT_bay6_floor9_j] $FI_limB_bay6_floor9_i $FI_limT_bay6_floor9_i $FI_limB_bay6_floor9_j $FI_limT_bay6_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 7
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090700 4090704 4090802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor9_i] [expr $kTL*$sigCrT_bay7_floor9_i] [expr $kBR*$sigCrB_bay7_floor9_j] [expr $kTR*$sigCrT_bay7_floor9_j] $FI_limB_bay7_floor9_i $FI_limT_bay7_floor9_i $FI_limB_bay7_floor9_j $FI_limT_bay7_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 8
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090800 4090804 4090902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor9_i] [expr $kTL*$sigCrT_bay8_floor9_i] [expr $kBR*$sigCrB_bay8_floor9_j] [expr $kTR*$sigCrT_bay8_floor9_j] $FI_limB_bay8_floor9_i $FI_limT_bay8_floor9_i $FI_limB_bay8_floor9_j $FI_limT_bay8_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 9 bay 9
set secInfo_i {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set secInfo_j {646.1660   1.1269   0.2000   0.0194   0.0071   0.0288   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 30.6000  15.0000   1.1500   0.6900   0.5000   5.0000 { -10.5  -7.5  -4.5  -1.5  1.5  4.5  7.5  10.5  }        1        2 1.0};
set kBL 1.429
set kTL 1.357
set kBR 1.429
set kTR 1.357
hingeBeamColumnFracture 1090900 4090904 4091002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 54.300 [expr 8404.266*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor9_i] [expr $kTL*$sigCrT_bay9_floor9_i] [expr $kBR*$sigCrB_bay9_floor9_j] [expr $kTR*$sigCrT_bay9_floor9_j] $FI_limB_bay9_floor9_i $FI_limT_bay9_floor9_i $FI_limB_bay9_floor9_j $FI_limT_bay9_floor9_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 1
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100100 4100104 4100202 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay1_floor10_i] [expr $kTL*$sigCrT_bay1_floor10_i] [expr $kBR*$sigCrB_bay1_floor10_j] [expr $kTR*$sigCrT_bay1_floor10_j] $FI_limB_bay1_floor10_i $FI_limT_bay1_floor10_i $FI_limB_bay1_floor10_j $FI_limT_bay1_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 2
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100200 4100204 4100302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor10_i] [expr $kTL*$sigCrT_bay2_floor10_i] [expr $kBR*$sigCrB_bay2_floor10_j] [expr $kTR*$sigCrT_bay2_floor10_j] $FI_limB_bay2_floor10_i $FI_limT_bay2_floor10_i $FI_limB_bay2_floor10_j $FI_limT_bay2_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 3
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100300 4100304 4100402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor10_i] [expr $kTL*$sigCrT_bay3_floor10_i] [expr $kBR*$sigCrB_bay3_floor10_j] [expr $kTR*$sigCrT_bay3_floor10_j] $FI_limB_bay3_floor10_i $FI_limT_bay3_floor10_i $FI_limB_bay3_floor10_j $FI_limT_bay3_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 4
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100400 4100404 4100502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor10_i] [expr $kTL*$sigCrT_bay4_floor10_i] [expr $kBR*$sigCrB_bay4_floor10_j] [expr $kTR*$sigCrT_bay4_floor10_j] $FI_limB_bay4_floor10_i $FI_limT_bay4_floor10_i $FI_limB_bay4_floor10_j $FI_limT_bay4_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 5
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100500 4100504 4100602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor10_i] [expr $kTL*$sigCrT_bay5_floor10_i] [expr $kBR*$sigCrB_bay5_floor10_j] [expr $kTR*$sigCrT_bay5_floor10_j] $FI_limB_bay5_floor10_i $FI_limT_bay5_floor10_i $FI_limB_bay5_floor10_j $FI_limT_bay5_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 6
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100600 4100604 4100702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor10_i] [expr $kTL*$sigCrT_bay6_floor10_i] [expr $kBR*$sigCrB_bay6_floor10_j] [expr $kTR*$sigCrT_bay6_floor10_j] $FI_limB_bay6_floor10_i $FI_limT_bay6_floor10_i $FI_limB_bay6_floor10_j $FI_limT_bay6_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 7
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100700 4100704 4100802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor10_i] [expr $kTL*$sigCrT_bay7_floor10_i] [expr $kBR*$sigCrB_bay7_floor10_j] [expr $kTR*$sigCrT_bay7_floor10_j] $FI_limB_bay7_floor10_i $FI_limT_bay7_floor10_i $FI_limB_bay7_floor10_j $FI_limT_bay7_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 8
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100800 4100804 4100902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor10_i] [expr $kTL*$sigCrT_bay8_floor10_i] [expr $kBR*$sigCrB_bay8_floor10_j] [expr $kTR*$sigCrT_bay8_floor10_j] $FI_limB_bay8_floor10_i $FI_limT_bay8_floor10_i $FI_limB_bay8_floor10_j $FI_limT_bay8_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 10 bay 9
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1100900 4100904 4101002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor10_i] [expr $kTL*$sigCrT_bay9_floor10_i] [expr $kBR*$sigCrB_bay9_floor10_j] [expr $kTR*$sigCrT_bay9_floor10_j] $FI_limB_bay9_floor10_i $FI_limT_bay9_floor10_i $FI_limB_bay9_floor10_j $FI_limT_bay9_floor10_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 2
set secInfo_i {659.9387   1.1242   0.2000   0.0386   0.0131   0.0561   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110200 4110204 4110302 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay2_floor11_i] [expr $kTL*$sigCrT_bay2_floor11_i] [expr $kBR*$sigCrB_bay2_floor11_j] [expr $kTR*$sigCrT_bay2_floor11_j] $FI_limB_bay2_floor11_i $FI_limT_bay2_floor11_i $FI_limB_bay2_floor11_j $FI_limT_bay2_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 3
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110300 4110304 4110402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor11_i] [expr $kTL*$sigCrT_bay3_floor11_i] [expr $kBR*$sigCrB_bay3_floor11_j] [expr $kTR*$sigCrT_bay3_floor11_j] $FI_limB_bay3_floor11_i $FI_limT_bay3_floor11_i $FI_limB_bay3_floor11_j $FI_limT_bay3_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 4
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110400 4110404 4110502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor11_i] [expr $kTL*$sigCrT_bay4_floor11_i] [expr $kBR*$sigCrB_bay4_floor11_j] [expr $kTR*$sigCrT_bay4_floor11_j] $FI_limB_bay4_floor11_i $FI_limT_bay4_floor11_i $FI_limB_bay4_floor11_j $FI_limT_bay4_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 5
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110500 4110504 4110602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor11_i] [expr $kTL*$sigCrT_bay5_floor11_i] [expr $kBR*$sigCrB_bay5_floor11_j] [expr $kTR*$sigCrT_bay5_floor11_j] $FI_limB_bay5_floor11_i $FI_limT_bay5_floor11_i $FI_limB_bay5_floor11_j $FI_limT_bay5_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 6
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110600 4110604 4110702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor11_i] [expr $kTL*$sigCrT_bay6_floor11_i] [expr $kBR*$sigCrB_bay6_floor11_j] [expr $kTR*$sigCrT_bay6_floor11_j] $FI_limB_bay6_floor11_i $FI_limT_bay6_floor11_i $FI_limB_bay6_floor11_j $FI_limT_bay6_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 7
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110700 4110704 4110802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor11_i] [expr $kTL*$sigCrT_bay7_floor11_i] [expr $kBR*$sigCrB_bay7_floor11_j] [expr $kTR*$sigCrT_bay7_floor11_j] $FI_limB_bay7_floor11_i $FI_limT_bay7_floor11_i $FI_limB_bay7_floor11_j $FI_limT_bay7_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 8
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110800 4110804 4110902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor11_i] [expr $kTL*$sigCrT_bay8_floor11_i] [expr $kBR*$sigCrB_bay8_floor11_j] [expr $kTR*$sigCrT_bay8_floor11_j] $FI_limB_bay8_floor11_i $FI_limT_bay8_floor11_i $FI_limB_bay8_floor11_j $FI_limT_bay8_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 11 bay 9
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1110900 4110904 4111002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor11_i] [expr $kTL*$sigCrT_bay9_floor11_i] [expr $kBR*$sigCrB_bay9_floor11_j] [expr $kTR*$sigCrT_bay9_floor11_j] $FI_limB_bay9_floor11_i $FI_limT_bay9_floor11_i $FI_limB_bay9_floor11_j $FI_limT_bay9_floor11_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 12 bay 3
set secInfo_i {659.9387   1.1242   0.2000   0.0386   0.0131   0.0561   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1120300 4120304 4120402 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay3_floor12_i] [expr $kTL*$sigCrT_bay3_floor12_i] [expr $kBR*$sigCrB_bay3_floor12_j] [expr $kTR*$sigCrT_bay3_floor12_j] $FI_limB_bay3_floor12_i $FI_limT_bay3_floor12_i $FI_limB_bay3_floor12_j $FI_limT_bay3_floor12_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 12 bay 4
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1120400 4120404 4120502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor12_i] [expr $kTL*$sigCrT_bay4_floor12_i] [expr $kBR*$sigCrB_bay4_floor12_j] [expr $kTR*$sigCrT_bay4_floor12_j] $FI_limB_bay4_floor12_i $FI_limT_bay4_floor12_i $FI_limB_bay4_floor12_j $FI_limT_bay4_floor12_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 12 bay 5
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1120500 4120504 4120602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor12_i] [expr $kTL*$sigCrT_bay5_floor12_i] [expr $kBR*$sigCrB_bay5_floor12_j] [expr $kTR*$sigCrT_bay5_floor12_j] $FI_limB_bay5_floor12_i $FI_limT_bay5_floor12_i $FI_limB_bay5_floor12_j $FI_limT_bay5_floor12_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 12 bay 6
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1120600 4120604 4120702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor12_i] [expr $kTL*$sigCrT_bay6_floor12_i] [expr $kBR*$sigCrB_bay6_floor12_j] [expr $kTR*$sigCrT_bay6_floor12_j] $FI_limB_bay6_floor12_i $FI_limT_bay6_floor12_i $FI_limB_bay6_floor12_j $FI_limT_bay6_floor12_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 12 bay 7
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1120700 4120704 4120802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor12_i] [expr $kTL*$sigCrT_bay7_floor12_i] [expr $kBR*$sigCrB_bay7_floor12_j] [expr $kTR*$sigCrT_bay7_floor12_j] $FI_limB_bay7_floor12_i $FI_limT_bay7_floor12_i $FI_limB_bay7_floor12_j $FI_limT_bay7_floor12_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 12 bay 8
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1120800 4120804 4120902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor12_i] [expr $kTL*$sigCrT_bay8_floor12_i] [expr $kBR*$sigCrB_bay8_floor12_j] [expr $kTR*$sigCrT_bay8_floor12_j] $FI_limB_bay8_floor12_i $FI_limT_bay8_floor12_i $FI_limB_bay8_floor12_j $FI_limT_bay8_floor12_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 12 bay 9
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1120900 4120904 4121002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor12_i] [expr $kTL*$sigCrT_bay9_floor12_i] [expr $kBR*$sigCrB_bay9_floor12_j] [expr $kTR*$sigCrT_bay9_floor12_j] $FI_limB_bay9_floor12_i $FI_limT_bay9_floor12_i $FI_limB_bay9_floor12_j $FI_limT_bay9_floor12_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 13 bay 4
set secInfo_i {659.9387   1.1242   0.2000   0.0386   0.0131   0.0561   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1130400 4130404 4130502 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay4_floor13_i] [expr $kTL*$sigCrT_bay4_floor13_i] [expr $kBR*$sigCrB_bay4_floor13_j] [expr $kTR*$sigCrT_bay4_floor13_j] $FI_limB_bay4_floor13_i $FI_limT_bay4_floor13_i $FI_limB_bay4_floor13_j $FI_limT_bay4_floor13_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 13 bay 5
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1130500 4130504 4130602 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay5_floor13_i] [expr $kTL*$sigCrT_bay5_floor13_i] [expr $kBR*$sigCrB_bay5_floor13_j] [expr $kTR*$sigCrT_bay5_floor13_j] $FI_limB_bay5_floor13_i $FI_limT_bay5_floor13_i $FI_limB_bay5_floor13_j $FI_limT_bay5_floor13_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 13 bay 6
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1130600 4130604 4130702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor13_i] [expr $kTL*$sigCrT_bay6_floor13_i] [expr $kBR*$sigCrB_bay6_floor13_j] [expr $kTR*$sigCrT_bay6_floor13_j] $FI_limB_bay6_floor13_i $FI_limT_bay6_floor13_i $FI_limB_bay6_floor13_j $FI_limT_bay6_floor13_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 13 bay 7
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1130700 4130704 4130802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor13_i] [expr $kTL*$sigCrT_bay7_floor13_i] [expr $kBR*$sigCrB_bay7_floor13_j] [expr $kTR*$sigCrT_bay7_floor13_j] $FI_limB_bay7_floor13_i $FI_limT_bay7_floor13_i $FI_limB_bay7_floor13_j $FI_limT_bay7_floor13_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 13 bay 8
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1130800 4130804 4130902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor13_i] [expr $kTL*$sigCrT_bay8_floor13_i] [expr $kBR*$sigCrB_bay8_floor13_j] [expr $kTR*$sigCrT_bay8_floor13_j] $FI_limB_bay8_floor13_i $FI_limT_bay8_floor13_i $FI_limB_bay8_floor13_j $FI_limT_bay8_floor13_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 13 bay 9
set secInfo_i {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set secInfo_j {659.9387   1.1242   0.2000   0.0308   0.0105   0.0449   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.7000  12.8000   1.9900   1.1000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.266
set kTL 1.132
set kBR 1.266
set kTR 1.132
hingeBeamColumnFracture 1130900 4130904 4131002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 73.800 [expr 6595.943*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor13_i] [expr $kTL*$sigCrT_bay9_floor13_i] [expr $kBR*$sigCrB_bay9_floor13_j] [expr $kTR*$sigCrT_bay9_floor13_j] $FI_limB_bay9_floor13_i $FI_limT_bay9_floor13_i $FI_limB_bay9_floor13_j $FI_limT_bay9_floor13_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 14 bay 6
set secInfo_i {589.4682   1.1250   0.2000   0.0311   0.0106   0.0452   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1140600 4140604 4140702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor14_i] [expr $kTL*$sigCrT_bay6_floor14_i] [expr $kBR*$sigCrB_bay6_floor14_j] [expr $kTR*$sigCrT_bay6_floor14_j] $FI_limB_bay6_floor14_i $FI_limT_bay6_floor14_i $FI_limB_bay6_floor14_j $FI_limT_bay6_floor14_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 14 bay 7
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1140700 4140704 4140802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor14_i] [expr $kTL*$sigCrT_bay7_floor14_i] [expr $kBR*$sigCrB_bay7_floor14_j] [expr $kTR*$sigCrT_bay7_floor14_j] $FI_limB_bay7_floor14_i $FI_limT_bay7_floor14_i $FI_limB_bay7_floor14_j $FI_limT_bay7_floor14_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 14 bay 8
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1140800 4140804 4140902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor14_i] [expr $kTL*$sigCrT_bay8_floor14_i] [expr $kBR*$sigCrB_bay8_floor14_j] [expr $kTR*$sigCrT_bay8_floor14_j] $FI_limB_bay8_floor14_i $FI_limT_bay8_floor14_i $FI_limB_bay8_floor14_j $FI_limT_bay8_floor14_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 14 bay 9
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1140900 4140904 4141002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor14_i] [expr $kTL*$sigCrT_bay9_floor14_i] [expr $kBR*$sigCrB_bay9_floor14_j] [expr $kTR*$sigCrT_bay9_floor14_j] $FI_limB_bay9_floor14_i $FI_limT_bay9_floor14_i $FI_limB_bay9_floor14_j $FI_limT_bay9_floor14_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 15 bay 6
set secInfo_i {589.4682   1.1250   0.2000   0.0311   0.0106   0.0452   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1150600 4150604 4150702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor15_i] [expr $kTL*$sigCrT_bay6_floor15_i] [expr $kBR*$sigCrB_bay6_floor15_j] [expr $kTR*$sigCrT_bay6_floor15_j] $FI_limB_bay6_floor15_i $FI_limT_bay6_floor15_i $FI_limB_bay6_floor15_j $FI_limT_bay6_floor15_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 15 bay 7
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1150700 4150704 4150802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor15_i] [expr $kTL*$sigCrT_bay7_floor15_i] [expr $kBR*$sigCrB_bay7_floor15_j] [expr $kTR*$sigCrT_bay7_floor15_j] $FI_limB_bay7_floor15_i $FI_limT_bay7_floor15_i $FI_limB_bay7_floor15_j $FI_limT_bay7_floor15_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 15 bay 8
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1150800 4150804 4150902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor15_i] [expr $kTL*$sigCrT_bay8_floor15_i] [expr $kBR*$sigCrB_bay8_floor15_j] [expr $kTR*$sigCrT_bay8_floor15_j] $FI_limB_bay8_floor15_i $FI_limT_bay8_floor15_i $FI_limB_bay8_floor15_j $FI_limT_bay8_floor15_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 15 bay 9
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1150900 4150904 4151002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor15_i] [expr $kTL*$sigCrT_bay9_floor15_i] [expr $kBR*$sigCrB_bay9_floor15_j] [expr $kTR*$sigCrT_bay9_floor15_j] $FI_limB_bay9_floor15_i $FI_limT_bay9_floor15_i $FI_limB_bay9_floor15_j $FI_limT_bay9_floor15_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 16 bay 6
set secInfo_i {589.4682   1.1250   0.2000   0.0311   0.0106   0.0452   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1160600 4160604 4160702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor16_i] [expr $kTL*$sigCrT_bay6_floor16_i] [expr $kBR*$sigCrB_bay6_floor16_j] [expr $kTR*$sigCrT_bay6_floor16_j] $FI_limB_bay6_floor16_i $FI_limT_bay6_floor16_i $FI_limB_bay6_floor16_j $FI_limT_bay6_floor16_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 16 bay 7
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1160700 4160704 4160802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor16_i] [expr $kTL*$sigCrT_bay7_floor16_i] [expr $kBR*$sigCrB_bay7_floor16_j] [expr $kTR*$sigCrT_bay7_floor16_j] $FI_limB_bay7_floor16_i $FI_limT_bay7_floor16_i $FI_limB_bay7_floor16_j $FI_limT_bay7_floor16_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 16 bay 8
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1160800 4160804 4160902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor16_i] [expr $kTL*$sigCrT_bay8_floor16_i] [expr $kBR*$sigCrB_bay8_floor16_j] [expr $kTR*$sigCrT_bay8_floor16_j] $FI_limB_bay8_floor16_i $FI_limT_bay8_floor16_i $FI_limB_bay8_floor16_j $FI_limT_bay8_floor16_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 16 bay 9
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1160900 4160904 4161002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor16_i] [expr $kTL*$sigCrT_bay9_floor16_i] [expr $kBR*$sigCrB_bay9_floor16_j] [expr $kTR*$sigCrT_bay9_floor16_j] $FI_limB_bay9_floor16_i $FI_limT_bay9_floor16_i $FI_limB_bay9_floor16_j $FI_limT_bay9_floor16_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 17 bay 6
set secInfo_i {589.4682   1.1250   0.2000   0.0311   0.0106   0.0452   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1170600 4170604 4170702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor17_i] [expr $kTL*$sigCrT_bay6_floor17_i] [expr $kBR*$sigCrB_bay6_floor17_j] [expr $kTR*$sigCrT_bay6_floor17_j] $FI_limB_bay6_floor17_i $FI_limT_bay6_floor17_i $FI_limB_bay6_floor17_j $FI_limT_bay6_floor17_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 17 bay 7
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1170700 4170704 4170802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor17_i] [expr $kTL*$sigCrT_bay7_floor17_i] [expr $kBR*$sigCrB_bay7_floor17_j] [expr $kTR*$sigCrT_bay7_floor17_j] $FI_limB_bay7_floor17_i $FI_limT_bay7_floor17_i $FI_limB_bay7_floor17_j $FI_limT_bay7_floor17_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 17 bay 8
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1170800 4170804 4170902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor17_i] [expr $kTL*$sigCrT_bay8_floor17_i] [expr $kBR*$sigCrB_bay8_floor17_j] [expr $kTR*$sigCrT_bay8_floor17_j] $FI_limB_bay8_floor17_i $FI_limT_bay8_floor17_i $FI_limB_bay8_floor17_j $FI_limT_bay8_floor17_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 17 bay 9
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1170900 4170904 4171002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor17_i] [expr $kTL*$sigCrT_bay9_floor17_i] [expr $kBR*$sigCrB_bay9_floor17_j] [expr $kTR*$sigCrT_bay9_floor17_j] $FI_limB_bay9_floor17_i $FI_limT_bay9_floor17_i $FI_limB_bay9_floor17_j $FI_limT_bay9_floor17_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 18 bay 6
set secInfo_i {589.4682   1.1250   0.2000   0.0311   0.0106   0.0452   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1180600 4180604 4180702 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay6_floor18_i] [expr $kTL*$sigCrT_bay6_floor18_i] [expr $kBR*$sigCrB_bay6_floor18_j] [expr $kTR*$sigCrT_bay6_floor18_j] $FI_limB_bay6_floor18_i $FI_limT_bay6_floor18_i $FI_limB_bay6_floor18_j $FI_limT_bay6_floor18_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 18 bay 7
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1180700 4180704 4180802 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay7_floor18_i] [expr $kTL*$sigCrT_bay7_floor18_i] [expr $kBR*$sigCrB_bay7_floor18_j] [expr $kTR*$sigCrT_bay7_floor18_j] $FI_limB_bay7_floor18_i $FI_limT_bay7_floor18_i $FI_limB_bay7_floor18_j $FI_limT_bay7_floor18_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 18 bay 8
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1180800 4180804 4180902 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay8_floor18_i] [expr $kTL*$sigCrT_bay8_floor18_i] [expr $kBR*$sigCrB_bay8_floor18_j] [expr $kTR*$sigCrT_bay8_floor18_j] $FI_limB_bay8_floor18_i $FI_limT_bay8_floor18_i $FI_limB_bay8_floor18_j $FI_limT_bay8_floor18_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

# Beams at floor 18 bay 9
set secInfo_i {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set secInfo_j {589.4682   1.1250   0.2000   0.0249   0.0085   0.0362   0.0000};
set compBackboneFactors [lreplace $compBackboneFactors 0 0   1.0000];# MpP/Mp
set compBackboneFactors [lreplace $compBackboneFactors 1 1   1.0000];# MpN/Mp
set fracSecGeometry { 23.4000  12.7000   1.7900   1.0000   0.5000   5.0000 { -7.5  -4.5  -1.5  1.5  4.5  7.5  }        1        2 1.0};
set kBL 1.296
set kTL 1.173
set kBR 1.296
set kTR 1.173
hingeBeamColumnFracture 1180900 4180904 4181002 "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag 66.500 [expr 5881.127*$Comp_I] $degradation $c $secInfo_i $secInfo_j "Bolted" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay9_floor18_i] [expr $kTL*$sigCrT_bay9_floor18_i] [expr $kBR*$sigCrB_bay9_floor18_j] [expr $kTR*$sigCrT_bay9_floor18_j] $FI_limB_bay9_floor18_i $FI_limT_bay9_floor18_i $FI_limB_bay9_floor18_j $FI_limT_bay9_floor18_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;

####################################################################################################
#                                            COLUMNS ELEMENTS                                      #
####################################################################################################

# COMMAND SYNTAX 
# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda
# spliceSecGeometry  min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j)
# (splice)    hingeBeamColumnSplice  ElementID node_i node_j eleDir, ... A, Ieff, ... 
# (no splice) hingeBeamColumn        ElementID node_i node_j eleDir, ... A, Ieff

# Columns at story 1 axis 1
set secInfo_i {813.9919   1.3987   0.8430   0.0782   0.0706   0.1724   0.0000};
set secInfo_j {813.9919   1.3987   0.8430   0.0782   0.0706   0.1724   0.0000};
hingeBeamColumn 2010100 10100 4020101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 1
set secInfo_i {820.1324   1.4855   0.8494   0.0851   0.0787   0.1901   0.0000};
set secInfo_j {820.1324   1.4855   0.8494   0.0851   0.0787   0.1901   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020100 4020103 4030101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 1
set secInfo_i {826.2480   1.4902   0.8557   0.0866   0.0801   0.1934   0.0000};
set secInfo_j {826.2480   1.4902   0.8557   0.0866   0.0801   0.1934   0.0000};
hingeBeamColumn 2030100 4030103 4040101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 1
set secInfo_i {764.9214   1.4852   0.8595   0.0851   0.0797   0.1914   0.0000};
set secInfo_j {764.9214   1.4852   0.8595   0.0851   0.0797   0.1914   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040100 4040103 4050101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 1
set secInfo_i {770.9439   1.5080   0.8662   0.0877   0.0827   0.1980   0.0000};
set secInfo_j {770.9439   1.5080   0.8662   0.0877   0.0827   0.1980   0.0000};
hingeBeamColumn 2050100 4050103 4060101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 1
set secInfo_i {712.2959   1.4808   0.8710   0.0846   0.0806   0.1920   0.0000};
set secInfo_j {712.2959   1.4808   0.8710   0.0846   0.0806   0.1920   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060100 4060103 4070101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 1
set secInfo_i {718.2359   1.4860   0.8783   0.0863   0.0822   0.1959   0.0000};
set secInfo_j {718.2359   1.4860   0.8783   0.0863   0.0822   0.1959   0.0000};
hingeBeamColumn 2070100 4070103 4080101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 1
set secInfo_i {660.3488   1.6220   0.8844   0.0922   0.0927   0.2158   0.0000};
set secInfo_j {660.3488   1.6220   0.8844   0.0922   0.0927   0.2158   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080100 4080103 4090101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 1
set secInfo_i {666.1303   1.6110   0.8921   0.0931   0.0932   0.2174   0.0000};
set secInfo_j {666.1303   1.6110   0.8921   0.0931   0.0932   0.2174   0.0000};
hingeBeamColumn 2090100 4090103 4100101 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 2
set secInfo_i {807.9147   1.3948   0.8367   0.0769   0.0693   0.1693   0.0000};
set secInfo_j {807.9147   1.3948   0.8367   0.0769   0.0693   0.1693   0.0000};
hingeBeamColumn 2010200 10200 4020201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 2
set secInfo_i {814.0553   1.4809   0.8431   0.0837   0.0773   0.1867   0.0000};
set secInfo_j {814.0553   1.4809   0.8431   0.0837   0.0773   0.1867   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020200 4020203 4030201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 2
set secInfo_i {820.1709   1.4856   0.8494   0.0852   0.0787   0.1901   0.0000};
set secInfo_j {820.1709   1.4856   0.8494   0.0852   0.0787   0.1901   0.0000};
hingeBeamColumn 2030200 4030203 4040201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 2
set secInfo_i {758.9368   1.4803   0.8527   0.0836   0.0782   0.1879   0.0000};
set secInfo_j {758.9368   1.4803   0.8527   0.0836   0.0782   0.1879   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040200 4040203 4050201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 2
set secInfo_i {764.9593   1.5030   0.8595   0.0862   0.0811   0.1944   0.0000};
set secInfo_j {764.9593   1.5030   0.8595   0.0862   0.0811   0.1944   0.0000};
hingeBeamColumn 2050200 4050203 4060201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 2
set secInfo_i {706.3933   1.4757   0.8638   0.0830   0.0789   0.1883   0.0000};
set secInfo_j {706.3933   1.4757   0.8638   0.0830   0.0789   0.1883   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060200 4060203 4070201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 2
set secInfo_i {712.3333   1.4809   0.8711   0.0846   0.0806   0.1921   0.0000};
set secInfo_j {712.3333   1.4809   0.8711   0.0846   0.0806   0.1921   0.0000};
hingeBeamColumn 2070200 4070203 4080201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 2
set secInfo_i {654.5327   1.6150   0.8766   0.0904   0.0907   0.2113   0.0000};
set secInfo_j {654.5327   1.6150   0.8766   0.0904   0.0907   0.2113   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080200 4080203 4090201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 2
set secInfo_i {660.3141   1.6041   0.8843   0.0913   0.0913   0.2130   0.0000};
set secInfo_j {660.3141   1.6041   0.8843   0.0913   0.0913   0.2130   0.0000};
hingeBeamColumn 2090200 4090203 4100201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 2
set secInfo_i {666.1838   1.5934   0.8922   0.0922   0.0919   0.2147   0.0000};
set secInfo_j {666.1838   1.5934   0.8922   0.0922   0.0919   0.2147   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100200 4100203 4110201 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 1 axis 3
set secInfo_i {801.9067   1.3910   0.8305   0.0756   0.0681   0.1663   0.0000};
set secInfo_j {801.9067   1.3910   0.8305   0.0756   0.0681   0.1663   0.0000};
hingeBeamColumn 2010300 10300 4020301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 3
set secInfo_i {808.0472   1.4763   0.8369   0.0823   0.0759   0.1835   0.0000};
set secInfo_j {808.0472   1.4763   0.8369   0.0823   0.0759   0.1835   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020300 4020303 4030301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 3
set secInfo_i {814.1628   1.4810   0.8432   0.0837   0.0773   0.1868   0.0000};
set secInfo_j {814.1628   1.4810   0.8432   0.0837   0.0773   0.1868   0.0000};
hingeBeamColumn 2030300 4030303 4040301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 3
set secInfo_i {753.0202   1.4755   0.8461   0.0821   0.0767   0.1844   0.0000};
set secInfo_j {753.0202   1.4755   0.8461   0.0821   0.0767   0.1844   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040300 4040303 4050301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 3
set secInfo_i {759.0427   1.4980   0.8529   0.0847   0.0796   0.1908   0.0000};
set secInfo_j {759.0427   1.4980   0.8529   0.0847   0.0796   0.1908   0.0000};
hingeBeamColumn 2050300 4050303 4060301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 3
set secInfo_i {700.5579   1.4706   0.8567   0.0815   0.0774   0.1846   0.0000};
set secInfo_j {700.5579   1.4706   0.8567   0.0815   0.0774   0.1846   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060300 4060303 4070301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 3
set secInfo_i {706.4978   1.4758   0.8639   0.0831   0.0790   0.1884   0.0000};
set secInfo_j {706.4978   1.4758   0.8639   0.0831   0.0790   0.1884   0.0000};
hingeBeamColumn 2070300 4070303 4080301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 3
set secInfo_i {648.7826   1.6081   0.8689   0.0886   0.0888   0.2070   0.0000};
set secInfo_j {648.7826   1.6081   0.8689   0.0886   0.0888   0.2070   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080300 4080303 4090301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 3
set secInfo_i {654.5641   1.5974   0.8766   0.0895   0.0894   0.2086   0.0000};
set secInfo_j {654.5641   1.5974   0.8766   0.0895   0.0894   0.2086   0.0000};
hingeBeamColumn 2090300 4090303 4100301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 3
set secInfo_i {660.4338   1.5868   0.8845   0.0904   0.0900   0.2104   0.0000};
set secInfo_j {660.4338   1.5868   0.8845   0.0904   0.0900   0.2104   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100300 4100303 4110301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 3
set secInfo_i {666.2500   1.5935   0.8923   0.0922   0.0919   0.2148   0.0000};
set secInfo_j {666.2500   1.5935   0.8923   0.0922   0.0919   0.2148   0.0000};
hingeBeamColumn 2110300 4110303 4120301 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 4
set secInfo_i {795.9861   1.3873   0.8244   0.0743   0.0668   0.1634   0.0000};
set secInfo_j {795.9861   1.3873   0.8244   0.0743   0.0668   0.1634   0.0000};
hingeBeamColumn 2010400 10400 4020401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 4
set secInfo_i {802.1266   1.4718   0.8307   0.0809   0.0745   0.1803   0.0000};
set secInfo_j {802.1266   1.4718   0.8307   0.0809   0.0745   0.1803   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020400 4020403 4030401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 4
set secInfo_i {808.2423   1.4764   0.8371   0.0823   0.0759   0.1836   0.0000};
set secInfo_j {808.2423   1.4764   0.8371   0.0823   0.0759   0.1836   0.0000};
hingeBeamColumn 2030400 4030403 4040401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 4
set secInfo_i {747.1898   1.4707   0.8395   0.0806   0.0753   0.1810   0.0000};
set secInfo_j {747.1898   1.4707   0.8395   0.0806   0.0753   0.1810   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040400 4040403 4050401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 4
set secInfo_i {753.2123   1.4930   0.8463   0.0832   0.0781   0.1873   0.0000};
set secInfo_j {753.2123   1.4930   0.8463   0.0832   0.0781   0.1873   0.0000};
hingeBeamColumn 2050400 4050403 4060401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 4
set secInfo_i {694.8074   1.4656   0.8496   0.0799   0.0758   0.1810   0.0000};
set secInfo_j {694.8074   1.4656   0.8496   0.0799   0.0758   0.1810   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060400 4060403 4070401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 4
set secInfo_i {700.7473   1.4708   0.8569   0.0815   0.0774   0.1847   0.0000};
set secInfo_j {700.7473   1.4708   0.8569   0.0815   0.0774   0.1847   0.0000};
hingeBeamColumn 2070400 4070403 4080401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 4
set secInfo_i {643.1163   1.6012   0.8613   0.0868   0.0869   0.2027   0.0000};
set secInfo_j {643.1163   1.6012   0.8613   0.0868   0.0869   0.2027   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080400 4080403 4090401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 4
set secInfo_i {648.8977   1.5907   0.8691   0.0877   0.0875   0.2044   0.0000};
set secInfo_j {648.8977   1.5907   0.8691   0.0877   0.0875   0.2044   0.0000};
hingeBeamColumn 2090400 4090403 4100401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 4
set secInfo_i {654.7674   1.5803   0.8769   0.0886   0.0881   0.2061   0.0000};
set secInfo_j {654.7674   1.5803   0.8769   0.0886   0.0881   0.2061   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100400 4100403 4110401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 4
set secInfo_i {660.5836   1.5870   0.8847   0.0904   0.0900   0.2105   0.0000};
set secInfo_j {660.5836   1.5870   0.8847   0.0904   0.0900   0.2105   0.0000};
hingeBeamColumn 2110400 4110403 4120401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 12 axis 4
set secInfo_i {666.3337   1.5936   0.8924   0.0922   0.0920   0.2148   0.0000};
set secInfo_j {666.3337   1.5936   0.8924   0.0922   0.0920   0.2148   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2120400 4120403 4130401 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 1 axis 5
set secInfo_i {795.9861   1.3873   0.8244   0.0743   0.0668   0.1634   0.0000};
set secInfo_j {795.9861   1.3873   0.8244   0.0743   0.0668   0.1634   0.0000};
hingeBeamColumn 2010500 10500 4020501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 5
set secInfo_i {802.1266   1.4718   0.8307   0.0809   0.0745   0.1803   0.0000};
set secInfo_j {802.1266   1.4718   0.8307   0.0809   0.0745   0.1803   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020500 4020503 4030501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 5
set secInfo_i {808.2423   1.4764   0.8371   0.0823   0.0759   0.1836   0.0000};
set secInfo_j {808.2423   1.4764   0.8371   0.0823   0.0759   0.1836   0.0000};
hingeBeamColumn 2030500 4030503 4040501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 5
set secInfo_i {747.1898   1.4707   0.8395   0.0806   0.0753   0.1810   0.0000};
set secInfo_j {747.1898   1.4707   0.8395   0.0806   0.0753   0.1810   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040500 4040503 4050501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 5
set secInfo_i {753.2123   1.4930   0.8463   0.0832   0.0781   0.1873   0.0000};
set secInfo_j {753.2123   1.4930   0.8463   0.0832   0.0781   0.1873   0.0000};
hingeBeamColumn 2050500 4050503 4060501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 5
set secInfo_i {694.8074   1.4656   0.8496   0.0799   0.0758   0.1810   0.0000};
set secInfo_j {694.8074   1.4656   0.8496   0.0799   0.0758   0.1810   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060500 4060503 4070501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 5
set secInfo_i {700.7473   1.4708   0.8569   0.0815   0.0774   0.1847   0.0000};
set secInfo_j {700.7473   1.4708   0.8569   0.0815   0.0774   0.1847   0.0000};
hingeBeamColumn 2070500 4070503 4080501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 5
set secInfo_i {643.1163   1.6012   0.8613   0.0868   0.0869   0.2027   0.0000};
set secInfo_j {643.1163   1.6012   0.8613   0.0868   0.0869   0.2027   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080500 4080503 4090501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 5
set secInfo_i {648.8977   1.5907   0.8691   0.0877   0.0875   0.2044   0.0000};
set secInfo_j {648.8977   1.5907   0.8691   0.0877   0.0875   0.2044   0.0000};
hingeBeamColumn 2090500 4090503 4100501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 5
set secInfo_i {654.7674   1.5803   0.8769   0.0886   0.0881   0.2061   0.0000};
set secInfo_j {654.7674   1.5803   0.8769   0.0886   0.0881   0.2061   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100500 4100503 4110501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 5
set secInfo_i {660.5836   1.5870   0.8847   0.0904   0.0900   0.2105   0.0000};
set secInfo_j {660.5836   1.5870   0.8847   0.0904   0.0900   0.2105   0.0000};
hingeBeamColumn 2110500 4110503 4120501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 12 axis 5
set secInfo_i {666.3337   1.5936   0.8924   0.0922   0.0920   0.2148   0.0000};
set secInfo_j {666.3337   1.5936   0.8924   0.0922   0.0920   0.2148   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2120500 4120503 4130501 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 1 axis 6
set secInfo_i {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
set secInfo_j {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
hingeBeamColumn 2010600 10600 4020601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 6
set secInfo_i {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set secInfo_j {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020600 4020603 4030601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 6
set secInfo_i {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
set secInfo_j {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
hingeBeamColumn 2030600 4030603 4040601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 6
set secInfo_i {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set secInfo_j {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040600 4040603 4050601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 6
set secInfo_i {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
set secInfo_j {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
hingeBeamColumn 2050600 4050603 4060601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 6
set secInfo_i {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set secInfo_j {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060600 4060603 4070601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 6
set secInfo_i {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
set secInfo_j {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
hingeBeamColumn 2070600 4070603 4080601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 6
set secInfo_i {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set secInfo_j {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080600 4080603 4090601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 6
set secInfo_i {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
set secInfo_j {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
hingeBeamColumn 2090600 4090603 4100601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 6
set secInfo_i {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set secInfo_j {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100600 4100603 4110601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 6
set secInfo_i {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
set secInfo_j {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
hingeBeamColumn 2110600 4110603 4120601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 12 axis 6
set secInfo_i {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set secInfo_j {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2120600 4120603 4130601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 13 axis 6
set secInfo_i {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
set secInfo_j {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
hingeBeamColumn 2130600 4130603 4140601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3325.622 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 14 axis 6
set secInfo_i {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set secInfo_j {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2140600 4140603 4150601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 15 axis 6
set secInfo_i {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
set secInfo_j {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
hingeBeamColumn 2150600 4150603 4160601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 16 axis 6
set secInfo_i {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set secInfo_j {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2160600 4160603 4170601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3431.395 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 17 axis 6
set secInfo_i {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
set secInfo_j {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
hingeBeamColumn 2170600 4170603 4180601 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3683.067 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 7
set secInfo_i {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
set secInfo_j {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
hingeBeamColumn 2010700 10700 4020701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 7
set secInfo_i {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set secInfo_j {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020700 4020703 4030701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 7
set secInfo_i {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
set secInfo_j {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
hingeBeamColumn 2030700 4030703 4040701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 7
set secInfo_i {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set secInfo_j {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040700 4040703 4050701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 7
set secInfo_i {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
set secInfo_j {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
hingeBeamColumn 2050700 4050703 4060701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 7
set secInfo_i {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set secInfo_j {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060700 4060703 4070701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 7
set secInfo_i {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
set secInfo_j {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
hingeBeamColumn 2070700 4070703 4080701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 7
set secInfo_i {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set secInfo_j {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080700 4080703 4090701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 7
set secInfo_i {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
set secInfo_j {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
hingeBeamColumn 2090700 4090703 4100701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 7
set secInfo_i {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set secInfo_j {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100700 4100703 4110701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 7
set secInfo_i {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
set secInfo_j {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
hingeBeamColumn 2110700 4110703 4120701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 12 axis 7
set secInfo_i {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set secInfo_j {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2120700 4120703 4130701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 13 axis 7
set secInfo_i {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
set secInfo_j {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
hingeBeamColumn 2130700 4130703 4140701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3325.622 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 14 axis 7
set secInfo_i {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set secInfo_j {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2140700 4140703 4150701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 15 axis 7
set secInfo_i {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
set secInfo_j {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
hingeBeamColumn 2150700 4150703 4160701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 16 axis 7
set secInfo_i {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set secInfo_j {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2160700 4160703 4170701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3431.395 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 17 axis 7
set secInfo_i {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
set secInfo_j {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
hingeBeamColumn 2170700 4170703 4180701 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3683.067 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 8
set secInfo_i {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
set secInfo_j {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
hingeBeamColumn 2010800 10800 4020801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 8
set secInfo_i {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set secInfo_j {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020800 4020803 4030801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 8
set secInfo_i {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
set secInfo_j {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
hingeBeamColumn 2030800 4030803 4040801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 8
set secInfo_i {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set secInfo_j {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040800 4040803 4050801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 8
set secInfo_i {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
set secInfo_j {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
hingeBeamColumn 2050800 4050803 4060801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 8
set secInfo_i {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set secInfo_j {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060800 4060803 4070801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 8
set secInfo_i {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
set secInfo_j {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
hingeBeamColumn 2070800 4070803 4080801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 8
set secInfo_i {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set secInfo_j {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080800 4080803 4090801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 8
set secInfo_i {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
set secInfo_j {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
hingeBeamColumn 2090800 4090803 4100801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 8
set secInfo_i {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set secInfo_j {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100800 4100803 4110801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 8
set secInfo_i {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
set secInfo_j {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
hingeBeamColumn 2110800 4110803 4120801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 12 axis 8
set secInfo_i {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set secInfo_j {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2120800 4120803 4130801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 13 axis 8
set secInfo_i {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
set secInfo_j {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
hingeBeamColumn 2130800 4130803 4140801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3325.622 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 14 axis 8
set secInfo_i {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set secInfo_j {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2140800 4140803 4150801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 15 axis 8
set secInfo_i {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
set secInfo_j {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
hingeBeamColumn 2150800 4150803 4160801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 16 axis 8
set secInfo_i {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set secInfo_j {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2160800 4160803 4170801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3431.395 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 17 axis 8
set secInfo_i {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
set secInfo_j {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
hingeBeamColumn 2170800 4170803 4180801 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3683.067 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 9
set secInfo_i {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
set secInfo_j {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
hingeBeamColumn 2010900 10900 4020901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 9
set secInfo_i {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set secInfo_j {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2020900 4020903 4030901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 9
set secInfo_i {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
set secInfo_j {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
hingeBeamColumn 2030900 4030903 4040901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 9
set secInfo_i {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set secInfo_j {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2040900 4040903 4050901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 9
set secInfo_i {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
set secInfo_j {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
hingeBeamColumn 2050900 4050903 4060901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 9
set secInfo_i {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set secInfo_j {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2060900 4060903 4070901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 9
set secInfo_i {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
set secInfo_j {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
hingeBeamColumn 2070900 4070903 4080901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 9
set secInfo_i {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set secInfo_j {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2080900 4080903 4090901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 9
set secInfo_i {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
set secInfo_j {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
hingeBeamColumn 2090900 4090903 4100901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 9
set secInfo_i {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set secInfo_j {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2100900 4100903 4110901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 9
set secInfo_i {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
set secInfo_j {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
hingeBeamColumn 2110900 4110903 4120901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 12 axis 9
set secInfo_i {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set secInfo_j {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2120900 4120903 4130901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 13 axis 9
set secInfo_i {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
set secInfo_j {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
hingeBeamColumn 2130900 4130903 4140901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3325.622 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 14 axis 9
set secInfo_i {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set secInfo_j {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2140900 4140903 4150901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 15 axis 9
set secInfo_i {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
set secInfo_j {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
hingeBeamColumn 2150900 4150903 4160901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 16 axis 9
set secInfo_i {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set secInfo_j {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2160900 4160903 4170901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3431.395 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 17 axis 9
set secInfo_i {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
set secInfo_j {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
hingeBeamColumn 2170900 4170903 4180901 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3683.067 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 1 axis 10
set secInfo_i {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
set secInfo_j {762.3917   1.3660   0.7896   0.0673   0.0601   0.1474   0.0000};
hingeBeamColumn 2011000 11000 4021001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5899.580 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 2 axis 10
set secInfo_i {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set secInfo_j {768.5322   1.4463   0.7959   0.0733   0.0671   0.1628   0.0000};
set sigCr 22.589
set ttab 1.880
set dtab 8.834
set spliceSecGeometry { 18.7000  16.7000   3.0400   1.8800 };
hingeBeamColumnSpliceZLS 2021000 4021003 4031001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 3 axis 10
set secInfo_i {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
set secInfo_j {774.6478   1.4509   0.8023   0.0747   0.0684   0.1659   0.0000};
hingeBeamColumn 2031000 4031003 4041001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 125.000 5674.104 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 4 axis 10
set secInfo_i {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set secInfo_j {714.1069   1.4438   0.8024   0.0727   0.0674   0.1625   0.0000};
set sigCr 23.330
set ttab 1.770
set dtab 8.820
set spliceSecGeometry { 18.3000  16.6000   2.8500   1.7700 };
hingeBeamColumnSpliceZLS 2041000 4041003 4051001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5120.425 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 5 axis 10
set secInfo_i {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
set secInfo_j {720.1294   1.4651   0.8091   0.0750   0.0700   0.1684   0.0000};
hingeBeamColumn 2051000 4051003 4061001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 117.000 5069.041 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 6 axis 10
set secInfo_i {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set secInfo_j {662.1780   1.4374   0.8097   0.0716   0.0674   0.1615   0.0000};
set sigCr 24.149
set ttab 1.660
set dtab 8.806
set spliceSecGeometry { 17.9000  16.5000   2.6600   1.6600 };
hingeBeamColumnSpliceZLS 2061000 4061003 4071001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 7 axis 10
set secInfo_i {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
set secInfo_j {668.1179   1.4425   0.8170   0.0730   0.0689   0.1649   0.0000};
hingeBeamColumn 2071000 4071003 4081001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 109.000 4598.578 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 8 axis 10
set secInfo_i {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set secInfo_j {610.9645   1.5626   0.8183   0.0772   0.0767   0.1795   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2081000 4081003 4091001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3607.003 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 9 axis 10
set secInfo_i {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
set secInfo_j {616.7459   1.5532   0.8260   0.0781   0.0773   0.1812   0.0000};
hingeBeamColumn 2091000 4091003 4101001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3677.061 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 10 axis 10
set secInfo_i {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set secInfo_j {622.6156   1.5438   0.8339   0.0790   0.0780   0.1829   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2101000 4101003 4111001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 11 axis 10
set secInfo_i {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
set secInfo_j {628.4318   1.5504   0.8416   0.0807   0.0798   0.1870   0.0000};
hingeBeamColumn 2111000 4111003 4121001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 12 axis 10
set secInfo_i {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set secInfo_j {634.1819   1.5569   0.8494   0.0824   0.0815   0.1911   0.0000};
set sigCr 25.060
set ttab 1.540
set dtab 8.792
set spliceSecGeometry { 17.5000  16.4000   2.4700   1.5400 };
hingeBeamColumnSpliceZLS 2121000 4121003 4131001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 101.000 3742.072 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 13 axis 10
set secInfo_i {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
set secInfo_j {571.1193   1.5160   0.8524   0.0774   0.0776   0.1809   0.0000};
hingeBeamColumn 2131000 4131003 4141001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3325.622 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 14 axis 10
set secInfo_i {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set secInfo_j {576.4851   1.5216   0.8604   0.0791   0.0793   0.1848   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2141000 4141003 4151001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 15 axis 10
set secInfo_i {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
set secInfo_j {581.8510   1.5279   0.8684   0.0808   0.0811   0.1889   0.0000};
hingeBeamColumn 2151000 4151003 4161001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3328.011 $degradation $c $secInfo_i $secInfo_j 0 0;

# Columns at story 16 axis 10
set secInfo_i {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set secInfo_j {587.2169   1.5036   0.8764   0.0809   0.0807   0.1885   0.0000};
set sigCr 26.199
set ttab 1.410
set dtab 8.806
set spliceSecGeometry { 17.1000  16.2000   2.2600   1.4100 };
hingeBeamColumnSpliceZLS 2161000 4161003 4171001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3431.395 $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;

# Columns at story 17 axis 10
set secInfo_i {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
set secInfo_j {592.6108   1.4207   0.8845   0.0777   0.0756   0.1785   0.0000};
hingeBeamColumn 2171000 4171003 4181001 "Vertical" $trans_selected $n $Es $FyCol $rigMatTag 91.400 3683.067 $degradation $c $secInfo_i $secInfo_j 0 0;

####################################################################################################
#                                              FLOOR LINKS                                         #
####################################################################################################

# Command Syntax 
# element truss $ElementID $iNode $jNode $Area $matID
element truss 1018 4181004 181100 $A_Stiff $rigMatTag;
element truss 1017 4171004 171100 $A_Stiff $rigMatTag;
element truss 1016 4161004 161100 $A_Stiff $rigMatTag;
element truss 1015 4151004 151100 $A_Stiff $rigMatTag;
element truss 1014 4141004 141100 $A_Stiff $rigMatTag;
element truss 1013 4131004 131100 $A_Stiff $rigMatTag;
element truss 1012 4121004 121100 $A_Stiff $rigMatTag;
element truss 1011 4111004 111100 $A_Stiff $rigMatTag;
element truss 1010 4101004 101100 $A_Stiff $rigMatTag;
element truss 1009 4091004 91100 $A_Stiff $rigMatTag;
element truss 1008 4081004 81100 $A_Stiff $rigMatTag;
element truss 1007 4071004 71100 $A_Stiff $rigMatTag;
element truss 1006 4061004 61100 $A_Stiff $rigMatTag;
element truss 1005 4051004 51100 $A_Stiff $rigMatTag;
element truss 1004 4041004 41100 $A_Stiff $rigMatTag;
element truss 1003 4031004 31100 $A_Stiff $rigMatTag;
element truss 1002 4021004 21100 $A_Stiff $rigMatTag;

####################################################################################################
#                                          EGF COLUMNS AND BEAMS                                   #
####################################################################################################

# GRAVITY COLUMNS
set secInfo {4870.0000   1.2682   0.9000   0.0641   0.0619   0.1466   0.0000};
hingeBeamColumn 602100 11100 21100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 756.000 31015.464 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 602200 11200 21200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 756.000 31015.464 $degradation $c $secInfo $secInfo 0 0;
set secInfo {4870.0000   1.2923   0.9000   0.0658   0.0641   0.1513   0.0000};
hingeBeamColumn 603100 21100 31100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 756.000 30582.641 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 603200 21200 31200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 756.000 30582.641 $degradation $c $secInfo $secInfo 0 0;
set secInfo {3860.0000   1.2914   0.9000   0.0708   0.0644   0.1567   0.0000};
hingeBeamColumn 604100 31100 41100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 677.000 22445.359 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 604200 31200 41200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 677.000 22445.359 $degradation $c $secInfo $secInfo 0 0;
set secInfo {3860.0000   1.2914   0.9000   0.0708   0.0644   0.1567   0.0000};
hingeBeamColumn 605100 41100 51100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 677.000 22445.359 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 605200 41200 51200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 677.000 22445.359 $degradation $c $secInfo $secInfo 0 0;
set secInfo {3550.0000   1.2294   0.9000   0.0533   0.0540   0.1252   0.0000};
hingeBeamColumn 606100 51100 61100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 568.000 21612.226 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 606200 51200 61200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 568.000 21612.226 $degradation $c $secInfo $secInfo 0 0;
set secInfo {3550.0000   1.2294   0.9000   0.0533   0.0540   0.1252   0.0000};
hingeBeamColumn 607100 61100 71100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 568.000 21612.226 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 607200 61200 71200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 568.000 21612.226 $degradation $c $secInfo $secInfo 0 0;
set secInfo {2750.0000   1.2290   0.9000   0.0584   0.0554   0.1322   0.0000};
hingeBeamColumn 608100 71100 81100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 500.000 15253.247 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 608200 71200 81200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 500.000 15253.247 $degradation $c $secInfo $secInfo 0 0;
set secInfo {2750.0000   1.3120   0.9000   0.0642   0.0631   0.1483   0.0000};
hingeBeamColumn 609100 81100 91100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 500.000 14524.162 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 609200 81200 91200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 500.000 14524.162 $degradation $c $secInfo $secInfo 0 0;
set secInfo {1365.0000   1.2681   0.9000   0.0566   0.0568   0.1323   0.0000};
hingeBeamColumn 610100 91100 101100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 254.150 7034.222 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 610200 91200 101200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 254.150 7034.222 $degradation $c $secInfo $secInfo 0 0;
set secInfo {1260.0000   1.2681   0.9000   0.0566   0.0568   0.1323   0.0000};
hingeBeamColumn 611100 101100 111100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 234.600 6493.128 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 611200 101200 111200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 234.600 6493.128 $degradation $c $secInfo $secInfo 0 0;
set secInfo {951.5000   1.0982   0.5000   0.0195   0.0349   0.0660   0.0000};
hingeBeamColumn 612100 111100 121100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 160.050 5216.219 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 612200 111200 121200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 160.050 5216.219 $degradation $c $secInfo $secInfo 0 0;
set secInfo {951.5000   1.0982   0.5000   0.0195   0.0349   0.0660   0.0000};
hingeBeamColumn 613100 121100 131100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 160.050 5216.219 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 613200 121200 131200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 160.050 5216.219 $degradation $c $secInfo $secInfo 0 0;
set secInfo {439.2000   1.1780   0.9000   0.0451   0.0458   0.1062   0.0000};
hingeBeamColumn 614100 131100 141100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 102.150 1883.372 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 614200 131200 141200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 102.150 1883.372 $degradation $c $secInfo $secInfo 0 0;
set secInfo {439.2000   1.1780   0.9000   0.0451   0.0458   0.1062   0.0000};
hingeBeamColumn 615100 141100 151100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 102.150 1883.372 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 615200 141200 151200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 102.150 1883.372 $degradation $c $secInfo $secInfo 0 0;
set secInfo {391.9500   1.1145   0.9000   0.0223   0.0247   0.0553   0.0000};
hingeBeamColumn 616100 151100 161100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 70.200 2184.400 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 616200 151200 161200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 70.200 2184.400 $degradation $c $secInfo $secInfo 0 0;
set secInfo {391.9500   1.1079   0.9000   0.0220   0.0242   0.0543   0.0000};
hingeBeamColumn 617100 161100 171100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 70.200 2208.608 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 617200 161200 171200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 70.200 2208.608 $degradation $c $secInfo $secInfo 0 0;
set secInfo {103.9500   1.0441   0.5000   0.0172   0.0282   0.0548   0.0000};
hingeBeamColumn 618100 171100 181100 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 31.860 362.197 $degradation $c $secInfo $secInfo 0 0;
hingeBeamColumn 618200 171200 181200 "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag 31.860 362.197 $degradation $c $secInfo $secInfo 0 0;

# GRAVITY BEAMS
element elasticBeamColumn  503000   21104   21202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  504000   31104   31202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  505000   41104   41202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  506000   51104   51202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  507000   61104   61202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  508000   71104   71202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  509000   81104   81202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  510000   91104   91202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  511000  101104  101202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  512000  111104  111202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  513000  121104  121202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  514000  131104  131202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  515000  141104  141202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  516000  151104  151202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  517000  161104  161202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  518000  171104  171202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;
element elasticBeamColumn  519000  181104  181202 94.4000 $Es [expr $Comp_I_GC * 4896.0000] $trans_selected;

# GRAVITY BEAMS SPRINGS
Spring_Pinching  9021104   21100   21104 97899.6480 $gap 1; Spring_Pinching  9021202   21200   21202 97899.6480 $gap 1; 
Spring_Pinching  9031104   31100   31104 97899.6480 $gap 1; Spring_Pinching  9031202   31200   31202 97899.6480 $gap 1; 
Spring_Pinching  9041104   41100   41104 97899.6480 $gap 1; Spring_Pinching  9041202   41200   41202 97899.6480 $gap 1; 
Spring_Pinching  9051104   51100   51104 97899.6480 $gap 1; Spring_Pinching  9051202   51200   51202 97899.6480 $gap 1; 
Spring_Pinching  9061104   61100   61104 97899.6480 $gap 1; Spring_Pinching  9061202   61200   61202 97899.6480 $gap 1; 
Spring_Pinching  9071104   71100   71104 97899.6480 $gap 1; Spring_Pinching  9071202   71200   71202 97899.6480 $gap 1; 
Spring_Pinching  9081104   81100   81104 97899.6480 $gap 1; Spring_Pinching  9081202   81200   81202 97899.6480 $gap 1; 
Spring_Pinching  9091104   91100   91104 97899.6480 $gap 1; Spring_Pinching  9091202   91200   91202 97899.6480 $gap 1; 
Spring_Pinching  9101104  101100  101104 61187.2800 $gap 1; Spring_Pinching  9101202  101200  101202 61187.2800 $gap 1; 
Spring_Pinching  9111104  111100  111104 57108.1280 $gap 1; Spring_Pinching  9111202  111200  111202 57108.1280 $gap 1; 
Spring_Pinching  9121104  121100  121104 48949.8240 $gap 1; Spring_Pinching  9121202  121200  121202 48949.8240 $gap 1; 
Spring_Pinching  9131104  131100  131104 44870.6720 $gap 1; Spring_Pinching  9131202  131200  131202 44870.6720 $gap 1; 
Spring_Pinching  9141104  141100  141104 32633.2160 $gap 1; Spring_Pinching  9141202  141200  141202 32633.2160 $gap 1; 
Spring_Pinching  9151104  151100  151104 32633.2160 $gap 1; Spring_Pinching  9151202  151200  151202 32633.2160 $gap 1; 
Spring_Pinching  9161104  161100  161104 32633.2160 $gap 1; Spring_Pinching  9161202  161200  161202 32633.2160 $gap 1; 
Spring_Pinching  9171104  171100  171104 32633.2160 $gap 1; Spring_Pinching  9171202  171200  171202 32633.2160 $gap 1; 
Spring_Pinching  9181104  181100  181104 32633.2160 $gap 1; Spring_Pinching  9181202  181200  181202 32633.2160 $gap 1; 

###################################################################################################
#                                       BOUNDARY CONDITIONS                                       #
###################################################################################################

# FRAME BASE SUPPORTS
fix 10100 1 1 1;
fix 10200 1 1 1;
fix 10300 1 1 1;
fix 10400 1 1 1;
fix 10500 1 1 1;
fix 10600 1 1 1;
fix 10700 1 1 1;
fix 10800 1 1 1;
fix 10900 1 1 1;
fix 11000 1 1 1;

# EGF SUPPORTS
fix 11100 1 1 0; fix 11200 1 1 0; 

###################################################################################################
###################################################################################################
                                         puts "

"                                               
                                      puts "Model Built"                                           
###################################################################################################
###################################################################################################

###################################################################################################
#                                              NODAL MASS                                         #
###################################################################################################

# MASS ON THE MOMENT FRAME

# Panel zones floor2
mass 4020103 0.1082  0.0011 11.6864;
mass 4020203 0.1082  0.0011 11.6864;
mass 4020303 0.1082  0.0011 11.6864;
mass 4020403 0.1082  0.0011 11.6864;
mass 4020503 0.1082  0.0011 11.6864;
mass 4020603 0.1082  0.0011 11.6864;
mass 4020703 0.1082  0.0011 11.6864;
mass 4020803 0.1082  0.0011 11.6864;
mass 4020903 0.1082  0.0011 11.6864;
mass 4021003 0.1082  0.0011 11.6864;
# Panel zones floor3
mass 4030103 0.1078  0.0011 11.6390;
mass 4030203 0.1078  0.0011 11.6390;
mass 4030303 0.1078  0.0011 11.6390;
mass 4030403 0.1078  0.0011 11.6390;
mass 4030503 0.1078  0.0011 11.6390;
mass 4030603 0.1078  0.0011 11.6390;
mass 4030703 0.1078  0.0011 11.6390;
mass 4030803 0.1078  0.0011 11.6390;
mass 4030903 0.1078  0.0011 11.6390;
mass 4031003 0.1078  0.0011 11.6390;
# Panel zones floor4
mass 4040103 0.1078  0.0011 11.6390;
mass 4040203 0.1078  0.0011 11.6390;
mass 4040303 0.1078  0.0011 11.6390;
mass 4040403 0.1078  0.0011 11.6390;
mass 4040503 0.1078  0.0011 11.6390;
mass 4040603 0.1078  0.0011 11.6390;
mass 4040703 0.1078  0.0011 11.6390;
mass 4040803 0.1078  0.0011 11.6390;
mass 4040903 0.1078  0.0011 11.6390;
mass 4041003 0.1078  0.0011 11.6390;
# Panel zones floor5
mass 4050103 0.1078  0.0011 11.6390;
mass 4050203 0.1078  0.0011 11.6390;
mass 4050303 0.1078  0.0011 11.6390;
mass 4050403 0.1078  0.0011 11.6390;
mass 4050503 0.1078  0.0011 11.6390;
mass 4050603 0.1078  0.0011 11.6390;
mass 4050703 0.1078  0.0011 11.6390;
mass 4050803 0.1078  0.0011 11.6390;
mass 4050903 0.1078  0.0011 11.6390;
mass 4051003 0.1078  0.0011 11.6390;
# Panel zones floor6
mass 4060103 0.1078  0.0011 11.6390;
mass 4060203 0.1078  0.0011 11.6390;
mass 4060303 0.1078  0.0011 11.6390;
mass 4060403 0.1078  0.0011 11.6390;
mass 4060503 0.1078  0.0011 11.6390;
mass 4060603 0.1078  0.0011 11.6390;
mass 4060703 0.1078  0.0011 11.6390;
mass 4060803 0.1078  0.0011 11.6390;
mass 4060903 0.1078  0.0011 11.6390;
mass 4061003 0.1078  0.0011 11.6390;
# Panel zones floor7
mass 4070103 0.1078  0.0011 11.6390;
mass 4070203 0.1078  0.0011 11.6390;
mass 4070303 0.1078  0.0011 11.6390;
mass 4070403 0.1078  0.0011 11.6390;
mass 4070503 0.1078  0.0011 11.6390;
mass 4070603 0.1078  0.0011 11.6390;
mass 4070703 0.1078  0.0011 11.6390;
mass 4070803 0.1078  0.0011 11.6390;
mass 4070903 0.1078  0.0011 11.6390;
mass 4071003 0.1078  0.0011 11.6390;
# Panel zones floor8
mass 4080103 0.1078  0.0011 11.6390;
mass 4080203 0.1078  0.0011 11.6390;
mass 4080303 0.1078  0.0011 11.6390;
mass 4080403 0.1078  0.0011 11.6390;
mass 4080503 0.1078  0.0011 11.6390;
mass 4080603 0.1078  0.0011 11.6390;
mass 4080703 0.1078  0.0011 11.6390;
mass 4080803 0.1078  0.0011 11.6390;
mass 4080903 0.1078  0.0011 11.6390;
mass 4081003 0.1078  0.0011 11.6390;
# Panel zones floor9
mass 4090103 0.1065  0.0011 11.4967;
mass 4090203 0.1065  0.0011 11.4967;
mass 4090303 0.1065  0.0011 11.4967;
mass 4090403 0.1065  0.0011 11.4967;
mass 4090503 0.1065  0.0011 11.4967;
mass 4090603 0.1065  0.0011 11.4967;
mass 4090703 0.1065  0.0011 11.4967;
mass 4090803 0.1065  0.0011 11.4967;
mass 4090903 0.1065  0.0011 11.4967;
mass 4091003 0.1065  0.0011 11.4967;
# Panel zones floor10
mass 4100103 0.1081  0.0011 11.6722;
mass 4100203 0.1081  0.0011 11.6722;
mass 4100303 0.1081  0.0011 11.6722;
mass 4100403 0.1081  0.0011 11.6722;
mass 4100503 0.1081  0.0011 11.6722;
mass 4100603 0.1081  0.0011 11.6722;
mass 4100703 0.1081  0.0011 11.6722;
mass 4100803 0.1081  0.0011 11.6722;
mass 4100903 0.1081  0.0011 11.6722;
mass 4101003 0.1081  0.0011 11.6722;
# Panel zones floor11
mass 4110203 0.1071  0.0011 11.5658;
mass 4110303 0.1071  0.0011 11.5658;
mass 4110403 0.1071  0.0011 11.5658;
mass 4110503 0.1071  0.0011 11.5658;
mass 4110603 0.1071  0.0011 11.5658;
mass 4110703 0.1071  0.0011 11.5658;
mass 4110803 0.1071  0.0011 11.5658;
mass 4110903 0.1071  0.0011 11.5658;
mass 4111003 0.1071  0.0011 11.5658;
# Panel zones floor12
mass 4120303 0.1059  0.0011 11.4343;
mass 4120403 0.1059  0.0011 11.4343;
mass 4120503 0.1059  0.0011 11.4343;
mass 4120603 0.1059  0.0011 11.4343;
mass 4120703 0.1059  0.0011 11.4343;
mass 4120803 0.1059  0.0011 11.4343;
mass 4120903 0.1059  0.0011 11.4343;
mass 4121003 0.1059  0.0011 11.4343;
# Panel zones floor13
mass 4130403 0.1043  0.0010 11.2678;
mass 4130503 0.1043  0.0010 11.2678;
mass 4130603 0.1043  0.0010 11.2678;
mass 4130703 0.1043  0.0010 11.2678;
mass 4130803 0.1043  0.0010 11.2678;
mass 4130903 0.1043  0.0010 11.2678;
mass 4131003 0.1043  0.0010 11.2678;
# Panel zones floor14
mass 4140603 0.0996  0.0010 10.7610;
mass 4140703 0.0996  0.0010 10.7610;
mass 4140803 0.0996  0.0010 10.7610;
mass 4140903 0.0996  0.0010 10.7610;
mass 4141003 0.0996  0.0010 10.7610;
# Panel zones floor15
mass 4150603 0.0996  0.0010 10.7610;
mass 4150703 0.0996  0.0010 10.7610;
mass 4150803 0.0996  0.0010 10.7610;
mass 4150903 0.0996  0.0010 10.7610;
mass 4151003 0.0996  0.0010 10.7610;
# Panel zones floor16
mass 4160603 0.0996  0.0010 10.7610;
mass 4160703 0.0996  0.0010 10.7610;
mass 4160803 0.0996  0.0010 10.7610;
mass 4160903 0.0996  0.0010 10.7610;
mass 4161003 0.0996  0.0010 10.7610;
# Panel zones floor17
mass 4170603 0.1002  0.0010 10.8172;
mass 4170703 0.1002  0.0010 10.8172;
mass 4170803 0.1002  0.0010 10.8172;
mass 4170903 0.1002  0.0010 10.8172;
mass 4171003 0.1002  0.0010 10.8172;
# Panel zones floor18
mass 4180603 0.1929  0.0019 20.8352;
mass 4180703 0.1929  0.0019 20.8352;
mass 4180803 0.1929  0.0019 20.8352;
mass 4180903 0.1929  0.0019 20.8352;
mass 4181003 0.1929  0.0019 20.8352;

# MASS ON THE GRAVITY SYSTEM

mass 11100 1.4933  1.4933 20.8352;	mass 11200 1.4933  1.4933 20.8352;
mass 21100 1.4872  1.4872 20.8352;	mass 21200 1.4872  1.4872 20.8352;
mass 31100 1.4872  1.4872 20.8352;	mass 31200 1.4872  1.4872 20.8352;
mass 41100 1.4872  1.4872 20.8352;	mass 41200 1.4872  1.4872 20.8352;
mass 51100 1.4872  1.4872 20.8352;	mass 51200 1.4872  1.4872 20.8352;
mass 61100 1.4872  1.4872 20.8352;	mass 61200 1.4872  1.4872 20.8352;
mass 71100 1.4872  1.4872 20.8352;	mass 71200 1.4872  1.4872 20.8352;
mass 81100 1.4690  1.4690 20.8352;	mass 81200 1.4690  1.4690 20.8352;
mass 91100 0.6809  0.6809 20.8352;	mass 91200 0.6809  0.6809 20.8352;
mass 101100 0.5927  0.5927 20.8352;	mass 101200 0.5927  0.5927 20.8352;
mass 111100 0.5046  0.5046 20.8352;	mass 111200 0.5046  0.5046 20.8352;
mass 121100 0.4163  0.4163 20.8352;	mass 121200 0.4163  0.4163 20.8352;
mass 131100 0.2391  0.2391 20.8352;	mass 131200 0.2391  0.2391 20.8352;
mass 141100 0.2391  0.2391 20.8352;	mass 141200 0.2391  0.2391 20.8352;
mass 151100 0.2391  0.2391 20.8352;	mass 151200 0.2391  0.2391 20.8352;
mass 161100 0.2404  0.2404 20.8352;	mass 161200 0.2404  0.2404 20.8352;
mass 171100 0.4630  0.4630 20.8352;	mass 171200 0.4630  0.4630 20.8352;

###################################################################################################
#                                            GRAVITY LOAD                                         #
###################################################################################################

pattern Plain 101 Linear {

	# MR Frame: Distributed beam element loads
	# Floor 2
	# Floor 3
	# Floor 4
	# Floor 5
	# Floor 6
	# Floor 7
	# Floor 8
	# Floor 9
	# Floor 10
	# Floor 11
	# Floor 12
	# Floor 13
	# Floor 14
	# Floor 15
	# Floor 16
	# Floor 17
	# Floor 18

	#  MR Frame: Point loads on columns
	# Floor2
	load 4020103 0.0 -41.7789 0.0;
	load 4020203 0.0 -41.7789 0.0;
	load 4020303 0.0 -41.7789 0.0;
	load 4020403 0.0 -41.7789 0.0;
	load 4020503 0.0 -41.7789 0.0;
	load 4020603 0.0 -41.7789 0.0;
	load 4020703 0.0 -41.7789 0.0;
	load 4020803 0.0 -41.7789 0.0;
	load 4020903 0.0 -41.7789 0.0;
	load 4021003 0.0 -41.7789 0.0;
	# Floor3
	load 4030103 0.0 -41.6094 0.0;
	load 4030203 0.0 -41.6094 0.0;
	load 4030303 0.0 -41.6094 0.0;
	load 4030403 0.0 -41.6094 0.0;
	load 4030503 0.0 -41.6094 0.0;
	load 4030603 0.0 -41.6094 0.0;
	load 4030703 0.0 -41.6094 0.0;
	load 4030803 0.0 -41.6094 0.0;
	load 4030903 0.0 -41.6094 0.0;
	load 4031003 0.0 -41.6094 0.0;
	# Floor4
	load 4040103 0.0 -41.6094 0.0;
	load 4040203 0.0 -41.6094 0.0;
	load 4040303 0.0 -41.6094 0.0;
	load 4040403 0.0 -41.6094 0.0;
	load 4040503 0.0 -41.6094 0.0;
	load 4040603 0.0 -41.6094 0.0;
	load 4040703 0.0 -41.6094 0.0;
	load 4040803 0.0 -41.6094 0.0;
	load 4040903 0.0 -41.6094 0.0;
	load 4041003 0.0 -41.6094 0.0;
	# Floor5
	load 4050103 0.0 -41.6094 0.0;
	load 4050203 0.0 -41.6094 0.0;
	load 4050303 0.0 -41.6094 0.0;
	load 4050403 0.0 -41.6094 0.0;
	load 4050503 0.0 -41.6094 0.0;
	load 4050603 0.0 -41.6094 0.0;
	load 4050703 0.0 -41.6094 0.0;
	load 4050803 0.0 -41.6094 0.0;
	load 4050903 0.0 -41.6094 0.0;
	load 4051003 0.0 -41.6094 0.0;
	# Floor6
	load 4060103 0.0 -41.6094 0.0;
	load 4060203 0.0 -41.6094 0.0;
	load 4060303 0.0 -41.6094 0.0;
	load 4060403 0.0 -41.6094 0.0;
	load 4060503 0.0 -41.6094 0.0;
	load 4060603 0.0 -41.6094 0.0;
	load 4060703 0.0 -41.6094 0.0;
	load 4060803 0.0 -41.6094 0.0;
	load 4060903 0.0 -41.6094 0.0;
	load 4061003 0.0 -41.6094 0.0;
	# Floor7
	load 4070103 0.0 -41.6094 0.0;
	load 4070203 0.0 -41.6094 0.0;
	load 4070303 0.0 -41.6094 0.0;
	load 4070403 0.0 -41.6094 0.0;
	load 4070503 0.0 -41.6094 0.0;
	load 4070603 0.0 -41.6094 0.0;
	load 4070703 0.0 -41.6094 0.0;
	load 4070803 0.0 -41.6094 0.0;
	load 4070903 0.0 -41.6094 0.0;
	load 4071003 0.0 -41.6094 0.0;
	# Floor8
	load 4080103 0.0 -41.6094 0.0;
	load 4080203 0.0 -41.6094 0.0;
	load 4080303 0.0 -41.6094 0.0;
	load 4080403 0.0 -41.6094 0.0;
	load 4080503 0.0 -41.6094 0.0;
	load 4080603 0.0 -41.6094 0.0;
	load 4080703 0.0 -41.6094 0.0;
	load 4080803 0.0 -41.6094 0.0;
	load 4080903 0.0 -41.6094 0.0;
	load 4081003 0.0 -41.6094 0.0;
	# Floor9
	load 4090103 0.0 -41.1007 0.0;
	load 4090203 0.0 -41.1007 0.0;
	load 4090303 0.0 -41.1007 0.0;
	load 4090403 0.0 -41.1007 0.0;
	load 4090503 0.0 -41.1007 0.0;
	load 4090603 0.0 -41.1007 0.0;
	load 4090703 0.0 -41.1007 0.0;
	load 4090803 0.0 -41.1007 0.0;
	load 4090903 0.0 -41.1007 0.0;
	load 4091003 0.0 -41.1007 0.0;
	# Floor10
	load 4100103 0.0 -41.7282 0.0;
	load 4100203 0.0 -41.7282 0.0;
	load 4100303 0.0 -41.7282 0.0;
	load 4100403 0.0 -41.7282 0.0;
	load 4100503 0.0 -41.7282 0.0;
	load 4100603 0.0 -41.7282 0.0;
	load 4100703 0.0 -41.7282 0.0;
	load 4100803 0.0 -41.7282 0.0;
	load 4100903 0.0 -41.7282 0.0;
	load 4101003 0.0 -41.7282 0.0;
	# Floor11
	load 4110203 0.0 -41.3477 0.0;
	load 4110303 0.0 -41.3477 0.0;
	load 4110403 0.0 -41.3477 0.0;
	load 4110503 0.0 -41.3477 0.0;
	load 4110603 0.0 -41.3477 0.0;
	load 4110703 0.0 -41.3477 0.0;
	load 4110803 0.0 -41.3477 0.0;
	load 4110903 0.0 -41.3477 0.0;
	load 4111003 0.0 -41.3477 0.0;
	# Floor12
	load 4120303 0.0 -40.8775 0.0;
	load 4120403 0.0 -40.8775 0.0;
	load 4120503 0.0 -40.8775 0.0;
	load 4120603 0.0 -40.8775 0.0;
	load 4120703 0.0 -40.8775 0.0;
	load 4120803 0.0 -40.8775 0.0;
	load 4120903 0.0 -40.8775 0.0;
	load 4121003 0.0 -40.8775 0.0;
	# Floor13
	load 4130403 0.0 -40.2825 0.0;
	load 4130503 0.0 -40.2825 0.0;
	load 4130603 0.0 -40.2825 0.0;
	load 4130703 0.0 -40.2825 0.0;
	load 4130803 0.0 -40.2825 0.0;
	load 4130903 0.0 -40.2825 0.0;
	load 4131003 0.0 -40.2825 0.0;
	# Floor14
	load 4140603 0.0 -38.4708 0.0;
	load 4140703 0.0 -38.4708 0.0;
	load 4140803 0.0 -38.4708 0.0;
	load 4140903 0.0 -38.4708 0.0;
	load 4141003 0.0 -38.4708 0.0;
	# Floor15
	load 4150603 0.0 -38.4708 0.0;
	load 4150703 0.0 -38.4708 0.0;
	load 4150803 0.0 -38.4708 0.0;
	load 4150903 0.0 -38.4708 0.0;
	load 4151003 0.0 -38.4708 0.0;
	# Floor16
	load 4160603 0.0 -38.4708 0.0;
	load 4160703 0.0 -38.4708 0.0;
	load 4160803 0.0 -38.4708 0.0;
	load 4160903 0.0 -38.4708 0.0;
	load 4161003 0.0 -38.4708 0.0;
	# Floor17
	load 4170603 0.0 -38.6716 0.0;
	load 4170703 0.0 -38.6716 0.0;
	load 4170803 0.0 -38.6716 0.0;
	load 4170903 0.0 -38.6716 0.0;
	load 4171003 0.0 -38.6716 0.0;
	# Floor18
	load 4180603 0.0 -74.4857 0.0;
	load 4180703 0.0 -74.4857 0.0;
	load 4180803 0.0 -74.4857 0.0;
	load 4180903 0.0 -74.4857 0.0;
	load 4181003 0.0 -74.4857 0.0;

	#  Gravity Frame: Point loads on columns
	load 21100 0.0 -576.5489 0.0;
	load 21200 0.0 -576.5489 0.0;
	load 31100 0.0 -574.2091 0.0;
	load 31200 0.0 -574.2091 0.0;
	load 41100 0.0 -574.2091 0.0;
	load 41200 0.0 -574.2091 0.0;
	load 51100 0.0 -574.2091 0.0;
	load 51200 0.0 -574.2091 0.0;
	load 61100 0.0 -574.2091 0.0;
	load 61200 0.0 -574.2091 0.0;
	load 71100 0.0 -574.2091 0.0;
	load 71200 0.0 -574.2091 0.0;
	load 81100 0.0 -574.2091 0.0;
	load 81200 0.0 -574.2091 0.0;
	load 91100 0.0 -567.1898 0.0;
	load 91200 0.0 -567.1898 0.0;
	load 101100 0.0 -262.8879 0.0;
	load 101200 0.0 -262.8879 0.0;
	load 111100 0.0 -228.8598 0.0;
	load 111200 0.0 -228.8598 0.0;
	load 121100 0.0 -194.8103 0.0;
	load 121200 0.0 -194.8103 0.0;
	load 131100 0.0 -160.7270 0.0;
	load 131200 0.0 -160.7270 0.0;
	load 141100 0.0 -92.3298 0.0;
	load 141200 0.0 -92.3298 0.0;
	load 151100 0.0 -92.3298 0.0;
	load 151200 0.0 -92.3298 0.0;
	load 161100 0.0 -92.3298 0.0;
	load 161200 0.0 -92.3298 0.0;
	load 171100 0.0 -92.8119 0.0;
	load 171200 0.0 -92.8119 0.0;
	load 181100 0.0 -178.7657 0.0;
	load 181200 0.0 -178.7657 0.0;

}

# ----- Gravity analyses commands ----- #
constraints Transformation;
numberer RCM;
system BandGeneral;
test RelativeEnergyIncr 1.0e-05 20;
algorithm Newton;
integrator LoadControl 0.10;
analysis Static;
if {[analyze 10]} {puts "Application of gravity load failed"};
loadConst -time 0.0;
remove recorders;

###################################################################################################
###################################################################################################
                                        puts "Gravity Done"                                        
###################################################################################################
###################################################################################################

###################################################################################################
#                                            CONTROL NODES                                        #
###################################################################################################

set ctrl_nodes {
	11000
	4021003
	4031003
	4041003
	4051003
	4061003
	4071003
	4081003
	4091003
	4101003
	4111003
	4121003
	4131003
	4141003
	4151003
	4161003
	4171003
	4181003
};

set hVector {
	168
	156
	156
	156
	156
	156
	156
	120
	120
	120
	120
	120
	120
	120
	120
	127
	150
};

###################################################################################################
#                                        EIGEN VALUE ANALYSIS                                     #
###################################################################################################

set num_modes 3
set dof 1
set ctrl_nodes2 $ctrl_nodes
set filename_eigen ""
set omegas [modal $num_modes $filename_eigen]

###################################################################################################
###################################################################################################
                                   puts "Eigen Analysis Done"                                      
###################################################################################################
###################################################################################################

###################################################################################################
#                                               DAMPING                                           #
###################################################################################################

# Calculate Rayleigh Damping constnats
set wI [lindex $omegas $DampModeI-1]
set wJ [lindex $omegas $DampModeJ-1]
set a0 [expr $zeta*2.0*$wI*$wJ/($wI+$wJ)];
set a1 [expr $zeta*2.0/($wI+$wJ)];
set a1_mod [expr $a1*(1.0+$n)/$n];


# Beam elastic elements
region 1 -ele 1020100 1020200 1020300 1020400 1020500 1020700 1020800 1020900 1030100 1030200 1030300 1030400 1030500 1030600 1030700 1030800 1030900 1040100 1040200 1040300 1040400 1040500 1040600 1040700 1040800 1040900 1050100 1050200 1050300 1050400 1050500 1050600 1050700 1050800 1050900 1060100 1060200 1060300 1060400 1060500 1060600 1060700 1060800 1060900 1070100 1070200 1070300 1070400 1070500 1070600 1070700 1070800 1070900 1080100 1080200 1080300 1080400 1080500 1080600 1080700 1080800 1080900 1090100 1090200 1090300 1090400 1090500 1090600 1090700 1090800 1090900 1100100 1100200 1100300 1100400 1100500 1100600 1100700 1100800 1100900 1110200 1110300 1110400 1110500 1110600 1110700 1110800 1110900 1120300 1120400 1120500 1120600 1120700 1120800 1120900 1130400 1130500 1130600 1130700 1130800 1130900 1140600 1140700 1140800 1140900 1150600 1150700 1150800 1150900 1160600 1160700 1160800 1160900 1170600 1170700 1170800 1170900 1180600 1180700 1180800 1180900 503000 504000 505000 506000 507000 508000 509000 510000 511000 512000 513000 514000 515000 516000 517000 518000 519000 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Column elastic elements
region 2 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2070100 2080100 2090100 2010200 2020200 2030200 2040200 2050200 2060200 2070200 2080200 2090200 2100200 2010300 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2090300 2100300 2110300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2090400 2100400 2110400 2120400 2010500 2020500 2030500 2040500 2050500 2060500 2070500 2080500 2090500 2100500 2110500 2120500 2010600 2020600 2030600 2040600 2050600 2060600 2070600 2080600 2090600 2100600 2110600 2120600 2130600 2140600 2150600 2160600 2170600 2010700 2020700 2030700 2040700 2050700 2060700 2070700 2080700 2090700 2100700 2110700 2120700 2130700 2140700 2150700 2160700 2170700 2010800 2020800 2030800 2040800 2050800 2060800 2070800 2080800 2090800 2100800 2110800 2120800 2130800 2140800 2150800 2160800 2170800 2010900 2020900 2030900 2040900 2050900 2060900 2070900 2080900 2090900 2100900 2110900 2120900 2130900 2140900 2150900 2160900 2170900 2011000 2021000 2031000 2041000 2051000 2061000 2071000 2081000 2091000 2101000 2111000 2121000 2131000 2141000 2151000 2161000 2171000 602100 602200 603100 603200 604100 604200 605100 605200 606100 606200 607100 607200 608100 608200 609100 609200 610100 610200 611100 611200 612100 612200 613100 613200 614100 614200 615100 615200 616100 616200 617100 617200 618100 618200 2020102 2040102 2060102 2080102 2020202 2040202 2060202 2080202 2100202 2020302 2040302 2060302 2080302 2100302 2020402 2040402 2060402 2080402 2100402 2120402 2020502 2040502 2060502 2080502 2100502 2120502 2020602 2040602 2060602 2080602 2100602 2120602 2140602 2160602 2020702 2040702 2060702 2080702 2100702 2120702 2140702 2160702 2020802 2040802 2060802 2080802 2100802 2120802 2140802 2160802 2020902 2040902 2060902 2080902 2100902 2120902 2140902 2160902 2021002 2041002 2061002 2081002 2101002 2121002 2141002 2161002 -rayleigh 0.0 0.0 $a1_mod 0.0;

# Hinge elements [beam springs, column springs]
region 3 -ele 1020102 1020104 1020202 1020204 1020302 1020304 1020402 1020404 1020502 1020504 1020702 1020704 1020802 1020804 1020902 1020904 1030102 1030104 1030202 1030204 1030302 1030304 1030402 1030404 1030502 1030504 1030602 1030604 1030702 1030704 1030802 1030804 1030902 1030904 1040102 1040104 1040202 1040204 1040302 1040304 1040402 1040404 1040502 1040504 1040602 1040604 1040702 1040704 1040802 1040804 1040902 1040904 1050102 1050104 1050202 1050204 1050302 1050304 1050402 1050404 1050502 1050504 1050602 1050604 1050702 1050704 1050802 1050804 1050902 1050904 1060102 1060104 1060202 1060204 1060302 1060304 1060402 1060404 1060502 1060504 1060602 1060604 1060702 1060704 1060802 1060804 1060902 1060904 1070102 1070104 1070202 1070204 1070302 1070304 1070402 1070404 1070502 1070504 1070602 1070604 1070702 1070704 1070802 1070804 1070902 1070904 1080102 1080104 1080202 1080204 1080302 1080304 1080402 1080404 1080502 1080504 1080602 1080604 1080702 1080704 1080802 1080804 1080902 1080904 1090102 1090104 1090202 1090204 1090302 1090304 1090402 1090404 1090502 1090504 1090602 1090604 1090702 1090704 1090802 1090804 1090902 1090904 1100102 1100104 1100202 1100204 1100302 1100304 1100402 1100404 1100502 1100504 1100602 1100604 1100702 1100704 1100802 1100804 1100902 1100904 1110202 1110204 1110302 1110304 1110402 1110404 1110502 1110504 1110602 1110604 1110702 1110704 1110802 1110804 1110902 1110904 1120302 1120304 1120402 1120404 1120502 1120504 1120602 1120604 1120702 1120704 1120802 1120804 1120902 1120904 1130402 1130404 1130502 1130504 1130602 1130604 1130702 1130704 1130802 1130804 1130902 1130904 1140602 1140604 1140702 1140704 1140802 1140804 1140902 1140904 1150602 1150604 1150702 1150704 1150802 1150804 1150902 1150904 1160602 1160604 1160702 1160704 1160802 1160804 1160902 1160904 1170602 1170604 1170702 1170704 1170802 1170804 1170902 1170904 1180602 1180604 1180702 1180704 1180802 1180804 1180902 1180904 503002 503004 504002 504004 505002 505004 506002 506004 507002 507004 508002 508004 509002 509004 510002 510004 511002 511004 512002 512004 513002 513004 514002 514004 515002 515004 516002 516004 517002 517004 518002 518004 519002 519004 602101 602102 602201 602202 603101 603102 603201 603202 604101 604102 604201 604202 605101 605102 605201 605202 606101 606102 606201 606202 607101 607102 607201 607202 608101 608102 608201 608202 609101 609102 609201 609202 610101 610102 610201 610202 611101 611102 611201 611202 612101 612102 612201 612202 613101 613102 613201 613202 614101 614102 614201 614202 615101 615102 615201 615202 616101 616102 616201 616202 617101 617102 617201 617202 618101 618102 618201 618202 2010101 2010102 2010201 2010202 2010301 2010302 2010401 2010402 2010501 2010502 2010601 2010602 2010701 2010702 2010801 2010802 2010901 2010902 2011001 2011002 2030101 2030102 2030201 2030202 2030301 2030302 2030401 2030402 2030501 2030502 2030601 2030602 2030701 2030702 2030801 2030802 2030901 2030902 2031001 2031002 2050101 2050102 2050201 2050202 2050301 2050302 2050401 2050402 2050501 2050502 2050601 2050602 2050701 2050702 2050801 2050802 2050901 2050902 2051001 2051002 2070101 2070102 2070201 2070202 2070301 2070302 2070401 2070402 2070501 2070502 2070601 2070602 2070701 2070702 2070801 2070802 2070901 2070902 2071001 2071002 2090101 2090102 2090201 2090202 2090301 2090302 2090401 2090402 2090501 2090502 2090601 2090602 2090701 2090702 2090801 2090802 2090901 2090902 2091001 2091002 2110301 2110302 2110401 2110402 2110501 2110502 2110601 2110602 2110701 2110702 2110801 2110802 2110901 2110902 2111001 2111002 2130601 2130602 2130701 2130702 2130801 2130802 2130901 2130902 2131001 2131002 2150601 2150602 2150701 2150702 2150801 2150802 2150901 2150902 2151001 2151002 2170601 2170602 2170701 2170702 2170801 2170802 2170901 2170902 2171001 2171002 -rayleigh 0.0 0.0 [expr $a1_mod/$n] 0.0;

# Nodes with mass
region 4 -nodes 4020103 4020203 4020303 4020403 4020503 4020603 4020703 4020803 4020903 4021003 4030103 4030203 4030303 4030403 4030503 4030603 4030703 4030803 4030903 4031003 4040103 4040203 4040303 4040403 4040503 4040603 4040703 4040803 4040903 4041003 4050103 4050203 4050303 4050403 4050503 4050603 4050703 4050803 4050903 4051003 4060103 4060203 4060303 4060403 4060503 4060603 4060703 4060803 4060903 4061003 4070103 4070203 4070303 4070403 4070503 4070603 4070703 4070803 4070903 4071003 4080103 4080203 4080303 4080403 4080503 4080603 4080703 4080803 4080903 4081003 4090103 4090203 4090303 4090403 4090503 4090603 4090703 4090803 4090903 4091003 4100103 4100203 4100303 4100403 4100503 4100603 4100703 4100803 4100903 4101003 4110203 4110303 4110403 4110503 4110603 4110703 4110803 4110903 4111003 4120303 4120403 4120503 4120603 4120703 4120803 4120903 4121003 4130403 4130503 4130603 4130703 4130803 4130903 4131003 4140603 4140703 4140803 4140903 4141003 4150603 4150703 4150803 4150903 4151003 4160603 4160703 4160803 4160903 4161003 4170603 4170703 4170803 4170903 4171003 4180603 4180703 4180803 4180903 4181003 -rayleigh $a0 0.0 0.0 0.0;

###################################################################################################
#                                     DETAILED RECORDERS                                          #
###################################################################################################

if {$addBasicRecorders == 1} {

	# Recorders for lateral displacement on each panel zone
	recorder Node -file $outdir/all_disp.out -dT 0.01 -time -nodes 4020103 4020203 4020303 4020403 4020503 4020603 4020703 4020803 4020903 4021003 4030103 4030203 4030303 4030403 4030503 4030603 4030703 4030803 4030903 4031003 4040103 4040203 4040303 4040403 4040503 4040603 4040703 4040803 4040903 4041003 4050103 4050203 4050303 4050403 4050503 4050603 4050703 4050803 4050903 4051003 4060103 4060203 4060303 4060403 4060503 4060603 4060703 4060803 4060903 4061003 4070103 4070203 4070303 4070403 4070503 4070603 4070703 4070803 4070903 4071003 4080103 4080203 4080303 4080403 4080503 4080603 4080703 4080803 4080903 4081003 4090103 4090203 4090303 4090403 4090503 4090603 4090703 4090803 4090903 4091003 4100103 4100203 4100303 4100403 4100503 4100603 4100703 4100803 4100903 4101003 4110203 4110303 4110403 4110503 4110603 4110703 4110803 4110903 4111003 4120303 4120403 4120503 4120603 4120703 4120803 4120903 4121003 4130403 4130503 4130603 4130703 4130803 4130903 4131003 4140603 4140703 4140803 4140903 4141003 4150603 4150703 4150803 4150903 4151003 4160603 4160703 4160803 4160903 4161003 4170603 4170703 4170803 4170903 4171003 4180603 4180703 4180803 4180903 4181003 -dof 1 disp;

}

if {$addBasicRecorders == 1} {

	# Recorders for beam fracture boolean
	# Left-bottom flange
	recorder Element -file $outdir/frac_LB.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 7 failure;

	# Left-top flange
	recorder Element -file $outdir/frac_LT.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 2 failure;

	# Right-bottom flange
	recorder Element -file $outdir/frac_RB.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 7 failure;

	# Right-top flange
	recorder Element -file $outdir/frac_RT.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 2 failure;

	# Recorders for beam fracture index
	# Left-bottom flange
	recorder Element -file $outdir/FI_LB.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 7 damage;

	# Left-top flange
	recorder Element -file $outdir/FI_LT.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 2 damage;

	# Right-bottom flange
	recorder Element -file $outdir/FI_RB.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 7 damage;

	# Right-top flange
	recorder Element -file $outdir/FI_RT.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 2 damage;

}

if {$addDetailedRecorders == 1} {

	# Recorders for beam fracture index
	# Left-bottom flange
	recorder Element -file $outdir/ss_LB.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 7 stressStrain;

	# Left-top flange
	recorder Element -file $outdir/ss_LT.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 2 stressStrain;

	# Right-bottom flange
	recorder Element -file $outdir/ss_RB.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 7 stressStrain;

	# Right-top flange
	recorder Element -file $outdir/ss_RT.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 2 stressStrain;

	# Recorders for slab fiber stressStrain

	# Left-Concrete
	recorder Element -file $outdir/slabComp_L.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 10 stressStrain;

	# Left-Steel
	recorder Element -file $outdir/slabTen_L.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 11 stressStrain;

	# Right-Concrete
	recorder Element -file $outdir/slabComp_R.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 10 stressStrain;

	# Right-Steel
	recorder Element -file $outdir/slabTen_R.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 11 stressStrain;

	# Recorders for web fibers

	# Left-web1
	recorder Element -file $outdir/webfiber_L1.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 12 stressStrain;

	# Left-web2
	recorder Element -file $outdir/webfiber_L2.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 13 stressStrain;

	# Left-web3
	recorder Element -file $outdir/webfiber_L3.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 14 stressStrain;


	# Left-web4
	recorder Element -file $outdir/webfiber_L4.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section fiber 15 stressStrain;


	# Right-web1
	recorder Element -file $outdir/webfiber_R1.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 12 stressStrain;

	# Right-web2
	recorder Element -file $outdir/webfiber_R2.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 13 stressStrain;

	# Right-web3
	recorder Element -file $outdir/webfiber_R3.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 14 stressStrain;


	# Right-web4
	recorder Element -file $outdir/webfiber_R4.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section fiber 15 stressStrain;

	# Recorders beam fiber-section element

	# Left
	recorder Element -file $outdir/def_left.out -dT 0.01 -ele 1020105 1020205 1020305 1020405 1020505 1020705 1020805 1020905 1030105 1030205 1030305 1030405 1030505 1030605 1030705 1030805 1030905 1040105 1040205 1040305 1040405 1040505 1040605 1040705 1040805 1040905 1050105 1050205 1050305 1050405 1050505 1050605 1050705 1050805 1050905 1060105 1060205 1060305 1060405 1060505 1060605 1060705 1060805 1060905 1070105 1070205 1070305 1070405 1070505 1070605 1070705 1070805 1070905 1080105 1080205 1080305 1080405 1080505 1080605 1080705 1080805 1080905 1090105 1090205 1090305 1090405 1090505 1090605 1090705 1090805 1090905 1100105 1100205 1100305 1100405 1100505 1100605 1100705 1100805 1100905 1110205 1110305 1110405 1110505 1110605 1110705 1110805 1110905 1120305 1120405 1120505 1120605 1120705 1120805 1120905 1130405 1130505 1130605 1130705 1130805 1130905 1140605 1140705 1140805 1140905 1150605 1150705 1150805 1150905 1160605 1160705 1160805 1160905 1170605 1170705 1170805 1170905 1180605 1180705 1180805 1180905 section deformation;

	# Right
	recorder Element -file $outdir/def_right.out -dT 0.01 -ele 1020106 1020206 1020306 1020406 1020506 1020706 1020806 1020906 1030106 1030206 1030306 1030406 1030506 1030606 1030706 1030806 1030906 1040106 1040206 1040306 1040406 1040506 1040606 1040706 1040806 1040906 1050106 1050206 1050306 1050406 1050506 1050606 1050706 1050806 1050906 1060106 1060206 1060306 1060406 1060506 1060606 1060706 1060806 1060906 1070106 1070206 1070306 1070406 1070506 1070606 1070706 1070806 1070906 1080106 1080206 1080306 1080406 1080506 1080606 1080706 1080806 1080906 1090106 1090206 1090306 1090406 1090506 1090606 1090706 1090806 1090906 1100106 1100206 1100306 1100406 1100506 1100606 1100706 1100806 1100906 1110206 1110306 1110406 1110506 1110606 1110706 1110806 1110906 1120306 1120406 1120506 1120606 1120706 1120806 1120906 1130406 1130506 1130606 1130706 1130806 1130906 1140606 1140706 1140806 1140906 1150606 1150706 1150806 1150906 1160606 1160706 1160806 1160906 1170606 1170706 1170806 1170906 1180606 1180706 1180806 1180906 section deformation;

}

if {$addBasicRecorders == 1} {

	# Recorders beam hinge element

	# Left
	recorder Element -file $outdir/hinge_left.out -dT 0.01 -ele 1020102 1020202 1020302 1020402 1020502 1020702 1020802 1020902 1030102 1030202 1030302 1030402 1030502 1030602 1030702 1030802 1030902 1040102 1040202 1040302 1040402 1040502 1040602 1040702 1040802 1040902 1050102 1050202 1050302 1050402 1050502 1050602 1050702 1050802 1050902 1060102 1060202 1060302 1060402 1060502 1060602 1060702 1060802 1060902 1070102 1070202 1070302 1070402 1070502 1070602 1070702 1070802 1070902 1080102 1080202 1080302 1080402 1080502 1080602 1080702 1080802 1080902 1090102 1090202 1090302 1090402 1090502 1090602 1090702 1090802 1090902 1100102 1100202 1100302 1100402 1100502 1100602 1100702 1100802 1100902 1110202 1110302 1110402 1110502 1110602 1110702 1110802 1110902 1120302 1120402 1120502 1120602 1120702 1120802 1120902 1130402 1130502 1130602 1130702 1130802 1130902 1140602 1140702 1140802 1140902 1150602 1150702 1150802 1150902 1160602 1160702 1160802 1160902 1170602 1170702 1170802 1170902 1180602 1180702 1180802 1180902 deformation;

	# Right
	recorder Element -file $outdir/hinge_right.out -dT 0.01 -ele 1020104 1020204 1020304 1020404 1020504 1020704 1020804 1020904 1030104 1030204 1030304 1030404 1030504 1030604 1030704 1030804 1030904 1040104 1040204 1040304 1040404 1040504 1040604 1040704 1040804 1040904 1050104 1050204 1050304 1050404 1050504 1050604 1050704 1050804 1050904 1060104 1060204 1060304 1060404 1060504 1060604 1060704 1060804 1060904 1070104 1070204 1070304 1070404 1070504 1070604 1070704 1070804 1070904 1080104 1080204 1080304 1080404 1080504 1080604 1080704 1080804 1080904 1090104 1090204 1090304 1090404 1090504 1090604 1090704 1090804 1090904 1100104 1100204 1100304 1100404 1100504 1100604 1100704 1100804 1100904 1110204 1110304 1110404 1110504 1110604 1110704 1110804 1110904 1120304 1120404 1120504 1120604 1120704 1120804 1120904 1130404 1130504 1130604 1130704 1130804 1130904 1140604 1140704 1140804 1140904 1150604 1150704 1150804 1150904 1160604 1160704 1160804 1160904 1170604 1170704 1170804 1170904 1180604 1180704 1180804 1180904 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/hinge_right_force.out -dT 0.01 -ele 1020104 1020204 1020304 1020404 1020504 1020704 1020804 1020904 1030104 1030204 1030304 1030404 1030504 1030604 1030704 1030804 1030904 1040104 1040204 1040304 1040404 1040504 1040604 1040704 1040804 1040904 1050104 1050204 1050304 1050404 1050504 1050604 1050704 1050804 1050904 1060104 1060204 1060304 1060404 1060504 1060604 1060704 1060804 1060904 1070104 1070204 1070304 1070404 1070504 1070604 1070704 1070804 1070904 1080104 1080204 1080304 1080404 1080504 1080604 1080704 1080804 1080904 1090104 1090204 1090304 1090404 1090504 1090604 1090704 1090804 1090904 1100104 1100204 1100304 1100404 1100504 1100604 1100704 1100804 1100904 1110204 1110304 1110404 1110504 1110604 1110704 1110804 1110904 1120304 1120404 1120504 1120604 1120704 1120804 1120904 1130404 1130504 1130604 1130704 1130804 1130904 1140604 1140704 1140804 1140904 1150604 1150704 1150804 1150904 1160604 1160704 1160804 1160904 1170604 1170704 1170804 1170904 1180604 1180704 1180804 1180904 force;

	recorder Element -file $outdir/hinge_left_force.out -dT 0.01 -ele 1020102 1020202 1020302 1020402 1020502 1020702 1020802 1020902 1030102 1030202 1030302 1030402 1030502 1030602 1030702 1030802 1030902 1040102 1040202 1040302 1040402 1040502 1040602 1040702 1040802 1040902 1050102 1050202 1050302 1050402 1050502 1050602 1050702 1050802 1050902 1060102 1060202 1060302 1060402 1060502 1060602 1060702 1060802 1060902 1070102 1070202 1070302 1070402 1070502 1070602 1070702 1070802 1070902 1080102 1080202 1080302 1080402 1080502 1080602 1080702 1080802 1080902 1090102 1090202 1090302 1090402 1090502 1090602 1090702 1090802 1090902 1100102 1100202 1100302 1100402 1100502 1100602 1100702 1100802 1100902 1110202 1110302 1110402 1110502 1110602 1110702 1110802 1110902 1120302 1120402 1120502 1120602 1120702 1120802 1120902 1130402 1130502 1130602 1130702 1130802 1130902 1140602 1140702 1140802 1140902 1150602 1150702 1150802 1150902 1160602 1160702 1160802 1160902 1170602 1170702 1170802 1170902 1180602 1180702 1180802 1180902 force;
}

if {$addDetailedRecorders == 1} {

	# Recorders for beam internal forces
	recorder Element -file $outdir/beam_forces.out -dT 0.01 -ele 1020100 1020200 1020300 1020400 1020500 1020700 1020800 1020900 1030100 1030200 1030300 1030400 1030500 1030600 1030700 1030800 1030900 1040100 1040200 1040300 1040400 1040500 1040600 1040700 1040800 1040900 1050100 1050200 1050300 1050400 1050500 1050600 1050700 1050800 1050900 1060100 1060200 1060300 1060400 1060500 1060600 1060700 1060800 1060900 1070100 1070200 1070300 1070400 1070500 1070600 1070700 1070800 1070900 1080100 1080200 1080300 1080400 1080500 1080600 1080700 1080800 1080900 1090100 1090200 1090300 1090400 1090500 1090600 1090700 1090800 1090900 1100100 1100200 1100300 1100400 1100500 1100600 1100700 1100800 1100900 1110200 1110300 1110400 1110500 1110600 1110700 1110800 1110900 1120300 1120400 1120500 1120600 1120700 1120800 1120900 1130400 1130500 1130600 1130700 1130800 1130900 1140600 1140700 1140800 1140900 1150600 1150700 1150800 1150900 1160600 1160700 1160800 1160900 1170600 1170700 1170800 1170900 1180600 1180700 1180800 1180900 globalForce;

}

if {$addDetailedRecorders == 1} {

	# Recorders for column internal forces
	recorder Element -file $outdir/column_forces.out -dT 0.01 -ele 2010100 2020100 2030100 2040100 2050100 2060100 2070100 2080100 2090100 2010200 2020200 2030200 2040200 2050200 2060200 2070200 2080200 2090200 2100200 2010300 2020300 2030300 2040300 2050300 2060300 2070300 2080300 2090300 2100300 2110300 2010400 2020400 2030400 2040400 2050400 2060400 2070400 2080400 2090400 2100400 2110400 2120400 2010500 2020500 2030500 2040500 2050500 2060500 2070500 2080500 2090500 2100500 2110500 2120500 2010600 2020600 2030600 2040600 2050600 2060600 2070600 2080600 2090600 2100600 2110600 2120600 2130600 2140600 2150600 2160600 2170600 2010700 2020700 2030700 2040700 2050700 2060700 2070700 2080700 2090700 2100700 2110700 2120700 2130700 2140700 2150700 2160700 2170700 2010800 2020800 2030800 2040800 2050800 2060800 2070800 2080800 2090800 2100800 2110800 2120800 2130800 2140800 2150800 2160800 2170800 2010900 2020900 2030900 2040900 2050900 2060900 2070900 2080900 2090900 2100900 2110900 2120900 2130900 2140900 2150900 2160900 2170900 2011000 2021000 2031000 2041000 2051000 2061000 2071000 2081000 2091000 2101000 2111000 2121000 2131000 2141000 2151000 2161000 2171000 globalForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column splices
	recorder Element -file $outdir/ss_splice.out -dT 0.01 -ele 2020105 2040105 2060105 2080105 2020205 2040205 2060205 2080205 2100205 2020305 2040305 2060305 2080305 2100305 2020405 2040405 2060405 2080405 2100405 2120405 2020505 2040505 2060505 2080505 2100505 2120505 2020605 2040605 2060605 2080605 2100605 2120605 2140605 2160605 2020705 2040705 2060705 2080705 2100705 2120705 2140705 2160705 2020805 2040805 2060805 2080805 2100805 2120805 2140805 2160805 2020905 2040905 2060905 2080905 2100905 2120905 2140905 2160905 2021005 2041005 2061005 2081005 2101005 2121005 2141005 2161005 section fiber 0 stressStrain;

	recorder Element -file $outdir/def_splice.out -dT 0.01 -ele 2020105 2040105 2060105 2080105 2020205 2040205 2060205 2080205 2100205 2020305 2040305 2060305 2080305 2100305 2020405 2040405 2060405 2080405 2100405 2120405 2020505 2040505 2060505 2080505 2100505 2120505 2020605 2040605 2060605 2080605 2100605 2120605 2140605 2160605 2020705 2040705 2060705 2080705 2100705 2120705 2140705 2160705 2020805 2040805 2060805 2080805 2100805 2120805 2140805 2160805 2020905 2040905 2060905 2080905 2100905 2120905 2140905 2160905 2021005 2041005 2061005 2081005 2101005 2121005 2141005 2161005  deformation;

	recorder Element -file $outdir/force_splice.out -dT 0.01 -ele 2020105 2040105 2060105 2080105 2020205 2040205 2060205 2080205 2100205 2020305 2040305 2060305 2080305 2100305 2020405 2040405 2060405 2080405 2100405 2120405 2020505 2040505 2060505 2080505 2100505 2120505 2020605 2040605 2060605 2080605 2100605 2120605 2140605 2160605 2020705 2040705 2060705 2080705 2100705 2120705 2140705 2160705 2020805 2040805 2060805 2080805 2100805 2120805 2140805 2160805 2020905 2040905 2060905 2080905 2100905 2120905 2140905 2160905 2021005 2041005 2061005 2081005 2101005 2121005 2141005 2161005  localForce;

}

if {$addBasicRecorders == 1} {

	# Recorders column hinges
	# Bottom
	recorder Element -file $outdir/hinge_bot.out -dT 0.01 -ele 2020103 2040103 2060103 2080103 2020203 2040203 2060203 2080203 2100203 2020303 2040303 2060303 2080303 2100303 2020403 2040403 2060403 2080403 2100403 2120403 2020503 2040503 2060503 2080503 2100503 2120503 2020603 2040603 2060603 2080603 2100603 2120603 2140603 2160603 2020703 2040703 2060703 2080703 2100703 2120703 2140703 2160703 2020803 2040803 2060803 2080803 2100803 2120803 2140803 2160803 2020903 2040903 2060903 2080903 2100903 2120903 2140903 2160903 2021003 2041003 2061003 2081003 2101003 2121003 2141003 2161003 2010101 2010201 2010301 2010401 2010501 2010601 2010701 2010801 2010901 2011001 2030101 2030201 2030301 2030401 2030501 2030601 2030701 2030801 2030901 2031001 2050101 2050201 2050301 2050401 2050501 2050601 2050701 2050801 2050901 2051001 2070101 2070201 2070301 2070401 2070501 2070601 2070701 2070801 2070901 2071001 2090101 2090201 2090301 2090401 2090501 2090601 2090701 2090801 2090901 2091001 2110301 2110401 2110501 2110601 2110701 2110801 2110901 2111001 2130601 2130701 2130801 2130901 2131001 2150601 2150701 2150801 2150901 2151001 2170601 2170701 2170801 2170901 2171001 deformation;
	# Top
	recorder Element -file $outdir/hinge_top.out -dT 0.01 -ele 2020104 2040104 2060104 2080104 2020204 2040204 2060204 2080204 2100204 2020304 2040304 2060304 2080304 2100304 2020404 2040404 2060404 2080404 2100404 2120404 2020504 2040504 2060504 2080504 2100504 2120504 2020604 2040604 2060604 2080604 2100604 2120604 2140604 2160604 2020704 2040704 2060704 2080704 2100704 2120704 2140704 2160704 2020804 2040804 2060804 2080804 2100804 2120804 2140804 2160804 2020904 2040904 2060904 2080904 2100904 2120904 2140904 2160904 2021004 2041004 2061004 2081004 2101004 2121004 2141004 2161004 2010102 2010202 2010302 2010402 2010502 2010602 2010702 2010802 2010902 2011002 2030102 2030202 2030302 2030402 2030502 2030602 2030702 2030802 2030902 2031002 2050102 2050202 2050302 2050402 2050502 2050602 2050702 2050802 2050902 2051002 2070102 2070202 2070302 2070402 2070502 2070602 2070702 2070802 2070902 2071002 2090102 2090202 2090302 2090402 2090502 2090602 2090702 2090802 2090902 2091002 2110302 2110402 2110502 2110602 2110702 2110802 2110902 2111002 2130602 2130702 2130802 2130902 2131002 2150602 2150702 2150802 2150902 2151002 2170602 2170702 2170802 2170902 2171002 deformation;
}

if {$addDetailedRecorders == 1} {

	# Bottom
	recorder Element -file $outdir/hinge_bot_force.out -dT 0.01 -ele 2020103 2040103 2060103 2080103 2020203 2040203 2060203 2080203 2100203 2020303 2040303 2060303 2080303 2100303 2020403 2040403 2060403 2080403 2100403 2120403 2020503 2040503 2060503 2080503 2100503 2120503 2020603 2040603 2060603 2080603 2100603 2120603 2140603 2160603 2020703 2040703 2060703 2080703 2100703 2120703 2140703 2160703 2020803 2040803 2060803 2080803 2100803 2120803 2140803 2160803 2020903 2040903 2060903 2080903 2100903 2120903 2140903 2160903 2021003 2041003 2061003 2081003 2101003 2121003 2141003 2161003 2010101 2010201 2010301 2010401 2010501 2010601 2010701 2010801 2010901 2011001 2030101 2030201 2030301 2030401 2030501 2030601 2030701 2030801 2030901 2031001 2050101 2050201 2050301 2050401 2050501 2050601 2050701 2050801 2050901 2051001 2070101 2070201 2070301 2070401 2070501 2070601 2070701 2070801 2070901 2071001 2090101 2090201 2090301 2090401 2090501 2090601 2090701 2090801 2090901 2091001 2110301 2110401 2110501 2110601 2110701 2110801 2110901 2111001 2130601 2130701 2130801 2130901 2131001 2150601 2150701 2150801 2150901 2151001 2170601 2170701 2170801 2170901 2171001 force;
	# Top
	recorder Element -file $outdir/hinge_top_force.out -dT 0.01 -ele 2020104 2040104 2060104 2080104 2020204 2040204 2060204 2080204 2100204 2020304 2040304 2060304 2080304 2100304 2020404 2040404 2060404 2080404 2100404 2120404 2020504 2040504 2060504 2080504 2100504 2120504 2020604 2040604 2060604 2080604 2100604 2120604 2140604 2160604 2020704 2040704 2060704 2080704 2100704 2120704 2140704 2160704 2020804 2040804 2060804 2080804 2100804 2120804 2140804 2160804 2020904 2040904 2060904 2080904 2100904 2120904 2140904 2160904 2021004 2041004 2061004 2081004 2101004 2121004 2141004 2161004 2010102 2010202 2010302 2010402 2010502 2010602 2010702 2010802 2010902 2011002 2030102 2030202 2030302 2030402 2030502 2030602 2030702 2030802 2030902 2031002 2050102 2050202 2050302 2050402 2050502 2050602 2050702 2050802 2050902 2051002 2070102 2070202 2070302 2070402 2070502 2070602 2070702 2070802 2070902 2071002 2090102 2090202 2090302 2090402 2090502 2090602 2090702 2090802 2090902 2091002 2110302 2110402 2110502 2110602 2110702 2110802 2110902 2111002 2130602 2130702 2130802 2130902 2131002 2150602 2150702 2150802 2150902 2151002 2170602 2170702 2170802 2170902 2171002 force;
}

if {$addBasicRecorders == 1} {

	# Recorders panel zone elements
	recorder Element -file $outdir/pz_rot.out -dT 0.01 -ele 9010100 9010200 9010300 9010400 9010500 9010600 9010700 9010800 9010900 9011000 9020100 9020200 9020300 9020400 9020500 9020600 9020700 9020800 9020900 9021000 9030100 9030200 9030300 9030400 9030500 9030600 9030700 9030800 9030900 9031000 9040100 9040200 9040300 9040400 9040500 9040600 9040700 9040800 9040900 9041000 9050100 9050200 9050300 9050400 9050500 9050600 9050700 9050800 9050900 9051000 9060100 9060200 9060300 9060400 9060500 9060600 9060700 9060800 9060900 9061000 9070100 9070200 9070300 9070400 9070500 9070600 9070700 9070800 9070900 9071000 9080100 9080200 9080300 9080400 9080500 9080600 9080700 9080800 9080900 9081000 9090100 9090200 9090300 9090400 9090500 9090600 9090700 9090800 9090900 9091000 9100100 9100200 9100300 9100400 9100500 9100600 9100700 9100800 9100900 9101000 9110200 9110300 9110400 9110500 9110600 9110700 9110800 9110900 9111000 9120300 9120400 9120500 9120600 9120700 9120800 9120900 9121000 9130400 9130500 9130600 9130700 9130800 9130900 9131000 9140600 9140700 9140800 9140900 9141000 9150600 9150700 9150800 9150900 9151000 9160600 9160700 9160800 9160900 9161000 9170600 9170700 9170800 9170900 9171000 9180600 9180700 9180800 9180900 9181000 deformation;
}

if {$addDetailedRecorders == 1} {

	recorder Element -file $outdir/pz_M.out -dT 0.01 -ele 9010100 9010200 9010300 9010400 9010500 9010600 9010700 9010800 9010900 9011000 9020100 9020200 9020300 9020400 9020500 9020600 9020700 9020800 9020900 9021000 9030100 9030200 9030300 9030400 9030500 9030600 9030700 9030800 9030900 9031000 9040100 9040200 9040300 9040400 9040500 9040600 9040700 9040800 9040900 9041000 9050100 9050200 9050300 9050400 9050500 9050600 9050700 9050800 9050900 9051000 9060100 9060200 9060300 9060400 9060500 9060600 9060700 9060800 9060900 9061000 9070100 9070200 9070300 9070400 9070500 9070600 9070700 9070800 9070900 9071000 9080100 9080200 9080300 9080400 9080500 9080600 9080700 9080800 9080900 9081000 9090100 9090200 9090300 9090400 9090500 9090600 9090700 9090800 9090900 9091000 9100100 9100200 9100300 9100400 9100500 9100600 9100700 9100800 9100900 9101000 9110200 9110300 9110400 9110500 9110600 9110700 9110800 9110900 9111000 9120300 9120400 9120500 9120600 9120700 9120800 9120900 9121000 9130400 9130500 9130600 9130700 9130800 9130900 9131000 9140600 9140700 9140800 9140900 9141000 9150600 9150700 9150800 9150900 9151000 9160600 9160700 9160800 9160900 9161000 9170600 9170700 9170800 9170900 9171000 9180600 9180700 9180800 9180900 9181000 force;
}

