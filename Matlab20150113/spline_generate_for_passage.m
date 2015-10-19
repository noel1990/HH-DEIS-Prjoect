function [waypoints wayangle waydist] = spline_generate_for_passage(PIE_curp, PIE_cura)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[waitpoints waitangle]
%[1100 800],100
%[1100 1600],-100
%[2100 800],80
%[2100 1600],-80
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global passage_path_length;
Shift = 40;
waypoints =[];
wayangle =[];
waypoints1 = [];
waypoints2 = [];
wayangle1 = [];
wayangle2 = [];
x = PIE_curp(1,1);
y = PIE_curp(1,2);

if x<1600
    if y<1200
        dist = Cal_Distance(PIE_curp,[1600-passage_path_length 1200-Shift]);
        sample_per_piece = round(dist/200);
        [ waypoints1 wayangle1 ] = spline_generate( PIE_curp,PIE_cura,[1600-passage_path_length 1200-Shift],0,sample_per_piece );
        sample_per_piece = 5;
        [ waypoints2 wayangle2 ] = spline_generate( [1600-passage_path_length 1200-Shift],0,[1600+passage_path_length 1200-Shift],0,sample_per_piece);
        waypoints = [waypoints1
            waypoints2];
        wayangle = [wayangle1 wayangle2];
%         for i=1:size(wayangle,2)
%             hold on;
%             plot(waypoints(i,1),waypoints(i,2),'*r');
%         end
    else
        dist = Cal_Distance(PIE_curp,[1600-passage_path_length 1200+Shift]);
        sample_per_piece = round(dist/200);
        [ waypoints1 wayangle1 ] = spline_generate( PIE_curp,PIE_cura,[1600-passage_path_length 1200+Shift],0,sample_per_piece );
        sample_per_piece = 5;
        [ waypoints2 wayangle2 ] = spline_generate( [1600-passage_path_length 1200+Shift],0,[1600+passage_path_length 1200+Shift],0,sample_per_piece);
        waypoints = [waypoints1
            waypoints2];
        wayangle = [wayangle1 wayangle2];
%         for i=1:size(wayangle,2)
%             plot(waypoints(i,1),waypoints(i,2),'*b');
%             hold on;
%         end
    end
else
    if y<1200
        dist = Cal_Distance(PIE_curp,[1600+passage_path_length 1200-Shift]);
        sample_per_piece = round(dist/200);
        [ waypoints1 wayangle1 ] = spline_generate( PIE_curp,PIE_cura,[1600+passage_path_length 1200-Shift],180,sample_per_piece );
        sample_per_piece = 5;
        [ waypoints2 wayangle2 ] = spline_generate( [1600+passage_path_length 1200-Shift],180,[1600-passage_path_length 1200-Shift],180,sample_per_piece);
        waypoints = [waypoints1
            waypoints2];
        wayangle = [wayangle1 wayangle2];
%         for i=1:size(wayangle,2)
%             plot(waypoints(i,1),waypoints(i,2),'*g');
%             hold on;
%         end
    else
        dist = Cal_Distance(PIE_curp,[1600+passage_path_length 1200+Shift]);
        sample_per_piece = round(dist/200);
        [ waypoints1 wayangle1 ] = spline_generate( PIE_curp,PIE_cura,[1600+passage_path_length 1200+Shift],180,sample_per_piece );
        sample_per_piece = 5;
        [ waypoints2 wayangle2 ] = spline_generate( [1600+passage_path_length 1200+Shift],180,[1600-passage_path_length 1200+Shift],180,sample_per_piece);
        waypoints = [waypoints1
            waypoints2];
        wayangle = [wayangle1 wayangle2];
%         for i=1:size(wayangle,2)
%             plot(waypoints(i,1),waypoints(i,2),'*k');
%             hold on;
%         end
    end
end

spline_Qty = size(waypoints,1);
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

