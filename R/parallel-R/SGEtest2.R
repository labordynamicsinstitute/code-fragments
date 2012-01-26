# from    http://blog.nguyenvq.com/2010/01/20/scheduled-parallel-computing-with-r-r-rmpi-openmpi-sun-grid-engine-sge/
cl <- makeCluster()
print(clusterCall(cl, function() Sys.info()))
mpi.close.Rslaves()
mpi.quit() 

