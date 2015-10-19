function [] = sendCoords( x, y, EndA, coord_type)
global COM_1;
%s = serial('COM1','BaudRate',115200,'DataBits',8,'StopBits',1);
%fopen(s);

for kk = 1:size(x,2)
    data = zeros(1,9);
    data(1) = coord_type;
    data(2) = bitshift(x(kk)+1000,-8);
    data(3) = mod(x(kk)+1000,256);
    data(4) = bitshift(y(kk)+1000,-8);
    data(5) = mod(y(kk)+1000,256);
    if coord_type == 1
        data(6) = bitshift(EndA(kk)+180 , -8);
        data(7) = mod(EndA(kk)+180 , 256);
        %        data(8) = bitshift(x(kk)+y(kk)+EndA(kk)+2180,-8);
        %        data(9) = mod(x(kk)+y(kk)+EndA(kk)+2180,256);
        data(8) = mod(x(kk)+y(kk)+EndA(kk)+2180,256);
    %data(8) = mod(data(1)+data(2)+data(3)+data(4)+data(5)+data(6)+data(7),256);
    elseif coord_type == 0
        data(6) = bitshift(EndA(kk), -8);        
        data(7) = mod(EndA(kk), 256);
        data(8) = mod(x(kk)+y(kk)+EndA(kk)+2000,256);
    %data(8) = mod(data(1)+data(2)+data(3)+data(4)+data(5)+data(6)+data(7),256);        
    end
    str = '';
    %   disp(data);
    for jj = 1:9
        t = dec2hex(data(jj),2);
        str = [str t ' '];
    end
    %    str = [str '\n\r'];
    str = [str '\n\r'];
    disp('Sent out msg.');
    msg = [coord_type x y EndA];
    disp(msg);
    
%     plot(x,y,'*g');hold on;
%     xlim([0 400]);
%     ylim([0 300]);
    %    fprintf(s,'%s',str );
%     if coord_type == 1
     fprintf(COM_1,'%s',str );
%     end
end

%fclose(s);



end
