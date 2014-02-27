function [stats] = de_StatsPaths(mss)
%
% Returns the distribution of weights and connections over all models within each sigma

    nHuContacted = cell(size(mss));

    for si=1:length(mss)
        if isempty(mss{si}), continue; end;

        % Init storage
        nHuContacted{si} = zeros(length(mss{si}), mss{si}(1).nHidden);

        for mi=1:length(mss{si})
            m = de_LoadProps(mss{si}(mi), 'ac', 'Weights');
            m.ac.Conns = (m.ac.Weights ~= 0);
            inPix = prod(m.nInput);
            for hi=1:m.nHidden
                hid2in = m.ac.Conns(inPix+1+hi, 1:inPix);
                in2hid = m.ac.Conns(inPix+1+[1:m.nHidden], hid2in);

                % Store teh key value
                nHuContacted{si}(mi,hi) = nnz(sum(in2hid,2)); %
            end;
        end;
    end;

    % Now compute stats
    stats.avg_path = cell(size(mss));
    stats.std_path = cell(size(mss));

    for si=1:length(mss)
        stats.avg_path{si} = mean(nHuContacted{si}(:));
        stats.std_path{si} = std(nHuContacted{si}(:));
    end;
