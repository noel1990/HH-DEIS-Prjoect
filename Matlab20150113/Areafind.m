function[x_start,x_end,y_start,y_end]=Areafind(imlab,num)



% [r,c]=find(imlab==num);
% x_start=r(1);
% y_start=c(1);
% 
% x_end=r(end);
% y_end=c(end);
im = imlab == num;
cols = sum(im,1) > 0;
rows = sum(im,2) > 0;

x_start = find(cols,1,'first');
x_end = find(cols,1,'last');

y_start = find(rows,1,'first');
y_end = find(rows,1,'last');


end