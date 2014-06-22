# ##############################################################################################################
# run_analysis.R
#
# This script is used to prepare a tidy HAR Human Activity Recognition data set.
# 
# This script is part of the deliverables for the coursera Getting and Cleaning Data course project.
#  See https://class.coursera.org/getdata-004/human_grading
#  and https://class.coursera.org/getdata-004/human_grading/view/courses/972137/assessments/3/submissions
#      
# Author: Steve Gerard
# Specification: (see second web reference above)
#
# Merge training and test data sets
# Extract mean and standard deviation for each measurement
# Use descriptive activity names
# Use descriptive variable names
# Create a second independent tidy data set - average each variable for every activity and subject.
# 
# Script parameters: None
# _______________________________________________________________________________________________________________
# Setup steps - done manually or see template example run_analysis_0.R 
# S 1 Create a working directory
# S 2 Set the working directory as current
# S 3 
# _______________________________________________________________________________________________________________
# Processing steps for this analysis script
# P 1 Download zip file
# P 2 Uncompress the zip file
# P 3 Adjust working directory to enter the unzipped UCI HAR Dataset sub-directory
# P 4 Process the zip file contents
#     Load activity label and feature names.. 
#      - load activity labels into data frame - activity_labels.txt
#      - load feature  names  into data frame - features.txt
#      - remove special characters from feature name columns. 
#        provides meaningful measure variable names and
#        helps avoid potential R syntax errors.
# P 5 Load measurement and subject data
#      - Load test 
#      - Load train
# P 6 Combine the data sets
#      - Merge test and train
#     Keep mean and standard deviation statistical summary measures and remove the rest.
#     features_info.txt file explains that summary variables are estimated from signals and fast fourier transform.
#     Some of the variables estimated from signals are:-
#           mad median absolute deviation
#           max largest value in array
#           min smallest value in array
#           sma signal magnitude area
#           energy sum of squares divided by number of measures
#           iqr interquartile range
#           entropy signal entropy
#           arCoeff Autoregression coefficients with Burg order equal to 4
#           correlation correlation coefficient between 2 signals
#           etc
# P 7 Prepare tidy output dataset by using reshape2 package
# P 8 Write the output dataset to a file
#
# ##############################################################################################################
# 1. Download zip file from project location
#download.file( "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","har.zip",mode="wb")

# 2. Uncompress the downloaded zip file
#system("UNZIP har.zip ",invisible=FALSE,intern=TRUE)

# 3. Adjust working directory to enter into the uncompressed zip file directory
#setwd(paste0(getwd(),"/UCI HAR Dataset"))
#getwd()

# 4. Begin to process the files provided by the zip file

# 4.1 Load activity labels to translate activity Id into activity label text
#     This provides 1 WALKING, 2 WALKING_UPSTAIRS, .. ,6 LAYING

activity_labels <- read.table(file = "activity_labels.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("activity_id","activity_label"))


# 4.2 Load feature names to translate V1,V2 column names into a human readable name
#     The V1,V2 etc names will be initially present after reading measures files in steps 5.1 and 5.2 into datasets.

# Initially load the raw feature name. This provides 561 raw feature names. 
features <- read.table(file="features.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("feature_id","feature_name_raw"))

# 4.3 Prepare a human readable feature name from the raw name. 
#     Raw names include brackets and other special characters such as comma, fullstop and hyphen which may cause R syntax errors.
#     This work is a vital part of preparing a tidy output dataset.
#     For now the activity_id and subject_id column names remain as they are.
#     The underscore will be replaced by space at the final step which provides the tidy output dataset file.
#
#     Prepare the feature name which is a translated raw feature_name column value.
#     ID  Name                    Raw
#     1   tBodyAcc.mean.X         tBodyAcc-mean()-X
#     38  tBodyAcc.correlation.XY tBodyAcc-correlation()-X,Y
#     77  tGravityAcc.arCoeff.Z4  tGravityAcc-arCoeff()-Z,4
#     252 tBodyGyroMag.arCoeff4   tBodyGyroMag-arCoeff()4
#     561 angleZgravityMean       angle(Z,gravityMean)

#     Each of the following steps replaces a pattern with another
#     Translate embedded brackets into an empty string. This removes left ( or right brackets ) from a raw feature name.
#     Translate hyphen to full stop. This makes the hierarchy or position of a variable within a group of variables clear.
#     

# 4.3.1 Remove embedded brackets ()
features$feature_name  <- gsub("\\)|\\(","",features$feature_name_raw)

# 4.3.2 Replace hyphen with dot to preserve the hierarchy of column names which belong to a group of columns
#       For example 
features$feature_name <- gsub("-",".",features$feature_name)

# 4.3.3 Remove comma
features$feature_name <- gsub(",","",features$feature_name)

# 4.4   Change the order of features so the raw feature name appears last
#       The new order is Feature Id, feature name, raw feature name
#       This is not such an important step.
features <- features[,c(1,3,2)]


# The result is 561 variables organised into groups named X.Y[.Z] where Z optionally increases <.1, ,.2 ,.3> etc for variables in a series.

# 5.1 Load test measurements (X and Y files) and subjects

X_test <- read.table(file="test//X_test.txt",header=FALSE,stringsAsFactors=FALSE,col.names=features$feature_name)

Y_test <- read.table(file="test//Y_test.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("activity_id"))

subject_test <- read.table(file="test//subject_test.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("subject_id"))

# 5.2 Load training measurements (X and Y files) and subjects

X_train <- read.table(file="train//X_train.txt",header=FALSE,stringsAsFactors=FALSE,col.names=features$feature_name)

Y_train <- read.table(file="train//Y_train.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("activity_id"))

subject_train <- read.table(file="train//subject_train.txt",header=FALSE,stringsAsFactors=FALSE,col.names=c("subject_id"))

# 6.0 Combine Y figures from test and training datasets
#     The rbind action results in 10299 observations 
Y_all <- rbind( Y_test,Y_train)

# Combine subject from test and training datasets

S_all <- rbind( subject_test,subject_train)
#     This rbind action also provides 10299 observations to match measurements to the subject

# Reduce the statistical fields to (mean) average  and (std) standard deviation.
# Identify the mean and standard deviation in measure variables.
# This is done by a case insensitive check for the text "mean" or "std" in column names.
# Ignore the meanFrequency column by using the grep invert option
# These steps reduce the number of number of measure variables to 73.
# Add 3 variables for subject and activity details = 76.

# 6.1 Assemble the descriptive column names provided by features.txt file
#     Keep only the mean and standard deviation as described above
#     Remove the meanFreq and angle variables which remain initially
X_COLS <- grep( pattern="std|mean",x=features$feature_name,value=TRUE,ignore.case=TRUE)
X_COLS <- grep( pattern="meanFreq",X_COLS,ignore.case=TRUE,value=TRUE,invert=TRUE)
X_COLS <- grep( pattern="^angle"  ,X_COLS,ignore.case=TRUE,value=TRUE,invert=TRUE)

# 6.2 Combine test and training measures by using RBIND.
#     Discard summary statistics other than mean and standard deviation
#     - keep columns identified in X_COLS
X_ALL <- rbind( X_test[,X_COLS], X_train[,X_COLS] )
# Add subject and activity identifiers 
X_ALL$subject_id  <- S_all$subject_id 
X_ALL$activity_id <- Y_all$activity_id
# Merge in the descriptive activity label
# The merge statement realises that both datasets have a common activity_id column and matches records using it.
# The result is to add a suitable activity_label to X_ALL.
X_ALL <- merge( X_ALL, activity_labels )

# After all these actions the structure which emerges is
#'data.frame':	10299 obs. of  69 variables:
# 1.  $ activity_id                      : int  1 1 1 1 1 1 1 1 1 1 ...
# 2.  $ tBodyAcc.mean.X                  : num  0.269 0.262 0.238 0.245 0.249 ...
# 3.  $ tBodyAcc.mean.Y                  : num  0.00789 -0.01622 0.0021 -0.03155 -0.02112 ...
# ...
# 67. $ fBodyBodyGyroJerkMag.std         : num  0.1383 -0.3929 -0.0248 0.0916 -0.7591 ...
# 68. $ subject_id                       : int  7 21 7 7 18 7 7 7 11 21 ...
# 69. $ activity_label                   : chr  "WALKING" "WALKING" "WALKING" "WALKING" ...
#

# 7.0 Prepare tidy data set
# 
# https://class.coursera.org/getdata-004/forum/thread?thread_id=262

# The above thread describes alternative wide and narrow format datasets.
# It suggests the wide format is more likely to be expected by coursera students.
# The decision rests on how a tidy dataset should be formulated.
# A number of criteria include whether each row and column contains only a single measure value.
# Since the narrow format is more complicated to query the wide format is used.

#  Wide format presents a single record for each subject and activity label combination. 
#   All measures are attached to the same record - 
#   each measure placed in a separate column each given a meaningful expressive human readable name.
#        Subject ID, Activity Label, tBodyAcc mean X, tBodyAcc mean Y, etc  
#  Narrow format presents a single record for each subject, activity label and variable name combination.
#        Subject ID, Activity Label, Variable, Value
#        1,"WALKING","tBodyAcc mean X",123
#   each measure is placed in a new record. 
#   each measure value is placed in a general purpose column named value.
#   each measure name is placed  in a general purpose column named variable.
#   We have to check the contents of the variable column to understand the contents of this record.
#   We have to combine many records to assemble the results of analysis for a given subject and activity label combination.
#   

# 7.1 Make available dataset reshaping package 
library(reshape2)

# 7.2 Begin to create a tidy data set. Start with a narrow representation by melting the measures
#     Melt on the subject and activity columns
#     This creates a narrow representation of the combined input data sets;
#     5 columns subject_id, activity_id, activity_label, variable,value
narrow <- melt(X_ALL,id=c("subject_id","activity_id","activity_label"))
#narrow <- melt(X_ALL[,1:length(X_ALL)],id=c("subject_id","activity_id","activity_label"))
#m2 <- melt(X_ALL[,c(75,1:74,76)],id=c("subject_id","activity_id","activity_label"))

#     Show the user the structure of the narrow format data frame
#str(narrow)
#'data.frame':	679734 obs. of  5 variables:
# $ subject_id    : int  7 21 7 7 18 7 7 7 11 21 ...
# $ activity_id   : int  1 1 1 1 1 1 1 1 1 1 ...
# $ activity_label: chr  "WALKING" "WALKING" "WALKING" "WALKING" ...
# $ variable      : Factor w/ 66 levels "tBodyAcc.mean.X",..: 1 1 1 1 1 1 1 1 1 1 ...
# $ value         : num  0.269 0.262 0.238 0.245 0.249 ...

# 7.3 Prepare a cross tab which reverts the narrow dataset to a wide format
#     Apply the DCAST statement ;
#      rows populated by changing subject ID 
#      columns populated by changing activity ID / label name with associated measure variables for 
#               a single subject ID/activity ID pair
#      for each row and column variable value which emerges compute the mean function
#tdy <- tidied <- dcast( narrow, subject_id + activity_id ~variable, mean)
tdy <- tidied <- dcast( narrow, subject_id + activity_id + activity_label ~variable, mean)
# 180 observations, 69 variables
# 7.4 Finalise the descriptive column names in tidy dataset
#     - Replace underscore (_) with space
#     - Replace fullstop   (.) with space
#     - Add average to the start of the names of calculated means 
names(tdy) <- sub( '_',' ',names(tdy))
names(tdy) <- gsub( '\\.',' ',names(tdy))
names(tdy) <- sub( '^t','average t',names(tdy))
names(tdy) <- sub( '^f','average f',names(tdy))


# 7.5 Show the finalised tidy data structure 
#names(tdy)
# [1] "subject_id"                        "activity_label"                   
# [3] "tBodyAcc.mean.X"                   "tBodyAcc.mean.Y"                  
# [5] "tBodyAcc.mean.Z"                   "tBodyAcc.std.X"                   
# [7] "tBodyAcc.std.Y"                    "tBodyAcc.std.Z"                   
# [9] "tGravityAcc.mean.X"                "tGravityAcc.mean

#Create independent tidy data set with avg [varible] for activity and subject

write.table( x=tdy, file="har_tidy.csv",quote=FALSE,sep=",",row.names=FALSE)
#tdy

