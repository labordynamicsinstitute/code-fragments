library(doMC)
registerDoMC()
options(cores = 2)
getDoParWorkers()
getDoParName()
N <- 10^4
system.time(foreach(i = 1:N, .combine = "cbind") %do% {
  sum(rnorm(N))
})
system.time(foreach(i = 1:N, .combine = "cbind") %dopar% {
  sum(rnorm(N))
})
