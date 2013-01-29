% Read example image 
%load('clown.mat'); 
lets = {'H','M','T','V','W','X','Y'};
f = figure;
for ti=1:length(lets)
    for bi=1:length(lets)

        im = zeros(135,100,3,'uint8');%uint8(255*ind2rgb(X,map));
        midpt = 0.5*[size(im,2) size(im,1)];

        %% Create the text mask 
        % Make an image the same size and put text in it 
        hf = figure('color','white','units','normalized','position',[.1 .1 .8 .8]);
        image(ones(size(im))); 
        set(gca,'units','pixels','position',[5 5 size(im,2)-1 size(im,1)-1],'visible','off')

        % Text at arbitrary position 
        text('units','pixels','position',[midpt(1)   midpt(2)/2],'fontsize',48,'string',lets{ti},'VerticalAlignment', 'middle', 'HorizontalAlignment','center') 
        text('units','pixels','position',[midpt(1) 3*midpt(2)/2],'fontsize',48,'string',lets{bi},'VerticalAlignment', 'middle', 'HorizontalAlignment','center') 

        for ii=1:10
            % Capture the text image 
            % Note that the size will have changed by about 1 pixel
            figure(hf);
            tim = getframe(gca); 

            % Extract the cdata
            tim2 = tim.cdata;

            % Make a mask with the negative of the text 
            tmask = tim2==0; 

            if any(tmask(:)), break; end;
        end;
        close(hf) 
        if ~any(tmask(:)), error('?'); end;

        % Place white text 
        % Replace mask pixels with UINT8 max 
        im(tmask) = uint8(255); 
        im = mean(im,3);

        figure(f);
        subplot(length(lets), length(lets), (bi-1)*length(lets)+ti);
        imshow(im);
        axis off
    end;
end;
