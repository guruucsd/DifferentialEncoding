import argparse
import os
import fnmatch as fnm
import re
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
import pickle
import shutil as sh

##################
#
##################
def process_data_weights(matdir, datafile):
    afiles = [f for f in os.listdir(matdir) if fnm.fnmatch(f,'*.mat')] #get all current mat files

    if (False and os.path.exists(datafile)):
        infile = open(datafile, 'rb')
        keys   = pickle.load(infile)
        stats  = pickle.load(infile)
        ufiles = pickle.load(infile)
        infile.close()
        
    else:
        ufiles = {}  # files used in the current stat set
        keys  = {'cc': set(),
                 'ih': set(),
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
        delay_cc  = int(np.max(net.sets.D_CC_INIT))
        max_wt    = float(np.max(net.sets.wt_lim_cc))
        try:
            cc_wt_lim = int(np.max(net.sets.cc_wt_lim))
        except:
            cc_wt_lim = 99

        #else:
        #    print f;
        #continue;
        
    #    if (sets.train_criterion > 0.1):
    #        cls = ("tc=%4.2f"%sets.train_criterion)
            #continue
        if (("calcd" in matdir) or ("mixed" in matdir)):
            cls = "ts=%2d,tc=%4.2f,T=[calcd/mixd]"%(sets.tsteps,sets.train_criterion)
        elif (len(set(net.T))==1 or np.max(abs(net.T-net.T_init))<0.001):
            cls = ("ts=%2d,tc=%4.2f,T=%4.2f"%(sets.tsteps,sets.train_criterion,net.T[0]))
        #    print "Using %s: %s"%(f,cls)
        else:
            cls = ("ts=%2d,tc=%4.2f,T-dynamic"%(sets.tsteps,sets.train_criterion))
        #    print "Skipping %s: %s"%(f,cls)
        #    continue
            
        # Add keys
        if (not cls in keys['clses']):
            keys['clses'].add(cls)
            stats['nrej'] [cls] = dict()
            stats['nl_ti'][cls] = dict() 
            stats['nl_p'] [cls] = dict()
            stats['l_p']  [cls] = dict()
        keys['cc'].add(delay_cc)
        if (not stats['nrej'][cls].has_key(delay_cc)):
            stats['nrej'] [cls][delay_cc] = dict() 
            stats['nl_ti'][cls][delay_cc] = dict() 
            stats['nl_p'] [cls][delay_cc] = dict()
            stats['l_p']  [cls][delay_cc] = dict()
        keys['ih'].add(delay_ih)
        if (not stats['nrej'][cls][delay_cc].has_key(delay_ih)):
            stats['nrej'] [cls][delay_cc][delay_ih] = 0
            stats['nl_ti'][cls][delay_cc][delay_ih] = []
            stats['nl_p'] [cls][delay_cc][delay_ih] = []
            stats['l_p']  [cls][delay_cc][delay_ih] = []
        
        # Validate run
        abs_diff  = np.abs(data.actcurve[pats.train.s==1] - pats.test.d[pats.train.s==1])
        nfailed   = np.sum(abs_diff>sets.train_criterion)

        if ((nfailed>0) and (sets.train_criterion*1.1<data.E_iter.shape[0],np.max(abs_diff))):
            stats['nrej'][cls][delay_cc][delay_ih] += 1
            print "%s did not train to criterion; failed after %d steps at %5.4f (%d failed)" % (f,data.E_iter.shape[0],np.max(abs_diff),nfailed)
            ufiles[f] = 0
            continue
    #    elif (sets.train_criterion!=0.25):
    #        stats['nrej'][cls][delay_cc][delay_ih] += 1
    #        print "%s trained to BAD tc=%4.2f in %d steps" % (f,sets.train_criterion,data.E_iter.shape[0])
    #        continue
        else:
            print "%s trained to criterion in %d steps (cls=%s)" % (f,data.E_iter.shape[0],cls)
            ufiles[f] = 1
        
        # Store values for data analysis
        
    
        stats['nl_ti'][cls][delay_cc][delay_ih].append(data.E_iter.shape[0])

        nl_abs_diff         = abs(data.nolesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        nl_max_diff         = max(nl_abs_diff)
        nl_bits_cor         = (nl_abs_diff<net.sets.train_criterion)
        nl_bits_set         = pats.train.gb.size
        
        l_abs_diff         = abs(data.lesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        l_max_diff         = max(l_abs_diff)
        l_bits_cor         = (l_abs_diff<net.sets.train_criterion)
        l_bits_set         = pats.train.gb.size
        
        if (any(pats.lbls=='intra')):
            stats['nl_p'] [cls][delay_cc][delay_ih].append(round(50*(data.an.nlbg_inter + data.an.nlbg_intra)))
            stats['l_p']  [cls][delay_cc][delay_ih].append(round(50*(data.an.lbg_inter  + data.an.lbg_intra)))
        else:
        	stats['l_p'] [cls][delay_cc][delay_ih].append( 100*sum(l_bits_cor)/l_bits_set)

        #try:
        #except:
        #    stats['nl_p'] [cls][delay_cc][delay_ih].append(round(50*(data.an.nl.bg_inter + data.an.nl.bg_intra)))
       # 
       # try:
       # except:
       #     stats['l_p']  [cls][delay_cc][delay_ih].append(round(50*(data.an.l.bg_inter  + data.an.l.bg_intra)))
        
    # Point out any unused files
    for f in  set(ufiles.keys()).difference(afiles):
        print "WARNING: file %s in pkl but NOT in directory."%f
    
    return keys,stats,ufiles
    

##################
#
##################
def process_data_delays(matdir, datafile):
    afiles = [f for f in os.listdir(matdir) if fnm.fnmatch(f,'*.mat')] #get all current mat files

    if (False and os.path.exists(datafile)):
        infile = open(datafile, 'rb')
        keys   = pickle.load(infile)
        stats  = pickle.load(infile)
        ufiles = pickle.load(infile)
        infile.close()
        
    else:
        ufiles = {}  # files used in the current stat set
        keys  = {'cc': set(),
                 'ih': set(),
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
        delay_cc  = int(np.max(net.sets.D_CC_INIT))
        delay_ih  = int(np.max(net.sets.D_IH_INIT))
        try:
            cc_wt_lim = int(np.max(net.sets.cc_wt_lim))
        except:
            cc_wt_lim = 99

        #else:
        #    print f;
        #continue;
        
    #    if (sets.train_criterion > 0.1):
    #        cls = ("tc=%4.2f"%sets.train_criterion)
            #continue
        if (("calcd" in matdir) or ("mixed" in matdir)):
            cls = "ts=%2d,tc=%4.2f,T=[calcd/mixd]"%(sets.tsteps,sets.train_criterion)
        elif (len(set(net.T))==1 or np.max(abs(net.T-net.T_init))<0.001):
            cls = ("ts=%2d,tc=%4.2f,T=%4.2f"%(sets.tsteps,sets.train_criterion,net.T[0]))
        #    print "Using %s: %s"%(f,cls)
        else:
            cls = ("ts=%2d,tc=%4.2f,T-dynamic"%(sets.tsteps,sets.train_criterion))
        #    print "Skipping %s: %s"%(f,cls)
        #    continue
            
        # Add keys
        if (not cls in keys['clses']):
            keys['clses'].add(cls)
            stats['nrej'] [cls] = dict()
            stats['nl_ti'][cls] = dict() 
            stats['nl_p'] [cls] = dict()
            stats['l_p']  [cls] = dict()
        keys['cc'].add(delay_cc)
        if (not stats['nrej'][cls].has_key(delay_cc)):
            stats['nrej'] [cls][delay_cc] = dict() 
            stats['nl_ti'][cls][delay_cc] = dict() 
            stats['nl_p'] [cls][delay_cc] = dict()
            stats['l_p']  [cls][delay_cc] = dict()
        keys['ih'].add(delay_ih)
        if (not stats['nrej'][cls][delay_cc].has_key(delay_ih)):
            stats['nrej'] [cls][delay_cc][delay_ih] = 0
            stats['nl_ti'][cls][delay_cc][delay_ih] = []
            stats['nl_p'] [cls][delay_cc][delay_ih] = []
            stats['l_p']  [cls][delay_cc][delay_ih] = []
        
        # Validate run
        abs_diff  = np.abs(data.actcurve[pats.train.s==1] - pats.test.d[pats.train.s==1])
        nfailed   = np.sum(abs_diff>sets.train_criterion)

        if ((nfailed>0) and (sets.train_criterion*1.1<data.E_iter.shape[0],np.max(abs_diff))):
            stats['nrej'][cls][delay_cc][delay_ih] += 1
            print "%s did not train to criterion; failed after %d steps at %5.4f (%d failed)" % (f,data.E_iter.shape[0],np.max(abs_diff),nfailed)
            ufiles[f] = 0
            continue
    #    elif (sets.train_criterion!=0.25):
    #        stats['nrej'][cls][delay_cc][delay_ih] += 1
    #        print "%s trained to BAD tc=%4.2f in %d steps" % (f,sets.train_criterion,data.E_iter.shape[0])
    #        continue
        else:
            print "%s trained to criterion in %d steps (cls=%s)" % (f,data.E_iter.shape[0],cls)
            ufiles[f] = 1
        
        # Store values for data analysis
        
    
        stats['nl_ti'][cls][delay_cc][delay_ih].append(data.E_iter.shape[0])

        nl_abs_diff         = abs(data.nolesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        nl_max_diff         = max(nl_abs_diff)
        nl_bits_cor         = (nl_abs_diff<net.sets.train_criterion)
        nl_bits_set         = pats.train.gb.size
        
        l_abs_diff         = abs(data.lesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        l_max_diff         = max(l_abs_diff)
        l_bits_cor         = (l_abs_diff<net.sets.train_criterion)
        l_bits_set         = pats.train.gb.size
        
        if (any(pats.lbls=='intra')):
            stats['nl_p'] [cls][delay_cc][delay_ih].append(round(50*(data.an.nlbg_inter + data.an.nlbg_intra)))
            stats['l_p']  [cls][delay_cc][delay_ih].append(round(50*(data.an.lbg_inter  + data.an.lbg_intra)))
        else:
        	stats['l_p'] [cls][delay_cc][delay_ih].append( 100*sum(l_bits_cor)/l_bits_set)

        #try:
        #except:
        #    stats['nl_p'] [cls][delay_cc][delay_ih].append(round(50*(data.an.nl.bg_inter + data.an.nl.bg_intra)))
       # 
       # try:
       # except:
       #     stats['l_p']  [cls][delay_cc][delay_ih].append(round(50*(data.an.l.bg_inter  + data.an.l.bg_intra)))
        
    # Point out any unused files
    for f in  set(ufiles.keys()).difference(afiles):
        print "WARNING: file %s in pkl but NOT in directory."%f
    
    return keys,stats,ufiles
    

##################
#
##################
def process_data_tsteps(matdir, datafile):
    afiles = [f for f in os.listdir(matdir) if fnm.fnmatch(f,'*.mat')] #get all current mat files

    if (os.path.exists(datafile)):
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
        tstep     = int(sets.tsteps)
        delay_cc  = int(np.max(net.sets.D_CC_INIT))
        delay_ih  = int(np.max(net.sets.D_IH_INIT))
        try:
            cc_wt_lim = int(np.max(net.sets.cc_wt_lim))
        except:
            cc_wt_lim = 99

        #else:
        #    print f;
        continue;
        
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
        key = 'ccd=%2d,ihd=%2d,cc_wt_lim=%4.2f'%(delay_cc,delay_ih,cc_wt_lim)
        keys['delays'].add(key)
        if (not stats['nrej'][cls][tstep].has_key(key)):
            stats['nrej'] [cls][tstep][key] = 0
            stats['nl_ti'][cls][tstep][key] = []
            stats['nl_p'] [cls][tstep][key] = []
            stats['l_p']  [cls][tstep][key] = []
        
        # Validate run
        abs_diff  = np.abs(data.actcurve[pats.train.s==1] - pats.test.d[pats.train.s==1])
        nfailed   = np.sum(abs_diff>sets.train_criterion)

        if ((nfailed>0) and (sets.train_criterion*1.1<data.E_iter.shape[0],np.max(abs_diff))):
            stats['nrej'][cls][tstep][key] += 1
            print "%s did not train to criterion; failed after %d steps at %5.4f (%d failed)" % (f,data.E_iter.shape[0],np.max(abs_diff),nfailed)
            ufiles[f] = 0
            continue
    #    elif (sets.train_criterion!=0.25):
    #        stats['nrej'][cls][tstep][key] += 1
    #        print "%s trained to BAD tc=%4.2f in %d steps" % (f,sets.train_criterion,data.E_iter.shape[0])
    #        continue
        else:
            print "%s trained to criterion in %d steps (cls=%s)" % (f,data.E_iter.shape[0],cls)
            ufiles[f] = 1
        
        # Store values for data analysis
        
    
        stats['nl_ti'][cls][tstep][key].append(data.E_iter.shape[0])

        nl_abs_diff         = abs(data.nolesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        nl_max_diff         = max(nl_abs_diff)
        nl_bits_cor         = (nl_abs_diff<net.sets.train_criterion)
        nl_bits_set         = pats.train.gb.size
        
        l_abs_diff         = abs(data.lesion.ypat[pats.train.s==1]-pats.train.d[pats.train.s==1])
        l_max_diff         = max(l_abs_diff)
        l_bits_cor         = (l_abs_diff<net.sets.train_criterion)
        l_bits_set         = pats.train.gb.size
        
        if (any(pats.lbls=='intra')):
            stats['nl_p'] [cls][tstep][key].append(round(50*(data.an.nlbg_inter + data.an.nlbg_intra)))
            stats['l_p']  [cls][tstep][key].append(round(50*(data.an.lbg_inter  + data.an.lbg_intra)))
        else:
        	stats['l_p'] [cls][tstep][key].append( 100*sum(l_bits_cor)/l_bits_set)

        #try:
        #except:
        #    stats['nl_p'] [cls][tstep][key].append(round(50*(data.an.nl.bg_inter + data.an.nl.bg_intra)))
       # 
       # try:
       # except:
       #     stats['l_p']  [cls][tstep][key].append(round(50*(data.an.l.bg_inter  + data.an.l.bg_intra)))
        
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
# Load the results
##################
def load_data(matdir, datafile):
    
    if (os.path.exists(datafile)):
        infile = open(datafile, 'rb')
        keys   = pickle.load(infile)
        stats  = pickle.load(infile)
        ufiles = pickle.load(infile)
        infile.close()
        
    else:
        raise Exception('File does not exist', datafile)

    return keys,stats,ufiles

##################
# Main program
##################

if __name__ == "__main__":
    ### Get some command line args
    parser = argparse.ArgumentParser(description='Create plots of network results')
    parser.add_argument('dir',  metavar='dir',  type=str, nargs='1', default='',
                       help='directory containing mat files to process')
    parser.add_argument('type', metavar='type', type=str, nargs='1', default='delays',
                        help='type of processing [delays,weight,tsteps]');

    args = parser.parse_args()
    
    ####
    for d in args.dir:
        matdir   = 'data/'+d
        datafile = matdir+'/'+type+'.pkl'
        if (args.type=='delays'):
            keys,stats,ufiles = process_data_delays(matdir, datafile)
        elif (args.type=='weight'):
            keys,stats,ufiles = process_data_weights(matdir, datafile)
        elif (args.type=='tsteps'):
            keys,stats,ufiles = process_data_delays(matdir, datafile)
        save_data(datafile, keys,stats,ufiles)
