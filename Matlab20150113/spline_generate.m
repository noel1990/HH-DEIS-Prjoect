function [ waypoints wayangle ] = spline_generate( point1,angle1,point2,angle2,sample_per_piece )
dist = sqrt((point2(1,1)-point1(1,1))^2+(point2(1,2)-point1(1,2))^2)/3;
%dist = 80;
control_point1 = round(point1-dist*[cosd(angle1) sind(angle1)]);
control_point2 = round(point1);
control_point3 = round(point1+dist*[cosd(angle1) sind(angle1)]);
control_point4 = round(point2-dist*[cosd(angle2) sind(angle2)]);
control_point5 = round(point2);
control_point6 = round(point2+dist*[cosd(angle2) sind(angle2)]);
control_points_x = [control_point1(1,1) control_point2(1,1) control_point3(1,1) control_point4(1,1) control_point5(1,1) control_point6(1,1)];
control_points_y = [control_point1(1,2) control_point2(1,2) control_point3(1,2) control_point4(1,2) control_point5(1,2) control_point6(1,2)];
goalangle = deg2rad(angle2);
for i = 1:sample_per_piece
    t(i) = i/sample_per_piece;
end
for i = 1:3
    for ii = 1:sample_per_piece
        tmp_point = [0 0];
        b0 = base_Equation0(t(ii));
        b1 = base_Equation1(t(ii));
        b2 = base_Equation2(t(ii));
        b3 = base_Equation3(t(ii));
        tmp_point(1,1) = b0*control_points_x(1,(i-1)+1) + b1*control_points_x(1,(i-1)+2) + b2*control_points_x(1,(i-1)+3) + b3*control_points_x(1,(i-1)+4);
        tmp_point(1,2) = b0*control_points_y(1,(i-1)+1) + b1*control_points_y(1,(i-1)+2) + b2*control_points_y(1,(i-1)+3) + b3*control_points_y(1,(i-1)+4);
        waypoints(((i-1)*sample_per_piece+ii),1) = tmp_point(1,1);
        waypoints(((i-1)*sample_per_piece+ii),2) = tmp_point(1,2);
    end
end
for i = 1:3*sample_per_piece-1
    wayangle(i) = atan2((waypoints(i+1,2)-waypoints(i,2)),(waypoints(i+1,1)-waypoints(i,1)));
end
wayangle(3*sample_per_piece) = goalangle;
end