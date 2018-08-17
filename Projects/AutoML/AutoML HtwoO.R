# Home Credit Auto ML 
# Copied from here: http://www.business-science.io/business/2018/08/07/kaggle-competition-home-credit-default-risk.html

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

  # This is ugly dunno why he did it
  application_train_tbl %>%
    slice(1:10) %>%
    knitr::kable()
  
  
# Train/Test ####  
# Training data: Separate into x and y tibbles
x_train_tbl <- application_train_tbl %>% select(-TARGET)
y_train_tbl <- application_train_tbl %>% select(TARGET)   

# Testing data: What we submit in the competition
x_test_tbl  <- application_test_tbl

# Remove the original data to save memory
rm(application_train_tbl)
rm(application_test_tbl)


# Data Inspection ####
skim_to_list(x_train_tbl)
# skim(x_train_tbl)    

# AutoML workflow ####

# Characters to Factors
  # We'll convert these char variables to factor()s because this package needs them that way
  string_2_factor_names <- x_train_tbl %>%
                            select_if(is.character) %>%
                            names()
  
  string_2_factor_names

# Numerics
  unique_numeric_values_tbl <- x_train_tbl %>%
                                select_if(is.numeric) %>% # Select factor() vars only from x_train_tbl
                                map_df(~ unique(.) %>% length()) %>% # I get this kinda
                                gather() %>% # Not sure wtf gather does yet
                                arrange(value) %>% # Just a sort
                                mutate(key = as_factor(key)) # Create new column "key"
  
  unique_numeric_values_tbl
  # Factor limit (you must have 7- uniques to be converted to factor)
  factor_limit <- 7
  
  num_2_factor_names <- unique_numeric_values_tbl %>%
    filter(value < factor_limit) %>% # row filter
    arrange(desc(value)) %>% # Sort descending based on value col
    pull(key) %>% # grab only this column
    as.character() # convert to char
  # These are all the (former) numeric columns that have been converted to factor b/c they had 7 or less uniques
  num_2_factor_names # 35 vars to convert in main dataset
  
  
  # missing business
  missing_tbl <- x_train_tbl %>%
    summarize_all(.funs = ~ sum(is.na(.)) / length(.)) %>% # Find the amount of NA's per column (all cols, not just numerics)
    gather() %>% # dunno wtf this does!
    arrange(desc(value)) %>% # sort desc on result column
    filter(value > 0) # row filter to make sure to only look at vars with 1 or more missing entries
  # Holy hell, 61 cols w/ 1+ missings
  missing_tbl
  
  
  # H20 nonsense begins ####
  rec_obj <- recipe(~ ., data = x_train_tbl) %>% # not sure wtf recipe does
    step_string2factor(string_2_factor_names) %>% # convert the character vars to factor vars (based on the ones we ID'd above I think)
    step_num2factor(num_2_factor_names) %>% # the rest of the vars that need to be converted to factors
    step_meanimpute(all_numeric()) %>% # impute means for numerics
    step_modeimpute(all_nominal()) %>% # impute modes for char/factors remaining
    prep(stringsAsFactors = FALSE) # dunno wtf this does
  
  rec_obj # Not sure what in the hell this is
  
  # Bake means to... bake?
   # use the "recipe" on train and test I guess?
  x_train_processed_tbl <- bake(rec_obj, x_train_tbl) 
  x_test_processed_tbl  <- bake(rec_obj, x_test_tbl)
  
  
  # before magic, we have NA's
  # Before transformation
  x_train_tbl %>%
    select(1:30) %>%
    glimpse() # OWN_CAR_AGE for example
  
  # after magic, no more NA's! (becasue the first 30 rows is the whole dataset... -.- whatever, you get the picture)
  # After transformation
  x_train_processed_tbl %>%
    select(1:30) %>%
    glimpse()
  
  # Convert Y var to factor b/c H20
  y_train_processed_tbl <- y_train_tbl %>%
    mutate(TARGET = TARGET %>% as.character() %>% as.factor())

  # clean the gunk out
  rm(rec_obj)
  rm(x_train_tbl)
  rm(x_test_tbl)
  rm(y_train_tbl)
  
  # or just... you know (beats me why he doesn't do this shite)
  rm(rec_obj, x_train_tbl, x_test_tbl, y_train_tbl)

  
  # OK forreal H20
  h2o.init()

  # more shenanigans
  h2o.no_progress()

  # Train thyme?
  data_h2o <- as.h2o(bind_cols(y_train_processed_tbl, x_train_processed_tbl))

  # splits-a-roo
  splits_h2o <- h2o.splitFrame(data_h2o, ratios = c(0.7, 0.15), seed = 1234)
  
  train_h2o <- splits_h2o[[1]]
  valid_h2o <- splits_h2o[[2]]
  test_h2o  <- splits_h2o[[3]]

  # Define Y again? w/e
  y <- "TARGET"
  x <- setdiff(names(train_h2o), y)
  
  automl_models_h2o <- h2o.automl(
    x = x,
    y = y,
    training_frame    = train_h2o,
    validation_frame  = valid_h2o,
    leaderboard_frame = test_h2o,
    max_runtime_secs  = 90
  )
  
  # The end?
  automl_leader <- automl_models_h2o@leader

  # how'd we do?
  performance_h2o <- h2o.performance(automl_leader, newdata = test_h2o)

  # get confus cat .gif
  performance_h2o %>%
    h2o.confusionMatrix()

  # oh ya bby, the good stuff
  performance_h2o %>%
    h2o.auc()

  #get ready kaggle, here we come!
  prediction_h2o <- h2o.predict(automl_leader, newdata = as.h2o(x_test_processed_tbl))

  # tbl and such
  prediction_tbl <- prediction_h2o %>%
    as.tibble() %>%
    bind_cols(
      x_test_processed_tbl %>% select(SK_ID_CURR)
    ) %>%
    select(SK_ID_CURR, p1) %>%
    rename(TARGET = p1)
  
  prediction_tbl  
  