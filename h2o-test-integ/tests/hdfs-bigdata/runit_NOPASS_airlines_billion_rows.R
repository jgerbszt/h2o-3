#----------------------------------------------------------------------
# Purpose:  This test exercises HDFS operations from R.
#----------------------------------------------------------------------

setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source('../h2o-runit-hadoop.R')

ipPort <- get_args(commandArgs(trailingOnly = TRUE))
myIP   <- ipPort[[1]]
myPort <- ipPort[[2]]
hdfs_name_node <- Sys.getenv(c("NAME_NODE"))
print(hdfs_name_node)

library(RCurl)
library(testthat)
library(h2o)

heading("BEGIN TEST")
conn <- h2o.init(ip=myIP, port=myPort, startH2O = FALSE)
h2o.removeAll()

hdfs_data_file = "/datasets/airlinesbillion.csv"

#----------------------------------------------------------------------
# Single file cases.
#----------------------------------------------------------------------

heading("Testing single file importHDFS")
url <- sprintf("hdfs://%s%s", hdfs_name_node, hdfs_data_file)
data.hex <- h2o.importFile(conn, url)
data1.hex <- data.hex

n <- nrow(data.hex)
print(n)
if (n != 1166952590) {
    stop("nrows is wrong")
}

#Constructing validation and train sets by sampling (20/80)
#creating a column as tall as airlines(nrow(air))
s <- h2o.runif(data.hex)    # Useful when number of rows too large for R to handle
data.train <- data.hex[s <= 0.8,]
data.valid <- data.hex[s > 0.8,]

## Response = Distance 
myY = "C19"
myX = setdiff(names(data.hex), myY)
## Build GLM Model and compare AUC with h2o1
data_irlsm.glm <- h2o.glm(x = myX, y = myY, training_frame = data.train, validation_frame=data.valid, family = "gaussian", solver = "IRLSM")
data_lbfgs.glm <- h2o.glm(x = myX, y = myY, training_frame = data.train, validation_frame=data.valid, family = "gaussian", solver = "L_BFGS")

## Chose which col as response
## Response = IsDepDelayed
myY = "C31"
myX = setdiff(names(data1.hex), myY)
data1.gbm <- h2o.gbm(x = myX, y = myY, training_frame = data.train, validation_frame=data.valid, ntrees = 10, max_depth = 5, distribution = "AUTO")
data2.gbm <- h2o.gbm(x = myX, y = myY, training_frame = data.train, validation_frame=data.valid, ntrees = 10, max_depth = 5, distribution = "bernoulli")
data3.gbm <- h2o.gbm(x = myX, y = myY, training_frame = data.train, validation_frame=data.valid, ntrees = 10, max_depth = 5, distribution = "multinomial")

#Random Forest
#data1.rf = h2o.randomForest(x = myX, y = myY, training_frame = data.train, validation_frame=data.valid, ntrees = 10, max_depth = 5)
#data1.rf

#Deep Learning
#data1.dl <- h2o.deeplearning(x=myX, y=myY, training_frame=data.train, validation_frame=data.valid, replicate_training_data=FALSE, epochs=.1, hidden=c(5,5))
#data1.dl 

PASS_BANNER()
