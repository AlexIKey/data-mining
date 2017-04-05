#########################################################################
# ������� �.�., ��������� �.�. (2017) �������������, ��������� � ������ ��������� Data Mining 
# � �������������� R. (����� �������: http://www.ievbras.ru/ecostat/Kiril/R/DM )
#########################################################################
#########################################################################
# ����� 7. ������ ������������� ��� �������������� �������
#########################################################################

#  7.1. ����� ������ � ����� k-��������� �������
#-----------------------------------------------------------------------
data(iris) ; library(ggplot2)
qplot(Sepal.Length, Sepal.Width, data = iris) +
      facet_grid(facets = ~ Species)+
      geom_smooth(color="red", se = FALSE) 
qplot(Petal.Length, Petal.Width,data = iris) +
      facet_grid(facets = ~ Species)+
      geom_smooth(color="red", se = FALSE) 

library(vegan) 
mod.pca <- rda(iris[,-5], scale = TRUE)
scores <- as.data.frame(scores(mod.pca, display ="sites",
 scaling = 3))
scores$Species <- iris$Species
# �������� � �������� ���� ���� ����������� ���������
axX <- paste("PC1 (",
   as.integer(100*mod.pca$CA$eig[1]/sum(mod.pca$CA$eig)),"%)")
axY <- paste("PC2 (",
   as.integer(100*mod.pca$CA$eig[2]/sum(mod.pca$CA$eig)),"%)")
# ���������� ������� ��� hull "������� ����� �� �������"
l <- lapply(unique(scores$Species), function(c) 
         { f <- subset(scores,Species==c); f[chull(f),]})
hull <- do.call(rbind, l)
# ������� ������������� ���������
ggplot() + 
  geom_polygon(data=hull,aes(x=PC1,y=PC2, fill=Species),
alpha=0.4, linetype=0) +  
  geom_point(data=scores,aes(x=PC1,y=PC2,shape=Species,
colour=Species),size=3) + 
  scale_colour_manual( values = c('purple', 'green', 'blue'))+
  xlab(axX) + ylab(axY) + coord_equal() + theme_bw() 

library(kknn)   #   -------- ����� �-��������� �������  kNN
train.kknn(Species ~ ., iris, kmax = 50, kernel="rectangular") 
max_K=20 ; gen.err.kknn <- numeric(max_K)
mycv.err.kknn <- numeric(max_K) ; n <- nrow(iris)
#  ������������� ����� ��������� ������� �� 1 �� 20
for (k.val in 1:max_K)  {  
  pred.train <- kknn(Species ~ .,
     iris,train=iris,test=iris,k=k.val,kernel="rectangular")
  gen.err.kknn[k.val] <- mean(pred.train$fit != iris$Species)
  for (i in 1:n)   {
   pred.mycv <- kknn(Species~., train=iris[-i,],test=iris[i,],
         k=k.val,kernel="rectangular")
   mycv.err.kknn[k.val] <- mycv.err.kknn[k.val] +
        (pred.mycv$fit != iris$Species[i])   }
}  ;  mycv.err.kknn <- mycv.err.kknn/n
plot(1:20,gen.err.kknn,type="l",xlab='k', ylim=c(0,0.07),
    ylab='������ �������������', col="limegreen", lwd=2) 
points(1:max_K,mycv.err.kknn,type="l",col="red", lwd=2)
legend("bottomright",c("��� ��������",
   "���������� ��������"),lwd=2,col=c("limegreen", "red")) 

library(caret) ; set.seed(123)
contrl <- trainControl(method="repeatedcv",repeats = 3)
train(Species ~ ., data = iris, method = "knn", 
       trControl = contrl, preProcess = c("center","scale"),
       tuneLength = 20)

set.seed(123) ;  (samp.size <- floor(nrow(iris) * .75))
train.ind <- sample(seq_len(nrow(iris)), size = samp.size)
train <- iris[train.ind,]  ;  test <- iris[-train.ind, ] 
knn.iris <- knn(train = train[,-5], test = test[,-5], 
cl = train[,"Species"], k = 13, prob = T)
table(����=test$Species,�������=knn.iris)
Acc = mean(knn.iris == test$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")

#-----------------------------------------------------------------------
#  7.2. "�������" ������������� ������
#-----------------------------------------------------------------------

library(klaR)
naive_iris <- NaiveBayes(iris$Species ~ ., data = iris)
naive_iris$tables$Petal.Width 
plot(naive_iris,lwd=2)

pred <- predict(naive_iris,iris[,-5])$class
table(����=iris$Species, �������=pred)
Acc = mean(pred == iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")

library(caret)
#  ��������� ������� �����-�������� � �������  
train_control <- trainControl(method='cv',number=10)
Test <- train(Species~., data = iris, trControl=train_control, method="nb")
print(Test)
Acc = mean(predict(Test$finalModel,iris[,-5])$class
                          == iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")

#-----------------------------------------------------------------------
#  7.3. ������������� � �������� ��������������� ������������
#-----------------------------------------------------------------------

require(MASS)
LDA.iris <- lda(formula = Species ~ .,data = iris)
LDA.iris$scaling # ������������ �������� ��������������
LDA.iris$svd
(prop = LDA.iris$svd^2/sum(LDA.iris$svd^2)) 
prop =percent(prop)
pred <-predict(LDA.iris,newdata = iris)
scores = data.frame(Species = iris$Species,pred$x)
# ������� ������������� ���������
require(ggplot2)
ggplot() +   geom_point(data=scores,
  aes(x=LD1,y=LD2,shape=Species,colour=Species),size=3) + 
  scale_colour_manual( values = c('purple', 'green', 'blue'))+
  labs(x = paste("LD1 (", prop[1], ")", sep=""),
       y = paste("LD2 (", prop[2], ")", sep="")) + theme_bw()

lda(scale(iris[,1:4]), gr = iris$Species)$scaling

train <- sample(1:150, 140)
LDA.iris3 <- lda(Species ~ .,iris, subset = train)
plda = predict(LDA.iris3,newdata = iris[-train, ])
data.frame(Species=iris[-train,5], plda$class, plda$posterior)

Acc = mean(pred$class == iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")

LDA.irisCV <- lda(Species ~ ., data = iris,  CV = TRUE)
table(����=iris$Species,�������=LDA.irisCV$class)
Acc = mean(LDA.irisCV$class==iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")

#-----------------------------------------------------------------------
#  7.4. ���������� �������������� � R
#-----------------------------------------------------------------------

# ������������ ��������������� ������ 
require(MASS)
QDA.iris = qda(Species~ Petal.Length+Petal.Width, data = iris)
pred = predict(QDA.iris)$class
table(����=iris$Species,�������=pred)
Acc = mean(pred ==iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")
library(klaR)
partimat(Species ~ Petal.Length + Petal.Width,
         data = iris, method="qda")

library(caret)
set.seed(123)
# ���������� ������ ������� ��������
train(Species ~ Petal.Length + Petal.Width, data = iris, method = "qda", trControl = trainControl(method = "cv"))

# ���������� ���� ����� ���������
train(Species ~ ., data = iris, method = "qda", 
trControl = trainControl(method = "cv"))

# ���������������� ��������������� ������ 
library(rda)
set.seed(123)
#  1- ���� ������ �����������
train(Species ~ ., data = iris, method = "rda", 
trControl = trainControl(method = "cv"))

#  2- ���� � ���������� lambda = 0.1:0.5 � gamma = 0.02:0.1
RDAGrid <- expand.grid(.lambda = (1:5)/10, .gamma = (1:5)/50)
train(Species ~ ., data = iris, method = "rda", 
tuneGrid =RDAGrid, trControl = trainControl(method = "cv"))

#  ���������� �������������� � ������ ��� ��������
RDA.iris <- rda(Species~., data=iris, gamma=0.02, lambda=0.5)
pred = predict(RDA.iris)$class
Acc = mean(pred ==iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")

# ������ ������� �������� 
library(e1071)
SVM.iris <- svm(Species~., data=iris)
pred <- predict(SVM.iris, iris[,1:4], type="response")
table(����=iris$Species,�������=pred)
Acc = mean(pred ==iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")
pred.DV <- predict(SVM.iris, iris[,1:4], 
decision.values = TRUE)
ind <- sort(sample(150,9))
data.frame(attr(pred.DV, "decision.values")[ind,],
                iris$Species[ind])

plot(cmdscale(dist(iris[,-5])), col = as.integer(iris[,5])+1,
     pch = c("o","+")[1:150 %in% SVM.iris$index + 1], font=2,
xlab="����� 1",ylab="����� 1" ) 
legend (0,1.2, c("setosa","versicolor","virginica"),pch = "o", 
        col =2:4)

#-----------------------------------------------------------------------
# 7.5. ���������������� ������������� ���������
#-----------------------------------------------------------------------

library(nnet)
MN.iris <- multinom(Species~., data=iris)
summary(MN.iris)
Probs <- fitted(MN.iris) 
pred=apply(Probs,1,function(x)
        colnames(Probs)[which(x==max(x))])
table(����=iris$Species,�������=pred)
Acc = mean(pred ==iris$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")
z <- summary(MN.iris)$coefficients/
       summary(MN.iris)$standard.errors
# p-�������� �� ������ ����� ������ 
(1 - pnorm(abs(z), 0, 1))*2 
# p-�������� �� ������  t-����������
pt(z, df = nrow(iris) - 5, lower=FALSE) 

#-----------------------------------------------------------------------
# 7.6. �������������� �� ������ ������������� ��������� �����
#-----------------------------------------------------------------------

data(iris)
ind = sample(2, nrow(iris), replace = TRUE, prob=c(0.7, 0.3))
trainset = iris[ind == 1,]
testset = iris[ind == 2,]
trainset$setosa = trainset$Species == "setosa"
trainset$virginica = trainset$Species == "virginica"
trainset$versicolor = trainset$Species == "versicolor

library(neuralnet)
net.iris = neuralnet(versicolor + virginica + setosa ~
Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
trainset, hidden=3)
net.iris$result.matrix
plot(net.iris)

net.prob = compute(net.iris, testset[-5])$net.result
pred = c("versicolor",   "virginica",   "setosa")
 [apply(net.prob,   1,   which.max)]
table(����=testset$Species, �������= pred)
Acc = mean(pred == testset$Species)
paste("��������=", round(100*Acc, 2), "%", sep="")























