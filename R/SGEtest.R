# from http://blog.nguyenvq.com/2010/01/20/scheduled-parallel-computing-with-r-r-rmpi-openmpi-sun-grid-engine-sge/
mpi.remote.exec(paste("I am",mpi.comm.rank(),"of",mpi.comm.size()))
mpi.remote.exec(paste("I am",Sys.info(),"of",mpi.comm.size()))
mpi.close.Rslaves()
mpi.quit() 

