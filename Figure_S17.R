rm(list = ls())

setwd("E://project//urine//addnew//thrid//gender.pred.age.roc1")

library(randomForest)
library('pROC')
library('ggplot2')

prof <- as.data.frame(read.csv('file:///E:/project/urine/new/hclust-barplot/data/newL610000.txt',head=T,row.names = 1,sep='\t'))
map <- as.data.frame(read.csv('file:///E:/project/urine/new/hclust-barplot/data/map.age.txt',head=T,row.names = 1,sep='\t'))

prof <- as.data.frame(t(prof[,rownames(map)]))

F.prof <- prof[map$Gender=="F",]
M.prof <- prof[map$Gender=="M",]
F.map <- map[map$Gender=="F",]
M.map <- map[map$Gender=="M",]

F.prof$Group <- F.map$Age
M.prof$Group <- M.map$Age

#########F pred F   M pred M

data <- F.prof
set.seed(1)
sub <- sample(1:nrow(data),round(nrow(data)*4/5))
train_data <- data[sub,-ncol(data)] #取4/5的数据做训练集
test_data <- data[-sub,-ncol(data)] #取1/5的数据做测试集

train_Group <- data[sub,ncol(data)]
test_Group <- data[-sub,ncol(data)]

colnames(train_data) <- make.names(colnames(train_data))
colnames(test_data) <- make.names(colnames(test_data))

set.seed(1)
ntree_fit <- randomForest(train_Group~.,data=train_data,ntree=10000)
pdf("train.FF.ErrorRate.age.pdf")
plot(ntree_fit)
dev.off()

pdf("train.FF.ImportanceFeatures.age.pdf")
varImpPlot(ntree_fit)
dev.off()

sig <- ntree_fit$importance
write.table(sig,file="sig.FF.age.txt",sep="\t")
pred <- as.data.frame(predict(ntree_fit,test_data))
pred$real <- test_Group

write.table(pred,file="pred.FF.age.txt",sep="\t")

fig1.cor <- cor.test(pred[,1],pred[,2],method = "spearman")
colnames(pred) <- c("predict","real")
fig1 <- ggplot(pred,aes(x=predict , y=real))+geom_point() + 
  annotate("text",label=paste("pvalue=",fig1.cor$p.value,"  ","r=",fig1.cor$estimate) ,x=65,y=40)+ 
  geom_smooth(method = "glm")
pdf("F pred F.age.line.pdf",useDingbats=F)
fig1
dev.off()



#########F pred M   M pred F

test_data <- M.prof

test_Group <- M.map$Age

pdf("train.FM.ErrorRate.age.pdf")
plot(ntree_fit)
dev.off()

pdf("train.FM.ImportanceFeatures.age.pdf")
varImpPlot(ntree_fit)
dev.off()

sig <- ntree_fit$importance
# write.table(sig,file="sig.MF.age.txt",sep="\t")
pred <- as.data.frame(predict(ntree_fit,test_data))
pred$real <- test_Group


# write.table(pred,file="pred.MF.age.txt",sep="\t")

fig1.cor <- cor.test(pred[,1],pred[,2],method = "spearman")
colnames(pred) <- c("predict","real")
fig1 <- ggplot(pred,aes(x=predict , y=real))+geom_point() + 
  annotate("text",label=paste("pvalue=",fig1.cor$p.value,"  ","r=",fig1.cor$estimate) ,x=65,y=40)+ 
        geom_smooth(method = "glm")
pdf("F pred M.age.line.pdf",useDingbats=F)
fig1
dev.off()
