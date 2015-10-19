function [] = draw_robot2( P, a ,color)

% Robot diameter is 260mm
% Scale is 1/2 so 130
% Radius is 65

r = 160;
l1 = 1:r;
for kk = 1:r
    l1(kk,1:2) = P+[cos(kk*2*pi/r) sin(kk*2*pi/r)]*130;
end
l1(end+1,:) = l1(1,:);

l2 = [P;P+[cosd(a) sind(a)]*130];
col_str=strcat('-',color);
plot( l1(:,1), l1(:,2),col_str );
plot( l2(:,1), l2(:,2),col_str );

end

