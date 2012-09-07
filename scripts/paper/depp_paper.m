% Figures in the presentation
addpath('..');
DEInit();
%addpath(genpath('../../code'));
%addpath(genpath('../reza'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Slide 8: cartoon data
%close all; figure; bar([500 600;600 500]); 
%set(gca,'xticklabel',{'Global','Local'}); set(gca,'ylim', [0 800]); set(gca,'FontSize',18); set(gca,'ytick',[]); 
%legend(gca,'LVF / RH','RVF / LH','Location','NorthWest'); 
%xlabel('Target Level', 'FontSize', 24); ylabel('Reaction Time', 'FontSize', 24);
%print(gcf,'cartoon','-dpng');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Slide 16: Hsiao et al.
%Slide 20(a): images
%reza_args = reza_sets('runs', 68, 'plots', {'ls-bars','images'}, 'stats', {});
%DESimulatorHL(2, 'de', 'sergent', {'reza-ized'}, reza_args{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Slide 17: Hsiao et al., Original Sergent and reversed Sergent
%DESimulatorHL(2, 'de', 'sergent', {}, reza_args{:});
%DESimulatorHL(2, 'de', 'sergent', {'shuffled'}, reza_args{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Slide 18: Further training
%Slide 21(a): connectivity
%reza_further_args = reza_sets('runs', 68, 'plots', {'ls-bars','connectivity'}, 'stats', {}, ...
%                              'ac.EtaInit', 0.1, 'ac.Acc', 1.005, 'ac.Dec', 1.2, ...
%                              'p.EtaInit',  0.1, 'p.Acc',  1.01,  'p.Dec',  1.2);
%DESimulatorHL(2, 'de', 'sergent', {'reza-ized'}, reza_further_args{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Slide 19: heat map
%reza_loop_iters();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Slide 22: current, Original Sergent and reversed Sergent
%Slide 20(b): images
%Slide 21(a): connectivity
%Slide 23: spatial frequencies
%ben_args = ben_sets('runs', 68, 'plots', {'ls-bars','images','connectivity','ffts'}, 'stats', {'ffts'});
%DESimulatorHL(2, 'de', 'sergent', {}, ben_args{:});
%DESimulatorHL(2, 'de', 'sergent', {'shuffled'}, ben_args{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Slide 24: LSB fft
%lsb_args = ben_sets('runs', 25, 'plots', {'ls-bars','connectivity','ffts'}, 'stats', {'ffts'}, 'ac.AvgError', 0, 'ac.MaxIterations', 100);
%DESimulatorLSB(2, 'lsb_orig', 'recog', {'small.1'}, lsb_args{:});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Table:
depp_loop_sigma;
