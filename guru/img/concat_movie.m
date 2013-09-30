function mv = concat_movie(mv1, mv2, concat_type)

if ~exist('concat_type','var')
    concat_type='horz'; end;

mv = mv1;

for fi=1:length(mv1.F)
    switch concat_type
        case 'vert'
            mv.F(fi).cdata = zeros(2*size(mv1.F(fi).cdata,1), size(mv1.F(fi).cdata,2), size(mv1.F(fi).cdata,3), 'uint8');
            mv.F(fi).cdata(1:size(mv1.F(fi).cdata,1), 1:size(mv1.F(fi).cdata,2), 1:size(mv1.F(fi).cdata,3)) = mv1.F(fi).cdata;
            mv.F(fi).cdata(size(mv1.F(fi).cdata,1)+1:end, 1:size(mv1.F(fi).cdata,2), 1:size(mv1.F(fi).cdata,3)) = mv2.F(fi).cdata;
        case 'horz'
            mv.F(fi).cdata = zeros(size(mv1.F(fi).cdata,1), 2*size(mv1.F(fi).cdata,2), size(mv1.F(fi).cdata,3), 'uint8');
            mv.F(fi).cdata(1:size(mv1.F(fi).cdata,1), 1:size(mv1.F(fi).cdata,2), 1:size(mv1.F(fi).cdata,3)) = mv1.F(fi).cdata;
            mv.F(fi).cdata(1:size(mv1.F(fi).cdata,1), size(mv1.F(fi).cdata,2)+1:end, 1:size(mv1.F(fi).cdata,3)) = mv2.F(fi).cdata;
    end;
end;

mv.winsz = [0 0 size(mv.F(1).cdata,1) size(mv.F(1).cdata,2)];

