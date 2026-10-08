read_META_RAMSES <-function(filenc_meta) {

# Get the PARAMETER

PARAMETER=ncvar_get(filenc_meta,"PARAMETER")

# Get the predeployment calibration coefficient

PCC=ncvar_get(filenc_meta,"PREDEPLOYMENT_CALIB_COEFFICIENT")

# index nitrate string  

RAMSES_STRING=str_pad("DOWN_IRRADIANCE_SPECTRUM",64,"right")
 
# Find the profile containing NITRATE 

index_ramses=which(PARAMETER == RAMSES_STRING, arr.ind=TRUE)

PCC_RAMSES=PCC[index_ramses]

###############################################################################
### PARSING the CALIBRATION ###################################################
###############################################################################

## Could add a test on the DAC, the parse depends on the DAC

######################################################
# Coriolis PARSING
###################################################### 

# Split the PREDEPLOYMENT CALIB COEFFICIENT with ; into each part of the calibration 
RAMSES_PART=str_split(PCC_RAMSES,";")

#########################
## PART 1 / POLYNOM COEFFICIENTS for WAVELENGTHS COMPUTATION
#########################
# RAMSES_PART[[1]][1] 

index_poly=str_detect(RAMSES_PART[[1]],"c0s")

POLY_RAMSES=str_split(RAMSES_PART[[1]][index_poly],",")

index_c0s=str_detect(POLY_RAMSES[[1]],"c0s=")
index_c1s=str_detect(POLY_RAMSES[[1]],"c1s=")
index_c2s=str_detect(POLY_RAMSES[[1]],"c2s=")
index_c3s=str_detect(POLY_RAMSES[[1]],"c3s=")
index_c4s=str_detect(POLY_RAMSES[[1]],"c4s")


c0s=as.numeric(str_replace(POLY_RAMSES[[1]][index_c0s],"c0s=",""))
c1s=as.numeric(str_replace(POLY_RAMSES[[1]][index_c1s],"c1s=",""))
c2s=as.numeric(str_replace(POLY_RAMSES[[1]][index_c2s],"c2s=",""))
c3s=as.numeric(str_replace(POLY_RAMSES[[1]][index_c3s],"c3s=",""))
c4s=as.numeric(str_replace(POLY_RAMSES[[1]][index_c4s],"c4s=",""))


######################################################
# End of Coriolis PARSING
###################################################### 

META_RAMSES=list("c0s"=c0s,"c1s"=c1s,"c2s"=c2s,"c3s"=c3s,"c4s"=c4s)

return(META_RAMSES)

}


