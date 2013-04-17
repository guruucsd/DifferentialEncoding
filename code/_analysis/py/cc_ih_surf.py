import argparse
import os
import fnmatch as fnm
import re
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
import pickle
import shutil as sh
from process_data_delays import *


##################
# Do some reports
##################
def report_data(keys,stats,rpts=["rejs","iters","err"]):
    
    if ("rejs" in rpts):
        print "# rejections"
        for c in sorted(keys['clses']):
            print "Class = %s"%c
            for d in sorted(keys['delays']):
                for ts in sorted(keys['tsteps']):
                    try:
                        if (stats['nrej'][c][ts][d] > 0):
                            print "[%2d,%2s;n=%2d]: %d rejections" % (ts,d,stats['nrej'][c][ts][d]+len(stats['nl_ti'][c][ts][d]),stats['nrej'][c][ts][d])
                    except:
                        if (False):
                            print "[%2d,%2s;n=?]: [no data]" % (ts,d)
            print ""
    
    # This is dependent on 
    if ("iters" in rpts):
        print "Iterations to train to criterion:"
        for c in sorted(keys['clses']):
            print "Class = %s"%c
            for d in sorted(keys['delays']):
                for ts in sorted(keys['tsteps']):
                    try:
                        print "[%2d,%2s;n=%2d]: %6.1f +/- %5.1f" % (ts,d,len(stats['nl_ti'][c][ts][d]),np.mean(stats['nl_ti'][c][ts][d]),np.std(stats['nl_ti'][c][ts][d]))
                    except:
                        print "[%2d,%2s;n=?]: [no data]" % (ts,d)
                print ""
            print ""
    
    if ("err" in rpts):
        print "Average post-lesion error:"
        for c in sorted(keys['clses']):
            print "Class = %s"%c
            for d in sorted(keys['delays']):
                for ts in sorted(keys['tsteps']):
                    try:
                        print "[%2d,%2s;n=%2d]: %5.1f +/- %4.1f" % (ts,d,len(stats['l_p'][c][ts][d]),np.mean(stats['l_p'][c][ts][d]),np.std(stats['l_p'][c][ts][d]))
                    except:
                        print "[%2d,%2s;n=?]: [no data]" % (ts,d)
                print ""
            print ""

##################
# Do some plots
##################
def plot_data(keys,stats):
    plt.ioff()
    for c in sorted(keys['clses']):
        plt.figure()
        for delay in sorted(keys['delays'], reverse=True):
            try:
                color  = 'b' if (delay==1) else 'g'
                marker = 'v' if (delay==1) else 'o'
                x      = [ts for ts in sorted(stats['l_p'][c].keys()) if stats['l_p'][c][ts].has_key(delay)]
                y      = [np.mean(stats['l_p'][c][ts][delay]) for ts in x]
                yerr   = [np.std (stats['l_p'][c][ts][delay]) / np.sqrt(len(stats['l_p'][c][ts][delay])) for ts in x] 
                plt.errorbar(x,y,yerr=yerr, color=color, fmt=('-'+marker), hold=True,markersize=9,linewidth=1.2)
            except:
                print ""
        plt.legend(loc='upper right')
        plt.xlabel('time steps')
        plt.ylabel('% bits correct')
        plt.ylim([50,100]);



##################
# Main program
##################

### Get some command line args
parser = argparse.ArgumentParser(description='Create plots of network results')
parser.add_argument('dir', metavar='dir', type=str, nargs='+', default='',
                   help='directory containing mat files to process')
args = parser.parse_args()

####
for d in args.dir:
    matdir   = 'data/'+d
    datafile = matdir+'/data.pkl'
    keys,stats,ufiles = load_data(matdir, datafile)
    #save_data(datafile, keys,stats,ufiles)
    
    #report_data(keys,stats,"iters")
    #plot_data(keys,stats)
#plt.show()
    