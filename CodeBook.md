This code book describes the contents of the file har_tidy.csv. 

Variables are derived from the UCI HAR dataset. 

All variables are numeric data types except the Activity Label which is a string

The subject ID  identifies a test subject and falls in the range 1 to 30.
The activity ID identifies an activity and falls in the range 1 to 6
The activity label is a translated activity ID and will be one of 
	WALKING
	WALKING_UPSTAIRS
	WALKING_DOWNSTAIRS
	SITTING
	STANDING
	LAYING
	
Each feature is normalised and bounded within the range [-1,1]. This is the range of measure variables.
	 

As described in features_info.txt and simplified here :-
sensor signals (accelerometer and gyroscope) are 
 . pre-processed by applying noise filters
 . sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window)
 . gravity is subject to a filter with 0.3 HZ cutoff frequency
 . for each window a vector of features was obtained by calculating variables from the time and frequency domain


Explanation of variable names
==============================
 
Variables are provided by accelerometer and gyroscope sensors - Acc and Gyro variable names.
 
Units of the variables
=======================

Acelleration signal(Acc) is in standard gravity units (g)
Angular velocity vector measured by the gyroscope (Gyro) units are radians per second.
 
The variable names starting with t are 3 dimensional axial signals (ending X,Y,Z) calculated using the Euclidean norm 
The variable names starting with f are the result of a fast fourier transformation
The variable names starting with Average are calculated means of a measure variable for a single subject/activity combination - more details below.
As detailed above 
   each Average is a mean of a feature which is bounded to the range -1 to 1.
   each Acc variable is in standard gravity units(g)
   each Gyro variable is in radians per second units
 

 Calculated variables
 ===================
 
 The summary variable names starting with Average are calculated and placed in the tdy tidy data frame on line 233 of run_analysis.R
 They are calculated using a mean function performed within DCAST which provides variables describing the cross tab of subject and activity label.
 The Average prefix is added for presentation later on in processing.
 
 Additional working variables calculated include:
 X_COLS - names of features which fall within the mean and standard deviation name pattern scope
 X_ALL  - unified measures from test and training with associated subject/activity details
 narrow - melted X_ALL by subject and activity 
 tdy    - transformed wide format tidy data equivalent to narrow provided by DCAST statement
 

Variable Name         			                 
1	subject id    			
2	activity id   			
3	activity label 			
4	Average tBodyAcc mean X		
5	Average tBodyAcc mean Y		
6	Average tBodyAcc mean Z		
7	Average tBodyAcc std X		
8	Average tBodyAcc std Y		
9	Average tBodyAcc std Z		
10	Average tGravityAcc mean X	
11	Average tGravityAcc mean Y	
12	Average tGravityAcc mean Z
13	Average tGravityAcc std X
14	Average tGravityAcc std Y
15	Average tGravityAcc std Z
16	Average tBodyAccJerk mean X
17	Average tBodyAccJerk mean Y
18	Average tBodyAccJerk mean Z
19	Average tBodyAccJerk std X
20	Average tBodyAccJerk std Y
21	Average tBodyAccJerk std Z
22	Average tBodyGyro mean X
23	Average tBodyGyro mean Y
24	Average tBodyGyro mean Z
25	Average tBodyGyro std X
26	Average tBodyGyro std Y
27	Average tBodyGyro std Z
28	Average tBodyGyroJerk mean X
29	Average tBodyGyroJerk mean Y
30	Average tBodyGyroJerk mean Z
31	Average tBodyGyroJerk std X
32	Average tBodyGyroJerk std Y
33	Average tBodyGyroJerk std Z
34	Average tBodyAccMag mean
35	Average tBodyAccMag std
36	Average tGravityAccMag mean
37	Average tGravityAccMag std
38	Average tBodyAccJerkMag mean
39	Average tBodyAccJerkMag std
40	Average tBodyGyroMag mean
41	Average tBodyGyroMag std
42	Average tBodyGyroJerkMag mean
43	Average tBodyGyroJerkMag std
44	Average fBodyAcc mean X
45	Average fBodyAcc mean Y
46	Average fBodyAcc mean Z
47	Average fBodyAcc std X
48	Average fBodyAcc std Y
49	Average fBodyAcc std Z
50	Average fBodyAccJerk mean X
51	Average fBodyAccJerk mean Y
52	Average fBodyAccJerk mean Z
53	Average fBodyAccJerk std X
54	Average fBodyAccJerk std Y
55	Average fBodyAccJerk std Z
56	Average fBodyGyro mean X
57	Average fBodyGyro mean Y
58	Average fBodyGyro mean Z
59	Average fBodyGyro std X
60	Average fBodyGyro std Y
61	Average fBodyGyro std Z
62	Average fBodyAccMag mean
63	Average fBodyAccMag std
64	Average fBodyBodyAccJerkMag mean
65	Average fBodyBodyAccJerkMag std
66	Average fBodyBodyGyroMag mean
67	Average fBodyBodyGyroMag std
68	Average fBodyBodyGyroJerkMag mean
69	Average fBodyBodyGyroJerkMag std

Data transformations method
===========================

X files provide measure data
Y files provide measure activity identifiers. 
subject files identify the subject performing the activity

The tidy data combines training and test datasets provided by different sources into a single unified ALL dataset.
The tidy data integrates separate subject,activity and measure datasets provided by different file sources.
Each file is loaded into a separate dedicated data frame before unifying them.
The unify actions combine separate files to show in a single record/line the subject ID, activity label and mean measure information.
While reading the file into a table options prevent treating strings as factors.

Transformations applied to clean up the data
---------------------------------------------

The activity label is provided by matching the activity_id to one found in the activity_labels.txt file dataset.
The feature names are provided by the features.txt file. Transform feature names:-
	Erase left and right brackets () characters- replace with empty string
	Erase comma ,
	Replace hyphen with . so that the hierarchy of column names is more visible. 
	(Later on while preparing the output tidy file the dot becomes a space)
	Assemble the feature columns so the raw feature name provided by the file appears last.
While preparing a vector of column names to be included in the output file measures ignore those which :-
	do not contain "mean" or "std" or 
	contain "meanFreq" or 
	start with "angle".

Perform a melt action to transform the wide format to an interim narrow one consisting of subject ID, activity label, variable and value.
Perform a DCAST to re-construct a wide format from the narrow one - each variable name provides an additional column name
Calculate the mean for each resulting cross tab subject and activity measure variable.

Transform the tidy column names
	Replace underscore (_) and fullstop (.) with space
	Add "average" to the start of the measure variables - starting with t or f
	The output file is formatted with a comma separating character and no header