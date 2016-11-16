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
