function [ cap ] = guru_capitalizeStr ( str )
%Takes in a string and capitalizes the first letter of it.

cap = strcat(upper(str(1)), str(2:end));


end

