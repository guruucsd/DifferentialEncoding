function [train,test] = de_StimCreate(stimSet, taskType, opt)
%Input:
%  stimSet  : a string specifying which INPUT sets to train autoencoder on
%               low
%               med
%               high
%               mixed
%
%  taskType : a string specifying which OUTPUT task to train on
%               recog: face recognition task
%
%  opt      : a vector of options; all listed will be applied
%
%OUTPUT: a data file with the following variables:
%
%  train.X    : matrix containing 16 vectors, each a unique hierarchical stimulus.
%  train.T    : target vectors for perceptron (labels, based on task)
%
%  test.*     : same as train object, but

  if (~exist('stimSet', 'var') || isempty(stimSet)), stimSet  = 'HMTVWXY';  end;
  if (~exist('taskType','var')), taskType = 'recog';     end;
  if (~exist('opt','var')),      opt      = {'blur'};     end;
  if (~iscell(opt)),             opt      = {opt};  end;

  [train.nInput]  = guru_getopt(opt, 'nInput',  [135 100]);
  [train.blurs]   = guru_getopt(opt, 'blurs', [1 3 5]);
  %%

  % With this info, create our X and TT vectors
  [train.X, train.XLAB] = stim2D(stimSet, train.nInput);
  [train.X, train.XLAB] = de_applyOptions(opt, train.X, train.XLAB, train.nInput, train.blurs);

  % Nail down targets for each task
  if (~isempty(taskType))
      [train.T, train.TLAB]         = de_createTargets(taskType, train.X, train.XLAB);
  end;

  test = train;


%%%%%%%%%%%%%%%%%%%%%
function [X,XLAB] = stim2D(stimSet, nInput)

    lets = num2cell(stimSet);
    nlets = length(lets);
    
    X = zeros(prod(nInput),nlets.^2);
    XLAB = cell(nlets.^2,1);
    
    fontsize = 48*(nInput(1)/135); %48pt on 135px height image works well
    
    for ti=1:nlets
        for bi=1:nlets
            ii = (bi-1)*nlets+ti;
            
            im = zeros(nInput(1),nInput(2),3,'uint8');%uint8(255*ind2rgb(X,map));
            midpt = 0.5*[size(im,2) size(im,1)];

            %% Create the text mask 
            % Make an image the same size and put text in it 
            hf = figure('color','white','units','normalized','position',[.1 .1 .8 .8]);
            image(ones(size(im))); 
            set(gca,'units','pixels','position',[5 5 size(im,2)-1 size(im,1)-1],'visible','off')

            % Text at arbitrary position 
            text('units','pixels','position',[midpt(1)   midpt(2)/2],'fontsize',fontsize,'string',lets{ti},'VerticalAlignment', 'middle', 'HorizontalAlignment','center') 
            text('units','pixels','position',[midpt(1) 3*midpt(2)/2],'fontsize',fontsize,'string',lets{bi},'VerticalAlignment', 'middle', 'HorizontalAlignment','center') 

%            for ri=1:10
%                % Capture the text image 
%                % Note that the size will have changed by about 1 pixel
%                figure(hf);
%                tim = getframe(gca); 
%
%                % Extract the cdata
%                tim2 = tim.cdata;
%
%                % Make a mask with the negative of the text 
%                tmask = tim2==0; 
%
%                if any(tmask(:)), break; end;
%            end;
            tf = [tempname() '.tif'];
            print(hf, tf, '-dtiff');
            close(hf) 
            tim = imread(tf);
            tim2 = tim(end-nInput(1):end,1:nInput(2));
            tmask = tim2==0;

            if ~any(tmask(:)), error('?'); end;

            % Place white text 
            % Replace mask pixels with UINT8 max 
            im(tmask) = uint8(255); 
            im = mean(im,3);

            %figure(f);
            %subplot(nlets, nlets, ii);
            %imshow(im);
            %axis off
            X(:,ii) = im(:);
            XLAB{ii} = sprintf('%s|%s', lets{ti}, lets{bi});
        end;
    end;


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [X_new, XLAB_new] = de_applyOptions(opt, X, XLAB, nInput, blurs)
  %
  % Apply gaussian blur to each image

  nimg = size(X,2);
  X_new = zeros(size(X,1), nimg*3);
  XLAB_new = cell(size(X_new,2),1);

  for ii=1:nimg
      for bi=1:length(blurs)
          orig_img = reshape(X(:,ii), nInput);
          kernel = blurs(bi);
          
          filt     = fspecial('gaussian', [kernel kernel], 4);
          blur_img = imfilter(orig_img,filt,'same');

          newidx = ii+(bi-1)*nimg;
          X_new(:,newidx) = blur_img(:);
          XLAB_new{newidx} = sprintf('%s%%%dpx', XLAB{ii}, blurs(bi));
      end;
  end;
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [T, TLAB]         = de_createTargets(taskType, X, XLAB)
  %
  % Only one task at the moment: compare upper and lower letters

  nimg = size(X,2);
  T = zeros(1,nimg);
  TLAB = cell(nimg,1);
  
  for ii=1:nimg
      tlet = XLAB{ii}(1); blet=XLAB{ii}(3);
      T(ii) = double(tlet==blet);
      if T(ii), TLAB{ii} = 'same'; else, TLAB{ii} = 'diff'; end;
  end;
