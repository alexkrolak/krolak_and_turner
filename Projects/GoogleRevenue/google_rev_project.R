# Google Revenue Contest
# Copied from here: https://www.kaggle.com/c/google-analytics-customer-revenue-prediction/data

# Data Dictionary
{
  # Data Fields:
  # fullVisitorId- A unique identifier for each user of the Google Merchandise Store.
  # channelGrouping - The channel via which the user came to the Store.
  # date - The date on which the user visited the Store.
  # device - The specifications for the device used to access the Store.
  # geoNetwork - This section contains information about the geography of the user.
  # sessionId - A unique identifier for this visit to the store.
  # socialEngagementType - Engagement type, either "Socially Engaged" or "Not Socially Engaged".
  # totals - This section contains aggregate values across the session.
  # trafficSource - This section contains information about the Traffic Source from which the session originated.
  # visitId - An identifier for this session. This is part of the value usually stored as the _utmb cookie. This is only unique to the user. For a completely unique ID, you should use a combination of fullVisitorId and visitId.
  # visitNumber - The session number for this user. If this is the first session, then this is set to 1.
  # visitStartTime - The timestamp (expressed as POSIX time).
  # Removed Data Fields
  # Some fields were censored to remove target leakage. The major censored fields are listed below.
  # 
  # hits - This row and nested fields are populated for any and all types of hits. Provides a record of all page visits.
  # customDimensions - This section contains any user-level or session-level custom dimensions that are set for a session. This is a repeated field and has an entry for each dimension that is set.
  # totals - Multiple sub-columns were removed from the totals field.
}




# Libraries
# Install these (commented)
{
  # install.packages("h2o")
  # install.packages("tidyverse")
  # install.packages("skimr")
  # install.packages("recipes")
  # install.packages("data.table")
  install.packages("DataExplorer")
}


# Load them
{
  # General 
  library(tidyverse)
  library(data.table)
  library(DataExplorer)
  library(skimr)
  
  # Preprocessing
  library(recipes)
  
  # Machine Learning
  library(h2o)
}

# Load Data

sample_sub <- fread(file="./data_in/sample_submission.csv")
data_train <- fread(file="./data_in/train.csv")
data_test  <- read_csv("./data_in/test.csv")

# EDA
{
  skim(sample_sub)
  skim(data_train)
  skim(data_test)
  
  
}




