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

theta=t(apply(fit$document_sums+alpha,2,function(x) x/sum(x)))   #distribution of each songs in 20 topics
phi=t(apply(t(fit$topics)+eta,2,function(x) x/sum(x)))    #distribution of each topics in 5000 word

  
  
  
  ##visulization of topic model
musicreview=list(phi=phi,theta=theta,doc.lenght=doc.length, vocab=vocab, term.frequency=term.frequency)

library(LDAvis)
json=createJSON(phi=musicreview$phi,theta=musicreview$theta,doc.length=musicreview$doc.lenght,
                vocab=musicreview$vocab,term.frequency = musicreview$term.frequency)

serVis(json,out.dir="vis2",open.browser = F)

