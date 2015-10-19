global OA_sec_d;
security_distance_draw = OA_sec_d;
for i=1:size(CPC_Pre,1)
    th = linspace(0,2*pi,32);
    X_Secur_Cell = CPC_Pre(i,1)+security_distance_draw*cos(th);
    Y_Secur_Cell = CPC_Pre(i,2)+security_distance_draw*sin(th);
    plot(X_Secur_Cell,Y_Secur_Cell,'k:');
end