function[result,point]=checkpoint(p1,p2,q1,q2)

%assume p1 p2 determine line A A1*x+B1*y+C1
%asSume q1 q2 determine line B A2*x+B2*y+C2
%result give 1 or 0
%point give the point is result is 1
result=0;
A1=p2(1,2)-p1(1,2); 
B1=p1(1,1)-p2(1,1);
C1=p2(1,1)*p1(1,2)-p1(1,1)*p2(1,2);

A2=q2(1,2)-q1(1,2);
B2=q1(1,1)-q2(1,1);
C2=q2(1,1)*q1(1,2)-q1(1,1)*q2(1,2);

A=[A1,B1;A2,B2];
B=[-C1;-C2];

point=A\B;

if isreal(point)&&point(2,1)<=1600&&point(1,1)<=1200
    result=1;
else
    result=0;
    
end


end