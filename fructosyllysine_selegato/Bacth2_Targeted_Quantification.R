###################################### Quantification Analysis
# Scripts created by Denise Selegato (denise.selegato@embl.de)

###################################### Updates, install and call packages 
install.packages("ggsci")
install.packages("matrixStats")
install.packages("ggrepel")
install.packages("tidyverse")

suppressPackageStartupMessages({
  library(tidyverse)
  library(ggsci)
  library(matrixStats)
  library(ggrepel)
  library(VennDiagram)
  library(BiocManager)
  library(preprocessCore)
  library(ggplot2)
  library(dplyr)
  library(IRdisplay)
  library(tibble)
  library(dplyr)
  library(ggplot2)
})

Sys.time()
rm(list=ls())

############################################################################ 
###################################### Input and check files:

### Set wd
Directory<- c("C:/Users/selegato/Desktop/R projects/Projects/Munich_OMM_HILICMSpos_SecondBatch_semitargeted/")
#setwd(Directory)

### Create Results folder
dirs <- dir(path=paste(getwd(), sep=""), full.names=TRUE, recursive=TRUE)
folders <- unique(dirname(dirs))
files <- list.files(folders, full.names=TRUE)
files_1 <- basename((files))
files_2 <- dirname((files))
# Creating a Result folder
dir.create(path=paste(files_2[[1]], "/BoxplotsM", sep=""), showWarnings = TRUE)
fName <-paste(files_2[[1]], "/BoxplotsM", sep="")

### Import the feature table and metadata
# ft
ft_url <- paste0(Directory, "20241203_Quant_table_SamplesM.csv")
# metadata
md_url <-  paste0(Directory, "metadata.csv")


### read data
ft <- read.csv(ft_url, header = T, check.names = F, row.names = 1)
md <- read.csv(md_url, header = T, check.names = F, row.names = 1)

### dimension of the data
dim(ft)
dim(md)
head(ft)
head(md)

############################################################################ 
###################################### Transform data:

### 1) Bring feature table and metadata in the correct format:
# how many files in the metadata are also present in the feature table
table(rownames(md) %in% colnames(ft))
# which file names in the metadata are not in the feature table?
setdiff(rownames(md),colnames(ft))
md <- md[rownames(md) %in% colnames(ft),]
dim(md)


### 2) transpose ft
ft <- t(ft)
head(ft)
dim(ft)


### 3) Check filenames in md and ft
# In order to perform a boxplot as described below, it is important that the filenames
# in our metadata are identical as well as in the same order as the filenames in 
# our feature table. Let's make sure this is true, using the below code (this 
# should return TRUE).
identical(rownames(ft),rownames(md))
# put the rows in the feature table and metadata in the same order
ft <- ft[match(rownames(md),rownames(ft)),]
identical(rownames(ft),rownames(md))


### 4) Merge ft and md
DataI <- cbind.data.frame(md,ft)
dim(DataI)


### 5) Filter dataset
Data<-DataI 

nmeta<-ncol(md)+1
df<-Data[,nmeta:ncol(Data)]
md_df<-Data[,1:ncol(md)]


### 6) Remove noise from area values
df[df < 10000] <- 0


### 7) Transforming intensity in concentration using calibration curve of FL
# Get the concentration of FL injected
concentration_uM=NULL
for (i in 1:nrow(df)){
  temp<-df[i,2]
  x<-(temp+8428.2)/3e6
  concentration_uM<-rbind(concentration_uM,x)  
}

concentration_uM<-data.frame(concentration_uM)
colnames(concentration_uM)<-colnames(df[2])
rownames(concentration_uM)<-rownames(df)


### 8) Get the weight of FL in the injected volume 
MW<-308.33
V1<- 1.5e-6 # Volume injected into the machine

concentrationM<-concentration_uM*1e-6 #concentration in molar
nmols<-V1*concentrationM
mcecum_injected<-nmols*MW # in grams

### 9)  Get the weight of FL in the whole extract  
# Final volume of extract is 6 uL
V2<-6/1.5
mcecum_extract<-mcecum_injected*V2

## 10) Get the weight of FL in the total amount of cecum sample
V3<- 250 # Volume (uL) of water they diluted the cecum in.
weight <- as.numeric(md_df$ATTRIBUTE_Weights)
weight1<-weight/1000#weight in g

V3f=NULL
for(i in 1:length(weight)) {
  temp2<-V3 + (weight[i])
  V3f<-rbind(V3f, temp2)
}

V4<- V3f/6 #Volume I got for the metabolite extraction

mcecum_total=NULL
for(i in 1:length(weight)) {
  temp3<-mcecum_extract[i,1] * V4[i]
  mcecum_total<-rbind(mcecum_total,temp3)
}


## 11) Get the weight of FL per gram of cecum (mg of FL in g of cecum)
#Getting the weights of cecum

df1=NULL
for(i in 1:length(weight1)) {
  temp2<-mcecum_total[i,1]/weight1[i]
  df1<-rbind(df1, temp2)
}

df1<-df1*1000000 # mass in micrograms
df1<-data.frame(df1)
rownames(df1)<-rownames(concentration_uM)
colnames(df1)<-colnames(concentration_uM)

## 12) Concatenate new_ft and md
df1F<-cbind(Data[1:ncol(md)],df1)

#Saving final table with concentration
write.csv(df1F, file.path(Directory,"/BoxplotsM/Batch2_ConcentrationM.csv"),row.names =TRUE)


## 13) Get the molarity of the wash
MW<-308.33

molarity=NULL
for(i in 1:length(weight1)) {
  temp3a<-df1[i,1]*1e-6*weight1[i]
  temp3b<-V3f[i]*1e-6*MW
  temp3<-temp3a/temp3b
  molarity<-rbind(molarity, temp3)
}

molarity1<-molarity*1e6 # convert from M to uM
molarity2<-cbind(Data[1:ncol(md)],molarity1)

## Saving final table with molarity
write.csv(molarity2, file.path(Directory,"/BoxplotsM/Batch2_molarityM_Denise.csv"),row.names =TRUE)







#################################################################################
########################### Boxplots

###### 1) Cecum experiment

### Create results folder
dirs <- dir(path=paste(getwd(), sep=""), full.names=TRUE, recursive=TRUE)
folders <- unique(dirname(dirs))
files <- list.files(folders, full.names=TRUE)
files_1 <- basename((files))
files_2 <- dirname((files))
# Creating a Result folder
dir.create(path=paste(files_2[[1]], "/BoxplotsM/Cecum", sep=""), showWarnings = TRUE)
fName <-paste(files_2[[1]], "/BoxplotsM/Cecum", sep="")

## Filter only Cecum
library(dplyr)
library(ggplot2)
df2<-molarity2 %>%
  filter(ATTRIBUTE_Tissue!="MiceFood")

nmeta<-ncol(md)+1
df3<-df2[,nmeta:ncol(df2)]
mdf<-df2[,1:ncol(md)]

df3<-data.frame(df3)
rownames(df3)<-rownames(df2)
colnames(df3)<-colnames(df1)


### Do boxplot

for(i in 1:ncol(df3)) {
  
  namest<-colnames(df3[i])
  t2<-as.numeric(df3[, colnames(df3)==namest])
  
  boxplotF<- ggplot(df3,aes(x=as.factor(mdf$'ATTRIBUTE_concat'),y=t2, fill=as.factor(mdf$'ATTRIBUTE_Community')))+
    geom_boxplot(outlier.shape = NA)+
    geom_jitter(width=0.25, alpha=0.5)+
    facet_wrap(vars(mdf$'ATTRIBUTE_Time'), scales="free_x",nrow = 1)+
    theme_minimal()+
    scale_color_jama()+
    theme(legend.title = element_blank())+
    theme(legend.title = element_blank())+
    xlab("Conditions")+
    ylab("uM of Fructoselysine in cecal wash")+
    theme(axis.title = element_text(size = 8))+
    theme(axis.title.y = element_text(size = 8))+
    theme(axis.title.x = element_text(size = 6))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size = 8))+
    theme(axis.text.y = element_text(vjust = 0.5, hjust=1,size = 8))+
    theme(strip.background = element_rect(
      color="black", fill="gray", size=1.5, linetype="solid"))+
    theme(strip.text = element_text(size=6))+ 
    theme(legend.title = element_text(size = 4), legend.text = element_text(size = 4))
  
  boxplotF
  namesave=paste0("boxplot_Molarity_", namest,".png")
  diir=paste0(Directory,"/BoxplotsM/Cecum/",namesave)
  ggsave(boxplotF, file=diir, width = 14, height = 10, units = "cm", bg = "white")
  
  
}

## Filter only Cecum
library(dplyr)
library(ggplot2)
df2<-df1F %>%
  filter(ATTRIBUTE_Tissue!="MiceFood")

nmeta<-ncol(md)+1
df3<-df2[,nmeta:ncol(df2)]
mdf<-df2[,1:ncol(md)]

df3<-data.frame(df3)
rownames(df3)<-rownames(df2)
colnames(df3)<-colnames(df1)


### Do boxplot

for(i in 1:ncol(df3)) {
  
  namest<-colnames(df3[i])
  t2<-as.numeric(df3[, colnames(df3)==namest])
  
  boxplotF<- ggplot(df3,aes(x=as.factor(mdf$'ATTRIBUTE_concat'),y=t2, fill=as.factor(mdf$'ATTRIBUTE_Community')))+
    geom_boxplot(outlier.shape = NA)+
    geom_jitter(width=0.25, alpha=0.5)+
    facet_wrap(vars(mdf$'ATTRIBUTE_Time'), scales="free_x",nrow = 1)+
    theme_minimal()+
    scale_color_jama()+
    theme(legend.title = element_blank())+
    theme(legend.title = element_blank())+
    xlab("Conditions")+
    ylab("Fructoselysine concentration (ug/g Tissue)")+
    theme(axis.title = element_text(size = 8))+
    theme(axis.title.y = element_text(size = 8))+
    theme(axis.title.x = element_text(size = 6))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size = 8))+
    theme(axis.text.y = element_text(vjust = 0.5, hjust=1,size = 8))+
    theme(strip.background = element_rect(
      color="black", fill="gray", size=1.5, linetype="solid"))+
    theme(strip.text = element_text(size=6))+ 
    theme(legend.title = element_text(size = 4), legend.text = element_text(size = 4))
  
  boxplotF
  namesave=paste0("boxplot_weight_", namest,".png")
  diir=paste0(Directory,"/BoxplotsM/Cecum/",namesave)
  ggsave(boxplotF, file=diir, width = 14, height = 10, units = "cm", bg = "white")
  
  
}







###### 2) Mice Food experiment

### Create results folder
dirs <- dir(path=paste(getwd(), sep=""), full.names=TRUE, recursive=TRUE)
folders <- unique(dirname(dirs))
files <- list.files(folders, full.names=TRUE)
files_1 <- basename((files))
files_2 <- dirname((files))
# Creating a Result folder
dir.create(path=paste(files_2[[1]], "/BoxplotsM/MiceFood", sep=""), showWarnings = TRUE)
fName <-paste(files_2[[1]], "/BoxplotsM/MiceFood", sep="")

## Filter only MiceFood
df2<-molarity2 %>%
  filter(ATTRIBUTE_Tissue=="MiceFood")

nmeta<-ncol(md)+1
df3<-df2[,nmeta:ncol(df2)]
mdf<-df2[,1:ncol(md)]

df3<-data.frame(df3)
rownames(df3)<-rownames(df2)
colnames(df3)<-colnames(df1)


### Do boxplot

for(i in 1:ncol(df3)) {
  
  namest<-colnames(df3[i])
  t2<-as.numeric(df3[, colnames(df3)==namest])
  
  boxplotF<- ggplot(df3,aes(x=as.factor(mdf$'ATTRIBUTE_concat'),y=t2, fill=as.factor(mdf$'ATTRIBUTE_Community')))+
    geom_boxplot(outlier.shape = NA)+
    geom_jitter(width=0.25, alpha=0.5)+
    facet_wrap(vars(mdf$'ATTRIBUTE_Time'), scales="free_x",nrow = 1)+
    theme_minimal()+
    scale_color_jama()+
    theme(legend.title = element_blank())+
    theme(legend.title = element_blank())+
    xlab("Conditions")+
    #ylab("Fructoselysine concentration (uM/g Mice Food)")+
    ylab("uM of Fructoselysine in cecal wash")+
    theme(axis.title = element_text(size = 8))+
    theme(axis.title.y = element_text(size = 8))+
    theme(axis.title.x = element_text(size = 6))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size = 8))+
    theme(axis.text.y = element_text(vjust = 0.5, hjust=1,size = 8))+
    theme(strip.background = element_rect(
      color="black", fill="gray", size=1.5, linetype="solid"))+
    theme(strip.text = element_text(size=6))+ 
    theme(legend.title = element_text(size = 4), legend.text = element_text(size = 4))
  
  boxplotF
  namesave=paste0("boxplot_Molarity_", namest,".png")
  diir=paste0(Directory,"/BoxplotsM/MiceFood/",namesave)
  ggsave(boxplotF, file=diir, width = 14, height = 10, units = "cm", bg = "white")
  
  
}



## Filter only MiceFood
df2<-df1F %>%
  filter(ATTRIBUTE_Tissue=="MiceFood")

nmeta<-ncol(md)+1
df3<-df2[,nmeta:ncol(df2)]
mdf<-df2[,1:ncol(md)]

df3<-data.frame(df3)
rownames(df3)<-rownames(df2)
colnames(df3)<-colnames(df1)


### Do boxplot

for(i in 1:ncol(df3)) {
  
  namest<-colnames(df3[i])
  t2<-as.numeric(df3[, colnames(df3)==namest])
  
  boxplotF<- ggplot(df3,aes(x=as.factor(mdf$'ATTRIBUTE_concat'),y=t2, fill=as.factor(mdf$'ATTRIBUTE_Community')))+
    geom_boxplot(outlier.shape = NA)+
    geom_jitter(width=0.25, alpha=0.5)+
    facet_wrap(vars(mdf$'ATTRIBUTE_Time'), scales="free_x",nrow = 1)+
    theme_minimal()+
    scale_color_jama()+
    theme(legend.title = element_blank())+
    theme(legend.title = element_blank())+
    xlab("Conditions")+
    ylab("Fructoselysine concentration (uM/g Mice Food)")+
    #ylab("uM of Fructoselysine in cecal wash")+
    theme(axis.title = element_text(size = 8))+
    theme(axis.title.y = element_text(size = 8))+
    theme(axis.title.x = element_text(size = 6))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size = 8))+
    theme(axis.text.y = element_text(vjust = 0.5, hjust=1,size = 8))+
    theme(strip.background = element_rect(
      color="black", fill="gray", size=1.5, linetype="solid"))+
    theme(strip.text = element_text(size=6))+ 
    theme(legend.title = element_text(size = 4), legend.text = element_text(size = 4))
  
  boxplotF
  namesave=paste0("boxplot_weight_", namest,".png")
  diir=paste0(Directory,"/BoxplotsM/MiceFood/",namesave)
  ggsave(boxplotF, file=diir, width = 14, height = 10, units = "cm", bg = "white")
  
  
}



