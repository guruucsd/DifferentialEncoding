function dataFile = de_MakeDataset(expt, stimSet, taskType, opt)
%

    dataFile = de_GetDataFile(expt, stimSet, taskType, opt);
    
    if (~exist(dataFile,'file'))
        dataFile = de_StimCreate(expt, stimSet, taskType, opt);
    end;