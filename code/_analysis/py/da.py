import argparse
import os
import fnmatch as fnm
import re
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
import pickle

##################
# Main program
##################
def process_data(matdir, datafile):
    afiles = [f for f in os.listdir(matdir) if fnm.fnmatch(f,'*.mat')] #get all current mat files
    
    if (False and os.path.exists(datafile)):
        infile = open(datafile, 'rb')
        keys   = pickle.load(infile)
        stats  = pickle.load(infile)
        ufiles = pickle.load(infile)
        infile.close()
        
    else:
        ufiles = {}  # files used in the current stat set
        keys  = {'tsteps': set(),
                 'delays': set(),
                 'clses' : set()}
        stats = {'nrej'  : dict(),
                 'nl_ti' : dict(),  #no lesion training iterations
                 'nl_p'  : dict(),   #non-lesion performance (should be 100%!)
                 'l_p'   : dict()}    #lesion performance
    
    for f in afiles:
        
        if (f in ufiles):
            #print 'Skipping used file %s'%f
            continue
        else:
            #print 'Did not find %s in ufiles'%f
            ufiles[f] = False
            #continue
            
        d = sio.loadmat('%s/%s'%(matdir,f), squeeze_me=True, struct_as_record=False)
        data = d['data']; net = d['net']; pats = d['pats']; sets = net.sets
        
        
        # Determine keys
        tstep = int(sets.tsteps)
        delay  = int(np.max(net.D))
    #    if (sets.train_criterion > 0.1):
    #        cls = ("tc=%4.2f"%sets.train_criterion)
            #continue
        if (("calcd" in matdir) or ("mixed" in matdir)):
            cls = "tc=%4.2f,T=[calcd/mixd]"%(sets.train_criterion)
        elif (len(set(net.T))==1 or np.max(abs(net.T-net.T_init))<0.001):
            cls = ("tc=%4.2f,T=%4.2f"%(sets.train_criterion,net.T[0]))
        #    print "Using %s: %s"%(f,cls)
        else:
            cls = ("tc=%4.2f,T-dynamic"%sets.train_criterion)
        #    print "Skipping %s: %s"%(f,cls)
        #    continue
            
        # Add keys
        if (not cls in keys['clses']):
            keys['clses'].add(cls)
            stats['nrej'] [cls] = dict()
            stats['nl_ti'][cls] = dict() 
            stats['nl_p'] [cls] = dict()
            stats['l_p']  [cls] = dict()
        keys['tsteps'].add(tstep)
        if (not stats['nrej'][cls].has_key(tstep)):
            stats['nrej'] [cls][tstep] = dict() 
            stats['nl_ti'][cls][tstep] = dict() 
            stats['nl_p'] [cls][tstep] = dict()
            stats['l_p']  [cls][tstep] = dict()
        keys['delays'].add(delay)
        if (not stats['nrej'][cls][tstep].has_key(delay)):
            stats['nrej'] [cls][tstep][delay] = 0
            stats['nl_ti'][cls][tstep][delay] = []
            stats['nl_p'] [cls][tstep][delay] = []
            stats['l_p']  [cls][tstep][delay] = []
        
        # Validate run
        abs_diff  = np.abs(data.actcurve[pats.train.s==1] - pats.test.d[pats.train.s==1])
        nfailed   = np.sum(abs_diff>sets.train_criterion)

        if (nfailed>0):
            stats['nrej'][cls][tstep][delay] += 1
            print "%s did not train to criterion; failed after %d steps at %5.4f (%d failed)" % (f,data.E_iter.shape[0],np.max(abs_diff),nfailed)
            ufiles[f] = 0
            continue
    #    elif (sets.train_criterion!=0.25):
    #        stats['nrej'][cls][tstep][delay] += 1
    #        print "%s trained to BAD tc=%4.2f in %d steps" % (f,sets.train_criterion,data.E_iter.shape[0])
    #        continue
        else:
            print "%s trained to criterion in %d steps (cls=%s)" % (f,data.E_iter.shape[0],cls)
            ufiles[f] = 1
        
        # Store values for data analysis
        
    
        stats['nl_ti'][cls][tstep][delay].append(data.E_iter.shape[0])

        nl_abs_diff         = abs(data.nolesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        nl_max_diff         = max(nl_abs_diff)
        nl_bits_cor         = (nl_abs_diff<net.sets.train_criterion)
        nl_bits_set         = pats.train.gb.size
        
        l_abs_diff         = abs(data.lesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        l_max_diff         = max(l_abs_diff)
        l_bits_cor         = (l_abs_diff<net.sets.train_criterion)
        l_bits_set         = pats.train.gb.size
        
        if (any(pats.lbls=='intra')):
            stats['nl_p'] [cls][tstep][delay].append(round(50*(data.an.nlbg_inter + data.an.nlbg_intra)))
            stats['l_p']  [cls][tstep][delay].append(round(50*(data.an.lbg_inter  + data.an.lbg_intra)))
        else:
        	stats['l_p'] [cls][tstep][delay].append( 100*sum(l_bits_cor)/l_bits_set)

        #try:
        #except:
        #    stats['nl_p'] [cls][tstep][delay].append(round(50*(data.an.nl.bg_inter + data.an.nl.bg_intra)))
       # 
       # try:
       # except:
       #     stats['l_p']  [cls][tstep][delay].append(round(50*(data.an.l.bg_inter  + data.an.l.bg_intra)))
        
    # Point out any unused files
    for f in  set(ufiles.keys()).difference(afiles):
        print "WARNING: file %s in pkl but NOT in directory."%f
    
    return keys,stats,ufiles
    
    
##################
# Save the results
##################
def save_data(datafile, keys,stats,ufiles):
    outfile = open(datafile,'wb')
    pickle.dump(keys, outfile)
    pickle.dump(stats, outfile)
    pickle.dump(ufiles,outfile)
    outfile.close()

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
                            print "[%2d,%2d;n=%2d]: %d rejections" % (ts,d,stats['nrej'][c][ts][d]+len(stats['nl_ti'][c][ts][d]),stats['nrej'][c][ts][d])
                    except:
                        if (False):
                            print "[%2d,%2d;n=?]: [no data]" % (ts,d)
            print ""
    
    # This is dependent on 
    if ("iters" in rpts):
        print "Iterations to train to criterion:"
        for c in sorted(keys['clses']):
            print "Class = %s"%c
            for d in sorted(keys['delays']):
                for ts in sorted(keys['tsteps']):
                    try:
                        print "[%2d,%2d;n=%2d]: %6.1f +/- %5.1f" % (ts,d,len(stats['nl_ti'][c][ts][d]),np.mean(stats['nl_ti'][c][ts][d]),np.std(stats['nl_ti'][c][ts][d]))
                    except:
                        print "[%2d,%2d;n=?]: [no data]" % (ts,d)
                print ""
            print ""
    
    if ("err" in rpts):
        print "Average post-lesion error:"
        for c in sorted(keys['clses']):
            print "Class = %s"%c
            for d in sorted(keys['delays']):
                for ts in sorted(keys['tsteps']):
                    try:
                        print "[%2d,%2d;n=%2d]: %5.1f +/- %4.1f" % (ts,d,len(stats['l_p'][c][ts][d]),np.mean(stats['l_p'][c][ts][d]),np.std(stats['l_p'][c][ts][d]))
                    except:
                        print "[%2d,%2d;n=?]: [no data]" % (ts,d)
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
                plt.errorbar(x,y,yerr=yerr, color=color, fmt=('-'+marker), hold=True,label=('%s; Delay=%2d'%(c,delay)),markersize=9,linewidth=1.2)
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
    keys,stats,ufiles = process_data(matdir, datafile)
    save_data(datafile, keys,stats,ufiles)
    
    report_data(keys,stats,"iters")
    plot_data(keys,stats)
plt.show()
    