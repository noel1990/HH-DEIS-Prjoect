function P = ServerTranslate(P_S)
    x = P_S(1,1);
    y = P_S(1,2);
    
    x = 3200-x*2;
    y = 2*y;
    
    P = round([x y]);
    disp(P);
end