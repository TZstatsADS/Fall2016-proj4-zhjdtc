##fit Ridge model for feature
# use ridge model to fit song's feature to the probability of each topics. Then use this model
# to predict song's distribution on topics based on song's feature
# Last is to rank based on each word's probability of appearance


library(glmnet)
fit2=cv.glmnet(x=feature,y=theta,family="mgaussian",alpha=0)  
prediction=predict(fit2,test,s="lambda.min")
prob=prediciton %*% phi
result=1-prob
ranking=rank(result)


##use distance to find the test data close to which song
pitches.dist=rep(0,2350)

for (i in 1:2350){
  di=dist(rbind(pitches.feature[i,],test.pitches))
  pitches.dist[i]=di
  

}

pitches.index.min=which.min(pitches.dist)

