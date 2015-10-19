global OA_sec_d;
global Pie_curx;
global Pie_cury;
global Pie_cura;
security_distance = OA_sec_d*1.25;
% PIE_DATA=T.userdata;
% if ~isempty(PIE_DATA.opl)
%     CPC=PIE_DATA.opl;
%     CPC_Pre = [round(3200-CPC(:,2)*2),round(CPC(:,1)*2)];
% end
if ~isempty(CPC_Pre)
    OtherPIE = round([CPC_Pre(:,1),CPC_Pre(:,2)]);
%     figure(1);
%     draw_robot2([OtherPIE(1,1),OtherPIE(1,2)],0,'r');hold on;
    
    if STATE.Avoiding_Obstacle == 0
        Next_X = waypoints(next_wayp_index,1);
        Next_Y = waypoints(next_wayp_index,2);
        [OKtoGo, Danger_Robot] = CollisionTest([Next_X Next_Y],OtherPIE);
        if ~OKtoGo
            mark_danger_robot(Danger_Robot);
            if Inside_Otherpie_Test(Target_local,Danger_Robot)
%                 STATE.Avoiding_Obstacle = 1;
                waypoints = [1600 100 ; 1600 200];  %% just give point outside, won't be sent
                Spline_Qty = 2;
                waydist = zeros(1,2);
                dx = waypoints(2,1)-waypoints(1,1);
                dy = waypoints(2,2)-waypoints(1,2);
                waydist(1,1) = sqrt(dx*dx+dy*dy);
                next_wayp_index = 1;
                STATE.Avoiding_Obstacle = 1;
            else
                if size(Danger_Robot,1)>1
                    Danger_Robot(1,:) = select_rightmost_point(Danger_Robot,Pie_cura);
                end
                Angle_DanPie_NextP = atan2(Next_Y-Danger_Robot(1,2),Next_X-Danger_Robot(1,1));
                waypoints = zeros(2,2);
                waypoints(1,1) = Danger_Robot(1,1)+security_distance*cos(Angle_DanPie_NextP+pi/8);
                waypoints(1,2) = Danger_Robot(1,2)+security_distance*sin(Angle_DanPie_NextP+pi/8);
                waypoints(2,1) = Danger_Robot(1,1)+security_distance*cos(Angle_DanPie_NextP+pi/4);
                waypoints(2,2) = Danger_Robot(1,2)+security_distance*sin(Angle_DanPie_NextP+pi/4);
                Spline_Qty = 2;
                waydist = zeros(1,2);
                dx = waypoints(2,1)-waypoints(1,1);
                dy = waypoints(2,2)-waypoints(1,2);
                waydist(1,1) = sqrt(dx*dx+dy*dy);
                next_wayp_index = 1;
                STATE.Avoiding_Obstacle = 1;
            end
            figure(1);hold on;
            plot(waypoints(:,1),waypoints(:,2),'*r');
        end
        
    else
        if STATE.Action == 1
            start_point = [Pie_curx Pie_cury];
            start_angle = Pie_cura;
            target_point = [Target_X_Wait Target_Y_Wait];%%%%%%%%%%%%
            target_angle = Target_A_Wait;
            [Spline_Points_To_Target,Wayangle,Waydist]= GivePath(start_point,target_point,start_angle,target_angle);  %first run and give the path
%             figure(1);
%             X_send = round(Spline_Points_To_Target(next_wayp_index,1));
%             Y_send = round(Spline_Points_To_Target(next_wayp_index,2));
%             draw_robot2([X_send,Y_send],Wayangle(1,next_wayp_index),'g');hold on;
        elseif STATE.Action == 3  % STATE.Action = 3
            if STATE.SetPointBeforeTarget
                dx = TargetX - Pie_curx;
                dy = TargetY - Pie_cury;
                if sqrt(dx*dx+dy*dy)<200
                    Target_X_local = TargetX;
                    Target_Y_local = TargetY;
                    Target_A_local = atan2(dy,dx);
                else
                    d = 200;
                    AA = atan2(dy,dx);
                    Target_X_local = TargetX-d*cos(AA);
                    Target_Y_local = TargetY-d*sin(AA);
                    Target_A_local = AA;
                end
            else
                dx = TargetX - Pie_curx;
                dy = TargetY - Pie_cury;
                Target_X_local = TargetX;
                Target_Y_local = TargetY;
                Target_A_local = atan2(dy,dx);
            end
            start_point = [Pie_curx Pie_cury];
            start_angle = Pie_cura;
            target_point = [Target_X_local Target_Y_local];
            target_angle = rad2deg(Target_A_local);
            [Spline_Points_To_Target,Wayangle,Waydist]= GivePath(start_point,target_point,start_angle,target_angle);
%             figure(1);
%             X_send = round(Spline_Points_To_Target(next_wayp_index,1));
%             Y_send = round(Spline_Points_To_Target(next_wayp_index,2));
%             draw_robot2([X_send,Y_send],Wayangle(1,next_wayp_index),'g');hold on;
        else % STATE.Action = 4
            if STATE.SetPointBeforeTarget
                [Target_Inside_P_Case4 Target_Inside_A_Case4] = find_stopping_point([TargetX TargetY]);
                target_X = Target_Inside_P_Case4(1,1);
                target_Y = Target_Inside_P_Case4(1,2);
                target_A = Target_Inside_A_Case4;
                start_point = [Pie_curx Pie_cury];
                start_angle = Pie_cura;
                target_point = [target_X target_Y];
                target_angle = target_A;
                [Spline_Points_To_Target,Wayangle,Waydist] = GivePath(start_point,target_point,start_angle,target_angle);
%                 figure(1);
%                 X_send = round(Spline_Points_To_Target(next_wayp_index,1));
%                 Y_send = round(Spline_Points_To_Target(next_wayp_index,2));
%                 draw_robot2([X_send,Y_send],Wayangle(1,next_wayp_index),'g');hold on;
            else
                X_Start_State_4 = Pie_curx;
                Y_Start_State_4 = Pie_cury;
                A_Start_State_4 = Pie_cura;
                target_X = TargetX;
                target_Y = TargetY;
                dx = target_X - X_Start_State_4;
                dy = target_Y - Y_Start_State_4;
                target_A = rad2deg(atan2(dy,dx));
                start_point = [Pie_curx Pie_cury];
                start_angle = Pie_cura;
                target_point = [target_X target_Y];
                target_angle = target_A;
                [Spline_Points_To_Target,Wayangle,Waydist] = GivePath(start_point,target_point,start_angle,target_angle);
%                 figure(1);
%                 X_send = round(Spline_Points_To_Target(next_wayp_index,1));
%                 Y_send = round(Spline_Points_To_Target(next_wayp_index,2));
%                 draw_robot2([X_send,Y_send],Wayangle(1,next_wayp_index),'g');hold on;
            end
        end
        Next_X = Spline_Points_To_Target(1,1);
        Next_Y = Spline_Points_To_Target(1,2);
        [OKtoGo, Danger_Robot] = CollisionTest([Next_X Next_Y],OtherPIE);
        if OKtoGo
            waypoints = Spline_Points_To_Target;
            wayangle = Wayangle;
            waydist = Waydist;
            Spline_Qty = size(waypoints,1);
            next_wayp_index = 1;
            STATE.Avoiding_Obstacle = 0;
        else
            mark_danger_robot(Danger_Robot);
            if size(Danger_Robot,1)>1
                Danger_Robot(1,:) = select_rightmost_point(Danger_Robot,Pie_cura);
            end
            if next_wayp_index == 2  %% if the 2nd point, add a new point so that it alway has enough point to go to
                Angle_DanPie_NextP = atan2(waypoints(2,2)-Danger_Robot(1,2),waypoints(2,1)-Danger_Robot(1,1));
                waypoints(1,1) = waypoints(2,1);
                waypoints(1,2) = waypoints(2,2);
                waypoints(2,1) = Danger_Robot(1,1)+security_distance*cos(Angle_DanPie_NextP+pi/8);
                waypoints(2,2) = Danger_Robot(1,2)+security_distance*sin(Angle_DanPie_NextP+pi/8);
                Spline_Qty = 2;
                waydist = zeros(2,1);
                dx = waypoints(2,1)-waypoints(1,1);
                dy = waypoints(2,2)-waypoints(1,2);
                waydist(1) = sqrt(dx*dx+dy*dy);
                next_wayp_index = 1;
            end
        end
    end
end
