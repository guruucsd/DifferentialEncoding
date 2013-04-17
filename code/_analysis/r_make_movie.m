function mv = ringo_movie(net, y, pat)
%
close all

%
if ~exist('net','var'), net = struct('sets',struct('tsteps',35','nhidden_per',10)); end;
if ~exist('y','var'),   y = rand(net.sets.tsteps, 32, net.sets.nhidden_per*4+10+1); end;
if ~exist('pat','var'), pat = 1; end;
if ~exist('tdelay','var'), tdelay = 0.25; end;
if ~exist('col_fn','var'), col_fn = @(x) ([min(max(0, x),1) 0 min(max(0,-x),1)]); end; % + = red, - = blue

% we got the patterns, not an actual y value
if isstruct(y)
    pats = y;
    y = getfield(r_forwardpass(net,pats),'y');
end;

%
im = rgb2gray(imrotate(imread(fullfile(fileparts(which(mfilename)), 'ringo.png')),-0.0));
%im = imrotate(im, 0.1);
im = min(1, 1 - double(im)./255 + 0.20);

f = figure('color', 0.2*[1 1 1]); 
set(gca,'color', 0.2*[1 1 1], 'FontSize', 16);
imshow(im); hold on;
set(gca,'xlim', [15 520], 'ylim', [0 595])  % crop the image a bit

%
in_cent    = [269 569]; %[0 -8]
ih1l_cent  = [147 427]; %[-4 -3];
ih1r_cent  = [391 425];%[ 4 -3];
ih2l_cent  = [145 211]; %[-4 3];
ih2r_cent  = [390 207]; %[ 4 3];
out_cent   = [269 41]; %[0 8]
circ_r     = 9;
circ_pts   = 50;
circ_spc   = [24.4 24.4];

%
in_h = [];
out_h = [];
ih1l_h = [];
ih1r_h = [];
ih2l_h = [];
ih2r_h = [];


% Inputs
in_h(end+1) = mfe_filledCircle([in_cent(1)-2*circ_spc(1) in_cent(2)], circ_r, circ_pts, 'r');
in_h(end+1) = mfe_filledCircle([in_cent(1)-1*circ_spc(1) in_cent(2)], circ_r, circ_pts, 'r');
in_h(end+1) = mfe_filledCircle([in_cent(1)               in_cent(2)], circ_r, circ_pts, 'r');
in_h(end+1) = mfe_filledCircle([in_cent(1)+1*circ_spc(1) in_cent(2)], circ_r, circ_pts, 'r');
in_h(end+1) = mfe_filledCircle([in_cent(1)+2*circ_spc(1) in_cent(2)], circ_r, circ_pts, 'r');

% Outputs
out_h(end+1) = mfe_filledCircle([out_cent(1)-2*circ_spc(1) out_cent(2)], circ_r, circ_pts, 'r');
out_h(end+1) = mfe_filledCircle([out_cent(1)-1*circ_spc(1) out_cent(2)], circ_r, circ_pts, 'r');
out_h(end+1) = mfe_filledCircle([out_cent(1)               out_cent(2)], circ_r, circ_pts, 'r');
out_h(end+1) = mfe_filledCircle([out_cent(1)+1*circ_spc(1) out_cent(2)], circ_r, circ_pts, 'r');
out_h(end+1) = mfe_filledCircle([out_cent(1)+2*circ_spc(1) out_cent(2)], circ_r, circ_pts, 'r');


% IH 1 (left)
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-2*circ_spc(1) ih1l_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-2*circ_spc(1) ih1l_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-2*circ_spc(1) ih1l_cent(2)              ], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-2*circ_spc(1) ih1l_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-1*circ_spc(1) ih1l_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-1*circ_spc(1) ih1l_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-1*circ_spc(1) ih1l_cent(2)              ], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)-1*circ_spc(1) ih1l_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');

ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)+2*circ_spc(1) ih1l_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1l_h(end+1) = mfe_filledCircle([ih1l_cent(1)+2*circ_spc(1) ih1l_cent(2)              ], circ_r, circ_pts, 'r');

% IH 1 (right)
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+2*circ_spc(1) ih1r_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+2*circ_spc(1) ih1r_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+2*circ_spc(1) ih1r_cent(2)              ], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+2*circ_spc(1) ih1r_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+1*circ_spc(1) ih1r_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+1*circ_spc(1) ih1r_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+1*circ_spc(1) ih1r_cent(2)              ], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)+1*circ_spc(1) ih1r_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');

ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)-2*circ_spc(1) ih1r_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih1r_h(end+1) = mfe_filledCircle([ih1r_cent(1)-2*circ_spc(1) ih1r_cent(2)              ], circ_r, circ_pts, 'r');




% IH 2 (left)
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-2*circ_spc(1) ih2l_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-2*circ_spc(1) ih2l_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-2*circ_spc(1) ih2l_cent(2)              ], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-2*circ_spc(1) ih2l_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-1*circ_spc(1) ih2l_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-1*circ_spc(1) ih2l_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-1*circ_spc(1) ih2l_cent(2)              ], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)-1*circ_spc(1) ih2l_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');

ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)+2*circ_spc(1) ih2l_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2l_h(end+1) = mfe_filledCircle([ih2l_cent(1)+2*circ_spc(1) ih2l_cent(2)              ], circ_r, circ_pts, 'r');

% IH 2 (right)
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+2*circ_spc(1) ih2r_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+2*circ_spc(1) ih2r_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+2*circ_spc(1) ih2r_cent(2)              ], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+2*circ_spc(1) ih2r_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+1*circ_spc(1) ih2r_cent(2)-2*circ_spc(2)], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+1*circ_spc(1) ih2r_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+1*circ_spc(1) ih2r_cent(2)              ], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)+1*circ_spc(1) ih2r_cent(2)+1*circ_spc(2)], circ_r, circ_pts, 'r');

ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)-2*circ_spc(1) ih2r_cent(2)-1*circ_spc(2)], circ_r, circ_pts, 'r');
ih2r_h(end+1) = mfe_filledCircle([ih2r_cent(1)-2*circ_spc(1) ih2r_cent(2)              ], circ_r, circ_pts, 'r');
% 
% keyboard
% rectangle('Position', [in_cent-[6 2]/2 [6 2]]);
% rectangle('Position', [ih1r_cent-[4 6]/2 [5 5]]);
% rectangle('Position', [ih1l_cent-[6 6]/2 [5 5]]);
% rectangle('Position', [ih2r_cent-[4 6]/2 [5 5]]);
% rectangle('Position', [ih2l_cent-[6 6]/2 [5 5]]);
% rectangle('Position', [out_cent-[6 2]/2 [6 2]]);

%
if ~any(sum(net.wC(net.idx.cc,net.idx.cc)))
    cc1_cent = (ih1l_cent+ih1r_cent)/2;
    cc2_cent = (ih2l_cent+ih2r_cent)/2;
    
    mfe_filledCircle([cc1_cent(1) cc1_cent(2)-20], 20, circ_pts, get(gcf,'color'));
    mfe_filledCircle([cc1_cent(1) cc1_cent(2)+ 0], 20, circ_pts, get(gcf,'color'));
    mfe_filledCircle([cc2_cent(1) cc2_cent(2)-20], 20, circ_pts, get(gcf,'color'));
    mfe_filledCircle([cc2_cent(1) cc2_cent(2)+ 0], 20, circ_pts, get(gcf,'color'));
end;

%%
h = [in_h ih1l_h ih1r_h ih2l_h ih2r_h out_h];
uidx = [net.idx.lh_input ...
        net.idx.lh_early_ih net.idx.lh_early_cc ...
        net.idx.rh_early_ih net.idx.rh_early_cc ...
        net.idx.lh_late_ih  net.idx.lh_late_cc ...
        net.idx.rh_late_ih  net.idx.rh_late_cc ...
        net.idx.lh_output ];

%
F(net.sets.tsteps) = struct('cdata',[],'colormap',[]);

for ti=1:net.sets.tsteps
    % Inputs
    for hi=1:length(h)
        col = col_fn(y(ti,pat,uidx(hi)));
        %if ~any(col), col = [1 1 1]; end;
        set(h(hi),'FaceColor',col);
    end;
    if exist('th','var'), set(th, 'Color', get(gcf, 'color')); end;
    th = text(425, 25, sprintf('t = %2d/%2d', ti, net.sets.tsteps), 'Color', [1 1 1], 'FontSize', 16);
    
    % Hidden units

    drawnow;
%    pause(tdelay);

    F(ti) = getframe;
end;

mv = struct('F',F,'fps',1/tdelay,'winsz',[size(F(1).cdata,1) size(F(1).cdata,2)]);

%movie(mv.fig, mv.F, 1, mv.fps, mv.winsz);