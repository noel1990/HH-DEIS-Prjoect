 function theta=define_end_angle(startpoint,endpoint)
% 
% startpoint=[50,50];
% endpoint=[100,0];
%find the direction vector
D_vector=[endpoint(1,1)-startpoint(1,1),endpoint(1,2)- startpoint(1,2),0];
S_vector=[1,0,0];
%cacluate the degree by diveide into 4 areas
if D_vector(1,2)<=0&&D_vector(1,1)<=0
    %translate to degree
    theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
    theta=90+(rad2deg(theta))-180;
%     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));
  
elseif D_vector(1,2)<=0&&D_vector(1,1)>0
    theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
    theta=(rad2deg(theta)-90)+180;
%     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));

elseif D_vector(1,2)>=0&&D_vector(1,1)<=0
    theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
    theta=90+(rad2deg(theta))-180;
%     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));

elseif D_vector(1,2)>=0&&D_vector(1,1)>0
    theta=atan(cross(S_vector,D_vector)/sum(S_vector.*D_vector));
    theta=(rad2deg(theta))-90+180;
%     disp(sprintf('the direction of number %d pie is: %d',spiral_obj(1,4)+1,round(theta(1,3))));

end

end

