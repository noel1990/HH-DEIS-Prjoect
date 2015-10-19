function P_correct = distort_correct(P)
    
    M = 1200;
    N = 1600;
    R = sqrt(M*M + N*N)/2;
    x = N - P(:,1);
    y = P(:,2);
    center = [round(N/2) round(M/2)];
    x = x - center(1,1);
    y = y - center(1,2);
    
    [theta r] = cart2pol(x,y);
    r = r/R;
    
%     s = distortfun(r,k,4);
%     s = 1.0992*r-0.0315;
%     s = 0.3322*r.^2 + 0.7807*r + 0.0001;
    s = 0.0816*r.^3 + 0.2046*r.^2 + 0.8293*r;
    
    MM = 2400;
    NN = 3200;
    RR = sqrt(MM*MM + NN*NN)/2;
    center = [round(NN/2) round(MM/2)];
    s2 = s*RR;
    [xt,yt] = pol2cart(theta,s2);
    xt = xt + center(1,1);
    yt = yt + center(1,2);
    
    P_correct = [xt,yt];
end