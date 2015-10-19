function [waypoints,wayangle,waydist]=GivePath(start_point,target_point,start_angle,target_angle)

%the function give the initial path

dist_to_target = Cal_Distance(start_point, target_point);
sample_num = ceil(dist_to_target/200);
%sample_num = 1;
[ waypoints, wayangle ] = spline_generate( start_point,start_angle,target_point,target_angle,sample_num );
spline_Qty = size(waypoints,1);
% Room=0 left, Room=1 Right
if start_point(1,1) < 1600
    Room = 0;
else
    Room = 1;
end

Pie_r = 180;
if Room==0
    for i = 1:size(waypoints)-1
        if waypoints(i,1) < Pie_r
            waypoints(i,1) = Pie_r;
        end
        if waypoints(i,1) > 1600-Pie_r
            waypoints(i,1) = 1600-Pie_r;
        end
        if waypoints(i,2) < Pie_r
            waypoints(i,2) = Pie_r;
        end
        if waypoints(i,2) > 2400-Pie_r
            waypoints(i,2) = 2400-Pie_r;
        end
        
        if waypoints(i,1)>1300-Pie_r-100 && waypoints(i,2)>1000-Pie_r-100 && waypoints(i,2)<1400+Pie_r+100
            waypoints(i,1)=1300-Pie_r-100;
        end
    end
else
    for i = 1:size(waypoints)-1
        if waypoints(i,1) < 1600+Pie_r
            waypoints(i,1) = 1600+Pie_r;
        end
        if waypoints(i,1) > 3200-Pie_r
            waypoints(i,1) = 3200-Pie_r;
        end
        if waypoints(i,2) < Pie_r
            waypoints(i,2) = Pie_r;
        end
        if waypoints(i,2) > 2400-Pie_r
            waypoints(i,2) = 2400-Pie_r;
        end
        
        if waypoints(i,1)<1900+Pie_r+100 && waypoints(i,2)>1000-Pie_r-100 && waypoints(i,2)<1400+Pie_r+100
            waypoints(i,1)=1900+Pie_r+100;
        end
    end
end
for i = 1:spline_Qty-1
    wayangle(i) = atan2((waypoints(i+1,2)-waypoints(i,2)),(waypoints(i+1,1)-waypoints(i,1)));
end
wayangle(end) = target_angle;
%spline_plot(1,start_point,target_point,start_angle,target_angle);
%wayangle = round(rad2deg(wayangle));
dist_t = zeros(1,spline_Qty);
for i = 1:spline_Qty-1
    for j = i:spline_Qty-1
        dx = waypoints(j,1)-waypoints(j+1,1);
        dy = waypoints(j,2)-waypoints(j+1,2);
        dist_t(i)= dist_t(i)+sqrt(dx^2+dy^2);
    end
end
waypoints = round(waypoints);
wayangle = round(rad2deg(wayangle));
waydist = round(dist_t);
end