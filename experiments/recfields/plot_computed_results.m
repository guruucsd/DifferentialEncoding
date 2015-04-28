% Average connection length vs. crossing point.
% Computed somewhere else, plotted here.
ac=[5 7.6 10.8 15.4 19.5 27.1 31.4]
zc=[7.75 5 3.95 2.35 2.05 1.85 1.8]
figure; hold on;
plot(ac,zc,'o-','LineWidth',3,'MarkerSize',10,'MarkerFaceColor','blue')
set(gca,'FontSize',16);
xlabel('Average connection length (% of image size)');
ylabel('Crossing point (cycles/image)');
set(gca,'xlim',[min(ac)-.25 max(ac)+.25]);