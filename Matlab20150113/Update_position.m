function [x_update,y_update,a_update,index_update] = Update_position(waypoints,wayangle,next_wayp_index,cur_pos)
%The function give the update information

% global Pie_curx;
% global Pie_cury;
pie_curx = cur_pos(1);
pie_cury = cur_pos(2);
global Pie_curv;
waypx = round(waypoints(next_wayp_index,1));
waypy = round(waypoints(next_wayp_index,2));
waya = round(wayangle(1,next_wayp_index));
cur_dist = Cal_Distance([pie_curx pie_cury], [waypx waypy]);
% dist =Cal_Distance([waypx waypy],[waypoints(next_wayp_index+1,1) waypoints(next_wayp_index+1,2)]);
dist_thres = 20 + Pie_curv/2;

% if (cur_dist/dist < 0.5) || (cur_dist < 7.5)
if (cur_dist < dist_thres)
    next_wayp_index = next_wayp_index + 1;
end

x_update = waypx;
y_update = waypy;
a_update = waya;
index_update =  next_wayp_index;
end