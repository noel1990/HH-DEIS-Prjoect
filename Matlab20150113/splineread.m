function [waypoint1]=splineread()

read=0;
while(~read)
    try
        load 'waypoint.mat';
        delete waypoint.mat;
    catch
        pause(0.2)
        continue;
    end
    read=1;
end
waypoint1=waypoints;
end