function [net,data] = r_train_resilient(net,pats)
    if (net.sets.online)
        warning('online processing is broken; switching to batch processing')
        net.sets.online = false;
        [net,data] = r_train_resilient_online(net,pats); %old-style batch; online is broken
    else
        [net,data] = r_train_resilient_batch(net,pats); %new-style faaaast(er) batch
    end;
