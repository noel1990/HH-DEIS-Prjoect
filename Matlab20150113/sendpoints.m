% clear all;
% clearvars -global;
%init_serial;
function [] = sendpoints(curx, cury, cura)
global Req_Next;
global Next_Index;
global STATE;%first run time
global collision


%global Start_Ind;
% read=0;
% while(~read)
%     try
%         load '.\AAA\format.mat';
%     catch
%         pause(0.5)
%         continue;
%     end
% read=1;
% end
% %[cor,angle]=readf();
% start_point = [cor(1,1),cor(1,2)];
% start_angle = angle;
% end_point=[150,30];
% end_angle=0;
% if STATE 
    [cor,a]=readcor;
%     x_start=(760-cor(1,2))*4/9;
%     y_start=(cor(1,1)-25)*240/540;
%     a_start=a;
%     start_point = [x_start,y_start];
%     start_angle = a_start;    
% end
persistent x_start;
persistent y_start;
persistent a_start;

x_start=(760-cor(1,2))*4/9;
y_start=(cor(1,1)-25)*240/540;
a_start=a;
start_point = [x_start,y_start];
start_angle = a_start;
% start_point=[0,0];
% start_angle=0;
end_point=[x_start+150,y_start+80];
end_angle=0;

if STATE == 1
    STATE = 0;
    Req_Next = 0;
    Next_Index = 1;
    coord_type = 1; %0: next point to reach, 1: update position
    offsetx = round(start_point(1,1)-curx);
    offsety = round(start_point(1,2)-cury);
    offseta = round(start_angle-cura);
    sendCoords( offsetx, offsety, offseta, coord_type );
elseif collision(1,1)==1        %no collision ,safe
        collsionpoint_x=collision(1,2);
        collsionpoint_y=collision(1,3);
        collsionpoint_a=start_angle;
        coord_type = 0;         
        offsetx = round(start_point(1,1)-collsionpoint_x);
        offsety = round(start_point(1,2)-collsionpoint_y);
        offseta = round(start_angle-collsionpoint_a);
        cur_dist = distance([curx cury], [start_point(1,1) start_point(1,2)]);
        dist = distance([offsetx offsety],[waypoints(Next_Index+1,1) waypoints(Next_Index+1,2)]);
        sendCoords(offsetx, offsety,offseta, coord_type );
        if (cur_dist/dist < 0.5) || (cur_dist < 7)
            collision(1,1)=0; 
        end
    
else
    [ waypoints wayangle ] = spline_generate( start_point,start_angle, end_point,end_angle,10 );
    if Next_Index > size(waypoints,1)-1
        disp('Sending finished!');
    else
        coord_type = 0;
        waypx = round(waypoints(Next_Index,1));
        waypy = round(waypoints(Next_Index,2));
        waya = round(wayangle(1,Next_Index));
        cur_dist = distance([curx cury], [waypx waypy]);
        dist = distance([waypx waypy],[waypoints(Next_Index+1,1) waypoints(Next_Index+1,2)]);
        sendCoords( waypx, waypy, waya, coord_type );
        if (cur_dist/dist < 0.5) || (cur_dist < 7)
            Next_Index = Next_Index + 1;
        end
        if mod(Next_Index,5)== 0
            %             coord_type = 1; %0: next point to reach, 1: update position
            %             offsetx = round(start_point(1,1)-curx);
            %             offsety = round(start_point(1,2)-cury);
            %             offseta = round(start_angle-cura);
            %             sendCoords( offsetx, offsety, offseta, coord_type );
        end
    end
end
end