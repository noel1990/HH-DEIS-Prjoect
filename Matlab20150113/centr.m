function [centroids] = centr(inim,thresh,rowmask,colmask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


Ncm=size(colmask,1);
Nch=(Ncm-1)/2;
% % if thresh<0
%     threshim = (inim <= thresh);
% % hejtmp=imrgb(:,:,2);
% %imrgb(:,:,2)=uint8(round(255.0*threshim)+round(double(hejtmp).*(1-threshim))) ;  
% inim=threshim.*inim;
% else
   threshim= (thresh < inim );
   % hejtmp=imrgb(:,:,2);
  %imrgb(:,:,2)=uint8(round(255.0*threshim)+round(double(hejtmp).*(1-threshim))) ;  
   inim=threshim.*inim;
% end

%Centroid computations
threshim=sparse(threshim);
[row,col]=find(threshim);
LNZ=length(row);
k=1; cr=[];cc=[];
%Take out a local image but make sure that it is from inside of the larger
%image
while LNZ>0
%rL=max((row(k)-Nch),1);
ovf= (row(k) - Nch)-1;
if 0<=ovf 
    offrL=0;
else
    offrL=-ovf;
    rL=1;
end;
    
%rH=min((row(k)+Nch),size(inim,1));
ovf=size(inim,1)-(row(k)+Nch);
if 0<= ovf  
    offrH=0;
else
    offrH=-ovf;
    rH=size(inim,1);
end;
%cL=max((col(k)-Nch),1);
ovf= (col(k) - Nch)-1;
if 0<=ovf 
    offcL=0;
else
    offcL=-ovf+1;
    cL=1;
end;

%cH=min((col(k)+Nch),size(inim,2));
ovf= size(inim,2)-(col(k)+Nch);
if 0<=ovf 
    offcH=0;
else
    offcH=-ovf;
    rH=size(inim,2);
end;

%offrL,offrH,offcL,offcH
%(offrL+row(k)-Nch),(row(k)+Nch-offrH),(offcL+col(k)-Nch),(col(k)+Nch-offcH)
locim=inim((offrL+row(k)-Nch):(row(k)+Nch-offrH),(offcL+col(k)-Nch):(col(k)+Nch-offcH)); 
%MAKE SURE THAT THE CENTROID MASKS HAVE THE SAME SIZE AS THE LOCAL IMAGE
rowmaskl=rowmask((1+offrL:Ncm-offrH),(1+offcL:Ncm-offcH));
colmaskl=colmask((1+offrL:Ncm-offrH),(1+offcL:Ncm-offcH));

%      locim=(inim(max((row(k)-Nch),1):min((row(k)+Nch),size(inim,1)),max((col(k)-Nch),1):min((col(k)+Nch),size(inim,2)))); 
%     locim=(threshim(max((row(k)-Nch),1):(row(k)+Nch),max((col(k)-Nch),1):(col(k)+Nch))); 
%locim=reshape(locim, [Ncm*Ncm,1]);
%full(locim)
 sl=sum(sum(locim));

 lcr=sum(sum (rowmaskl.*locim))/sl;
 lcc= sum(sum(colmaskl.*locim))/sl;
  
% return

 cr=[cr;row(k)+ lcr];
 cc=[cc;col(k)+lcc];
 threshim(  max((row(k)-Ncm),1):(row(k)+Ncm),max((col(k)-Ncm),1):(col(k)+Ncm))=0;
[row,col]=find(threshim);
LNZ=length(row);
%pause
end
% figure(7); imagesc(threshim);truesize; axis off; axis image; colormap(gray(256))
centroids=([cr,cc]);    

end

