library(ncdf4)
library(stringr)
require("oce")

source("./read_META_RAMSES.R")

###########################################################
#### Reading the metadatafile 
###########################################################

### Reading the metadata file name 
liste_meta=read.table("liste_meta", header=FALSE, as.is=TRUE)

#### Open the metadata file 
filenc_meta=nc_open(liste_meta$V1,readunlim=FALSE)

#### Read the metadata file

META=read_META_RAMSES(filenc_meta)

### Get the calibration 

#### Init ######################################
#### Init the wavelength 
################################################

WAVELENGTH=rep(0.0,255) 

################################################
# Wavelength computation
################################################
### These are found in the File SAM_xxxx.ini
c0s = META$c0s
c1s = META$c1s
c2s = META$c2s
c3s = META$c3s
c4s = META$c4s


### Be careful Wavelength 1 is associated to pixel number 0 in the documentation
### Agreed with Edouard, let s go straightforward
 
for ( i in seq(1,255)) {

	WAVELENGTH[i]=c0s + c1s *(i+1) + c2s * (i+1)**2 + c3s * (i+1)**3 + c4s * (i+1)**4
}

##################################################################################
### Configuration of the area of interest
###
###
### !!! This information is sent by the float !!! 
### => Be Careful, it can change over time
### => Track configuration changes sent by the float
###  
### Vocabulary used in the program was defined by Catherine and Jean Philippe 
###################################################################################

#########################################################################################
LAUNCH_CONFIG_PARAMETER_NAME=ncvar_get(filenc_meta,"LAUNCH_CONFIG_PARAMETER_NAME")
LAUNCH_CONFIG_PARAMETER_VALUE=ncvar_get(filenc_meta,"LAUNCH_CONFIG_PARAMETER_VALUE")
pixel_start_ACC=LAUNCH_CONFIG_PARAMETER_VALUE[which(str_replace_all(LAUNCH_CONFIG_PARAMETER_NAME," ","") == "CONFIG_RamsesAccOutputPixelBegin_NUMBER")]
pixel_stop_ACC=LAUNCH_CONFIG_PARAMETER_VALUE[which(str_replace_all(LAUNCH_CONFIG_PARAMETER_NAME," ","") == "CONFIG_RamsesAccOutputPixelEnd_NUMBER")]
pixel_bin_ACC=LAUNCH_CONFIG_PARAMETER_VALUE[which(str_replace_all(LAUNCH_CONFIG_PARAMETER_NAME," ","") == "CONFIG_RamsesAccOutputBinningSize_NUMBER")]


#########################################################################################
# CONFIG_PARAMETER_NAME=ncvar_get(filenc_meta,"CONFIG_PARAMETER_NAME")
# CONFIG_PARAMETER_VALUE=ncvar_get(filenc_meta,"CONFIG_PARAMETER_VALUE")
# pixel_start_ACC=CONFIG_PARAMETER_VALUE[which(str_replace_all(CONFIG_PARAMETER_NAME," ","") == "CONFIG_RamsesAccOutputPixelBegin_NUMBER")]
# pixel_stop_ACC=CONFIG_PARAMETER_VALUE[which(str_replace_all(CONFIG_PARAMETER_NAME," ","") == "CONFIG_RamsesAccOutputPixelEnd_NUMBER")]
# pixel_bin_ACC=CONFIG_PARAMETER_VALUE[which(str_replace_all(CONFIG_PARAMETER_NAME," ","") == "CONFIG_RamsesAccOutputBinningSize_NUMBER")]
###########################################################################################

### this one is in the launch_config (stored in the meta_file)

#Imin=5 "5 is when the first pixel is pixel 0 "the dead pixel" / discussion with Edouard we stay as it is "

Imin=pixel_start_ACC

#Imax=144 "144 is when the first pixel is pixel 0 "the dead pixel" / discussion with Edouard we stay as it is "
Imax=pixel_stop_ACC 

Nbin=pixel_bin_ACC

N_VALUES =(Imax-Imin +1)/Nbin 

waveb=rep(0.0,N_VALUES)

for (ib in 1:N_VALUES) {
	wave=0

	for (i in (Imin+(ib-1)*Nbin):(Imin+ib*Nbin-1)) {

		wave=wave+WAVELENGTH[i]

	}
        
	waveb[ib]=wave/Nbin
       
}

print(waveb)

nc_close(filenc_meta)


