function [] = draw_robot( P, a, col_info )

r = 128;
l1 = 1:r;
for kk = 1:r
    l1(kk,1:2) = P+[cos(kk*2*pi/r) sin(kk*2*pi/r)]*65*2;
end
l1(end+1,:) = l1(1,:);

l2 = [P;P+[cos(a) sin(a)]*65*2];

if col_info == -1
    plot( l1(:,1), l1(:,2),'-k','linewidth',2 );
    plot( l2(:,1), l2(:,2),'-k','linewidth',2 );
elseif col_info == -2
    plot( l1(:,1), l1(:,2),'-c','linewidth',2 );
    plot( l2(:,1), l2(:,2),'-c','linewidth',2 );
elseif col_info == -3
    plot( l1(:,1), l1(:,2),'-m','linewidth',2 );
    plot( l2(:,1), l2(:,2),'-m','linewidth',2 );
else
    plot( l1(:,1), l1(:,2),'-b','linewidth',2 );
    plot( l2(:,1), l2(:,2),'-b','linewidth',2 );
end

Sensor_Posi_Angle = 34;

Prox_1 = P + [cos(a+Sensor_Posi_Angle*pi/180) sin(a+Sensor_Posi_Angle*pi/180)]*114;
Prox_2 = P + [cos(a-Sensor_Posi_Angle*pi/180) sin(a-Sensor_Posi_Angle*pi/180)]*114;



Prox_Max_Ang = 40*pi/180;
n = 10;
Sensor_Face_Angle = 25;

Prox_Ang_1 = linspace(a+Sensor_Face_Angle*pi/180-Prox_Max_Ang/2, a+Sensor_Face_Angle*pi/180+Prox_Max_Ang/2, n);
Prox_Ang_2 = linspace(a-Sensor_Face_Angle*pi/180-Prox_Max_Ang/2, a-Sensor_Face_Angle*pi/180+Prox_Max_Ang/2, n);

for kk=1:n
    Prox_1_Range_n(kk,:) = Prox_1 + 100*[cos(Prox_Ang_1(kk)) sin(Prox_Ang_1(kk))];
    Prox_1_Range_f(kk,:) = Prox_1 + 800*[cos(Prox_Ang_1(kk)) sin(Prox_Ang_1(kk))];
    
    Prox_2_Range_n(kk,:) = Prox_2 + 100*[cos(Prox_Ang_2(kk)) sin(Prox_Ang_2(kk))];
    Prox_2_Range_f(kk,:) = Prox_2 + 800*[cos(Prox_Ang_2(kk)) sin(Prox_Ang_2(kk))];
end


switch col_info
    case 0
        plot(Prox_1(1), Prox_1(2),'g.');
        plot(Prox_2(1), Prox_2(2),'g.');

        plot(Prox_1_Range_n(:,1),Prox_1_Range_n(:,2),'g');
        plot(Prox_1_Range_f(:,1),Prox_1_Range_f(:,2),'g');
        plot([Prox_1_Range_n(1,1) Prox_1_Range_f(1,1)],[Prox_1_Range_n(1,2) Prox_1_Range_f(1,2)],'g');
        plot([Prox_1_Range_n(end,1) Prox_1_Range_f(end,1)],[Prox_1_Range_n(end,2) Prox_1_Range_f(end,2)],'g');

        plot(Prox_2_Range_n(:,1),Prox_2_Range_n(:,2),'g');
        plot(Prox_2_Range_f(:,1),Prox_2_Range_f(:,2),'g');
        plot([Prox_2_Range_n(1,1) Prox_2_Range_f(1,1)],[Prox_2_Range_n(1,2) Prox_2_Range_f(1,2)],'g');
        plot([Prox_2_Range_n(end,1) Prox_2_Range_f(end,1)],[Prox_2_Range_n(end,2) Prox_2_Range_f(end,2)],'g');
    case 1
        plot(Prox_1(1), Prox_1(2),'r.');
        plot(Prox_2(1), Prox_2(2),'g.');

        plot(Prox_1_Range_n(:,1),Prox_1_Range_n(:,2),'r');
        plot(Prox_1_Range_f(:,1),Prox_1_Range_f(:,2),'r');
        plot([Prox_1_Range_n(1,1) Prox_1_Range_f(1,1)],[Prox_1_Range_n(1,2) Prox_1_Range_f(1,2)],'r');
        plot([Prox_1_Range_n(end,1) Prox_1_Range_f(end,1)],[Prox_1_Range_n(end,2) Prox_1_Range_f(end,2)],'r');

        plot(Prox_2_Range_n(:,1),Prox_2_Range_n(:,2),'g');
        plot(Prox_2_Range_f(:,1),Prox_2_Range_f(:,2),'g');
        plot([Prox_2_Range_n(1,1) Prox_2_Range_f(1,1)],[Prox_2_Range_n(1,2) Prox_2_Range_f(1,2)],'g');
        plot([Prox_2_Range_n(end,1) Prox_2_Range_f(end,1)],[Prox_2_Range_n(end,2) Prox_2_Range_f(end,2)],'g');
    case 2
        plot(Prox_1(1), Prox_1(2),'g.');
        plot(Prox_2(1), Prox_2(2),'r.');

        plot(Prox_1_Range_n(:,1),Prox_1_Range_n(:,2),'g');
        plot(Prox_1_Range_f(:,1),Prox_1_Range_f(:,2),'g');
        plot([Prox_1_Range_n(1,1) Prox_1_Range_f(1,1)],[Prox_1_Range_n(1,2) Prox_1_Range_f(1,2)],'g');
        plot([Prox_1_Range_n(end,1) Prox_1_Range_f(end,1)],[Prox_1_Range_n(end,2) Prox_1_Range_f(end,2)],'g');

        plot(Prox_2_Range_n(:,1),Prox_2_Range_n(:,2),'r');
        plot(Prox_2_Range_f(:,1),Prox_2_Range_f(:,2),'r');
        plot([Prox_2_Range_n(1,1) Prox_2_Range_f(1,1)],[Prox_2_Range_n(1,2) Prox_2_Range_f(1,2)],'r');
        plot([Prox_2_Range_n(end,1) Prox_2_Range_f(end,1)],[Prox_2_Range_n(end,2) Prox_2_Range_f(end,2)],'r');
    case 3
        plot(Prox_1(1), Prox_1(2),'r.');
        plot(Prox_2(1), Prox_2(2),'r.');

        plot(Prox_1_Range_n(:,1),Prox_1_Range_n(:,2),'r');
        plot(Prox_1_Range_f(:,1),Prox_1_Range_f(:,2),'r');
        plot([Prox_1_Range_n(1,1) Prox_1_Range_f(1,1)],[Prox_1_Range_n(1,2) Prox_1_Range_f(1,2)],'r');
        plot([Prox_1_Range_n(end,1) Prox_1_Range_f(end,1)],[Prox_1_Range_n(end,2) Prox_1_Range_f(end,2)],'r');

        plot(Prox_2_Range_n(:,1),Prox_2_Range_n(:,2),'r');
        plot(Prox_2_Range_f(:,1),Prox_2_Range_f(:,2),'r');
        plot([Prox_2_Range_n(1,1) Prox_2_Range_f(1,1)],[Prox_2_Range_n(1,2) Prox_2_Range_f(1,2)],'r');
        plot([Prox_2_Range_n(end,1) Prox_2_Range_f(end,1)],[Prox_2_Range_n(end,2) Prox_2_Range_f(end,2)],'r');
    otherwise
        
end



end

