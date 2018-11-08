# Copied from: https://shirinsplayground.netlify.com/2018/11/neural_nets_explained/


library(tidyverse)
library(readr)
library(h2o)
library(data.table)
h2o.init(nthreads = -1)
Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre.1.8.0_191')

telco_data <- fread("./data_in/WA_Fn-UseC_-Telco-Customer-Churn.csv")

telco_data %>%
  select_if(is.numeric) %>%
  gather() %>%
  ggplot(aes(x = value)) +
  facet_wrap(~ key, scales = "free", ncol = 4) +
  geom_density()

telco_data %>%
  select_if(is.character) %>%
  select(-customerID) %>%
  gather() %>%
  ggplot(aes(x = value)) +
  facet_wrap(~ key, scales = "free", ncol = 3) +
  geom_bar()


hf <- telco_data %>%
  mutate_if(is.character, as.factor) %>%
  as.h2o


hf_X <- colnames(telco_data)[2:20]
hf_X

hf_y <- colnames(telco_data)[21]
hf_y

dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf)

dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf,
                             activation = "RectifierWithDropout")

dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf,
                             activation = "RectifierWithDropout",
                             hidden = c(100, 80, 100),
                             hidden_dropout_ratios = c(0.2, 0.2, 0.2))

dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf,
                             activation = "RectifierWithDropout",
                             hidden = c(100, 80, 100),
                             hidden_dropout_ratios = c(0.2, 0.2, 0.2),
                             loss = "CrossEntropy")


dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf,
                             activation = "RectifierWithDropout",
                             hidden = c(100, 80, 100),
                             hidden_dropout_ratios = c(0.2, 0.2, 0.2),
                             loss = "CrossEntropy",
                             epochs = 200)

dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf,
                             activation = "RectifierWithDropout",
                             hidden = c(100, 80, 100),
                             hidden_dropout_ratios = c(0.2, 0.2, 0.2),
                             loss = "CrossEntropy",
                             epochs = 200,
                             rate = 0.005,
                             adaptive_rate = FALSE,
                             momentum_start = 0.5,
                             momentum_ramp = 100,
                             momentum_stable = 0.99,
                             nesterov_accelerated_gradient = TRUE)

dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf,
                             activation = "RectifierWithDropout",
                             hidden = c(100, 80, 100),
                             hidden_dropout_ratios = c(0.2, 0.2, 0.2),
                             loss = "CrossEntropy",
                             epochs = 200,
                             rate = 0.005,
                             adaptive_rate = TRUE,
                             momentum_start = 0.5,
                             momentum_ramp = 100,
                             momentum_stable = 0.99,
                             nesterov_accelerated_gradient = TRUE,
                             l1 = 0,
                             l2 = 0)


dl_model <- h2o.deeplearning(x = hf_X,
                             y = hf_y,
                             training_frame = hf,
                             activation = "RectifierWithDropout",
                             hidden = c(100, 80, 100),
                             hidden_dropout_ratios = c(0.2, 0.2, 0.2),
                             loss = "CrossEntropy",
                             epochs = 200,
                             rate = 0.005,
                             adaptive_rate = FALSE,
                             momentum_start = 0.5,
                             momentum_ramp = 100,
                             momentum_stable = 0.99,
                             nesterov_accelerated_gradient = TRUE,
                             l1 = 0,
                             l2 = 0,
                             nfolds = 3,
                             fold_assignment = "Stratified",
                             keep_cross_validation_predictions = TRUE,
                             balance_classes = TRUE,
                             seed = 42)


plot(dl_model)
h2o.cross_validation_predictions(dl_model)
h2o.cross_validation_holdout_predictions(dl_model)
