function [waypoints,wayangle,waydist]=spline_generate_allow_outside(start_point,target_point,start_angle,target_angle)

%the function give the initial path

dist_to_target = Cal_Distance(start_point, target_point);
sample_num = ceil(dist_to_target/200);
%sample_num = 1;
[ waypoints, wayangle ] = spline_generate( start_point,start_angle,target_point,target_angle,sample_num );
spline_Qty = size(waypoints,1);
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