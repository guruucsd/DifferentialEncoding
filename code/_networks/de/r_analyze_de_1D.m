function [data] = r_analyze_de_1D(net,pats,d)
%

    % Report on which hemisphere learned best
    
    % Report on which hemisphere was more robust
    
    
    % RH
    fprintf('Before Lesion (may be mixed due to timing?):\n');
    fprintf('\tRVF:  LH=%5.2e vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.rvf,:))))); %RVF
    fprintf('\tLVF:  LH=%5.2e vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.lvf,:))))); %LVF
    fprintf('\tS+:   LH=%5.2e vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.lc, :))))); %LH/local
    fprintf('\tL+:   LH=%5.2e vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.gl, :))))); %LH/global
    fprintf('\n');
    fprintf('\tL+S-: LH=%5.2e vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.gl&~pats.idx.lc,:))))); %LH/global
    fprintf('\tL-S+: LH=%5.2e vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.lc&~pats.idx.gl,:))))); %LH/local
    fprintf('\n');
    fprintf('\tRVF [L+S-: LH=%5.2e] vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.rvf&pats.idx.gl&~pats.idx.lc,:))))); %LH/global
    fprintf('\tRVF [L-S+: LH=%5.2e] vs RH=%5.2e\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.rvf&~pats.idx.gl&pats.idx.lc,:))))); %LH/global
    fprintf('\tLVF L+S-: LH=%5.2e vs [RH=%5.2e]\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.lvf&pats.idx.lc&~pats.idx.gl,:))))); %LH/local
    fprintf('\tLVF L-S+: LH=%5.2e vs [RH=%5.2e]\n', mean(squeeze(sqrt(d.nolesion.E(end,pats.idx.lvf&~pats.idx.lc&pats.idx.gl,:))))); %LH/local

    m = sum(squeeze(d.nolesion.E(end,:,:)));
    fprintf('After Normalization:\n');
    fprintf('\tRVF:  LH=%5.2e vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.rvf,:))))./m); %RVF
    fprintf('\tLVF:  LH=%5.2e vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.lvf,:))))./m); %LVF
    fprintf('\tS+:   LH=%5.2e vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.lc, :))))./m); %LH/local
    fprintf('\tL+:   LH=%5.2e vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.gl, :))))./m); %LH/global
    fprintf('\n');
    fprintf('\tL+S-: LH=%5.2e vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.gl&~pats.idx.lc,:))))./m); %LH/global
    fprintf('\tL-S+: LH=%5.2e vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.lc&~pats.idx.gl,:))))./m); %LH/local
    fprintf('\n');
    fprintf('\tRVF L+S-: [LH=%5.2e] vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.rvf&pats.idx.gl&~pats.idx.lc,:))))./m); %LH/global
    fprintf('\tRVF L-S+: [LH=%5.2e] vs RH=%5.2e\n', sum(squeeze((d.nolesion.E(end,pats.idx.rvf&~pats.idx.gl&pats.idx.lc,:))))./m); %LH/global
    fprintf('\tLVF L+S-: LH=%5.2e vs [RH=%5.2e]\n', sum(squeeze((d.nolesion.E(end,pats.idx.lvf&pats.idx.lc&~pats.idx.gl,:))))./m); %LH/local
    fprintf('\tLVF L-S+: LH=%5.2e vs [RH=%5.2e]\n', sum(squeeze((d.nolesion.E(end,pats.idx.lvf&~pats.idx.lc&pats.idx.gl,:))))./m); %LH/local
    
    fprintf('\nAfter Lesion (More like original model?):\n');
    fprintf('\tRVF:  LH=%5.2e vs RH=%5.2e\n', mean(squeeze(d.lesion.E(end,pats.idx.rvf,:)))); %RVF
    fprintf('\tLVF:  LH=%5.2e vs RH=%5.2e\n', mean(squeeze(d.lesion.E(end,pats.idx.lvf,:)))); %LVF
    fprintf('\tS+:   LH=%5.2e vs RH=%5.2e\n', mean(squeeze(d.lesion.E(end,pats.idx.lc, :)))); %LH/local
    fprintf('\tL+:   LH=%5.2e vs RH=%5.2e\n', mean(squeeze(d.lesion.E(end,pats.idx.gl, :)))); %LH/global
    fprintf('\n');
    fprintf('\tL+S-: LH=%5.2e vs RH=%5.2e\n', mean(squeeze(d.lesion.E(end,pats.idx.gl&~pats.idx.lc,:)))); %LH/global
    fprintf('\tL-S+: LH=%5.2e vs RH=%5.2e\n', mean(squeeze(d.lesion.E(end,pats.idx.lc&~pats.idx.gl,:)))); %LH/local
    fprintf('\n');
    fprintf('\tRVF L+S-: [LH=%5.2e] vs RH=%5.2e\n', mean(squeeze((d.lesion.E(end,pats.idx.rvf&pats.idx.gl&~pats.idx.lc,:))))); %LH/global
    fprintf('\tRVF L-S+: [LH=%5.2e] vs RH=%5.2e\n', mean(squeeze((d.lesion.E(end,pats.idx.rvf&~pats.idx.gl&pats.idx.lc,:))))); %LH/global
    fprintf('\tLVF L+S-: LH=%5.2e vs [RH=%5.2e]\n', mean(squeeze((d.lesion.E(end,pats.idx.lvf&pats.idx.lc&~pats.idx.gl,:))))); %LH/local
    fprintf('\tLVF L-S+: LH=%5.2e vs [RH=%5.2e]\n', mean(squeeze((d.lesion.E(end,pats.idx.lvf&~pats.idx.lc&pats.idx.gl,:))))); %LH/local

    %keyboard
    return;