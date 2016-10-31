clear all
freqs = 0.075 * [0.25 0.5 1     2     4     6     8    12    16    20];
f2 = figure;
for fi = 1:length(freqs)
    x = 0.5+mfe_grating2d( freqs(fi), 0, 0, 0.5, 20, 20 );
    subplot(5,length(freqs),fi);
    imagesc(x);
    set(gca,'ytick',[],'xtick',[])
end;

f1 = figure;

for ii=1:4
  [a,b,c,d] = nn_2layer('nin', 250, 'wMode', 'center-surround', 'dfromcent', ii, 'nBatches', 1, 'nSamps', 1, 'Sigma', ii*10*eye(2), 'freqs', freqs, 'nphases', 1, 'norients', 1);

  figure(f1);
  subplot(2,2,ii);
  imagesc(squeeze(mean(d,1)), max(abs(d(:)))*[-1 1]); colorbar;
  set(gca,'ytick',[],'xtick',[])
  title(sprintf('%d',ii));

  figure(f2);
    for fi = 1:length(freqs)
        x = (0.5+mfe_grating2d( freqs(fi), 0, 0, 0.5, 20, 20 )) .* squeeze(mean(d,1));
        subplot(5,length(freqs),(ii)*length(freqs)+fi);
        imagesc(x, max(abs(x(:)))*[-1 1]);
        set(gca,'ytick',[],'xtick',[])
        if fi==length(freqs), colorbar; end;
    end;

  if (~exist('bb','var'))
    aa = mean(a,1)%/mean(a(:));
    bb = mean(b,1)%/mean(b(:));
  else
    aa(ii,:) = mean(a,1)%/mean(a(:));
    bb(ii,:) = mean(b,1)%/mean(b(:));
  end
end

figure; plot(freqs, aa'); legend(guru_csprintf('%d', mat2cell(1:4)))
figure; plot(freqs, bb'); legend(guru_csprintf('%d', mat2cell(1:4)))

