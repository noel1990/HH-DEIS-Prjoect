function direction=finddirection(spiral_obj)
% clc;
% clear;
%
% spiral_obj=[748.545771328668 1098.90653744264 -3.10030850065096;803.621862249509 1108.96652512033 -1.00160062688929;736.692224175380 1153.12810298163 1.09928986288227;791.644541838091 1161.97423624922 0.998262851298348];
% for i=1:4
%     hold on
%     plot(spiral_obj(i,2),spiral_obj(i,1),'*')
%
% end
spiral_obj(:,3)=round(spiral_obj(:,3));
%x aiex is stand_vector
S_vector=[1,0,0];
%find the head
[r1,c1]=find(abs(spiral_obj(:,3))==3);
head_x=spiral_obj(r1,1);              %define the blue spiral postion
head_y=spiral_obj(r1,2);
% plot(spiral_obj(r1,2),spiral_obj(r1,1),'o')
% find the bottom
for i=1:size(spiral_obj,1)
    try
        Distance(i)=sqrt((spiral_obj(i,1)-head_x)^2+(spiral_obj(i,2)-head_y)^2);%caculate the distance
    catch
        Distance(i)=0;
        continue;
        
    end
end

[r2,c2]=find(Distance==max(Distance)); %find the maximum distance,the tail spiral
tail_x=spiral_obj(c2,1);               %define the tail spiral position
tail_y=spiral_obj(c2,2);

%find the direction vector
try
D_vector=[head_x-tail_x,head_y-tail_y,0];
catch
    D_vector=[];
end
%cacluate the degree by diveide into 4 areas
try
    if D_vector(1,2)<=0&&D_vector(1,1)<=0
        %translate to degree
        theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
        theta=90+(rad2deg(theta))-180;
        %     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));
        direction(1,1:2)=[round(theta(1,3)),spiral_obj(1,4)+1];
    elseif D_vector(1,2)<=0&&D_vector(1,1)>0
        theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
        theta=(rad2deg(theta)-90)+180;
        %     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));
        direction(1,1:2)=[round(theta(1,3)),spiral_obj(1,4)+1];
    elseif D_vector(1,2)>=0&&D_vector(1,1)<=0
        theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
        theta=90+(rad2deg(theta))-180;
        %     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));
        direction(1,1:2)=[round(theta(1,3)),spiral_obj(1,4)+1];
    elseif D_vector(1,2)>=0&&D_vector(1,1)>0
        theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
        theta=(rad2deg(theta))-90+180;
        %     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));
        direction(1,1:2)=[round(theta(1,3)),spiral_obj(1,4)+1];
    end
catch
    direction(1,1:2)=100;
end
% if spiral_obj(1,4)==3
%     angle=round(theta(1,3));
%     save ('angle.mat','angle');
%
% end
end










