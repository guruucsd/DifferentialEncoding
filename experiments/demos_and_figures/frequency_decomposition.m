addpath(genpath(fullfile(fileparts(which(mfilename)), '..', '..', 'code')));

%nwaves = 5;l
%figure; imshow(mfe_grating2d(0.02 * nwaves,0,0,0.5,250,250) + 0.5);
out_path = pwd;

load(de_MakeDataset('young_bion_1981', 'orig', '', {'large'}));

img = reshape(train.X(:,2), train.nInput);
padfactor = 1;
npad = train.nInput * padfactor;
fftSz = npad + train.nInput;

%%
cfft = fftshift(fft2(img, size(img,1)+npad(1), size(img,2)+npad(2)));
pwr = cfft.*conj(cfft); pwr = log10(1 + pwr)./max(log10(1 + pwr(:)));
figure('name', 'power');
imshow(pwr); colormap('jet'); colorbar;


%%
if ~exist('freq1D', 'var')
    [pwr1D, freq1D]	= guru_fft2to1( cfft.*conj(cfft), fftSz );
end;
freq1D = freq1D/(1 + padfactor);

figure('name', 'freq1D');
semilogy(freq1D, pwr1D);
set(gca, 'FontSize', 14);
xlabel('Spatial frequency (cycles/image)'); ylabel('power');
set(gca, 'xlim', [0 max(freq1D)]);
axis tight;



%%
gratingSz = [100 100];
[X,Y] = meshgrid([1:gratingSz(2)] - 1 - gratingSz(2)/2, [1:gratingSz(1)] - 1 - gratingSz(1)/2);


for gratings_on = [true false]
    for freq = [0 5 10 20]

        figure('name', sprintf('freq_%d_grating_wheel_%s', freq, guru_iff(gratings_on, 'on', 'off')));
        imshow(pwr); colormap('jet');% colorbar;
        mfe_freezeColors();
        hold on;

        phi = 0:0.01:2*pi;
        x = @(phi) 1 + fftSz(2)/2 + (padfactor+1) * freq*2 * cos(phi);
        y = @(phi) 1 + fftSz(1)/2 + (padfactor+1) * freq*2 * sin(phi);
        plot(x(phi),y(phi),'k', 'linewidth', 2);
        set(gca, 'xlim', 500*[-1 1] + fftSz(2)/2, 'ylim', 400*[-1 1] + fftSz(1)/2);
        set(gcf, 'position', [63         -21        1126         805]);

        if ~gratings_on, continue; end;
        for phs = [0:pi/4:2*pi]
            grating = max(pwr(:)) * (mfe_grating2d(0.005 * freq, 0, phs, 0.5, gratingSz(1), gratingSz(2)) + 0.5);

            % draw the grating
            pos = 1.25*fftSz(end:-1:1) .* [cos(phs) sin(phs)] + fftSz(end:-1:1)/2;
            surf(X + pos(1), Y + pos(2), grating, 'EdgeColor', 'none');
            colormap('gray');

            % draw a line
            pos2 = fftSz(end:-1:1) .* [cos(phs) sin(phs)] + fftSz(end:-1:1)/2;
            plot([x(phs) pos2(1)], [y(phs) pos2(2)], 'k:', 'LineWidth', 2);
        end;
    end
end;




%% Save outputs
if exist('out_path', 'var') && ~isempty(out_path)
    while ~isempty(findobj('type','figure'))
        if ~get(gcf, 'Name'), continue; end;
        export_fig(gcf, fullfile(out_path, sprintf('%s.png', get(gcf, 'Name'))), '-transparent');
        close(gcf);
    end;
end;
