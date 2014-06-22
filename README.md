This project explains the solution for the Coursera Getting and Cleaning Data course project.

The solution provides tidy data derived from the HAR Human Activity Recognition data set.

The following scripts are provided :-

1) setup_analysis.R Example of how to download the HAR file and prepare to process it.

2) run_analysis.R   Process a downloaded HAR zip archive and provide the tidy dataset.

Execution method :-

All the user has to do is decide on a working directory.

This work assumes C:\data\har5 on a windows PC.

Either manually or by running the setup_analysis.R script make the HAR files available.

After unzipping the project zip archive file Dataset.zip the results will be placed in a directory named UCI HAR Dataset.

Then run the analysis

source("run_analysis.R")

These instructions assume you will change the source command above to specify the correct code location.

=========================================================================================================================

The run_analysis.R script performs the following steps :-

Read various files using the read.table command to create a data frame from them. 
Specify options to not expect a header and to not treat strings as factors.
Provide specific column names except for the measures file (X) as these will be added later from feature information.

Begin with reference information to explain the context of the measures :-

Load activity_labels.txt file to provide an activity label instead of the activity ID.
Load features.txt file to set meaningful measure variable names - 561 observations.
Make the following changes to feature name data
     Remove brackets and comma
     Change hyphen to a full stop

Load test data files from the test sub-directory.
Load training data files from the train sub-directory.
For both cases load measures (X), activity (Y),and subject files. 
Combine test and training data into a single data set..
   Unify datasets using RBIND.
   Unify activity (Y) and subject (S) data from test and training sources.
   Identify the mean and standard deviation measure columns by their name pattern. 
	Pick those which contain "mean" or "std" without being sensitive to case.
        Apply the invert option of grep to ignore "meanFreq" and names starting with "angle". 
   Unify measure (X) data from test and training sources. 
   At the same time discard statistic column names not present in the identified name pattern list.
   Attach subject ID and activity ID which came from different files. Rely on their position in the datasets to match.
   Attach a descriptive activity label using the MERGE statement - match activity Id to the associated activity label.

Prepare a tidy data set..
Firstly apply the reshape2 package facilities to melt the combined data into a narrow format by subject, activity and variable name.
Then DCAST to calculate a mean for the crosstab of subject and activity measure variables. This returns to a wide format.
Perform final adjustments to the tidy dataset column names 
   Replace underscore and fullstop with space
   Place the word average at the start of the calculated means
Prepare the output tidy dataset file har_tidy.csv using the write.table command. Each column is separated by a comma.

======================================================================================================================
Comments

This work relies on the approach discussed here
https://class.coursera.org/getdata-004/forum/thread?thread_id=262

The above thread describes alternative wide and narrow format datasets.
It suggests the wide format is more likely to be expected by coursera students.
The decision rests on how a tidy dataset should be formulated.
A number of criteria include whether each row and column contains only a single measure value.
Since the narrow format is more complicated to query the wide format is used.

Wide format presents a single record for each subject and activity label combination. 
All measures are attached to the same record - 
   each measure placed in a separate column each given a meaningful expressive human readable name.
        Subject ID, Activity Label, tBodyAcc mean X, tBodyAcc mean Y, etc  

Narrow format presents a single record for each subject, activity label and variable name combination.
        Subject ID, Activity Label, Variable, Value
        1,"WALKING","tBodyAcc mean X",123
   each measure is placed in a new record. 
   each measure value is placed in a general purpose column named value.
   each measure name is placed  in a general purpose column named variable.
   We have to check the contents of the variable column to understand the contents of this record.
   We have to combine many records to assemble the results of analysis for a given subject and activity label combination.



