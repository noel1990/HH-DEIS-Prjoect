function spline_plot(demo,start_point,target_point,start_angle,target_angle)
demo1 = 1;
demo2 = 2;
demo3 = 3;
demo4 = 4;
switch demo
    case demo1
        n = 18;
        [ waypoints wayangle ] = spline_generate( start_point, start_angle, target_point, target_angle, n/3);
        figure;
        for i=1:n
            plot(waypoints(i,1),waypoints(i,2),'*');
            hold on;
        end
    case demo2
        n = 30;
        [ waypoints wayangle ] = spline_generate( [0,0], 0, [2000,1000], 0, n/3);
        figure;
        for i=1:n
            plot(waypoints(i,1),waypoints(i,2),'*');
            hold on;
        end
    case demo3
        n1 = 27;
        [ waypoints wayangle ] = spline_generate( [0,0], 0, [2000,1000], -90, n1/3);
        %         figure;
        %         for i=1:n
        %             plot(waypoints(i,1),waypoints(i,2),'*');
        %             hold on;
        %         end
        tmp_points = waypoints;
        tmp_angle = wayangle;
        n2 = 9;
        [ waypoints wayangle ] = spline_generate( [2000,1000], -90, [2000,500], -90, n2/3);
        %         for i=1:n
        %             plot(waypoints(i,1),waypoints(i,2),'*');
        %             hold on;
        %         end
        waypoints = [tmp_points
            waypoints];
        wayangle = [tmp_angle wayangle];
        figure;
        for i=1:n1+n2
            plot(waypoints(i,1),waypoints(i,2),'*');
            hold on;
        end
    case demo4
        n1 = 27;
        [ waypoints wayangle ] = spline_generate( [0,0], 0, [1000,1000], -90, n1/3);
        %         figure;
        %         for i=1:n
        %             plot(waypoints(i,1),waypoints(i,2),'*');
        %             hold on;
        %         end
        tmp_points = waypoints;
        tmp_angle = wayangle;
        n2 = 9;
        [ waypoints wayangle ] = spline_generate( [1000,1000], -90, [1000,0], -90, n2/3);
        %         for i=1:n
        %             plot(waypoints(i,1),waypoints(i,2),'*');
        %             hold on;
        %         end
        waypoints = [tmp_points
            waypoints];
        wayangle = [tmp_angle wayangle];
        figure;
        for i=1:n1+n2
            plot(waypoints(i,1),waypoints(i,2),'*');
            hold on;
        end
end
end