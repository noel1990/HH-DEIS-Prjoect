
function parameter=initial_pro()

load ('empty.mat');
parameter.empty = double(rgb2gray(imrgb));
parameter.empty = conv2(parameter.empty,ones(1,10),'same');
parameter.empty = conv2(parameter.empty,ones(10,1),'same');

%initial
parameter.Ncm=15; 
parameter.Nch=(parameter.Ncm-1)/2;
parameter.colmask=ones(parameter.Ncm,1)*(-parameter.Nch:parameter.Nch); % rowmask=reshape(rowmask, [Ncm*Ncm,1]);rowmask=rowmask';
parameter.rowmask=(-parameter.Nch:parameter.Nch)'*ones(1,parameter.Ncm); %colmask=reshape(colmask, [Ncm*Ncm,1]);colmask=colmask';

parameter.sma1=(0.75); %0.75
parameter.dx=gaussgen(parameter.sma1,'dxg',[1,round(parameter.sma1*6)]);
parameter.gx=gaussgen(parameter.sma1,'gau',[1,round(parameter.sma1*6)]);
parameter.gy=parameter.gx';
parameter.dy=-parameter.dx';

parameter.sma2=(16);
parameter.sma=[parameter.sma1,parameter.sma2];
parameter.typ=2; 
parameter.sm=double(-parameter.sma2); 
parameter.gammaf=100;
% ...if sm is negative then symdergaussgen interprets it as the radius
%   that we wish that the max filter values will occur (instead of standard
%   deviation.
parameter.h2=symdergaussgen( 2, double(-parameter.sma2), parameter.gammaf );
%            [i,j,s] = find(h2);
%                [m,n] = size(h2);
%                h2 = sparse(i,j,s,m,n);
parameter.scaling=['sclon'];
parameter.gamma=0.01;
parameter.thresh=0.4;
% parameter.Anglepre=[50];
% parameter.mypie_centroid_pre = [10,10];
% parameter.closest_pie_centriod_pre = [10,100];
end