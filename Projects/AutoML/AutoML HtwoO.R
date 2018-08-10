# Home Credit Auto ML 

# Libraries
  # Install these (commented)
  {
    # install.packages("h2o")
    # install.packages("tidyverse")
    # install.packages("skimr")
    # install.packages("recipes")
  }
  
  # Load them
  {
    # General 
    library(tidyverse)
    library(skimr)
    
    # Preprocessing
    library(recipes)
    
    # Machine Learning
    library(h2o)
  }

# Load Data
  application_train_tbl <- fread(file="./data_in/application_train.csv")
  application_test_tbl  <- read_csv("./data_in/application_test.csv")
