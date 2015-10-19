function [OKtoGo, Danger_Robot_P] = CollisionTest(Point, OtherPieCoord)
    global OA_sec_d;
    security_distance = OA_sec_d;
    OKtoGo = 1;
    Danger_Robot_P = zeros(size(OtherPieCoord));
    cnt = 0;
    
    for i=1:size(OtherPieCoord,1)
        dx = Point(1,1) - OtherPieCoord(i,1);
        dy = Point(1,2) - OtherPieCoord(i,2);
        d = sqrt(dx*dx+dy*dy);
        if d<security_distance
            OKtoGo = 0;
            cnt = cnt+1;
            Danger_Robot_P(cnt,:) = OtherPieCoord(i,:);
        end
    end
    
    Danger_Robot_P = Danger_Robot_P(1:cnt,:);
end