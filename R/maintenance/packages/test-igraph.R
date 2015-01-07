library(igraph)
g <- erdos.renyi.game(100000,0.0001,type="gnp")
summary(g)
shortest.paths(g)
starttime=Sys.time()
diameter(g)
Sys.time()-starttime

