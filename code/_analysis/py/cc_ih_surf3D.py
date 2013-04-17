from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import matplotlib.pyplot as plt
import numpy as np
from process_data import load_data

d='p1'
matdir   = 'data/'+d
datafile = matdir+'/delays.pkl'
keys,stats,ufiles = load_data(matdir, datafile)


##################
# Do some plots
##################
#def plot_data(keys,stats):
#stats['nrej'][cls][delay_cc][delay_ih] += 1

plt.ioff()
for c in sorted(keys['clses']):
    print c

    X = np.array(np.sort(list(keys['cc'])))
    Y = np.array(np.sort(list(keys['ih'])))
    Z = np.zeros((X.shape[0],Y.shape[0]))
    for i in np.arange(X.shape[0]):
        for j in np.arange(Y.shape[0]):
            Z[i][j] = np.mean( stats['l_p'][c][X[i]][Y[j]] )
    X, Y = np.meshgrid(X, Y)

    fig = plt.figure()
    #fig.hold=True

    ax = fig.gca(projection='3d')

    surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.jet,
            linewidth=0, antialiased=False)
    plt.xlabel('cc delay')
    plt.show()

#    ax.set_zlim3d(50, 100)
    
#    ax.zaxis.set_major_locator(LinearLocator(10))
#    ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))
    
    #fig.colorbar(surf, shrink=0.5, aspect=5)
    
#    color  = 'b' if (delay==1) else 'g'
#    marker = 'v' if (delay==1) else 'o'
#    x      = [ts for ts in sorted(stats['l_p'][c].keys()) if stats['l_p'][c][ts].has_key(delay)]
#    y      = [np.mean(stats['l_p'][c][ts][delay]) for ts in x]
#    yerr   = [np.std (stats['l_p'][c][ts][delay]) / np.sqrt(len(stats['l_p'][c][ts][delay])) for ts in x] 
#    plt.errorbar(x,y,yerr=yerr, color=color, fmt=('-'+marker), hold=True,markersize=9,linewidth=1.2)

    #plt.legend(loc='upper right')
   # plt.xlabel('cc delay')
   # plt.ylabel('ih delay')
#    plt.zlabel('% bits correct')
#    plt.ylim([50,100]);
    
