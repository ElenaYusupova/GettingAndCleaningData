library(stringr)
library(plyr)

getwd()
#setwd("Y:/R_ElkaTraining/Coursera/Getting_Cleaaning_Data/Week4")
#sFilePath <- "Y:/R_ElkaTraining/Coursera/Getting_Cleaaning_Data/Week4"

#Step 0:
#Download data set
#projectdata<- download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "projectdata.zip")
# Unzip files to Data directory
#unzip("projectdata.zip", exdir = "Data")

#1. Merge the training and the test sets to create one data set.
sTrainDir <- file.path("Data", "UCI HAR Dataset", "train")
sTestDir <- file.path("Data", "UCI HAR Dataset", "test")

# Get number of columns in the file
# Read first line
con <- file(file.path(sTrainDir, "X_train.txt"),"r")
sFirstLine <- readLines(con, n=1)
close(con)
# Clean and parse it
sFirstLine <- trimws(sFirstLine) # Remove trailing 
sFirstLine <- str_replace_all(sFirstLine, "  ", " ") # Replace double space with single
aColumns <- unlist(str_split(sFirstLine, " "))
message("Detected ", length(aColumns), " column(s) in traing file")

message("Reading file with training data -> can take a while...")
if (T) {
    aTime <- system.time({
        dfTrainingData <- read.fwf(file.path(sTrainDir, "X_train.txt"), widths = rep(15, length(aColumns))) 
    })
} else {

    # Alternative, faster, but more complex way

    # Read file -> all columns in one row
    aTrainingData <- read.csv(file.path(sTrainDir, "X_train.txt"), sep = "*", header = F, stringsAsFactors = F)
    
    # Parse read rows
    aTime <- system.time({    # Track execution time
        
        # Use plyr to bing rows into one big data.frame
        dfTrainingData <- plyr::ldply(sapply(aTrainingData[1:nrow(aTrainingData), ], function(sCurrentRow) { # sCurrentRow <- aTrainingData[1, ]
            sCurrentRow <- trimws(sCurrentRow) # Remove trailing 
            sCurrentRow <- str_replace_all(sCurrentRow, "  ", " ") # Replace double space with single
            
            as.data.frame(as.numeric(unlist(str_split(sCurrentRow, " "))))
        }, USE.NAMES = F), rbind, .id = NULL) # Do not return names from sapply -> because they are not yet set 8)
    })
}

# Sanity check -> Should be the same number of columns as count of features
dim(dfTrainingData)

# Reading test data 
con <- file(file.path(sTestDir, "X_test.txt"),"r")
sFirstLine <- readLines(con, n=1)
close(con)
# Clean and parse it
sFirstLine <- trimws(sFirstLine) # Remove trailing 
sFirstLine <- str_replace_all(sFirstLine, "  ", " ") # Replace double space with single
aColumns <- unlist(str_split(sFirstLine, " "))
message("Detected ", length(aColumns), " column(s) in test file")

message("Reading file with test data -> can take a while...")


if (T) {
    aTime <- system.time({
        dfTestData <- read.fwf(file.path(sTestDir, "X_test.txt"), widths = rep(15, length(aColumns)))     
    })
} else {
    # Alternative, faster, but more complex way
    
    # Read file -> all columns in one row
    dfTestData <- read.csv(file.path(sTestDir, "X_test.txt"), sep = "*", header = F, stringsAsFactors = F)
    
    # Parse read rows
    aTime <- system.time({    # Track execution time
        
        # Use plyr to bing rows into one big data.frame
        dfTestData <- plyr::ldply(sapply(dfTestData[1:nrow(dfTestData), ], function(sCurrentRow) { # sCurrentRow <- aTrainingData[1, ]
            sCurrentRow <- trimws(sCurrentRow) # Remove trailing 
            sCurrentRow <- str_replace_all(sCurrentRow, "  ", " ") # Replace double space with single
            
            as.data.frame(as.numeric(unlist(str_split(sCurrentRow, " "))))
        }, USE.NAMES = F), rbind, .id = NULL) # Do not return names from sapply -> because they are not yet set 8)
    })
}

# Sanity check -> Should be the same number of columns as count of features
dim(dfTestData)

# Read features
dfFeatures <- read.csv(file.path("Data", "UCI HAR Dataset", "features.txt"), sep = " ", header = F, stringsAsFactors = F)

# Only second column of interest
aFeatures <- dfFeatures[, 2]

# Set column names to features
colnames(dfTrainingData) <- aFeatures
colnames(dfTestData) <- aFeatures

# Read activities
dfTestActivitiesData <- read.csv(file.path(sTestDir, "y_test.txt"), header = F)
colnames(dfTestActivitiesData) <- "Activity_Index"

dfTrainActivitiesData <- read.csv(file.path(sTrainDir, "y_train.txt"), header = F)
colnames(dfTrainActivitiesData) <- "Activity_Index"

# Add activities to corresponding sets
dfTrainingData <- cbind(dfTrainingData, dfTrainActivitiesData) # colnames(dfTrainingData)
dfTestData <- cbind(dfTestData, dfTestActivitiesData) # colnames(dfTestData)

# Add Training/Test to corresponding sets
dfTrainingData <- cbind(dfTrainingData, Training = T) # colnames(dfTrainingData)
dfTestData <- cbind(dfTestData, Training = F) # colnames(dfTestData)

# Add subject data
dfTestSubjectData <- read.csv(file.path(sTestDir, "subject_test.txt"), header = F)
colnames(dfTestSubjectData) <- "Subject_Index"

dfTrainingSubjectData <- read.csv(file.path(sTrainDir, "subject_train.txt"), header = F)
colnames(dfTrainingSubjectData) <- "Subject_Index"

dfTrainingData <- cbind(dfTrainingData, dfTrainingSubjectData) # colnames(dfTrainingData)
dfTestData <- cbind(dfTestData, dfTestSubjectData)

# Finally combine both sets
dfCombinedData <- rbind(dfTrainingData, dfTestData)

#2. Extract only the measurements on the mean and standard deviation for each measurement
# Find index of mean and standard deviation
aColNames <- colnames(dfCombinedData)

aMeanStdIndex <- which(str_detect(aColNames, "mean[(]") | str_detect(aFeatures, "std[(]"))
# Sanity check
aFeatures[aMeanStdIndex]

# Perform extraction
dfMeanStdData <- dfCombinedData[, aMeanStdIndex]

#3. Use descriptive activity names to name the activities in the data set

# Read activities labels
dfActivityLabels <- read.csv(file.path("Data", "UCI HAR Dataset", "activity_labels.txt"), 
                             sep = " ", header = F, stringsAsFactors = F)

# Use mapping function to link activity index to descriptive name
matchActivity <- function(x) {
    dfActivityLabels$V2[x]    
} # matchActivity(1:6); matchActivity(c(6, 1, 3))

dfMeanStdData$sActivityName <- matchActivity(dfCombinedData$Activity_Index)

# Add Training identifier
dfMeanStdData$bIsTraining <- dfCombinedData$Training

dfMeanStdData$iSubjectIndex <- dfCombinedData$Subject_Index

#4. Appropriately labels the data set with descriptive variable names.
colnames(dfMeanStdData)

write.csv(dfMeanStdData, file = "Mean_and_StdDev_Metrics.csv", row.names = F)

#5. From the data set in step 4, create a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
# Select now only mean columns
aMeanIndex <- which(str_detect(colnames(dfMeanStdData), "mean[(]") | str_detect(colnames(dfMeanStdData), "std[(]"))
colnames(dfMeanStdData)[aMeanIndex]

dfMeanStdData.Clean <- dfMeanStdData
dfMeanStdData.Clean$bIsTraining <- NULL # Remove bIsTraining

# Compute for each activity name and subject index average (mean) for corresponding metric
dfAggMeanData <- aggregate(. ~ sActivityName + iSubjectIndex, dfMeanStdData.Clean, mean)

colnames(dfAggMeanData)[-c(1, 2)] <- paste0(colnames(dfAggMeanData)[-c(1, 2)], "-AvgByActBySubject")

write.table(dfAggMeanData, file = "Average_per_Acitivities_and_Subjects.txt", row.names = F)
