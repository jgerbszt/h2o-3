setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source('../../h2o-runit.R')

check.deeplearning.gridlayers <- function(conn) {
  iris.hex <- h2o.uploadFile(conn, locate("smalldata/iris/iris.csv"), destination_frame="iris.hex")
  print(summary(iris.hex))

  pretty.list <- function(ll) {
    str <- lapply(ll, function(x) { paste("(", paste(x, collapse = ","), ")", sep = "") })
    paste(str, collapse = ",")
  }
  hidden_opts <- list(c(20, 20), c(50, 50, 50))
  loss_opts <- c("MeanSquare", "CrossEntropy")
  hyper_params <- list(loss = loss_opts, hidden = hidden_opts)
  Log.info(paste("Deep Learning grid search over hidden layers:", pretty.list(hyper_params)))
  hh <- h2o.grid("deeplearning", x=1:4, y=5, training_frame=iris.hex, hyper_params = hyper_params)
  size_of_hyper_space <- length(hidden_opts)*length(loss_opts)
  expect_equal(length(hh@model_ids), size_of_hyper_space)

  # Get models
  hh_models <- lapply(hh@model_ids, function(mid) { 
    model = h2o.getModel(mid)
  })
  # Check expected number of models
  expect_equal(length(hh_models), size_of_hyper_space)

  # Collect all hidden parameters from models and verify that they are only from hidden_opts list
  hh_params <- unique(lapply(hh_models, function(model) { model@parameters$hidden }))
  expect_equal(length(hh_params), length(hidden_opts))
  expect_true(all(hh_params %in% hidden_opts))
  expect_true(all(hidden_opts %in% hh_params))

  # Collect all loss parameters from models and verify that they are only from loss_opts list
  hl_params <- unique(lapply(hh_models, function(model) { model@parameters$loss }))
  expect_equal(length(hl_params), length(loss_opts))
  # Symetric difference should be empty
  expect_true(all(hl_params %in% loss_opts))
  expect_true(all(loss_opts %in% hl_params))

  cat("\n\n Grid:")
  print(hh)

  cat("\n\n Collected hidden parameters from grid results:")
  print(hh_params)

  cat("\n\n Defined hidden parameters for grid search:")
  print(hidden_opts)

  testEnd()
}

doTest("Deep Learning Grid Search: Hidden Layers", check.deeplearning.gridlayers)

