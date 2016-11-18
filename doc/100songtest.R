##feature
library(raster)

source("http://bioconductor.org/biocLite.R")
biocLite("rhdf5")
library(rhdf5)


test.ls=list.dirs("~/Dropbox/Jingdan/Applied Data Science/Project 4/TestSongFile100/TestSongFile100")


test.pitches.raster<-raster(nrow=12,ncol=500)
test.timbre.raster<-raster(nrow=12,ncol=500)
test.pitches.feature=vector()
test.timbre.feature=vector()

for (test.dir in test.ls){
  test.ls2=list.files(path=test.dir,patter="\\.h5")
  
  for (test.file in test.ls2){
   
    test.sound_temp=h5read(paste(test.dir,test.file,sep="/"),"/analysis")
    test.pitches_temp=test.sound_temp$segments_pitches
    test.timbre_temp=test.sound_temp$segments_timbre
    
    test.pitches.raster.temp=raster(test.pitches_temp)
    test.timbre.raster.temp=raster(test.timbre_temp)
    
    extent(test.pitches.raster.temp)=extent(c(-180,180,-90,90))
    extent(test.timbre.raster.temp)=extent(c(-180,180,-90,90))
    
    test.pitches=resample(test.pitches.raster.temp,test.pitches.raster)
    test.timbre=resample(test.timbre.raster.temp,test.timbre.raster)
    
    test.pitches=as.matrix(test.pitches)
    test.timbre=as.matrix(test.timbre)
    
    test.pitches=matrix(t(test.pitches),nrow=1,ncol=6000 )
    test.timbre=matrix(t(test.timbre),nrow=1,ncol=6000)
    
    test.pitches.feature=rbind(test.pitches.feature,test.pitches)
    test.timbre.feature=rbind(test.timbre.feature,test.timbre)
    
  }
}

test.feature=cbind(test.pitches.feature,test.timbre.feature)

test.prediction=predict(fit2,test.feature,s="lambda.min")
test.prediction=test.prediction[,,1]
test.prob=test.prediction %*% phi
test.result=1-test.prob

test.ranking=matrix(0,nrow=100,ncol=4973)
for(i in 1:100){
  test.ranking[i,]=rank(test.result[i,])
  
}

write.xlsx(test.ranking,"~/Dropbox/Jingdan/Applied Data Science/Project 4/100song ranking.txt",sep="\t")







