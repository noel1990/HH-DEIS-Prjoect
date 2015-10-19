function  [o,I20nmxs,I20,I11]=spiral_detection_buf(inim,std,scaling,gamma,dx,gx,dy,gy,h2,rowmask,colmask,thresh)
% (C) Josef Bigun
%           [LS,C2LS]=spiral_detection(inim,std,scaling,gamma)
%Computes the linear symmetry (logzLS) in local neighborhoods in log(z) coordinates.
%The details of the theory is given in
% @Article{bigun97cviu2,
%   author =       {J. Bigun},
%   title =        {Pattern
% recognition in images by symmetries and coordinate transformations},
%   journal =      cviu,
%   year =         {1997},
%   OPTkey =       {},
%   volume =       {68},
%   number =    {3},
%   OPTmonth =     {},
%   pages =     {290-307},
%   OPTannote =    { %old key: bigun96cviu2},
% OPTnote =      {\htmladdnormallink{bigun97cviu2.pdf}{bigun97cviu2.pdf}},
% keywords =     "pattern recognition theory; local symmetry; lie
%                  groups; infinitesimal operators; image analysis;
%                  computer vision; matching; local orientation tensors;
%                  infinitesimal linear symmetry",
% }
%LS is a three dimensional matrix. It consists of  three 2-D matrices that represent the local
%orientation as well as two error measures of the local orientation fitting.
%The first component,  LS(:,:,1) is  2*angle where angle is the angle
% of a spiral. The second component LS(:,:,2) is
%is Lambda_{worst} -Lambda_{best} that represents the difference of the total errors when
%worst and best orientations are fit to the local neighborhood, known as |i20|. The third component LS(:,:,3)
%is the sum  of the best and worst total errors, Lambda_{worst} +Lambda_{best}, known as i11.
%The best fit orientation and the worst fit orientations are always orthogonal to each
%other, so that it is not necessary to compute the worst orientation explicitly.
%
%C2LS is a certainty measure corrected i20 which is (i11*|i20|)^gamma2 exp(i angle(i20)).
%It is forced to 0 (clipped) at i11<0.25*max_{global}(\lambda_{worst}+\lambda_{best})
%
%The function spiral_detection can be called with 1, 2, 3, or 4  input arguments as:
%spiral_detection(inim), spiral_detection(inim,std), spiral_detection(inim,std,scaling), spiral_detection(inim,std,scaling,gamma).
% The default values of the omitted arguments are
%      std=[0.8, 3.5];
%      scaling='sclon';
%      gamma=0.8;
% gamma is used to exponentiate the gradient magnitudes.
% If std(1)<0.9 then the size of the original image is doubled.
%See also lsdisp to display LS.


% 
% scl='sclon'; PI=atan(1)*4;
% sma1=0.9; sma2=1.5;
% gammad=0.8;
% 
% 
% if (1 < nargin)
sma1=std(1); sma2=std(2);
% end
% if (sma2<0) sma2=abs(sma2)/sqrt(2); end
% 
% if (2<nargin)
%     scl=scaling;
% end
% 
% if (nargin<3)
%     gamma=gammad;
% end

%if (sma1<0.9)
%    inim=imresize(inim,2);
%end



% %generate 4 1-D derivative filters.
% dx=gaussgen(sma1,'dxg',[1,round(sma1*6)]);
% gx=gaussgen(sma1,'gau',[1,round(sma1*6)]);
% dy=-dx';
% gy=gx';
% 
%typ=2; sm=sma2; gammaf=100 ;
% %typ=0; sm=0.33; gammaf=1;
% h2=symdergaussgen(typ,sm,gammaf);
spiral_time=[];
% if 3<nargout
%     [I20,I11] = gst_sep_unsep(inim,dx,gx,dy,gy,gamma,h2);
% else
    tic %2.1: start measuring the cpu-time
    [I20] = gst_sep_unsep(inim,dx,gx,dy,gy,gamma,h2);
 %   spiral_time= [spiral_time toc], Info=['<-I20 by non-separable filtering'] %2.1: append the cpu-time measurement obtained between the last tic and the current statement
% end

%put zeros around the boundary of I20
%compute the absolute values of pixels in I20
%normalize the absolute values with maximum absolute value
%gamma correct them with value 3.5
%Keep only those which are half as much as the maximum.
tic %2.2: start measuring the cpu-time
%b=round(3*sma1)+round((size(h2,1)-1)/2);
b=round(3*sma1)+round((size(h2,1)/2-1)/2);
I20(1:b-1,:)=0;
hs=size(I20,1);
if hs>2*b
    I20(hs-b:hs,:)=0;
end
% I20(hs-b:hs,:)=0;
I20(:,1:b-1)=0;
ws=size(I20,2);
if ws>2*b
    I20(:,ws-b:ws)=0;    
end
% I20(:,ws-b:ws)=0;
mI20=abs(I20);
mxm=max(mI20(:));
mI20=(mI20/mxm);
%mI20=(mI20 >= 0.25) .* mI20;
mI20=mI20.^3.5;
%mI20=(mI20 >= 0.35) .* mI20;
%spiral_time= [spiral_time toc], Info=['<-Thresholding I20.'] %2.2: append the cpu-time measurement obtained between the last tic and the current statement

%Use either Non-maximum suppression.
tic %2.3: start measuring the cpu-time
% mx_mI20=imdilate(imdilate(byte_mI20,ones(1,3*b)), ones(3*b,1));
% I20nmxs=(mx_mI20 == byte_mI20 ) & logical(byte_mI20);
% %I20nmxs= (mx_mI20 == logical(mI20)) & logical(mI20);
% [ro,co]=find(I20nmxs);
% ao=angle(I20(sub2ind(size(I20),ro,co)));
% o=[ro,co,ao];
% 

%Orcentroids computation to obtain the positions of peaks
[centroids ] = centr(mI20,thresh,rowmask,colmask );
% rowmask;
% colmask;

if( size(centroids,1) == 0 )
    o = [];
    I20nmxs=mI20;
    return;
end

ao=angle(I20(sub2ind(size(I20),round(centroids(:,1)),round(centroids(:,2)))));
centroids=centroids*2;
o=[centroids(:,1),centroids(:,2),ao];
I20nmxs=mI20;
%spiral_time= [spiral_time toc], Info=['<-Centroid'] %2.3: append the cpu-time measurement obtained between the last tic and the current statement

%byte_mI20=uint8(255*mI20);
%figure(10); imshow(byte_mI20);
%I20=exp(i*angle(I20)).*mI20;
%I20nmxs=mx_mI20;

%sspiral_time=sum(spiral_time), Info=['<-Spiral detection total']
%rspiral_time=spiral_time/sspiral_time

% if 3<nargout
%     I11=filter2(abs(h2), abs(LS));
%     I11(1:b-1,:)=0;
%     I11(hs-b:hs,:)=0;
%     I11(:,1:b-1)=0;
%     I11(:,ws-b:ws)=0;
% end

end







