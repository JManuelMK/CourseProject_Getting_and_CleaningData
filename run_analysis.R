library(data.table)
library(dplyr)

#You should create one R script called run_analysis.R that does the following.

#1.Merges the training and the test sets to create one data set.
#2.Extracts only the measurements on the mean and standard deviation for each measurement.
#3.Uses descriptive activity names to name the activities in the data set
#4.Appropriately labels the data set with descriptive variable names.
#5.From the data set in step 4, creates a second, independent tidy data set with the average 
#of each variable for each activity and each subject.

setwd('./DataScience_Specialization/Course3_GettingAndCleaningData/CourseProject')

file_Url<-'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(file_Url,'DataProject.zip',method='curl')


#1.Merges the training and the test sets to create one data set.###################################

#Read train data
train_data<-read.table('./UCI_HAR_Dataset/train/X_train.txt')
train_data_subject<-read.table('./UCI_HAR_Dataset/train/subject_train.txt')
train_data_labels<-read.table('./UCI_HAR_Dataset/train/y_train.txt')

#Read test data
test_data<-read.table('./UCI_HAR_Dataset/test/X_test.txt')
test_data_subject<-read.table('./UCI_HAR_Dataset/test/subject_test.txt')
test_data_labels<-read.table('./UCI_HAR_Dataset/test/y_test.txt')

#Join Train and Test Data
data_complete<-rbind(train_data,test_data) #Train plus test data

#Rename column to Subject
data_complete_subject<-rbind(train_data_subject,test_data_subject)
names(data_complete_subject)<-'Subject' #Name Column

#Rename column to Activity
data_complete_labels<-rbind(train_data_labels,test_data_labels)
names(data_complete_labels)<-'Activity'

################################################################################################################

#2.Extracts only the measurements on the mean and standard deviation for each measurement.######################
#Read Features file
features_file <- read.table('./UCI_HAR_Dataset/features.txt')

##Search for -mean() or -std() with grep in features and then select the respective columns
data_mean_std<-data_complete[,grep("-(mean|std)\\(\\)",features_file$V2)] 

################################################################################################################

#3 Uses descriptive activity names to name the activities in the data set#######################################

#Read Activity Labels
activity_labels<-read.table('./UCI_HAR_Dataset/activity_labels.txt')

#Substitute numbers for descriptive activity names
data_complete_labels[,1]<-activity_labels[data_complete_labels[, 1], 2]

################################################################################################################

#4.Appropriately labels the data set with descriptive variable names############################################

#Assign column names using features file, grep was used to locate the positions and then extract the respective names
names(data_mean_std)<-features_file$V2[grep("-(mean|std)\\(\\)",features_file$V2)] 

#Use of gsub to give more descriptive names
descriptive_names<-names(data_mean_std)
descriptive_names<-gsub('Acc','Acceleration_',descriptive_names)
descriptive_names<-gsub('Gyro','Gyroscope_',descriptive_names)
descriptive_names<-gsub('Jerk','JerkSignal',descriptive_names)
descriptive_names<-gsub('Mag','Magnitude',descriptive_names)
descriptive_names<-gsub('-','_',descriptive_names)
descriptive_names<-gsub('[(][)]','',descriptive_names)
descriptive_names<-gsub('__','_',descriptive_names)
descriptive_names<-gsub('std','standard_deviation',descriptive_names)
descriptive_names<-gsub('^f','FrequencyDomain_',descriptive_names)
descriptive_names<-gsub('^t','TimeDomain_',descriptive_names)
names(data_mean_std)<-descriptive_names

#Merge everything to create the final data set
FinalData<-cbind(data_mean_std,data_complete_subject,data_complete_labels)

#Save the data set
write.table(FinalData,'Mean_and_StandardDeviations_EachVariable.txt')
################################################################################################################

#5.From the data set in step 4, creates a second, independent tidy data set with the average####################
#of each variable for each activity and each subject.

#Group by activity and subject
groupedData<-group_by(FinalData,Activity,Subject)

#Get the average
averaged_data <- summarise_all(groupedData, funs(mean))

#Save the Independent Tidy data set
write.table(averaged_data,'AverageVariables_ByActivity_and_Subject.txt')
################################################################################################################

