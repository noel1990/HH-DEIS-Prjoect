function [P_stop A_stop] = find_stopping_point(P_target)
    x = P_target(1,1);
    y = P_target(1,2);
    
    thres = 300;
    
    if x > 3200-thres
        A_stop = 0;
        P_stop = [3200-thres y];
    elseif y > 2400-thres
        A_stop = 90;
        P_stop = [x 2400-thres];
    elseif x < thres
        A_stop = 180;
        P_stop = [thres y];
    else
        A_stop = -90;
        P_stop = [x thres];
    end
end