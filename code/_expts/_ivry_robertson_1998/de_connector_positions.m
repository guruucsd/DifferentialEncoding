function [mu,hpl] = de_connector1D_positions(nHidden,dbg)

    hpl = 1;

    switch (nHidden)

      case 6
        mu=(2:5:27);
      
      case 10
        mu=(1:3:28);
      
      case 11
        mu=(1:2.75:28.5);
      
      case 12
        mu=(.75:2.5:28.25);
        
      case 13
        mu=(1:2.25:28);
        
      case 14
        mu=(2:2:28);
        
      case 15
        mu=[1,3,5,6,8,10,11,13,15,16,18,20,21,23,25]; %begin making the connections...
        
      case 23
        mu=4:26;

      case 25
        mu=3:27;

      case 27
        mu=2:28;
        
      case 29
        mu = 1:29;
        
      otherwise
        error('1D connector not set up to handle %d hidden nodes.', nHidden);
    end
    