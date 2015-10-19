
%imrgb=imread('images/spirals2.jpg');
%%The following matlab rectangles are obtained by mrect=getrect()  
% A matlab rectangle has the order: x,y,xsize,ysize...
%%CAUTION: There is a bug in getrect. it may return xs,ys that can be too large.
% mrect =[1    16   140   115];  
% mrect =[640     2   123   185]; 
% mrect =[  1   456    87   143];
% mrect =[716   454    84   146];

%imrgb is the full input image
%This is how to read directly from the axis camera watching the robots.
%When ready use it. 
%imrgb=imread('http://ideax3.hh.se/axis-cgi/jpg/image.cgi?resolution=1600x1200');
imrgb=imread('images/two_pies_different_freq.jpg'); 
%imrgb=imread('images/imageBit.bmp');
%imrgb=imread('images/group2-png-old/im1605-23.png');
%imrgb=imread('images\group5\Images(Group 5)\images(9.33 am)\images(8 am)\01.jpeg');

%IF YOU carefuly look at the labels of the two pies in the image, you will
%see that they have different number of "arms". This is on purpose to
%illustrate the effect of the treshold, roi, etc. Your spirals look like
%the spirals of the pie-robot at the bottom. Zoom in the full (resulting) image to see if
%the spirals are found (marked). Due to down-sampling of matlab images,
%some  marker-crosses may not be visible (though they are there) at the
%screen resolution of the full-image (which is higher in resolution).

%1. roi is the full image
mrect =     [1    1   size(imrgb,2) size(imrgb,1)]; thresh=0.3;%entire image as rectangle...

%2. roi is a rectangle containing the top pie-robot...
% mrect=[ 1205    121    286    301]; thresh=0.4;  %Notice we now can  lower 
                                                 %threshold to allow full
                                                 %detection even if the spiral 
                                                 %certainty is low for one
                                                 %spiral. This is because
                                                 %our Threshold is relative, that is, if the maximum
                                                 %of |I20| occuring in the
                                                 %roi is I20max, the actual
                                                 %threshold used to isolate spiral-center (blobs) is
                                                 %thresh*I20max. It  means
                                                 %that reducing the size of
                                                 %roi helps in that we 
                                                 %reduce I20max compared to
                                                 %having found it from full image as roi, where a higher I20max risk to occur.
                                                 %HOWEVER, IF CHANGING THRESHOLD
                                                 %DECREASES FALSE ACCEPTANCE
                                                 %ERRORS (FA), IT ALWAYS WORSENS (INCREASES) FALSE
                                                 %REJECTION (FR) ERRORS. IT IS NOT
                                                 %POSSIBLE TO REDUCE FA AND
                                                 %FR ERRORS AT THE SAME
                                                 %TIME BY CHANGING A
                                                 %THRESHOLD. A COMPROMISE
                                                 %IS TO TRY TO KEEP IT AS
                                                 %HIGH AS POSSIBLE WHILE WE CAN DETECT SPIRALS EVERYWHERE IN THE IMAGE PLANE.
%3. roi is a rectangle containing the bottom pie...
% mrect=[  1253    408    301    250]; thresh=0.6;  %Notice we now can afford HIGHER treshold.
                                                       
 
                                                 %figure(1); image(imrgb);axis image; truesize

%Region Of Interest, roi, is in the order: rowTL,colTL,rowBR, colBR 
%Translate matlab rectangle to roi
roi=mrect;
botr=roi(1:2)+roi(3:4)-1;
roi=[roi(1:2),botr];
roi=[roi(2),roi(1),roi(4),roi(3)];
roi_imrgb=imrgb(roi(1):roi(3),roi(2):roi(4),:);
roi_im=roi_imrgb(:,:,2);
%figure(1);imshow(roi_imrgb ); truesize

%Initialization: produce centroid masks (rowmask and colmask)
 Ncm=15; Nch=(Ncm-1)/2;
 colmask=ones(Ncm,1)*[-Nch:Nch]; % rowmask=reshape(rowmask, [Ncm*Ncm,1]);rowmask=rowmask';
 rowmask=[-Nch:Nch]'*ones(1,Ncm); %colmask=reshape(colmask, [Ncm*Ncm,1]);colmask=colmask';


%initialization: spiral detection
%generate 4 1D derivative filters and a 2D complex filter.
sma1=(0.75); %0.75  
dx=gaussgen(sma1,'dxg',[1,round(sma1*6)]);
gx=gaussgen(sma1,'gau',[1,round(sma1*6)]);
dy=-dx';
gy=gx';

sma2=(16); 
sma=[sma1,sma2];
typ=2; sm=double(-sma2); gammaf=100;
% ...if sm is negative then symdergaussgen interprets it as the radius
%   that we wish that the max filter values will occur (instead of standard
%   deviation.
h2=symdergaussgen(typ,sm,gammaf);
%            [i,j,s] = find(h2);
%                [m,n] = size(h2);
%                h2 = sparse(i,j,s,m,n);
scaling=['sclon'];
gamma=0.01;
Info=['....ENTERING ROI COMPUTATIONS....ENTERING ROI COMPUTATIONS....ENTERING ROI COMPUTATIONS...']

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
spiral_obj
%Number of spiral objects 
Number_of_spiral_obj=size(spiral_obj,1)
end
figure(5);imshow(imrgb); axis image; truesize

location = zeros(size(spiral_obj, 1), 2);
location = [spiral_obj(:,2), spiral_obj(:,1)];
[Idx, c]= kmeans(location, 2);

hold on 
for i = 1: size(c, 1)
   plot(c(i,1), c(i,2), '*');
end  

%crp= [213  213+422 979       979+581 ];
% hold on
% % 
% % for i=1:size(spiral_obj,1)
% %     plot(spiral_obj(i,2),spiral_obj(i,1), '*');
% % end
% 
% hold off
imwrite(imrgb, 'images/org_plus_cross.tiff');
%imwrite(imrgb(crp(1):crp(2),crp(3):crp(4),:), 'images/org_plus_cross_subimage.tiff');

ptime=[ptime sum(ptime) ptime/sum(ptime)]

% % figure(7); imagesc(threshim);truesize; axis off; axis image; colormap(gray(256))
% % figure(8);image(roi_imrgb ); truesize
% % 
  figure(2);I20rgb=lsdisp(I20,3,'sclon'); %truesize; axis off
%   crp2=round(crp/2);
%   imwrite(I20rgb(crp2(1):crp2(2),crp2(3):crp2(4),:), 'images/I20rgb.tiff');

  figure(6);imshow(I20nmxs); truesize; axis image
% % 
% % roi_im=mark_obj(roi_im,spiral_obj_roi);
% % figure(11);imshow(roi_im);
% % figure(11);imshow(roi_im);


%%End: Info



