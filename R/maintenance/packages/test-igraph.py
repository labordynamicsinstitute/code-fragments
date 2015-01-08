from igraph import *
import os
import time
g = Graph.Erdos_Renyi(100000,0.0001)
start = time.time()
print("Diameter of g:", g.diameter())
print("Elapsed time: ", time.time() - start )
print("The End")
