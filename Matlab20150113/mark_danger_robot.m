function mark_danger_robot(P)
    global OA_sec_d;
    security_distance_draw = OA_sec_d;
    th = linspace(0,2*pi,32);
    for i=1:size(P,1);
        X_Secur_Cell = P(i,1)+security_distance_draw*cos(th);
        Y_Secur_Cell = P(i,2)+security_distance_draw*sin(th);
        plot(X_Secur_Cell,Y_Secur_Cell,'r-','linewidth',2);
    end
end
