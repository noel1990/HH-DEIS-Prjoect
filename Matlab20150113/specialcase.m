function pie_id=specialcase(spiral_new)

% spiral_new=[
%     525.7    1136.0   -1
%     604.8    1150.6    1
%     572.6    1105.2   -1];

% plot(572.6,1105.2,'o' )
% hold on
% plot(525.7,1136.0 ,'o' )
% hold on
% plot(604.8,1150.6 ,'o' )
theta=zeros(1,3);

%make the three vector to find the angle
vector_one=[spiral_new(2,1)-spiral_new(1,1),spiral_new(2,2)-spiral_new(1,2)];
vector_two=[spiral_new(3,1)-spiral_new(1,1),spiral_new(3,2)-spiral_new(1,2)];
vector_three=[spiral_new(3,1)-spiral_new(2,1),spiral_new(3,2)-spiral_new(2,2)];

% find the angle between vector
theta(1,1)=subspace(vector_one',vector_two');
theta(1,2)=subspace(vector_one',vector_three');
theta(1,3)=subspace(vector_two',vector_three');
theta_bottom=find(theta==max(theta)); % the largest angle is the bottom spiral
% bottom_spiral=spiral_new(theta_bottom,:); %find the bottom spiral

[IDX,C]=kmeans(spiral_new,1); %find the centroid location
plot(C(1,1),C(1,2),'*')
%
tail_x=spiral_new(theta_bottom,1);
tail_y=spiral_new(theta_bottom,2);
centroid_x=C(1,1);
centroid_y=C(1,2);
pie_id=zeros(1,3);
pie_id(1,2)=spiral_new(theta_bottom,3);
vector_btc=[centroid_x-tail_x,centroid_y-tail_y,0];
for k=1:size(spiral_new,1)
    vector_oth1(k,:)=[centroid_x-spiral_new(k,1),centroid_y-spiral_new(k,2),0];
    vector_oth=[centroid_x-spiral_new(k,1),centroid_y-spiral_new(k,2),0];             %define the vector three spiral to head
    theta1(k,:)=cross(vector_btc,vector_oth)/norm(vector_btc)/norm(vector_oth);%define the angle
    if theta1(k,3)<0     %if sin(angle)<0,means CW,left side
        pie_id(1,1)=spiral_new(k,3);
    elseif theta1(k,3)>0 %if sin(angle)>0,means CCW,right side
        pie_id(1,3)=spiral_new(k,3);
    else
        continue;
    end
 
end   
    
    
    