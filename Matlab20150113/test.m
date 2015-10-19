% clc;
% clear;
%
%
%
% while(1)
%    pause(0.5);
%   T = add();
%    disp(T);
% end

%definition of global variables
clear;
clc;
global Rec;
%global STATE;
global Pie_curx;
global Pie_cury;
global Pie_cura;
global Pie_curv;
global Stop_Signal;
global odo_pos_buffer;
global data_counter;
% %initialize variables
first_run = 1;
next_wayp_index = 1;
Position_update = 0;
data_counter=0;
Stop_Signal = 0;
odo_pos_buffer = zeros(50,4);
Spline_Qty = 0;
First_Time_To_Decide_Passage_Usage = 1;
STATE.PassageUse = 0;
STATE.NeedToFreePassage = 0;
STATE.SetPointBeforeTarget = 1;
STATE.Avoiding_Obstacle = 0;
STATE.Waiting = 0;
STATE.NewPosition = 1;  %% When the robot receives a new position
STATE.NeedToGoOutside = 0;
STATE.LastTimeOutside = 0;
STATE.Action = 1;
L=40;
CAopen = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1: Going To Wait Point
% 2: Going Through the passage
% 3: Going to the Target point Inside
% 4: Going to the Target point Outside
% 5: Finished here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ask server for target points
%in pixcel unit
try
    init_serial;
catch
    close_serial;
    init_serial;
end

position_list = [];
P = getNextPos(1);
position_list(end+1,:) = [P(1) P(2)];
% TargetX = P(1);
% TargetY = P(2);
TargetX = 1000;
TargetY = 1000;

% target_point  = round([3200-position_list(1,1)*2,position_list(1,2)*2]/10);
% TargetX = target_point(1,1);
% TargetY = target_point(1,2);

% %add
parameter = initial_pro();
% %
% % % start timer
T=timer('Name','mytimer','TimerFcn',@mainfun,'ExecutionMode','fixedSpacing','Busymode','drop','Period',0.2);

T.TimerFcn={'mainfun',parameter};

start(T);

% open serial
try
    init_serial;
catch
    close_serial;
    init_serial;
end

%synchronous PIE current position with image
Sync_when_stop;
%main loop
%pause(0.1)
pie_curx = Pie_curx;
pie_cury = Pie_cury;
pie_cura = Pie_cura;
while (~Stop_Signal)
    pause(0.01)
    %record the odometery time
%     time_odo = java.lang.System.currentTimeMillis;
    %record odometry data
%     odo_pos_buffer(1:end-1,:) = odo_pos_buffer(2:end,:);
%     odo_pos_buffer(end,:) = [Pie_curx Pie_cury Pie_cura time_odo];
    %     data=T.userdata;
    try
        load('format.mat');
        delete('format.mat');
        A=Angle;
        MPC=mypie_centroid;
        %         P = distort_correct([MPC(2),MPC(1)]);
        %         CPC=closest_pie_centriod;%%%CPC is not needed here
        if(~isempty(MPC)&&~isempty(A))
            data_ok = 1;
        end
    catch
        data_ok = 0;
        disp('Can not load the file!');
    end
    if(data_ok == 1)
        data_ok = 0;
        %           Position_update = 1;
        %         img_x = round(P(1)/10);
        %         img_y = round(P(2)/10);
        %         img_a = round(A);
        img_x = round(3200-MPC(1,2)*2);
        img_y = round(MPC(1,1)*2);
        img_a = round(A);
        t_img = time_img;
        t_odo = odo_pos_buffer(:,4);
        t_d = abs(t_odo-t_img);
        [tt index] = min(t_d);
        
        odo_x = odo_pos_buffer(index,1);
        odo_y = odo_pos_buffer(index,2);
        odo_a = odo_pos_buffer(index,3);
        
        dx = TargetX - Pie_curx;
        dy = TargetY - Pie_cury;
        Dist_to_End = sqrt(dx*dx+dy*dy);
               
        if Dist_to_End > 500
            Fuse_Factor = 1 - Pie_curv/250;
        else
            Fuse_Factor = (Dist_to_End/500)*(1-Pie_curv/250);
        end
        
        if Pie_curv ~= 0
            if Fuse_Factor > 0.5
                Fuse_Factor = 0.5;
            end
        end
        
        pie_curx = Pie_curx + Fuse_Factor*(img_x-odo_x);
        pie_cury = Pie_cury + Fuse_Factor*(img_y-odo_y);
        pie_cura = wrapAngle(Pie_cura + Fuse_Factor*(img_a-odo_a));
    else
        pie_curx = Pie_curx;
        pie_cury = Pie_cury;
        pie_cura = Pie_cura; 
    end
    
    odo_pos_buffer = zeros(50,4);
    
    str = [pie_curx pie_cury pie_cura];
    disp('Fused position.');
    disp(str);
    %[waitpoints waitangle]
    %[100 70],100
    %[100 175],-100
    %[220 70],80
    %[220 175],-80
    
    %from outside point
    if first_run
        first_run = 0;
        start_point = [pie_curx pie_cury];
        start_angle = pie_cura;
        %         if TargetX <160
        %             target_angle = rad2deg(atan2((120-TargetY ),(80-TargetX)));
        %         else
        %             target_angle = rad2deg(atan2((120-TargetY ),(240-TargetX)));
        %         end
        target_angle = rad2deg(atan2((TargetY-start_point(1,1)),(TargetX-start_point(1,2))));
        target_point = [TargetX TargetY];%%%%%%%%%%%%
        Target_CAP =  target_point;
        Target_CAA = target_angle ;
        [waypoints,wayangle,wayatmp]= GivePath(start_point,target_point,start_angle,target_angle);  %first run and give the path
        %        [waypoints,wayangle]= GivePath([0 0],[100 100],0,0);  %first run and give the path
        coord_type = 0;
        sendCoords(waypoints(1,1), waypoints(1,2), wayangle(1,1), coord_type ); %send first point in the path list
        %         disp('===== Spline angle ======');
        %         disp(wayatmp(1,1));
        %        next_wayp_index = 1 ;
    else
        Spline_Qty = size(waypoints,1);
        coord_type = 0;
        if(Rec == 1)
            Rec=0;
            if (next_wayp_index < Spline_Qty)                                       % still have point in the path list
                pre_wayp_index = next_wayp_index;
                [x_update,y_update,a_update,next_wayp_index] = Update_position(waypoints,wayangle,pre_wayp_index,[pie_curx pie_cury]); % update position
                sendCoords(x_update,y_update,a_update, coord_type );
%                 if round(next_wayp_index/Spline_Qty) == 0.8
%                     Position_update = 1;
%                 end
                figure(1);
                draw_robot2([x_update,y_update],wayatmp(1,next_wayp_index),'g');hold on;
                %                 disp('===== Spline angle ======');
                %                 disp(wayatmp(1,next_wayp_index));
            else
%                 Position_update = 1;
                sendCoords(waypoints(end,1),waypoints(end,2),wayangle(1,end), coord_type );
                figure(1);
                draw_robot2([waypoints(end,1),waypoints(end,2)],wayatmp(1,next_wayp_index),'g');hold on;
                %                 disp('===== Spline angle ======');
                %                 disp(wayatmp(1,end));
            end
            
        end
    end
    
    %     if (Pie_curv == 0)&&(next_wayp_index == Spline_Qty)
    %         Sync_when_stop;
    %     end
    
    %     Position_update = 0;
    if Position_update
        % send position to correct
        pause(0.015);
        coord_type = 1; %0: next point to reach, 1: update position
        offsetx = round(pie_curx);
        offsety = round(pie_cury);
        offseta = round(pie_cura);
        sendCoords( offsetx, offsety, offseta, coord_type );
        
        time = java.lang.System.currentTimeMillis;
        odo_pos_buffer(end,:) = [pie_curx pie_cury pie_cura time];
        Position_update = 0;
        %         odo_pos_buffer = zeros(50,4);
    end
end