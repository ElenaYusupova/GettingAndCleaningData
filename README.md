# ReadMe 

This repository contains output from test exercise for Getting and Cleaning Data as part of Coursera course work.

Dataset Origin and Some Background

This project uses data set downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

In short, it contains smartphone sensonrs measurements and thier transformed values. Readme.txt in the archive contains details on the data set. 

Once the data set was downloaded and unziped following operations/transformations were performed:

1.	Merge the training and the test sets to create one data set.
2.	Extract only the measurements on the mean and standard deviation for each measurement.
3.	Use descriptive activity names to name the activities in the data set -  i.e. WALKING, LAYING, etc.
4.	Appropriately label the data set with descriptive variable names. 
5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Documents relevant to the project:
- Average_per_Acitivities_and_Subjects.txt – dataset that is the result of analysis steps 1 – 5.
- Codebook.md - file with description of variables in the data set.
- Run_Analysis.r - R script used to produce the data set.
