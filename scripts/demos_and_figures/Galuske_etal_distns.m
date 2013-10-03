% Determine (normalized) inter-patch distance and center-to-patch distance
%   from data in Galuke et al (2000)

D = [1450 1236
     1432 1099
     1463 1234
     1544 1303
     1630 1464
     1149 1022
     1370 1207
    ];
S = [856 844
     689 616
     728 707
     746 734
     823 802
     572 558
     589 640
    ];

fprintf('Inter-patch distance: %4.2f\n', mean(D)./mean(S)); %inter-patch distance
fprintf('Center-to-patch distance: %4.2f\n', 1750/mean(mean(S))); %center-to-patch distance; 1750 taken from paper



