%get values from serial
global Pie_curx;
global Pie_cury;
% global Pie_cura;

% try
%     delete('format.mat');
% catch
% end

% Get the image data
data_ok = 0;
CPC=[];
CPC_Pre=[];
while data_ok == 0
    PIE_DATA=T.userdata;
    
    if (~isempty(PIE_DATA))
%         load('format.mat');
%         delete('format.mat');
       
        A=PIE_DATA.angle;
        MPC=PIE_DATA.mpc;
        if ~isempty(PIE_DATA.opl)
            CPC=PIE_DATA.opl;
            CPC_Pre = [round(3200-CPC(:,2)*2),round(CPC(:,1)*2)];
        end
        
        if(~isempty(MPC)&&~isempty(A))
            x_img = round(3200-MPC(1,2)*2);
            y_img = round(MPC(1,1)*2);
            %             x_img = round(P(1)/10);
            %             y_img = round(P(2)/10);
            a_img = round(A);
%             try
                
%             catch
%                 CPC_Pre = [0,0];
%             end
            MPC_Pre = [x_img,y_img];
            data_ok = 1;
            PIE_DATA=[];
%             PIE_DATA.newdata=-1;
        end
    else
        data_ok = 0;
    end
end

while 1
    pause(0.01);
    %    if(Pie_curx == x_img && Pie_cury == y_img && Pie_cura == a_img)
    if((Pie_curx == x_img) && (Pie_cury == y_img))
        break;
    end
    
    pause(0.015);
    coord_type = 1; %0: next point to reach, 1: update position
    %     offsetx = x_img-Pie_curx;
    %     offsety = y_img-Pie_cury;
    %     offseta = a_img-Pie_cura;
    offsetx = x_img;
    offsety = y_img;
    offseta = a_img;
    sendCoords( offsetx, offsety, offseta, coord_type );
end
disp('Position Synced! ----------------------------------------');