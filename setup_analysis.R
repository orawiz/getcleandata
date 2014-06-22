# ######################################################################
#
# setup_analysis.R
#
# Setup for processing the project HAR dataset into a tidy format
# 
# This script prepares for the processing of the project data set file.
#
# This script is an example and not run. The steps should be completed manually.
# The reason is that a number of steps may fail on the windows platform.
# However the coded steps below do work.
#
# Typical issues include :-
#  A directory cannot be created because of permission problems
#  A file cannot be written because of a sharing violation
#  The R system() command requires a parameter which names a known executable ; 
#        .exe, .com, .bat etc to pass command line argument parameters to.
#        I use cmd /k to make visible the output from run DOS commands like DIR or mkdir which are built-in to DOS 
#  The R Sys.which() windows emulation explains the path to a chosen executable
#
# ######################################################################

# Step number and description

# S 1 Create a working directory
system("cmd /k mkdir c:\\data\\har5",invisible=FALSE,intern=TRUE)

# S 2 Set the working directory as current
setwd("C:\\data\\har5")

# Confirm the new working directory 
getwd()

# The following steps will be done in run_analysis.R
# That way the choice of parent working directory location can be made outside the scripts. 

# S 3 Collect the project file by downloading from internet
#     The mode option specifies a (B)inary transmission since this is a compressed zip archive file.
#     The mode option also (W)rites to replace any existing file
#     Rename the file to har.zip
download.file( "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","har.zip",mode="wb")

# S 4 Uncompress the zip archive file contents 
system("UNZIP har.zip ",invisible=FALSE,intern=TRUE)

# S 5 Adjust the working directory to the contents of the zip archive now uncompressed into a directory
#     Enter the UCI HAR Dataset parent directory
setwd( paste(getwd(),"UCI HAR Dataset", sep="/"))



