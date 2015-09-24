function [X1,X2] = vectcolsign(X,P)

n = size(X,2);

X1 = zeros(1,n+1);
X2 = zeros(1,n+1);

X1(1,1) = NaN;
X2(1,1) = NaN;

if (P(1,1)==1)
    X1(1,2)= X(1,1);
    X2(1,2)= NaN;
else
    X2(1,2)= X(1,1);
    if (P(1,2)==1)
        X1(1,2) = X(1,1);
    else
        X1(1,2) = NaN;
    end
end

for i = 2 : n-1
    if (P(1,i) == 1)
        X1(1,i+1) = X(1,i);
        X2(1,i+1) = NaN;
    end
    
    if (P(1,i) == 2)
        X2(1,i+1) = X(1,i);
        
        if ((P(1,i-1) == 1) || (P(1,i+1) == 1))
            X1(1,i+1) = X(1,i);
        else
            X1(1,i+1) = NaN;
        end
    end
end

if (P(1,n)==1)
    X1(1,n+1)= X(1,n);
    X2(1,n+1)= NaN;
else
    X2(1,n+1)= X(1,n);
    if (P(1,n-1)==1)
        X1(1,n+1) = X(1,n);
    else
        X1(1,n+1) = NaN;
    end
end