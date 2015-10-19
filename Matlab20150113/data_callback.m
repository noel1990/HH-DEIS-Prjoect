function data_callback(obj,event)
% DGI_data_callback
global Rec;
global COM_1;
global Pie_curx;
global Pie_cury;
global Pie_cura;
global Pie_curv;
global Pie_col_info;
global odo_pos_buffer;
global data_counter;
input_line = fgetl(COM_1);

%'00 01 02 03 04 05 06 07 \r\n'
%length 24
%split 1x9cells
%disp('Received curposition msg.');
%disp(input_line);
% Todo
% Do something with Data
if length(input_line) == 24%check the length
    split_input = regexp(input_line,' ','split');
    if length(split_input) == 9
        %disp(input_line);
        for k=1:8
            tmp(k) = hex2dec(strtrim(split_input{k}));
        end
        checksum = mod(tmp(1)+tmp(2)+tmp(3)+tmp(4)+tmp(5)+tmp(6)+tmp(7),256);
        %disp([tmp(10) checksum]);
        if checksum == tmp(8)
            %msg_type = tmp(1);
            %msg_nbr = tmp(2);
            Pie_col_info = tmp(1);
            Pie_curx = tmp(2)*256+tmp(3)-1000;
            Pie_cury = tmp(4)*256+tmp(5)-1000;
            Pie_cura = tmp(6)*360/255-180;
            Pie_curv = tmp(7);
            %record the odometery time
            time_odo = java.lang.System.currentTimeMillis;
            odo_pos_buffer(1:end-1,:) = odo_pos_buffer(2:end,:);
            odo_pos_buffer(end,:) = [Pie_curx Pie_cury Pie_cura time_odo];
            data_counter=data_counter+1;
            %            sendpoints(Pie_curx, Pie_cury, Pie_cura);
            disp('Received curposition msg.');
            str = [Pie_col_info Pie_curx Pie_cury Pie_cura Pie_curv];
            disp(str);
            figure(1);
%             cla;
%             xlim([0 4000]);
%             ylim([0 3000]);           
%             P=[Pie_curx,Pie_cury];
%             draw_robot2(P,Pie_cura,'b');
%             hold on;
            %             plot(Pie_curx,Pie_cury,'*b');
            %v = tmp(7);%not included
            %                 disp(input_line);
            Rec = 1;
        else
            disp('Something error!!!');
            
        end
    end
end