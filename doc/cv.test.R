##tain set and test test
set.seed(1989)
train_ind=sample(seq(1,2350),2250)
feature_train=feature[train_ind,]
feature_test=feature[-train_ind,]

test_lyr=dat[-train_ind,]


document_train=document[train_ind]

K=20
G=5000
alpha=0.02
eta=0.02



library(lda)
fit_train=lda.collapsed.gibbs.sampler(documents=document_train,K=K,vocab=vocab,
                                num.iterations=G,alpha=alpha,eta=eta,initial=NULL,
                                burnin=0,compute.log.likelihood = TRUE)

theta_train=t(apply(fit_train$document_sums+alpha,2,function(x) x/sum(x)))
phi_train=t(apply(t(fit_train$topics)+eta,2,function(x) x/sum(x)))

##fit Ridge model for feature
library(glmnet)
fit2_train=cv.glmnet(x=feature_train,y=theta_train,family="mgaussian",alpha=0)


fit2_train.lasso=cv.glmnet(x=feature_train,y=theta_train,family="mgaussian",alpha=1)


##Ridge
prediction2_ridge=predict(fit2_train,feature_test,s="lambda.min")
prediction2_ridge=prediction2_ridge[,,1]
prob2_ridge=prediction2_ridge %*% phi_train
result2_ridge=1-prob2_ridge

ranking2_ridge=matrix(0,nrow=100,ncol=4973)
test_index=as.vector("matrix")
mean2_ridge=rep(0,100)
#LASSO
prediction2_lasso=predict(fit2_train.lasso,feature_test,s="lambda.min")
prediction2_lasso=prediction2_lasso[,,1]
prob2_lasso=prediction2_lasso %*% phi_train
result2_lasso=1-prob2_lasso


ranking2_ridge=matrix(0,nrow=100,ncol=4973)
test_index=as.vector("matrix")
mean2_ridge=rep(0,100)

ranking2_lasso=matrix(0,nrow=100,ncol=4973)
mean2_lasso=rep(0,100)






for (i in 1:100){
  ranking2_ridge[i,]=as.integer(rank(result2_ridge[i,]))
  ranking2_lasso[i,]=as.integer(rank(result2_lasso[i,]))
  
  
  
  index=which(test_lyr[i,]!=0)
  test_index=rbind(test_index,index)
  mean2_ridge[i]=mean(ranking2_ridge[i,index])
  mean2_lasso[i]=mean(ranking2_lasso[i,index])
  
}



