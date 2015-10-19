function boolean = Inside_Otherpie_Test(P,Danger_Robot)
    global OA_sec_d;
    boolean = 0;
    x = P(1,1);
    y = P(1,2);
    for i=1:size(Danger_Robot,1)
        dx = Danger_Robot(i,1)-x;
        dy = Danger_Robot(i,2)-y;
        d = sqrt(dx*dx+dy*dy);
        if d<OA_sec_d
            boolean = 1;
            break;
        end
    end
end