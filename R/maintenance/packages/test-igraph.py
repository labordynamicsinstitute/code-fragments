from igraph import *
g = Graph.Erdos_Renyi(100000,0.0001)
g.diameter()
