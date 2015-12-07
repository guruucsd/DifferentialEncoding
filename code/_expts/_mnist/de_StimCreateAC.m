function de_StimCreateAC(stimSet, opt)
%

  if (~exist('stimSet', 'var')), stimSet  = 'de'; end;
  if (~exist('opt','var')),      opt      = {};     end;
  if (~iscell(opt)),             opt      = {opt};  end;
  dim = 2;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % With this info, create our X and TT vectors
  [train] = stim2D(stimSet, 'train');
  [train] = de_applyOptions(opt, train);

  [test] = stim2D(stimSet, 'test');
  [test] = de_applyOptions(opt, test);

  nInput = train.nInput;

  % Output everything (including images)
  outFile        = de_GetDataFile(dim, stimSet, '', opt);
  if (~exist(guru_fileparts(outFile,'pathstr'), 'dir'))
    guru_mkdir(guru_fileparts(outFile,'pathstr'), 'dir');
  end;
  save(outFile);

  %de_visualizeData(outFile);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [dataset] = stim2D(stimSet, trainOrTest)
    switch (stimSet)
        case 'mnist'
            mnist = load( fullfile(de_GetBaseDir(), 'data', 'mnist_all.mat') );

            if (strcmp(trainOrTest, 'train'))
                dataset.X = vertcat(mnist.train0, ...
                            mnist.train1, ...
                            mnist.train2, ...
                            mnist.train3, ...
                            mnist.train4, ...
                            mnist.train5, ...
                            mnist.train6, ...
                            mnist.train7, ...
                            mnist.train8, ...
                            mnist.train9)';

                dataset.XLAB = vertcat( repmat({'0'}, size(mnist.train0,1), 1), ...
                               repmat({'1'}, size(mnist.train1,1), 1), ...
                               repmat({'2'}, size(mnist.train2,1), 1), ...
                               repmat({'3'}, size(mnist.train3,1), 1), ...
                               repmat({'4'}, size(mnist.train4,1), 1), ...
                               repmat({'5'}, size(mnist.train5,1), 1), ...
                               repmat({'6'}, size(mnist.train6,1), 1), ...
                               repmat({'7'}, size(mnist.train7,1), 1), ...
                               repmat({'8'}, size(mnist.train8,1), 1), ...
                               repmat({'9'}, size(mnist.train9,1), 1));

            else
                dataset.X = vertcat(mnist.test0, ...
                            mnist.test1, ...
                            mnist.test2, ...
                            mnist.test3, ...
                            mnist.test4, ...
                            mnist.test5, ...
                            mnist.test6, ...
                            mnist.test7, ...
                            mnist.test8, ...
                            mnist.test9)';
                dataset.XLAB = vertcat( repmat({'0'}, size(mnist.test0,1), 1), ...
                               repmat({'1'}, size(mnist.test1,1), 1), ...
                               repmat({'2'}, size(mnist.test2,1), 1), ...
                               repmat({'3'}, size(mnist.test3,1), 1), ...
                               repmat({'4'}, size(mnist.test4,1), 1), ...
                               repmat({'5'}, size(mnist.test5,1), 1), ...
                               repmat({'6'}, size(mnist.test6,1), 1), ...
                               repmat({'7'}, size(mnist.test7,1), 1), ...
                               repmat({'8'}, size(mnist.test8,1), 1), ...
                               repmat({'9'}, size(mnist.test9,1), 1));
            end;

            dataset.X = dataset.X(:,1:250:end); %reduce size
            dataset.XLAB = dataset.XLAB(1:250:end);

            dataset.nInput = [28 28];

        otherwise
            % load every file in the given directory
            files = dir( fullfile(de_GetBaseDir(), 'data', stimSet) );
            error('Unknown stim set: %s', stimSet);
    end;

    % Now, normalize to be between 0 and 1!
%    dataset.X = dataset.X ./ repmat(mean(dataset.X,2), [1, size(dataset.X,2)]);
%    dataset.X(isnan(dataset.X)) = 0;
%    dataset.X = dataset.X ./ (max(max(dataset.X))-min(min(dataset.X)));
    dataset.X = double( (dataset.X - min(min(dataset.X))) / max(max(dataset.X)) ); %normalize


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [dataset] = de_applyOptions(opt, dataset)
  %
  % Take a weighted stimulus training set, and apply some options to
  % shuffle inputs
    i = 1;
    while i<=length(opt)
        switch (opt{i})
            case 'patchSize'
                i = i + 1;
                patchSize = opt{i};

%                [dataset.X, dataset.XLBL] = createPatches(dataset.X, dataset.XLBL);
        end;
        i = i + 1;
    end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X,nInput,STIM,ST] = createPatches(stimSet)
            de_GetDataFile(dim, stimSet, taskType, opt)
%function trainSet(images, patchSize, patchTypes)

patchSize = [31 13];

    if (size(images,2) < patchSize(1)), error('Patch width greater than image width'); end;
    if (size(images,3) < patchSize(2)), error('Patch height greater than image height'); end;

patches = zeros([0 patchSize]);

switch patchTypes
    case 1 %center patches only

       % patches(images(:



    case 2 % start with center patch, then extract patches in steps of deviation dx, dy


end;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function de_visualizeData(outFile)
  %
  %

    load(outFile);

    switch (length(train.TT))
      case 64, nRows = 8; nCols = 8;
      case 16, nRows = 4; nCols = 4;
      case 8,  nRows = 2; nCols = 4;
      otherwise,         [nRows,nCols] = guru_optSubplots(length(TT));
    end;

    for objName = {'train' 'test'}
      objName = objName{1};
      obj = eval(objName);

      obj.X = obj.X - min(min(obj.X));
      obj.X = obj.X / max(max(obj.X));
      %obj.T = round(obj.T*2);

      figTitle = sprintf('%dD %s set; stimSet=%s, taskType=%s, opt=%s', ...
                         dim, objName, stimSet, taskType, [opt{:}]);

      figure;
      set(findobj(gcf,'Type','text'),'FontSize',6) ;

      for i=1:length(obj.TT)
        subplot(nRows,nCols,i);
        colormap(gray);

        imagesc(reshape(obj.X(:,i), nInput));

        %
        set(gca, 'xtick',[],'ytick',[]);
        hold on;
        TC = num2cell(round(obj.T(:,i)));
        xlabel(sprintf('%s: %s (%s)', guru_text2label(obj.XLAB{i}), sprintf('%d', TC{:}), guru_text2label(obj.TLAB{i})));
      end;

      %
      hold on;
      mfe_suptitle(figTitle);

      %
      print(strrep(outFile, '.mat', sprintf('-%s.%s', objName, 'png')), '-dpng');
      close(gcf);
    end;

