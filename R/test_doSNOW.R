library(doSNOW)
registerDoSNOW(makeCluster(2, type = "SOCK"))
getDoParWorkers()
getDoParName()
N <- 10^4
system.time(foreach(i = 1:N, .combine = "cbind") %do% {
  sum(rnorm(N))
})
system.time(foreach(i = 1:N, .combine = "cbind") %dopar% {
  sum(rnorm(N))
})

