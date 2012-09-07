function f=drawpat(filename,mode)
% drawpat draws the gabor filter responses (maginitude) from a pat file
%   drawpat(filename, mode)
%   filename: the pat file
%   mode: draw all the frequencies and orientations if mode=0 (default)
%         draw log of the sum of orientations if mode<>0
%   f: the handle of the figure.

if nargin<2 mode=0; end
%read pat
[pat,fre,ori,h,w]=readpat(filename,2);
%get freq & ori
[junk,gfParams] = gfCreateFilterBank(fre,ori,[w h],1);

%plot
f=figure;
if mode==0
    for i=1:fre
        for j=1:ori
            subplot(fre,ori,(i-1)*ori+j);
            imagesc(squeeze(pat(:,:,j,i)));
            daspect([1 1 1]);
            %axis off;
            colormap(gray);
            hold on;
            set(gca,'ytick',[],'xtick',[]);
            ylabel(sprintf('f=%4.2f\no=%4.2f', gfParams{i,j}(1), gfParams{i,j}(2)));
        end
    end
else
    patlogsum=log(squeeze(sum(pat,3)));

    for i=1:fre
        subplot(1,fre,i);
        imagesc(squeeze(patlogsum(:,:,i)));
        daspect([1 1 1]);
        %axis off;
        colormap(gray);
        hold on;
        set(gca,'ytick',[],'xtick',[]);
        xlabel(sprintf('f=%4.2f', gfParams{i,1}(1)));
    end
end