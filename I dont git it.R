

# Set correct working directory up depending on who's running code.
# TODO: Set file path automatically according to who's running the code instead of using a string.
krolak_or_turner <- "krolak"
if(krolak_or_turner == "krolak"){
  setwd("Z:/Portfolio/krolak_and_turner")
}else if(krolak_or_turner == "turner"){
  setwd("PUT YOUR FILE PATH HERE")
}

# Libraries
{
  # Make sure to install if you haven't already
    # install.packages("DataExplorer")
    # install.packages("data.table")
    # install.packages("dplyr")
  # Load them up
  library(DataExplorer)
  library(data.table)
  library(dplyr)
}


# Load Data
{
  # load training data
  train <- fread("./data_in/train.csv")
  # load testing data
  test <- fread("./data_in/test.csv")
}


# meh
create_report(train)




