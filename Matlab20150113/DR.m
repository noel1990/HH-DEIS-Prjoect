 function [] = DR(CPC,R)
theta = 0:pi/20:2*pi;
x = CPC(1,1)+R*sin(theta);
y = CPC(1,2)+R*cos(theta);
plot(x,y,'*r')