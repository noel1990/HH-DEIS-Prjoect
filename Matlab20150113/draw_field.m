function [] = draw_field()

c1 = [0 0]*2;
c2 = [1600 1200]*2;
c3 = [800 500]*2;
c4 = [800 700]*2;

l1 = [c1;[c1(1) c2(2)];c2;[c2(1) c1(2)];c1];
l2 = [[c3(1) c1(2)];c3];
l3 = [[c4(1) c2(2)];c4];
l4 = [c3(1)-150*2 c3(2);c3(1)+150*2 c3(2)];
l5 = [c4(1)-150*2 c4(2);c4(1)+150*2 c4(2)];

a = linspace(pi/2,3*pi/2,20);
Embarking_L_X = 1300+250*cos(a);
Embarking_L_Y = 1200+250*sin(a);
a = linspace(-pi/2,pi/2,20);
Embarking_R_X = 1900+250*cos(a);
Embarking_R_Y = 1200+250*sin(a);

% DeadZone_R = [2050,1000;2550,900;2550,1500;2050,1400;2050,1000];
% DeadZone_L = [650,1500;650,900;1150,1000;1150,1400;650,1500];

plot(l1(:,1),l1(:,2),'-k');
plot(l2(:,1),l2(:,2),'-k');
plot(l3(:,1),l3(:,2),'-k');
plot(l4(:,1),l4(:,2),'-k');
plot(l5(:,1),l5(:,2),'-k');
plot(Embarking_L_X, Embarking_L_Y, ':b');
plot(Embarking_R_X, Embarking_R_Y, ':b');
% plot(DeadZone_R(:,1),DeadZone_R(:,2),'r:');
% plot(DeadZone_L(:,1),DeadZone_L(:,2),'r:');
axis([-200 1800 -200 1400]*2);

end

