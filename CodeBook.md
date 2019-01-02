# Code Book

## Assignment
One of the most exciting areas in all of data science right now is wearable computing
see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing 
to develop the most advanced algorithms to attract new users. The data linked to from the 
course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone.
A full description is available at the site where the data was obtained:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average 
of each variable for each activity and each subject.

Download data

```R
file_Url<-'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(file_Url,'DataProject.zip',method='curl')
```

## 1.Merges the training and the test sets to create one data set

### Read the train data
```R
train_data<-read.table('./UCI_HAR_Dataset/train/X_train.txt')
train_data_subject<-read.table('./UCI_HAR_Dataset/train/subject_train.txt')
train_data_labels<-read.table('./UCI_HAR_Dataset/train/y_train.txt')
```

### Read the test data
```R
test_data<-read.table('./UCI_HAR_Dataset/test/X_test.txt')
test_data_subject<-read.table('./UCI_HAR_Dataset/test/subject_test.txt')
test_data_labels<-read.table('./UCI_HAR_Dataset/test/y_test.txt')
```

### Join Train and Test Data
```R
data_complete<-rbind(train_data,test_data) #Train plus test data
```

### Join Subjects from Train and Test data
```R
data_complete_subject<-rbind(train_data_subject,test_data_subject)
```

The column name was set to subject
```R
names(data_complete_subject)<-'Subject' #Name Column
```

### Join Labels from Train and Test data
```R
data_complete_labels<-rbind(train_data_labels,test_data_labels)
```
The column name was set to 'Activity'
```R
names(data_complete_labels)<-'Activity'
```

## 2.Extracts only the measurements on the mean and standard deviation for each measurement

### Read Features file
```R
features_file <- read.table('./UCI_HAR_Dataset/features.txt')
```

### Filter for mean and std
Search for -mean() and -std() using grep on features. The positions will be the columns to subset
```R
data_mean_std<-data_complete[,grep("-(mean|std)\\(\\)",features_file$V2)]
```

## 3.Uses descriptive activity names to name the activities in the data set

### Read Activity Labels
```R
activity_labels<-read.table('./UCI_HAR_Dataset/activity_labels.txt')
```
### Substitute numbers for descriptive activity names
```R
data_complete_labels[,1]<-activity_labels[data_complete_labels[, 1], 2]
```

## 4.Appropriately labels the data set with descriptive variable names

Assign column names with the respective features using the features file, grep was used to locate the positions and then extract the respective names

```R
names(data_mean_std)<-features_file$V2[grep("-(mean|std)\\(\\)",features_file$V2)]
```

The assigned names are not totally descriptive and that is why gsub was used to make them more descriptive
```R
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
descriptive_names<-gsub('^t','TimeDomain_',descriptive_na
```

### Merge everything to create final data set
```R
FinalData<-cbind(data_mean_std,data_complete_subject,data_complete_labels)
```

Save the data, this is the first output to complete the assignment
```R
write.table(FinalData,'Mean_and_StandardDeviations_EachVariable.txt')
```

## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

First the data was grouped by activity and subject
```R
groupedData<-group_by(FinalData,Activity,Subject)
```

and then the average was obtained and the second output to complete the assignment was saved
```R
averaged_data <- summarise_all(groupedData, funs(mean))
write.table(averaged_data,'AverageVariables_ByActivity_and_Subject.txt')
```


