function [angle_list,otherpie_centroid_list,mypie_centroid]=findmypie(spiral_obj,Idx,N,angle_list)

% spiral_obj=[296.376528375068,1339.61243177098,-1.00920365581976;350.111852311757,1356.14716208372,1.05459621566321;535.742977413487,1380.32438994408,3.09542373208194;282,1386,3.13769391434199;336.527690347741,1403.94915035361,-1.05963706434385;489.550727026260,1407.08690957169,-1.07802806979491;568.182034265134,1421.67985574356,1.02958594265084;522.351724249374,1449.05394564441,1.02515259933139];
% Idx=[2;2;1;2;2;1;1;1];
% N=2;


mypie = [];
Distance=[];
pie_id=zeros(N,3);
otherpie_list=cell(N-1,1);
otherpie_centroid = zeros(1,3);
otherpie_centroid_list = [];
mypie_centroid = [];

for i=1:N
    
    spiral_new=[];
    [r,c]=find(Idx(:,1)==i);                  %find the same index
    for j=1:length(r)                           %combine a new matrix
        spiral_new(j,1:3)=spiral_obj(r(j),1:3);
        spiral_new(j,3)=round(spiral_new(j,3));
    end
    
    if size(spiral_new,1)~=4
        otherpie=spiral_new;
        otherpie_list(i,1)=mat2cell(otherpie);
        
    else
        %     pie_data(i,1)=mat2cell(spiral_new);
        [r1,c1]=find(abs(spiral_new(:,3))==3);%find the blue spiral,head
        
        if ~isempty(r1)
            %     if isempty(r1)
            %         pie_id(i,1:3)=specialcase(spiral_new);% can't find the head one
            %         continue;
            %     else
            head_x=spiral_new(r1,1);              %define the blue spiral postion
            head_y=spiral_new(r1,2);
            if length(head_x)>1||length(head_y)>1
                continue;
            end
            if r1~=1;
                spiral_new([1;r1],:)=spiral_new([r1;1],:); %change the line,the head spiral in line
            end
            
            for jj=1:size(spiral_new,1)
                Distance(jj)=sqrt((spiral_new(jj,1)-head_x)^2+(spiral_new(jj,2)-head_y)^2);%caculate the distance
            end
            [r2,c2]=find(Distance==max(Distance)); %find the maximum distance,the tail spiral
            tail_x=spiral_new(c2,1);               %define the tail spiral position
            tail_y=spiral_new(c2,2);
            if c2~=2;
                
                spiral_new([2;c2],:)=spiral_new([c2;2],:); %change the line
            end
            pie_id(i,2)=spiral_new(2,3);                 %the bottom spiral in line 2
            vector_bth=[head_x-tail_x,head_y-tail_y,0]; %vector from tail to head
            % vector_oth1(k,:)=[head_x-spiral_new(k,1),head_y-spiral_new(k,2),0];
            
            
            vector_oth=[head_x-spiral_new(3,1),head_y-spiral_new(3,2),0]; %define the vector one sidesprial(not decide) to head
            theta=cross(vector_bth,vector_oth)/norm(vector_bth)/norm(vector_oth);%define the angle
            
            if theta(1,3)<0     %if sin(angle)<0,means CW,left side,line 3
                pie_id(i,1)=spiral_new(3,3);
                pie_id(i,3)=spiral_new(4,3);
            else               %if sin(angle)>0,means CCW,right side,line 4
                pie_id(i,1)=spiral_new(4,3);
                pie_id(i,3)=spiral_new(3,3);
                spiral_new([4;3],:)=spiral_new([3;4],:); %change the line
            end
           
            
            %substitute -1 to 0
            for j=1:3
                if pie_id(i,j)==-1
                    pie_id(i,j)=0;
                elseif pie_id(i,j)~=1;
                    pie_id(i,j) = 2;
                end
            end
            %give the binary number
            try
                num=bin2dec(strcat(mat2str(pie_id(i,1)),mat2str(pie_id(i,2)),mat2str(pie_id(i,3))));
            catch
                num=100;
            end
            %determine which pie it is
            if num == 3
                mypie=spiral_new;
                mypie(1,4)=num;
                [Idx1, mypie_centroid]= kmeans(mypie(:,1:2), 1,'emptyaction','drop');
                angle=finddirection(mypie(:,1:4));
                angle_list=angle;
            elseif num<100
                otherpie=spiral_new;
                otherpie_list(i,1)=mat2cell(otherpie);
                otherpie(1,4)=num;
                [Idx1, otherpie_centroid(1,1:2)]= kmeans(otherpie(:,1:2), 1,'emptyaction','drop');
%                 angle=finddirection(otherpie(:,1:4));
                
%                 angle_list=[angle_list;angle];
                otherpie_centroid(1,3) = num+1;
                if isempty(otherpie_centroid_list)
                   otherpie_centroid_list =  otherpie_centroid;
                else
                   otherpie_centroid_list=[otherpie_centroid_list;otherpie_centroid];
                end
                otherpie=spiral_new;
                otherpie_list(i,1)=mat2cell(otherpie);
            end
            
        
          
        end
        
    end
end



%give the binary number
% for i=1:N
%
%     otherpie=cell2mat(pie_data(i,1));
%     if num==0&&size(otherpie,1)~=4;
%         continue;
%     elseif num==3
%         %         disp('this is my pie,number 4')
%         mypie=otherpie;
%         mypie(1,4)=num;   %add pie number
%         [Idx, mypie_centroid]= kmeans(mypie(:,1:2), 1,'emptyaction','drop');
%         if length(otherpie_centroid) <2
%             mypie_centroid =[mypie_centroid 0];
%         end
%         angle=finddirection(mypie(:,1:4));
%         angle_list=[angle_list;angle];
%         %         disp(cell2mat(pie_data(i,1)));
%         %         plot(mypie(1,2),mypie(1,1),'*');
%     else
%         %         disp(sprintf('this is pie number: %d',num+1));
%
%         otherpie(1,4)=num;   %add pie number
%         %         disp(otherpie)
%         [Idx,otherpie_centroid]= kmeans(otherpie(:,1:2), 1,'emptyaction','drop');
%         angle=finddirection(otherpie(:,1:4));
%         angle_list=[angle_list;angle];
%         if length(otherpie_centroid) <2
%             otherpie_centroid =[otherpie_centroid 0];
%         end
%         otherpie_centroid = [ otherpie_centroid,num+1];
%         %         disp(otherpie_centroid);
%         %         disp( otherpie_centroid);
%         %         disp(otherpie_centroid_list)
%         otherpie_centroid_list=[otherpie_centroid_list;otherpie_centroid];
%         %         disp(cell2mat(pie_data(i,1)))
%         %         plot(otherpie(1,2),otherpie(1,1),'o');
%         otherpie_list(i,1)=mat2cell(otherpie);
%
%         %   disp(sprintf('the location is %d',))
%     end
% end
%
%
% %
% % try
% %  mypie=mypie;
% %
% % catch expection
% %     if isempty(mypie)
% %         disp(sprintf('can not find my pie'));
% %     else
% %        rethrow(expection)
% %
% %     end
% % end
% end