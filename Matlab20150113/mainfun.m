% % %
% clc;
% T=timer('TimerFcn',@C_Avoidance,'StartFcn',@mainfun,'ExecutionMode','fixedDelay','Busymode','drop','Period',0.3);
%
% start(T);
%
% while(1)
% pause(0.5)

%  clc;
% % %  clear;
%function [parameter]=mainfun(parameter)
% % for kk=1:100
 function []=mainfun(obj,event,parameter)

tic;
% disp('image analysis start');
% empty=load ('empty.mat');
% empty = double(rgb2gray(empty.empty));
% empty = conv2(empty,ones(1,10),'same');
% empty = conv2(empty,ones(10,1),'same');
%
% %initial
% Ncm=7; Nch=(Ncm-1)/2;
% colmask=ones(Ncm,1)*[-Nch:Nch]; % rowmask=reshape(rowmask, [Ncm*Ncm,1]);rowmask=rowmask';
% rowmask=[-Nch:Nch]'*ones(1,Ncm); %colmask=reshape(colmask, [Ncm*Ncm,1]);colmask=colmask';
%
% sma1=(0.75)/2; %0.75
% dx=gaussgen(sma1,'dxg',[1,round(sma1*6)]);
% gx=gaussgen(sma1,'gau',[1,round(sma1*6)]);
% gy=gx';
% dy=-dx';
%
% sma2=(16)/2;
% sma=[sma1,sma2];
% typ=2; sm=double(-sma2); gammaf=50;
% % ...if sm is negative then symdergaussgen interprets it as the radius
% %   that we wish that the max filter values will occur (instead of standard
% %   deviation.
% h2=symdergaussgen(typ,sm,gammaf);
% %            [i,j,s] = find(h2);
% %                [m,n] = size(h2);
% %                h2 = sparse(i,j,s,m,n);
% scaling=['sclon'];
% gamma=0.08;
% thresh=0.4;
otherpie_list=[];
mypie_list=[];
angle_list=[];
otherpie_centroid_list=[];
mypie_centroid=[];
filterlist = [];
closest_pie_centriod = [];




for k=1:1
    imrgb=imread('http://ideax3.hh.se/axis-cgi/jpg/image.cgi?resolution=1600x1200');
    % imrgb=double(imrgb);
    %
    % [qmp num] = bwlabel(imrgb);
    % figure(5);imshow(imrgb); axis image; truesize
    %
    %
    %save empty.mat imrgb
    % %  roi is the full image
    
    img = double( imrgb(:,:,2) );
    % Region Of Interest, roi, is in the order: rowTL,colTL,rowBR, colBR
    % % find the ROI, translate rgb 2 gray
    imgray = double(rgb2gray(imrgb));
    imgray=double(imgray);
    smooth = ones(1,10);
    imgray = conv2(imgray,smooth,'same');
    imgray = conv2(imgray,smooth','same');
    imgray = abs(parameter.empty-imgray);
    
    m = max(max(imgray));
    me = mean(mean(imgray));
    dme = m-me;
    %disp(dme);
    if(dme < 1500)
        roi = [];
        errim = imgray;
        break;
    end
    
    imgray = imgray/m;
    errim = imgray;
    
    imgray = imgray > 0.2; % THRESHOLD
    imgray = imdilate(imgray,ones(10,10));
    
    [imlab, num] = bwlabel(imgray,4);
    
    if num<=1;
        continue;
    end
    roilist = [];
    
    for i=1:num
        [x_start,x_end,y_start,y_end]=Areafind(imlab,i);
        if( x_end-x_start > 50 && y_end-y_start > 50 )
            roilist(end+1, 1:4) = [x_start x_end y_start y_end];
        end
    end
    
    
    for j=1:size(roilist,1)
        x_start=roilist(j,1);
        x_end=roilist(j,2);
        y_start=roilist(j,3);
        y_end=roilist(j,4);
        
        %         %                   hold on;
%         R=rectangle('position',[x_start,y_start, x_end-x_start, y_end-y_start]);
        % %
        
        
        
        mrect=[x_start,y_start, x_end-x_start, y_end-y_start];
        roi=mrect;
        botr=roi(1:2)+roi(3:4)-1;
        roi=[roi(1:2),botr];
        roi=[roi(2),roi(1),roi(4),roi(3)];
        roi_imrgb=imrgb(roi(1):roi(3),roi(2):roi(4),:);
        roi_im=roi_imrgb(:,:,2);
        inimg = double(roi_im);
        
%         
%         inimg = img( y_start:y_end, x_start:x_end);
%         roi = inimg;
        
        
        [spiral_obj_roi,I20nmxs,I20]=spiral_detection_buf(inimg,parameter.sma,parameter.scaling,parameter.gamma,parameter.dx,parameter.gx,parameter.dy,parameter.gy,parameter.h2,parameter.rowmask,parameter.colmask,parameter.thresh);
        
        spiral_obj=[];
        if size(spiral_obj_roi,1)>0
            spiral_obj=[roi(1)+spiral_obj_roi(:,1)-1,roi(2)+spiral_obj_roi(:,2)-1,spiral_obj_roi(:,3)];
        end
        
        %         for i=1:size(spiral_obj,1)
        %             plot(spiral_obj(i,2),spiral_obj(i,1),'o')
        %             hold on;
        %         end
        
        location = [];
        location = [spiral_obj(:,2), spiral_obj(:,1)];
        
        try
            if size(spiral_obj_roi,1)>0
                imrgb(:,:,2)=mark_obj(imrgb(:,:,2),spiral_obj);
                
                %Number of spiral objects
                Number_of_spiral_obj=size(spiral_obj,1);
            end
        catch
            Number_of_spiral_obj=size(spiral_obj,1);
        end
        
        N=ceil(Number_of_spiral_obj/4);
        [Idx, c]= kmeans(location, N,'emptyaction','drop');
        
        [mypie,otherpie,angle_list,otherpie_centroid_list,mypie_centroid]=findmypie(spiral_obj,Idx,N,angle_list,otherpie_centroid_list,mypie_centroid);
        otherpie_list=[otherpie_list;otherpie];
        mypie_list=[mypie_list;mypie];
        
        
    end
    
    
    
    if isempty(mypie_list)
        disp(sprintf('my pie is not in the area'));
    end
    
    if isempty(otherpie_list)
        disp(sprintf('otherpie is not in the area'));
        
    end
    
    
%     figure(5);imshow(imrgb); axis image; truesize
    %     figure(1);
    %     clf;
    %     imagesc(errim);colormap('gray'); % Display original image
    %
    %     axis equal;
    %     hold on;
    %     axis([0 800 0 600]);
    %     set(gca,'YDir','reverse');
    %     hold on;
%             try
%                 text(mypie_list(1,2)+10,mypie_list(1,1)+10,'\leftarrow my pie,4','Color','red');
%             catch
%                 text(10,60,'my pie undefine','Color','green')
%             end
%     
%     
%             for i=1:size(otherpie_list,1)
%                 op=cell2mat(otherpie_list(i,1));
%     
%                 hold on
%                 if ~isempty(op)&&size(op,2)==4 %          disp(op)
%                     text(op(1,2)+10,op(1,1)+10,sprintf('%d',op(1,4)+1),'Color','white');
%                 else
%                     text(30,10,'undefine place','Color','green')
%                 end
%             end
    
    %     if obj.UserData == 1
    %         waypoint=splineread();  %update list
    %     end
    % filter otherpie_list
    if ~isempty(mypie_list)&&~isempty(otherpie_centroid_list)
        filternum = otherpie_centroid_list(:,3)- 50;
        ind = find(filternum<0);
        
        for i = 1:size(ind)
            filterlist(i,:) = otherpie_centroid_list(ind(i),:);
        end
        
        
        Distance_list=[];
        
        %find the closest pie to my next point
        for i=1:size(filterlist,1)
            Distance_pie = Cal_Distance(mypie_centroid(1,1:2),filterlist(i,1:2));
            Distance_num=[Distance_pie,filterlist(i,3)];
            Distance_list=[Distance_list;Distance_num];
            
            
            
            
            
            
            if ~isempty(Distance_list)
                %             if min(Distance_list(:,1))>=0&& min(Distance_list(:,1))<=100
                [r,c]=find(Distance_list(:,1)==min(Distance_list(:,1)));
                closest_pie=filterlist(r);
                closest_pie_centriod = filterlist(r,:);
                %                 disp(closest_pie_centriod);
                
                %                 [Next_point1]=C_Avoidance2(closest_pie_centriod,parameter.next_point);
                %                 disp(Next_point1);
                %
                %             else
                %                 closest_pie=[];
                %                 disp(waypoint(num,1));
                %
                %             end
                
            else
                closest_pie_centriod=[0 0 0];
                %                 disp(closest_pie_centriod);
            end
            
            
            
            %     C_Avoidance(mypie_list,closest_pie);
        end
        
        
        
        
    end
    
    
    
    try
        c=find(angle_list(:,2)==4);
        Angle=angle_list(c,1);
    catch
        Angle=[];
    end
    
    % parameter.Anglepre = fullfil(Angle,parameter.Anglepre);
    % parameter.mypie_centroid_pre = fullfil( mypie_centroid,parameter.mypie_centroid_pre);
    % parameter.closest_pie_centriod_pre = fullfil( closest_pie_centriod ,parameter.closest_pie_centriod_pre);
    % Anglepre = parameter.Anglepre ;
    % mypie_centroid_pre = parameter.mypie_centroid_pre;
    % closest_pie_centriod_pre = parameter.closest_pie_centriod_pre;
    %
    % if isempty(Angle)||isempty(mypie_centroid)||isempty(closest_pie_centriod)
    %     %     disp(['stop time is :' datestr(event.Data.time)])
    %     %     obj.UserData = 'stop';
    %     %     disp(parameter.closest_pie_centriod_pre);
    %     %     disp(parameter.Anglepre );
    %     %     disp(parameter.mypie_centroid_pre);
    %     error('empty data!')
    % end
    % %
    
    
    disp(closest_pie_centriod);
%     if isempty(closest_pie_centriod)
%         closest_pie_centriod = [];
%          disp(closest_pie_centriod);
%     end
    
    disp(mypie_centroid);
%     if isempty(mypie_centroid)
%         mypie_centroid = [];
%         disp(mypie_centroid);
%     end
    
%     disp(Angle);
    
    time_img = java.lang.System.currentTimeMillis();
    %     obj.userdata=[Angle mypie_centroid closest_pie_centriod time];
    
     save format.mat Angle mypie_centroid  closest_pie_centriod  time_img
         
    toc;
end







