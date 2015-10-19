%definition of global variables
clear all;
clc;
global Rec;
global Pie_curx;
global Pie_cury;
global Pie_cura;
global Pie_curv;
global Pie_col_info;
global Stop_Signal;
global odo_pos_buffer;
global data_counter;
global Wait_Point_X_Offset;
global Wait_Point_Y_Offset;
global passage_path_length;
global OA_sec_d;
%initialize variables
% Started = 0;
First_Time = 1;
next_wayp_index = 1;
Position_update = 0;
Delay_Cnt = 0;
data_counter=0;
Stop_Signal = 0;
odo_pos_buffer = zeros(50,4);
Wait_Point_X_Offset = 600;
Wait_Point_Y_Offset = 500;
passage_path_length = 500;
OA_sec_d = 350;
Sync_After_Stop_Done = 0;
First_Time_To_Decide_Passage_Usage = 1;
STATE.PassageUse = 0;
STATE.NeedToFreePassage = 0;
STATE.SetPointBeforeTarget = 1;
STATE.Avoiding_Obstacle = 0;
STATE.Waiting = 0;
STATE.NewPosition = 1;  % When the robot receives a new position
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
%and translate from pixcel unit into mm
position_list = [];
P = getNextPos(1);
% P = [2600 500];
position_list(end+1,:) = [P(1) P(2) 0];
TargetX = P(1);
TargetY = P(2);
% target_point  = round([3200-position_list(1,1)*2,position_list(1,2)*2]/10);
% TargetX = target_point(1,1);
% TargetY = target_point(1,2);

% %add
parameter = initial_pro();
%
% % start timer
T=timer('Name','mytimer','TimerFcn',@mainfun1,'StartDelay',0.5,'ExecutionMode','fixedSpacing','Busymode','drop','Period',0.2);
T.TimerFcn={'mainfun1',parameter};
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
while (~Stop_Signal)
    pause(0.01)
    %     data=T.userdata;
    %need passage or not
    if First_Time_To_Decide_Passage_Usage == 1
        First_Time_To_Decide_Passage_Usage = 0;
        if OutSide([TargetX TargetY])
            STATE.NeedToGoOutside = 1;
            %                 STATE.SkipSyncWhenStop = 1;
        else
            STATE.NeedToGoOutside = 0;
            %                 STATE.SkipSyncWhenStop = 0;
        end
        
        if (Pie_curx<1600 && TargetX>1600)||(Pie_curx>1600 && TargetX<1600)
            STATE.PassageUse = 1;
            STATE.Action = 1;  %% go to wait point
        else
            STATE.PassageUse = 0;
            if STATE.NeedToGoOutside
                STATE.Action = 4;  %% go to target point outside
            else
                STATE.Action = 3;  %% go to target point inside
            end
        end
        
    end
    cla;
    figure(1);
    draw_field();
    hold on;
    %sensor fusion
    PIE_DATA=T.userdata;
    if ~isempty(PIE_DATA.opl)
        CPC=PIE_DATA.opl;
        CPC_Pre = [round(3200-CPC(:,2)*2),round(CPC(:,1)*2)];
        figure(1);
        for i = 1:size(CPC_Pre,1)
            draw_robot([CPC_Pre(i,1) CPC_Pre(i,2)],deg2rad(0),-1);    
        end
    end
    data_ok = 0;
    if(data_ok == 1)
        data_ok = 0;
        Position_update = 1;
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
        
        Pie_curx = Pie_curx + Fuse_Factor*(img_x-odo_x);
        Pie_cury = Pie_cury + Fuse_Factor*(img_y-odo_y);
        Pie_cura = wrapAngle(Pie_cura + Fuse_Factor*(img_a-odo_a));
    end
    
    odo_pos_buffer = zeros(50,4);
    
    figure(1);
    draw_otherpie_security_circle;
    draw_robot([Pie_curx Pie_cury],deg2rad(Pie_cura),Pie_col_info);
    
    switch STATE.Action
        case 1
            disp('Going To Wait Point');
            %[waitpoints waitangle]
            %[1000 700],100
            %[1000 1700],-100
            %[2200 700],80
            %[2200 1700],-80
            if Pie_curx < 1600
                Target_X_Wait = 1600-Wait_Point_X_Offset;
            else
                Target_X_Wait = 1600+Wait_Point_X_Offset;
            end
            if Pie_cury < 1200
                Target_Y_Wait = 1200-Wait_Point_Y_Offset;
                Target_A_Wait = 90;
            else
                Target_Y_Wait = 1200+Wait_Point_Y_Offset;
                Target_A_Wait = -90;
            end
            
            if First_Time
                start_point = [Pie_curx Pie_cury];
                start_angle = Pie_cura;
                target_point = [Target_X_Wait Target_Y_Wait];%%%%%%%%%%%%
                target_angle = Target_A_Wait;
                [waypoints,wayangle,waydist]= GivePath(start_point,target_point,start_angle,target_angle);  %first run and give the path
                Spline_Qty = size(waypoints,1);
                next_wayp_index = 1 ;
                STATE.Avoiding_Obstacle = 0;
            end
            Target_local = [Target_X_Wait Target_Y_Wait];
            Obs_Avd;
            figure(1);
            plot(waypoints(:,1),waypoints(:,2),'mx');
            if OutSide([waypoints(next_wayp_index,1) waypoints(next_wayp_index,2)], Pie_curx)   % if the point is outside, wait
                STATE.Waiting = 1;
            else
                STATE.Waiting = 0;
                Sync_After_Stop_Done = 0;
            end
            if STATE.Waiting
                Stop_Robot;
            else
                %                 if(Rec == 1)
                %                     Rec = 0;
                cur_dist = Cal_Distance([Pie_curx Pie_cury], [waypoints(next_wayp_index,1) waypoints(next_wayp_index,2)]);
                dist_thres = 20 + Pie_curv/2;
                if (cur_dist < dist_thres)
                    if (next_wayp_index ~= Spline_Qty)
                        next_wayp_index = next_wayp_index + 1;
                    end
                end
                if Pie_curv ~= 0
                    First_Time = 0;
%                     Started = 1;
                end
                
%                 if First_Time
%                     Started = 0;
%                 end
%                 if ((Pie_curv==0) && (next_wayp_index == Spline_Qty) && Started)
                if(Pie_curv==0) && (next_wayp_index == Spline_Qty)
                    % Send msg to server to apply the passage %
                    if (requestPassage)
                        First_Time = 1;
                        STATE.Action = 2;   %% finished here
                        Sync_when_stop;
                    end
                else
                    coord_type = 0;
                    X_send = round(waypoints(next_wayp_index,1));
                    Y_send = round(waypoints(next_wayp_index,2));
                    Dist_send = round(waydist(1,next_wayp_index));
                    sendCoords(X_send,Y_send,Dist_send, coord_type );
                    figure(1);
                    plot(X_send,Y_send,'ro');
%                     draw_robot2([X_send,Y_send],wayangle(1,next_wayp_index),'g');hold on;
                end
            end
            %             end
        case 2
            disp('Going Through the passage');
            STATE.NeedToFreePassage = 1;
            if First_Time
                start_point = [Pie_curx Pie_cury];
                start_angle = Pie_cura;
                [waypoints wayangle waydist] = spline_generate_for_passage(start_point,start_angle);
                Spline_Qty = size(waypoints,1);
                if Pie_curx < 1600
                    dx = TargetX-(1600-passage_path_length);
                    dy = TargetY-(1200);
                    waydist = waydist+sqrt(dx*dx+dy*dy);
                else
                    dx = TargetX-(1600+passage_path_length);
                    dy = TargetY-(1200);
                    waydist = waydist+sqrt(dx*dx+dy*dy);
                end
                next_wayp_index = 1 ;
            end
            figure(1);
            plot(waypoints(:,1),waypoints(:,2),'mx');
            %             if(Rec == 1)
            %                 Rec = 0;
            cur_dist = Cal_Distance([Pie_curx Pie_cury], [waypoints(next_wayp_index,1) waypoints(next_wayp_index,2)]);
            dist_thres = 20 + Pie_curv/2;
            if (cur_dist < dist_thres)
                if (next_wayp_index ~= Spline_Qty)
                    next_wayp_index = next_wayp_index + 1;
                end
            end
            if Pie_curv ~= 0
                First_Time = 0;
%                 Started = 1;
            end
            
%             if First_Time
%                 Started = 0;
%             end
%             if ((cur_dist < dist_thres) && (next_wayp_index == Spline_Qty) && Started)
            if(cur_dist < dist_thres) && (next_wayp_index == Spline_Qty)
                First_Time = 1;
                if STATE.NeedToGoOutside
                    STATE.Action = 4;  %% go to target point outside
                else
                    STATE.Action = 3;  %% go to target point inside
                end
            else
                coord_type = 0;
                X_send = round(waypoints(next_wayp_index,1));
                Y_send = round(waypoints(next_wayp_index,2));
                Dist_send = round(waydist(1,next_wayp_index));
                sendCoords(X_send,Y_send,Dist_send, coord_type );
                figure(1);
                plot(X_send,Y_send,'ro');
%                 draw_robot2([X_send,Y_send],wayangle(1,next_wayp_index),'g');hold on;
            end
            %             end
        case 3
            disp('Going to the Target point Inside');
            if First_Time
                if STATE.PassageUse
                    if Pie_cura > -90 && Pie_cura < 90
                        X_Start_State_3 = 1600+passage_path_length;
                        Y_Start_State_3 = 1200;
                        A_Start_State_3 = 0;
                    else
                        X_Start_State_3 = 1600-passage_path_length;
                        Y_Start_State_3 = 1200;
                        A_Start_State_3 = 180;
                    end
                else
                    X_Start_State_3 = Pie_curx;
                    Y_Start_State_3 = Pie_cury;
                    A_Start_State_3 = Pie_cura;
                end
                
                if STATE.SetPointBeforeTarget
                    dx = X_Start_State_3 - TargetX;
                    dy = Y_Start_State_3 - TargetY;
                    if sqrt(dx*dx+dy*dy)<200
                        target_X = TargetX;
                        target_Y = TargetY;
                    else
                        dx = TargetX - X_Start_State_3;
                        dy = TargetY - Y_Start_State_3;
                        d = 200;
                        target_X = TargetX-d*cos(atan2(dy,dx));
                        target_Y = TargetY-d*sin(atan2(dy,dx));
                    end
                    [target_X target_Y] = move_point_inside(target_X, target_Y);
                else
                    X_Start_State_3 = Pie_curx;
                    Y_Start_State_3 = Pie_cury;
                    A_Start_State_3 = Pie_cura;
                    target_X = TargetX;
                    target_Y = TargetY;
                end
                
                dx = target_X - X_Start_State_3;
                dy = target_Y - Y_Start_State_3;
                target_A = rad2deg(atan2(dy,dx));
                start_point = [X_Start_State_3 Y_Start_State_3];
                start_angle = A_Start_State_3;
                target_point = [target_X target_Y];
                target_angle = target_A;
                [waypoints,wayangle,waydist] = GivePath(start_point,target_point,start_angle,target_angle);
                Spline_Qty = size(waypoints,1);
                next_wayp_index = 1;
                STATE.Avoiding_Obstacle = 0;
            end
            Target_local = [target_X target_Y];
            Obs_Avd;
            figure(1);
            plot(waypoints(:,1),waypoints(:,2),'mx');
            if OutSide([waypoints(next_wayp_index,1) waypoints(next_wayp_index,2)], Pie_curx)   %% if the point is outside, wait
                STATE.Waiting = 1;
            else
                STATE.Waiting = 0;
                Sync_After_Stop_Done = 0;
            end
            if STATE.Waiting
                Stop_Robot;
            else
                if STATE.NeedToFreePassage
                    if Pie_curx<1600
                        dx = Pie_curx-1300;
                        dy = Pie_cury-1200;
                        DToPassageEnd = sqrt(dx*dx+dy*dy);
                        if DToPassageEnd > (250-130)
                            freePassage;
                            STATE.NeedToFreePassage = 0;
                        end
                    else
                        dx = Pie_curx-1900;
                        dy = Pie_cury-1200;
                        DToPassageEnd = sqrt(dx*dx+dy*dy);
                        if DToPassageEnd > (250-130)
                            freePassage;
                            STATE.NeedToFreePassage = 0;
                        end
                    end
                end
                %                 if(Rec == 1)
                %                     Rec = 0;
                cur_dist = Cal_Distance([Pie_curx Pie_cury], [waypoints(next_wayp_index,1) waypoints(next_wayp_index,2)]);
                dist_thres = 20 + Pie_curv/2;
                if (cur_dist < dist_thres)
                    if (next_wayp_index ~= Spline_Qty)
                        next_wayp_index = next_wayp_index + 1;
                    end
                end
                if Pie_curv ~= 0
                    First_Time = 0;
%                     Started = 1;
                end
                
%                 if First_Time
%                     Started = 0;
%                 end
%                 if ((Pie_curv==0) && (next_wayp_index == Spline_Qty) && Started)
                if(Pie_curv==0) && (next_wayp_index == Spline_Qty)
                    Sync_when_stop;
                    dx = Pie_curx - TargetX;
                    dy = Pie_cury - TargetY;
                    d_error = sqrt(dx*dx+dy*dy);
                    if d_error>30
                        First_Time = 1;
                        STATE.SetPointBeforeTarget = 0;
                    else
                        STATE.Action = 5;   %% finished here
                        STATE.SetPointBeforeTarget = 1;   %%not for current spline, just for next spline
                    end
                else
                    coord_type = 0;
                    X_send = round(waypoints(next_wayp_index,1));
                    Y_send = round(waypoints(next_wayp_index,2));
                    Dist_send = round(waydist(1,next_wayp_index));
                    sendCoords(X_send,Y_send,Dist_send, coord_type );
                    figure(1);
                    plot(X_send,Y_send,'ro');
%                     draw_robot2([X_send,Y_send],wayangle(1,next_wayp_index),'g');hold on;
                end
            end
            %             end
        case 4
            disp('Going To Target Point Outside');
            if First_Time
                if STATE.PassageUse
                    if Pie_cura > -90 && Pie_cura < 90
                        X_Start_State_4 = 1600+passage_path_length;
                        Y_Start_State_4 = 1200;
                        A_Start_State_4 = 0;
                    else
                        X_Start_State_4 = 1600-passage_path_length;
                        Y_Start_State_4 = 1200;
                        A_Start_State_4 = 180;
                    end
                else
                    X_Start_State_4 = Pie_curx;
                    Y_Start_State_4 = Pie_cury;
                    A_Start_State_4 = Pie_cura;
                end
                
                if STATE.SetPointBeforeTarget
                    [Target_Inside_P_Case4 Target_Inside_A_Case4] = find_stopping_point([TargetX TargetY]);
                    target_X = Target_Inside_P_Case4(1,1);
                    target_Y = Target_Inside_P_Case4(1,2);
                    target_A = Target_Inside_A_Case4;
                    start_point = [X_Start_State_4 Y_Start_State_4];
                    start_angle = A_Start_State_4;
                    target_point = [target_X target_Y];
                    target_angle = target_A;
                    [waypoints,wayangle,waydist] = GivePath(start_point,target_point,start_angle,target_angle);
                else
                    X_Start_State_4 = Pie_curx;
                    Y_Start_State_4 = Pie_cury;
                    A_Start_State_4 = Pie_cura;
                    target_X = TargetX;
                    target_Y = TargetY;
                    dx = target_X - X_Start_State_4;
                    dy = target_Y - Y_Start_State_4;
                    target_A = rad2deg(atan2(dy,dx));
                    start_point = [X_Start_State_4 Y_Start_State_4];
                    start_angle = A_Start_State_4;
                    target_point = [target_X target_Y];
                    target_angle = target_A;
                    [waypoints,wayangle,waydist] = spline_generate_allow_outside(start_point,target_point,start_angle,target_angle);
                end
                Spline_Qty = size(waypoints,1);
                next_wayp_index = 1;
                STATE.Avoiding_Obstacle = 0;
            end
            Target_local = [TargetX TargetY];
            Obs_Avd;
            figure(1);
            plot(waypoints(:,1),waypoints(:,2),'mx');
            if waypoints(1,1) == 1600&&waypoints(1,2) == 100
                STATE.Waiting = 1;
            else
                STATE.Waiting = 0;
                Sync_After_Stop_Done = 0;
            end
            
            if STATE.Waiting
                Stop_Robot;
            else
                if STATE.NeedToFreePassage
                    if Pie_curx<1600
                        dx = Pie_curx-1300;
                        dy = Pie_cury-1200;
                        DToPassageEnd = sqrt(dx*dx+dy*dy);
                        if DToPassageEnd > (250-130)
                            freePassage;
                            STATE.NeedToFreePassage = 0;
                        end
                    else
                        dx = x-1900;
                        dy = y-1200;
                        DToPassageEnd = sqrt(dx*dx+dy*dy);
                        if DToPassageEnd > (250-130)
                            freePassage;
                            STATE.NeedToFreePassage = 0;
                        end
                    end
                end
                %                 if(Rec == 1)
                %                     Rec = 0;
                cur_dist = Cal_Distance([Pie_curx Pie_cury], [waypoints(next_wayp_index,1) waypoints(next_wayp_index,2)]);
                dist_thres = 20 + Pie_curv/2;
                if (cur_dist < dist_thres)
                    if (next_wayp_index ~= Spline_Qty)
                        next_wayp_index = next_wayp_index + 1;
                    end
                end
                if Pie_curv ~= 0
                    First_Time = 0;
%                     Started = 1;
                end
                
%                 if First_Time
%                     Started = 0;
%                 end
%                 if ((Pie_curv==0) && (next_wayp_index == Spline_Qty) && Started)
                if(Pie_curv==0) && (next_wayp_index == Spline_Qty)
                    if STATE.SetPointBeforeTarget
                        Sync_when_stop;
                    end
                    dx = Pie_curx - TargetX;
                    dy = Pie_cury - TargetY;
                    d_error = sqrt(dx*dx+dy*dy);
                    if d_error>30
                        First_Time = 1;
                        STATE.SetPointBeforeTarget = 0;
                    else
                        STATE.Action = 5;   %% finished here
                        STATE.SetPointBeforeTarget = 1;   %%not for current spline, just for next spline
                    end
                else
                    coord_type = 0;
                    X_send = round(waypoints(next_wayp_index,1));
                    Y_send = round(waypoints(next_wayp_index,2));
                    Dist_send = round(waydist(1,next_wayp_index));
                    sendCoords(X_send,Y_send,Dist_send,coord_type );
                    figure(1);
                    plot(X_send,Y_send,'ro');
%                     draw_robot2([X_send,Y_send],wayangle(1,next_wayp_index),'g');hold on;
                end
            end
            %             end
        case 5
            disp('Finish reaching the target');
    end
    if STATE.Action == 5
        Delay_Cnt = Delay_Cnt + 1;
        if Delay_Cnt == 15
            Delay_Cnt = 0;
            position_counter = size(position_list,1);
            P = getNextPos(1);
            position_list(end+1,:) = [P(1) P(2) 0];
            if STATE.NeedToGoOutside
                STATE.LastTimeOutside = 1;
            else
                STATE.LastTimeOutside = 0;
            end
            position_counter = position_counter + 1;
            if position_counter <= size(position_list,1)
                if ~STATE.NeedToGoOutside
                    Sync_when_stop;
                end
                odo_pos_buffer = zeros(50,4);
                time_odo = java.lang.System.currentTimeMillis;
                odo_pos_buffer(1:end-1,:) = odo_pos_buffer(2:end,:);
                odo_pos_buffer(end,:) = [Pie_curx Pie_cury Pie_cura time_odo];
                TargetX = position_list(position_counter,1);
                TargetY = position_list(position_counter,2);
                % Some variables need to be reset here !!!
                First_Time_To_Decide_Passage_Usage = 1;
                First_Time = 1;
            else
                break;                        %% Finished here!
            end
        end
    end
    
    Position_update = 0;
    if Position_update
        % send position to correct
        pause(0.015);
        coord_type = 1; %0: next point to reach, 1: update position
        offsetx = round(Pie_curx);
        offsety = round(Pie_cury);
        offseta = round(Pie_cura);
        sendCoords( offsetx, offsety, offseta, coord_type );
        
        time = java.lang.System.currentTimeMillis;
        odo_pos_buffer(end,:) = [Pie_curx Pie_cury Pie_cura time];
        Position_update = 0;
        %         odo_pos_buffer = zeros(50,4);
    end
end