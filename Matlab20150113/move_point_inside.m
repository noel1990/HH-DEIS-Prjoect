function [Target_X Target_Y] = move_point_inside(Target_X,Target_Y)
    thres = 180;
    if Target_X > 3200-thres
        Target_X = 3200-thres;
    end
    
    if Target_Y > 2400-thres
        Target_Y = 2400-thres;
    end
    
    if Target_X < thres
        Target_X = thres;
    end
    
    if Target_Y < thres
        Target_Y = thres;
    end
end