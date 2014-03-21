function new_bins = guru_newbins( bins, breakfactor )

bin_spacing = diff(bins(1:2));

new_bins = (bins(1)-bin_spacing):(bin_spacing/breakfactor):bins(end);
new_bins = new_bins(2:end);
