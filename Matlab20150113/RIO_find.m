function out=RIO_find(mypie,otherpie)

ylim=100;
xlim=100;
detection_count=1;
% detection=0;
Rc=zeros(1,2);
%define the ROI area
%find if has other spiral in the area
while(1)
    toc;
    if mypie(1,4)~=3
        out=1;
        break;
    end
    
    
    if detection_count==3
        ylim=100;
        xlim=100;
        detection_count=1;
    end
    pause(0.01);
    imrgb=imread('http://ideax3.hh.se/axis-cgi/jpg/image.cgi?resolution=800x600');
    [Idx,c]=kmeans(mypie,1);
    
    figure(5);imshow(imrgb); axis image;
    
    
    
    recal=1;
    
    %four concor and line limit
    if c(1,1)+xlim>=600  %x limit<1600 and two cornor
        Rc(1,1)=600-2*xlim;
        if c(1,2)-ylim<=1
            Rc(1,2)=1;
            recal=0;
        elseif c(1,2)+ylim>=800
            Rc(1,2)=800-2*ylim;
            recal=0;
        else
            Rc(1,2)=c(1,2)-ylim;
        end
        
    elseif c(1,1)-xlim<=1  %x limit>0 and two cornor
        Rc(1,1)=1;
        if c(1,2)-ylim<=1
            Rc(1,2)=1;
            recal=0;
        elseif c(1,2)+ylim>=800
            Rc(1,2)=800-2*ylim;
            recal=0;
        else
            Rc(1,2)=c(1,2)-ylim;
        end
        
        
        
    elseif c(1,2)-ylim<=1&&recal     %ylimit>0
        Rc(1,2)=1;
        Rc(1,1)=c(1,1)-xlim;
        
        
    elseif c(1,2)+ylim>=800&&recal   % ylimit<1200
        Rc(1,2)=800-2*ylim;
        Rc(1,1)=c(1,1)-xlim;
        
    else
        Rc(1,1)=c(1,1)-xlim;
        Rc(1,2)=c(1,2)-ylim;
    end
    
    mrect=[Rc(1,2),Rc(1,1),2*xlim,2*ylim];
    hold on;
    R=rectangle('position',[Rc(1,2),Rc(1,1),2*xlim,2*ylim]);
    thresh=0.4;
    
    
    
    roi=mrect;
    botr=roi(1:2)+roi(3:4)-1;
    roi=[roi(1:2),botr];
    roi=[roi(2),roi(1),roi(4),roi(3)];
    roi_imrgb=imrgb(roi(1):roi(3),roi(2):roi(4),:);
    roi_im=roi_imrgb(:,:,2);
    % figure(1);imshow(roi_imrgb ); truesize
    
    
    %Initialization: produce centroid masks (rowmask and colmask)
    Ncm=8; Nch=(Ncm-1)/2;
    colmask=ones(Ncm,1)*[-Nch:Nch]; % rowmask=reshape(rowmask, [Ncm*Ncm,1]);rowmask=rowmask';
    rowmask=[-Nch:Nch]'*ones(1,Ncm); %colmask=reshape(colmask, [Ncm*Ncm,1]);colmask=colmask';
    
    
    %initialization: spiral detection
    %generate 4 1D derivative filters and a 2D complex filter.
    sma1=(0.75)/2; %0.75
    dx=gaussgen(sma1,'dxg',[1,round(sma1*6)]);
    gx=gaussgen(sma1,'gau',[1,round(sma1*6)]);
    dy=-dx';
    gy=gx';
    
    sma2=(16)/2;
    sma=[sma1,sma2];
    typ=2; sm=double(-sma2); gammaf=50;
    
    % ...if sm is negative then symdergaussgen interprets it as the radius
    %   that we wish that the max filter values will occur (instead of standard
    %   deviation.
    h2=symdergaussgen(typ,sm,gammaf);
    %            [i,j,s] = find(h2);
    %                [m,n] = size(h2);
    %                h2 = sparse(i,j,s,m,n);
    scaling=['sclon'];
    gamma=0.01;
    % Info=['....ENTERING ROI COMPUTATIONS....ENTERING ROI COMPUTATIONS....ENTERING ROI COMPUTATIONS...']
    
    ptime=[];
    tic
    %DETECT spiral objects.
    [spiral_obj_roi,I20nmxs,I20]=spiral_detection_buf(double(roi_im),sma,scaling,gamma,dx,gx,dy,gy,h2,rowmask,colmask,thresh);
    spiral_obj=[];
    if size(spiral_obj_roi,1)>0
        spiral_obj=[roi(1)+spiral_obj_roi(:,1)-1,roi(2)+spiral_obj_roi(:,2)-1,spiral_obj_roi(:,3)];
    end
    ptime=[ptime toc];
    
    
    if size(spiral_obj_roi,1)>0
        imrgb(:,:,2)=mark_obj(imrgb(:,:,2),spiral_obj);
        
        Number_of_spiral_obj=size(spiral_obj,1);
    end
    
    
    
    % figure(5);imshow(imrgb); axis image;
    
    for i=1:size(spiral_obj,1)
        hold on
        plot(spiral_obj(i,2),spiral_obj(i,1),'o')
    end
    
    location = zeros(size(spiral_obj, 1), 2);
    location = [spiral_obj(:,2), spiral_obj(:,1)];
    
    headnum=length(find(round(abs(spiral_obj(:,3)))==3));
    
    %if the number of sporal lss than 4,break, scan the whole area
    %if the number of spiral is 4, continue;
    %if the number of spiral more than 4, but num~=head*4,expand the area
    %if the number of sprral more than 4, num==head*4,anaylse
    direction=[];
    if Number_of_spiral_obj<4 || Number_of_spiral_obj>30         %out of area,not pie nearby
        out=1;
        break;
        
    elseif Number_of_spiral_obj==4                           % out of area, some pie nearby
        [Idx, c]= kmeans(location, 1);                          
        N=ceil(size(spiral_obj,1)/4);
        [mypie,otherpie]=findmypie(spiral_obj,Idx,N);
        if isempty(mypie)                                     
            mypie=cell2mat(otherpie(1,1));
            continue;
        else
            direction(1,1:2)=finddirection(mypie);
            continue;
        end
    elseif Number_of_spiral_obj~=4*headnum                  %detect some pie is coming
        ylim=ylim+50;
        xlim=xlim+50;
        detection_count=detection_count+1;
        
        continue;
        
    elseif Number_of_spiral_obj==4*headnum
        N=ceil(size(spiral_obj,1)/4);                      %define the number of pie
        mark=1;
        time=3;
        while(mark)
            time=time-1;
            [Idx, c]= kmeans(location, N);
            mark=0;
            u=unique(Idx);
            for i=1:length(u)
                cluter=length(find(Idx==u(i)));
                
                if cluter~=4
                    mark=1;
                    break;
                end
            end%
            if time==1                               %separate three time no decision
               break;
            end
        end
        
        if time==1                                  % restart
            continue;
        end
        hold on
        % for i = 1: size(c, 1)
        %    plot(c(i,1), c(i,2), '*');
        %
        % end
        %
        % hold on
        %find the centroid of my pie
        [mypie,otherpie]=findmypie(spiral_obj,Idx,N);
        
        %find the direction of my pie
        
%         direction(1,1:2)=finddirection(mypie);
        
        
        
        
        
        %find the direction of other pie
        for i=1:size(otherpie,1)
            p=cell2mat(otherpie(i,1));
            if ~isempty(p)
                direction(i+1,1:2)=finddirection(p);
            end
        end
        
        %collsion avoidance estimation
        C_Avoidance(mypie,otherpie);
        delete(R);
    else
        %         detection=0;
        continue;
    end
    %     detection=0;
    %  figure(2);I20rgb=lsdisp(I20,3,'sclon'); %truesize; axis off
    %   crp2=round(crp/2);
    %   imwrite(I20rgb(crp2(1):crp2(2),crp2(3):crp2(4),:), 'images/I20rgb.tiff');
    tic;
    %   figure(6);imshow(I20nmxs); truesize; axis image
end
end