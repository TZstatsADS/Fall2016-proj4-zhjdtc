#######
##feature extraction and standardization
#######

library(raster)

source("http://bioconductor.org/biocLite.R")
biocLite("rhdf5")
library(rhdf5)

load("lyr.RData")

id=read.table("common_id.txt")
song=h5ls("~/Dropbox/Jingdan/Applied Data Science/Project 4/data/A/A/A/TRAAABD128F429CF47.h5")
soundtest=h5read("~/Dropbox/Jingdan/Applied Data Science/Project 4/data/A/A/A/TRAAABD128F429CF47.h5","/analysis")

ls=list.dirs("~/Dropbox/Jingdan/Applied Data Science/Project 4/data")
sound=vector()
filename=vector()
song=vector()

pitches.raster<-raster(nrow=12,ncol=500)
timbre.raster<-raster(nrow=12,ncol=500)
pitches.feature=vector()
timbre.feature=vector()

for (dir in ls){
  ls2=list.files(path=dir,patter="\\.h5")
  
  for (file in ls2){
    filename=c(filename,gsub(".h5","",file)) 
    sound_temp=h5read(paste(dir,file,sep="/"),"/analysis")
    pitches_temp=sound_temp$segments_pitches
    timbre_temp=sound_temp$segments_timbre
    
    pitches.raster.temp=raster(pitches_temp)
    timbre.raster.temp=raster(timbre_temp)
    
    extent(pitches.raster.temp)=extent(c(-180,180,-90,90))
    extent(timbre.raster.temp)=extent(c(-180,180,-90,90))
    
    pitches=resample(pitches.raster.temp,pitches.raster)
    timbre=resample(timbre.raster.temp,timbre.raster)
    
    pitches=as.matrix(pitches)
    timbre=as.matrix(timbre)
    
    pitches=matrix(t(pitches),nrow=1,ncol=6000 )
    timbre=matrix(t(timbre),nrow=1,ncol=6000)
    
    pitches.feature=rbind(pitches.feature,pitches)
    timbre.feature=rbind(timbre.feature,timbre)
    
  }
}

