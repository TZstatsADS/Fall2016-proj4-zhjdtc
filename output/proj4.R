

##feature
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

feature=cbind(pitches.feature,timbre.feature)


##use distance to find the test data close to which song
pitches.dist=rep(0,2350)

for (i in 1:2350){
  di=dist(rbind(pitches.feature[i,],test.pitches))
  pitches.dist[i]=di
  

}

pitches.index.min=which.min(pitches.dist)



##topic model

library(NLP)
library(tm)
library(lda)
library(LDAvis)



dat=lyr
dat=dat[,-c(1,2,3,6:30)]   #clean lyrics data

dat=t(t(dat))

document.name=lyr[,1]
document=vector("list",length(document.name))
names(document)=document.name

vocab=colnames(dat)
for (i in 1:length(document)){
  index=(dat[i,]!=0)
  index=which(index=="TRUE")
  document[[i]]=rbind(as.integer(index-1),as.integer(dat[i,index]))
  
}

doc.length=sapply(document,function(x) sum(x[2,]))
term.table=colSums(dat)
term.frequency=as.integer(term.table)


K=20
G=5000
alpha=0.02
eta=0.02



library(lda)
fit=lda.collapsed.gibbs.sampler(documents=document,K=K,vocab=vocab,
                                num.iterations=G,alpha=alpha,eta=eta,initial=NULL,
                                burnin=0,compute.log.likelihood = TRUE)

theta=t(apply(fit$document_sums+alpha,2,function(x) x/sum(x)))
phi=t(apply(t(fit$topics)+eta,2,function(x) x/sum(x)))


##fit Ridge model for feature
library(glmnet)
fit2=cv.glmnet(x=feature,y=theta,family="mgaussian",alpha=0)



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

write.table(test.ranking,"~/Dropbox/Jingdan/Applied Data Science/Project 4/100song ranking.txt",sep="\t")




