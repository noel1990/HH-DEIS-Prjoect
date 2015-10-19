function [rgbim]=lsdisp(hsvim,gamma,scaling)
% $Id: lsdisp.m,v 1.5 2012/04/25 12:27:38 josef Exp $   
%(C) Josef Bigun 2009, 2010, 2011
%        [rgbim]=lsdisp(hsvim,gamma,scaling)
%converts an hsv image to rgb and displays it. The result is put in rgbim when an output
%argument is required otherwise no rgbim is returned.
%
%There are two behaviours of lsdisp depending on dimension of hsvim.
%hsvim can be a 2D-matrix (complex or real valued) or a 3D matrix that is real-valued.
% 
%When hsvim is a 2D matrix then it is treated as complex valued (even if the elements are real).
%To be precise, the arguments of hsvim, that is angle(hsvim), are assumed all zero if hsvim is real valued. 
%lsdisp  will  modulate the hue of the screen pixels  by angle(hsvim) linearly so that the range [0,2PI] corresponds, 
%to hues defined by the CIE color standard, with zero representing the red color.
%Saturation of the screen elements is put to 1. The Value of screen elements is modulated by the magnitudes, mag(hsvim). 
%The parameter gamma is a positive real number that performs gamma
%correction on Value component and defaults to gamma=0.6. 
%
%When hsvim is a 3D matrix, then it is assumed that it  has  elements with real values.
%The matrix corresponding to the first dimension is directly interpreted in the range of 
%[0,2PI] and as an angle.  The angles are  modulate the hue of the screen elements linearly so that the 
%range [0,2PI] corresponds to hues defined according to the CIE color standard, 
%with zero representing the color red. Saturation is modulated by hsvim(:,:,2) whereas
%Value is modulated by hsvim(:,:,3). The parameter gamma is a positive
%real number that performs gamma correction on Saturation (notice the
%difference with the above) and defaults to 0.6. 
%
%The scaling is a switch ('sclon', or 'scloff') that turns on/off the
%normalization performed on mag(hsvim) before the display and defaults
%to 'sclon'; 
%
%The output,  rgbim, if present, is a 3D matrix which is the rgb version of  hsvim. 
%
%Two Examples
%  1. lsdisp(linsym(inim));
%  2. [LSX,LSY,I11]=linsym_sep_sep(inim,dx,gx,dy,gy,gamma,gx2,gy2); 
%     lsdisp(complex(LSX,LSY))
%     figure
%     lsdisp(I11)

PI=4*atan(1);
gam=.6;  %default , originally it was 3.5
scl='sclon'; %default

if (1<nargin)
    gam=gamma;   
end

if (2<nargin)
    scl=scaling;   
end

if ((isreal(hsvim)) && (size(hsvim,3)==3))
   HH=mod(hsvim(:,:,1),2*PI);
   SS=hsvim(:,:,2);
   VV=hsvim(:,:,3);
   if (~strcmp(scl ,'scloff'))
      mxs= max(VV(:));
      VV=VV/mxs;
      SS=SS/mxs;
   end
   SS=SS.^gam;
else
   HH=mod(angle(hsvim), 2*PI);
   SS=ones(size(hsvim,1), size(hsvim,2)); 
   VV=abs(hsvim);
   if (~strcmp(scl ,'scloff')) %entered when scl NOT 'scloff'
      VV=VV/max(VV(:));
   end
   VV=VV.^gam;
end

hsvim(:,:,1)=HH/2/PI;
hsvim(:,:,2)=SS;
hsvim(:,:,3)=VV;
rgbimage=hsv2rgb(hsvim);

%image(rgbimage);
if (0<nargout)
    rgbim=rgbimage;
%    imwrite(rgbim,'rgbim.tif','tif'); 
end
set(gcf, 'InvertHardcopy', 'off');
imshow(rgbimage,'Border','tight','InitialMagnification',100);
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@dataCursorCallback_vhs);

%imshow(rgbimage); 
%truesize;
%imtool(rgbimage);
end
