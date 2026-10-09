###################################### Quantification Analysis
# Scripts created by Denise Selegato (denise.selegato@embl.de)


############################################################################
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
})

# Check last update and clean global environment
Sys.time()
rm(list=ls())



############################################################################ 
###################################### Input and check files:

### Set wd
Directory<- c("C:/Users/selegato/Desktop/R projects/Projects/Munich_OMM_HILICMSpos_ThirdBatch_semitargeted/")
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
ft_url <- paste0(Directory, "Quant_Table_20241107-M.csv")
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
Data<-DataI %>%
  filter(ATTRIBUTE_Exp!="Pool")%>%
  filter(ATTRIBUTE_Exp!="IS")%>%
  filter(ATTRIBUTE_Exp!="waterwash")

nmeta<-ncol(md)+1
df<-Data[,nmeta:ncol(Data)]
md_df<-Data[,1:ncol(md)]

### 6) Remove noise from area values
df[df < 10000] <- 0

### 7) Transforming area value in weight of FL using calibration curve of FL
# Get the weight of FL in the injected sample
weight_g_inj=NULL

for (i in 1:nrow(df)){
  temp<-df[i,2]
  x<-(temp-84791)/1e16
  weight_g_inj<-rbind(weight_g_inj,x)  
}

weight_g_inj<-data.frame(weight_g_inj) 
colnames(weight_g_inj)<-colnames(df[2])
rownames(weight_g_inj)<-rownames(df)


### 8) Get the weight of FL in the extract 
V_inj<- 5 # Volume injected into the machine in uL
V_extr<- 125 # Volume from the extract in uL
V<- V_extr/V_inj

weight_g_extr<-weight_g_inj[1,1]*V
for (i in 2:nrow(df)){
  weight_g_extr[i]<-weight_g_inj[i,1]*V
}


## 9) Get the weight of FL in the total amount of cecum sample
# get final volume of water in each sample
V_water<- 250 # Volume of water they diluted the cecum in uL
weight <- as.numeric(md_df$ATTRIBUTE_weight) #weight in g
weight1<-weight*1000 #weight in ng

V_samples =NULL
for(i in 1:length(weight1)) {
  temp2<-V_water + (weight1[i])
  V_samples<-rbind(V_samples, temp2)
}

# get the weight of FL in the entire sample
V_aliquot<-20 #uL
V_total<- V_samples/V_aliquot 

weight_g_sample=NULL
for(i in 1:length(weight)) {
  temp3<-weight_g_extr[i] * V_total[i]
  weight_g_sample<-rbind(weight_g_sample,temp3) 
}


## 10) Get the weight of FL per gram of cecum (mg of FL in g of cecum)

weight_g_sample1<-weight_g_sample*1e6 #1e6 converts the weight of FL from g to ug
df1=NULL
for(i in 1:length(weight)) {
  temp2<-weight_g_sample1[i,1]/weight[i]
  df1<-rbind(df1, temp2)
}

df1<-data.frame(df1)
rownames(df1)<-rownames(weight_g_inj)
colnames(df1)<-colnames(weight_g_inj)


## 11) Concatenate new_ft and md
df1F<-cbind(Data[1:ncol(md)],df1)

## 12) Saving final table with weight per gram of tissue
write.csv(df1F, file.path(Directory,"/BoxplotsM/Batch3_ConcentrationM_Denise.csv"),row.names =TRUE)


## 13) Get the molarity of the wash
MW<-308.33

molarity=NULL
for(i in 1:length(weight)) {
  temp3a<-df1[i,1]*1e-6*weight[i]
  temp3b<-V_samples[i]*1e-6*MW
  temp3<-temp3a/temp3b
  molarity<-rbind(molarity, temp3)
}

molarity1<-molarity*1e6 # convert from M to uM
molarity2<-cbind(Data[1:ncol(md)],molarity1)

## 12) Saving final table with molarity
write.csv(molarity2, file.path(Directory,"/BoxplotsM/Batch3_molarityM_Denise.csv"),row.names =TRUE)



 #################################################################################
 ########################### FL_Mutants experiment
 
### Create results folder
 dirs <- dir(path=paste(getwd(), sep=""), full.names=TRUE, recursive=TRUE)
 folders <- unique(dirname(dirs))
 files <- list.files(folders, full.names=TRUE)
 files_1 <- basename((files))
 files_2 <- dirname((files))
 # Creating a Result folder
 dir.create(path=paste(files_2[[1]], "/BoxplotsM/FL_Mutants", sep=""), showWarnings = TRUE)
 fName <-paste(files_2[[1]], "/BoxplotsM/FL_Mutants", sep="")
 
## Filter only FL mutants
 df2<-df1F %>%
   filter(ATTRIBUTE_Exp=="FL_mutants")
 
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
     facet_wrap(vars(mdf$'ATTRIBUTE_Salmonella'), scales="free_x",nrow = 1)+
     theme_minimal()+
     scale_color_jama()+
     theme(legend.title = element_blank())+
     theme(legend.title = element_blank())+
     xlab("Conditions")+
     ylab("Fructoselysine concentration (ug/g Tissue)")+
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
   namesave=paste0("boxplot_Denise_", namest,".png")
   diir=paste0(Directory,"/BoxplotsM/FL_Mutants/",namesave)
   ggsave(boxplotF, file=diir, width = 14, height = 10, units = "cm", bg = "white")
   
   
 }
 








#################################################################################
########################### Plot germ-free content

dirs <- dir(path=paste(getwd(), sep=""), full.names=TRUE, recursive=TRUE)
folders <- unique(dirname(dirs))
files <- list.files(folders, full.names=TRUE)
files_1 <- basename((files))
files_2 <- dirname((files))
# Creating a Result folder
dir.create(path=paste(files_2[[1]], "/BoxplotsM/germ_free_content", sep=""), showWarnings = TRUE)
fName <-paste(files_2[[1]], "/BoxplotsM/germ_free_content", sep="")

## Filter only germ-free
df2<-df1F %>%
  filter(ATTRIBUTE_Exp=="GF_content")

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
  
  boxplotF<- ggplot(df3,aes(x=as.factor(mdf$'ATTRIBUTE_concat'),y=t2, fill=as.factor(mdf$'ATTRIBUTE_concat')))+
    geom_boxplot(outlier.shape = NA)+
    geom_jitter(width=0.25, alpha=0.5)+
    #facet_wrap(vars(mdf$'ATTRIBUTE_Salmonella'), scales="free_x",nrow = 1)+
    theme_minimal()+
    scale_color_jama()+
    theme(legend.title = element_blank())+
    theme(legend.title = element_blank())+
    xlab("Conditions")+
    ylab("Fructoselysine concentration (ug/g Tissue)")+
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
  namesave=paste0("boxplot_Denise_", namest,".png")
  diir=paste0(Directory,"/BoxplotsM/germ_free_content/",namesave)
  ggsave(boxplotF, file=diir, width = 14, height = 10, units = "cm", bg = "white")
  
  
}










#################################################################################
########################### Plot ori_vs_evo

dirs <- dir(path=paste(getwd(), sep=""), full.names=TRUE, recursive=TRUE)
folders <- unique(dirname(dirs))
files <- list.files(folders, full.names=TRUE)
files_1 <- basename((files))
files_2 <- dirname((files))
# Creating a Result folder
dir.create(path=paste(files_2[[1]], "/BoxplotsM/ori_vs_evo", sep=""), showWarnings = TRUE)
fName <-paste(files_2[[1]], "/BoxplotsM/ori_vs_evo", sep="")

## Filter only ori vs evo
df2<-df1F %>%
  filter(ATTRIBUTE_Exp=="ori_vs_evo")

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
  
  boxplotF<- ggplot(df3,aes(x=as.factor(mdf$'ATTRIBUTE_concat'),y=t2, fill=as.factor(mdf$'ATTRIBUTE_concat')))+
    geom_boxplot(outlier.shape = NA)+
    geom_jitter(width=0.25, alpha=0.5)+
    facet_wrap(vars(mdf$'ATTRIBUTE_day'), scales="free_x",nrow = 1)+
    theme_minimal()+
    scale_color_jama()+
    theme(legend.title = element_blank())+
    theme(legend.title = element_blank())+
    xlab("Conditions")+
    #ylab("uM of Fructoselysine in cecal wash")+
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
  namesave=paste0("boxplot_Denise_", namest,".png")
  diir=paste0(Directory,"/BoxplotsM/ori_vs_evo/",namesave)
  ggsave(boxplotF, file=diir, width = 14, height = 10, units = "cm", bg = "white")
  
  
}



