function [h, x, y]= symdergaussgen(typ,sm,gamma,sizev)
% $Id: symdergaussgen.m,v 1.3 2011/05/30 17:08:51 josef Exp $  
% (C) Josef Bigun
% This function generates a 2-D gaussian kernel with standard deviation of sma if type ='gauss'.
% it generates a 2-D  symmetry derivative of a gaussian kernel with standard deviation of sma.
%   The argument sizev is a vector telling the size of the filter [height,width].
% By using height=1 or width=1, 1-D gaussian or derivative of gaussians can be generated.
%If sma is smaller than 0.33, it causes sizev=[1 1].
%
% The function can be called with 0, 1, 2, 3 and 4 arguments as:
%   symdergaussgen, symdergaussgen(type), symdergaussgen(typ,sm),
%     symdergaussgen(typ,sm,gamma), and symdergaussgen(typ,sm,gamma,sizev).
% The default values of the omitted variables  are
%typ=1; sm=1; gamma=1.0; sizev=[-1,-1];
%
%  -if typ<>0´ and sm is negative then sm is interpreted as radius at 
%  which the filter is maximum, not as standard deviation. Information on
%  this is given. Gamma controls how steeply the filter magnitide goes down from its
%  maximum down to zero.
%  -If typ=0 the routine generates a gaussian with  sm as standard
%  deviation (using gaussgen) and gamma has no effect.  If sm is negative (while typ=0) 
%   it is interpreted as a down-size factor f, and sm is computed from this as sm=0.75*f/2 (see gausgen);
%  
% If a sizev element is negative, then the filter size in the
% negative dimensions are calculated by the routine itself. 
% If sizev is omitted altogether then the
% filter size is calculated in both dimensions by the routine itself.


%%Argument parsing

%No arguments
typd=1; if nargin<1 typ=typd; end
% if 0==typ
%     Info=['Use gaussgen to generate derivation filters of symmetry-order 0'];
%     return
% end

%1 argument
smd =1; if nargin <2 sm=smd;end

%2 arguments
gammad=1.0; if nargin<3  gamma=gammad; end

%3 arguments
sized=[-1,-1]; if nargin<4  sizev=sized; end





atyp=abs(typ);

if atyp==0
    [h, x, y]=gaussgen(sm,'gau',sizev);
%     figure(1003);
    lsdisp(complex(h),1);
     Info=['Using gaussgen to generate filters of symmetry-order 0'];
else
    %If negative, reinterpret sm such that it will correspond to the
    %max-magnitude radius directly. 
    if sm<0
        sm=abs(sm)/sqrt(2);
    end;
    %    XF=sm*(sqrt(typ))
    %    RF=XF+ (sm*3/sqrt(2))
    EF=sm*(prod(1./[1:2:(atyp-1)]+1))*sqrt(2/pi);
    if mod(atyp,2)==1
        EF=sm*(prod(1./[2:2:(atyp-1)]+1))*sqrt(pi/2);
    end
%     Info=['Expected Filter Radius=', num2str(EF)]
    r0=sqrt(atyp)*sm;
%     Info=['Radius at filter maximum=', num2str(r0)]

%Filter absolute value  at truncation,  
   ep=exp(-9/sqrt(2));

%Calculate thefilter size as the root of H
H=@(rr) ep-((rr^atyp)*exp(-(rr/sm)^2/2)/(((sqrt(atyp)*sm)^atyp)*exp(-atyp/2)))^gamma;
    rn=fzero(H,sqrt(atyp)*sm*[0, 1]);
    rx=fzero(H,sqrt(atyp)*sm*[1, 6]);
%     Info=['Inner radius, rn, and Outer radius, rx, are defined as the filter values reaching ep=', num2str(ep) ]
    wr=rx-rn;
%     Info=['rn=',num2str(rn), '  rx=',num2str(rx), '  rx-rn=',num2str(wr) ]
    
    %   RF=r0+ (sm*3)  %rather good approximation of rx
    %   RF=EF+ (sm*3/sqrt(2)) %poor approximation of rx despite that r0<EF.
    
    if sizev(1)<0 sizev(1)=1+2*round(rx); end
    if sizev(2)<0 sizev(2)=1+2*round(rx); end

[x,y]=meshgrid(-(sizev(2)-1)/2:(sizev(2)-1)/2,-(sizev(1)-1)/2:(sizev(1)-1)/2);
[th,r]=cart2pol(x,y);

h = exp(-(r.*r)/(2*sm*sm));
    h=r.^(abs(atyp)).*h;
    h=h/(((sqrt(atyp)*sm)^atyp)*exp(-atyp/2));
    if gamma ~=1.0
        h=h.^gamma;
        %        h(abs(r(:)-rn) <= 0.5)=1; h(abs(r(:)-rx) <= 0.5)=1; h(abs(r(:)-EF) <= 0.5)=0.25; h(abs(r(:)-r0) <= 0.5)=0.5;
    end
%Normalize so that max is 1 (Obs! for typ <> 0)
h = h/sum(sum(h));
% plot the complex filter, for inspection/debugging

[hre,him]=pol2cart(typ*th,h);
h=hre+i*him;
% Info=['filtersize=', num2str(sizev)]
lsdisp((h),1)
end

% figure(1004);
% set(1004, 'Position', [600, 40,500,400])
% if size(h,1)<size(h,2)
%     plot(x((size(h,1)+1)/2,:),abs(h((size(h,1)+1)/2,:)))
% else
%     plot(y(:,(size(h,2)+1)/2),abs(h(:,(size(h,2)+1)/2)) )
% end



