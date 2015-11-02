%Benjamin Blaise 17 decembre 2008
%O-PLS par algorythme NIPALS.
%Matrice de donn�es X, matrice d'information Y avec calculs de nf facteurs.
%d'apr�s chemometrics and intelligent laboratory systems, vol 58,
%p.109-130, 2001

function [T,Tortho,W,C,Xdef] = oplsSRV(X,Y,nf)


[nr,nc]=size(X);


for j= 1:nf

    convergence=1;
    
    u2=Y'*Y;

    
        while (convergence>0.0000000001)
        
        o2=u2;
 
    %Calcul du weight vecteur de X W=X'Y et normalisation
        w=X'*Y/(Y'*Y);
        w1=w'*w;
        w2=abs(sqrt(w1));
        w=w/w2;
       
    
        %Calcul du score vecteur de X T=XW
        t=X*w/(w'*w);
        t1=t'*t;
    
        %Calcul du weight vecteur de Y
        c=Y'*t/t1;
        c1=c'*c;
    
        %Calcul du score vecteur de Y
        u=Y*c/c1;
        u1=u'*u;
        u2=abs(sqrt(u1));
        
        %Calcul de la condition de convergence
        convergence=abs((u2-o2)/o2);
   
    end
        
        %Calcul du loading P
        p=X'*t/t1;
        
        %Calcul de wortho
        wortho=p-w;
        wortho1=wortho'*wortho;
        wortho2=abs(sqrt(wortho1));
        wortho=wortho/wortho2;
        
        %Calcul de Tortho
        tortho=X*wortho/(wortho'*wortho);
        tortho1=tortho'*tortho;
        
        %Calcul de Portho
        portho=X'*tortho/tortho1;
        
        %Calcul de Cortho
        cortho=Y'*tortho/tortho1;
        
    
    %Deflation des matrices
    X=X-tortho*portho';
    

    T(:,j)=t;
    P(:,j)=p;
    C(:,j)=c;
    W(:,j)=w;

    Tortho(:,j)=tortho;
    Portho(:,j)=portho;
    Wortho(:,j)=wortho;
    Cortho(:,j)=cortho;
    

end

Xortho=Tortho*Portho';
Xdef=X;












    
    
    
    
    
    
  
   






