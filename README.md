# Fall2016-proj4-zhjdtc

**Topic Words of Music**
  In this project, we use 2350 songs to produce a model so that whenwe have new 100 songs, we could predict those songs' lyrics based on 
their features.
  Data: 2350 songs' features(analysis) and words' frequencies in each lyric.
  First, use topic model on 2350 songs' lyrics to create 20 topics ( a way of cluster). 
  Second, extract features from H5 files and according to songs' resource website, the most useful audio features are timbre and pitches. So I extract them and by using resize technic of pictures to standardize those features to create a 1x12000 vector feature for each song. This way is much better than cut, and is similar to knn since it uses means of columns around to reproduce new cells. This way loses least information of songs' feature. Also I check other features but those with confidence interval has too many noises and are not as important as timbre and pitches. Including too many features would slow down our calculation and may create overfitting.
  Third, use ridge model to connect feature to topic model. I use "mgaussian" family to fit a model so that we could predict a  distribution on 20 topics based on songs' features. Therefore when we have new song, we could predict how likely it belongs to each topic. I also tried LASSO but ridge is more stable. Also PCA and some other dimension reduction method works even worse. The sum of each prediction is 1. So we did not lose too much information.
  Forth, since I have distribution on topics, I multiply them with each topic's distribution on words, then I get a probability distribution on words. Then we could rank based on probability.
