function gfFilterFolder(filelist,imagefolder,outputfolder,filtersize,normalize,frequency,orientation,type,ftype,resample)
% gfFilterFolder applies gabor filter on images listed in a file
%   gfFilterFolder(filelist,imagefolder,outputfolder,frequency,scale,type,ftype)
%
%   filelist: text file that contains all the images need to be filtered
%   imagefolder: where to read the image files
%   output folder: where to save the filtered patterns. they are saved as
%   .pat files with the same name as images
%   filtersize: the [height width] of the filters, better same as images when
%   processing faces
%   normalize: normalize the response value across orientation if
%   normalize=1; do not normalize otherwise
%   frequency: how many frequencies of the filters. default=8
%   scale: how many scales of the filters. default=5
%   type: 1-abs(default); 2-real part; 3-imaginary part; 4-complex
%   ftype: filter type (see gfCreateFilter)
%   resample: resample rate (post-processing dropping of points). default 1 (no resampling)

% gabor filters are created accroding to: p7 of
% Dailey, Matthew N. and Cottrell, Garrison W. (1999)
% Organization of Face and Object Recognition in Modular Neural Networks.
% Neural Networks 12(7-8):1053-1074.
% 5 frequencies k=[1 2 3 4 5]; f=(2*pi/N)*(2^k); N is the width of the
% filter
% 8 orientations o=[0 1 2 3 4 5 6 7]*pi/8;

if (nargin<10 || isempty(resample))   resample=1;    end
if (nargin<9 || isempty(ftype))       ftype=1;       end
if (nargin<8 || isempty(type))        type=1;        end
if (nargin<7 || isempty(frequency))   frequency=5;   end
if (nargin<6 || isempty(orientation)) orientation=8; end
if (nargin<5 || isempty(normalize))   normalize=1;   end

% filter images from a directory listing
if (isstruct(filelist))
  gfFilterFolder( {filelist(find([filelist.isdir]==0)).name}, ...
                  imagefolder,outputfolder,filtersize,normalize,frequency,orientation,type);

% filter images from a text file list
elseif (ischar(filelist))

  if (exist(filelist,'file'))
    allfiles={};
    fid=fopen(filelist);
    while (1)
        %readline
        tline = fgetl(fid);
        if ~ischar(tline), break, end

        %get the file name (should be the first thing of the line
        [strFile tline]=strtok(tline);
        [strFile tline]=strtok(strFile,'.');
        allfiles{end+1} = [strFile '.pgm'];
    end
    fclose(fid);

    gfFilterFolder( allfiles,imagefolder,outputfolder,filtersize,normalize,frequency,orientation,type);

  % filter images from a directory
  elseif (exist(filelist,'dir'))
    gfFilterFolder( dir(fullfile(filelist,'*.pgm')),imagefolder,outputfolder,filtersize,normalize,frequency,orientation,type);

  % filter a single image
  else
    gfFilterFolder( {filelist},imagefolder,outputfolder,filtersize,normalize,frequency,orientation,type );

  end; %ischar(filelist)

elseif (~iscell(filelist))
  error('Unknown type for filelist input variable.');

else


  % create filters
  gaborfilters = gfCreateFilterBank(frequency, orientation, filtersize, ftype);

  % filter each file
  for i=1:length(filelist)
    strFile = filelist{i};

    %read the image
    % if the image cannot be read, skip it
    try
        img=imread(fullfile(imagefolder, strFile));
        display(['Processing image ' strFile]);
    catch
        display(['Cannot read image ' strFile]);
        continue;
    end

    %filter, write to the output folder
    filteredimg = gfFilterImage(img, gaborfilters, type);

    % downsample original and filter
    if (resample ~= 1)
      img = imresize(img, resample);

      for i=1:prod(size(filteredimg))
        filteredimg{i} = imresize(filteredimg{i}, resample);
      end;
    end;

    s=size(img,1)*size(img,2);
    gaborpat=zeros(4+frequency*orientation*s,1);

    % save the number of frequency and orientation of filters,
    % save the imagesize
    gaborpat(1)=frequency;
    gaborpat(2)=orientation;
    gaborpat(3)=size(img,1);
    gaborpat(4)=size(img,2);
    for k=1:frequency
        for o=1:orientation
            if normalize==1
                gaborpat(4+((k-1)*orientation+o-1)*s+1:4+((k-1)*orientation+o)*s)=filteredimg{k,o}(:)/sum(filteredimg{k,o}(:));
            else
                gaborpat(4+((k-1)*orientation+o-1)*s+1:4+((k-1)*orientation+o)*s)=filteredimg{k,o}(:);
            end
        end
    end

    patFile=fullfile(outputfolder, [strtok(strFile,'.') '.pat']);
    save(patFile,'gaborpat','-ASCII');
  end;
end;