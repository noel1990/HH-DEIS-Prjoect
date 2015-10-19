function [h, x, y]=gaussgen(sma,type,sizev)
% $Id: gaussgen.m,v 1.5 2005/12/05 22:52:00 josef Exp josef $
% (C) Josef Bigun
% This function generates a 2-D gaussian kernel with standard deviation of sma if type ='gauss'.
% it generates a 2-D  gaussian derivative kernel with standard deviation of sma
% if type='dxg'.  The argument sizev is a vector telling the size of the filter [height,width].
% By using height=1 or widht=1, 1-D gaussian or derivative of gaussians can be generated.
%
% The function can be called with 0, 1, 2, and 3 arguments as:
%   gaussgen, gaussgen(sma), gausssgen(sma,type), and
%   gaussgen(sma,type,sizev)
% The default values of the omitted variables  are
% sma =1;
% typ='gau';
% siz =[1,round(6*std)];
% If sma is negative then it is interpreted as reduction factor, not as standard deviation.
% The corresponding sigma is calculated using the max-norm approximation of octave
% reduction. The used sigma is typed.


sm =1;
if nargin>0 sm=sma;  end


%%Reinterpretation of sm depending on its value
if  ((0<=sm) && (sm<=0.33))
    sizev=[1,1]
    Info=['Sigma, if positive, and less then 0.33 it is set to 0.33 as done now.!']
    Info=['...Filter size is set to 1x1!']
    sm=0.33, sizev=[1,1]
elseif (-1<= sm &&(sm<0))
    Info=['Reduction factor requests must not be in [-1, 0 )']
    Info=['...Reduction filters must reduce image size with a factor larger than 1 to be meaningful.']
    return
    %If sm is less then -1 then, it is interpreted as
    % reduction-factor for a reducton filter. The sigma for the
    %corresponding filter is computed and printed%
elseif sm<-1
    Info =['... The reduction factor you requested is rf=',num2str(abs(sm)),'.']
    Info =['The corresponding sm and filter size yields:']
    sm=0.75*(abs(sm)/2)
end

typ='gau';

if nargin>1
    if size(type,2)==2
        if (type=='xg')
            typ='dxg';
        elseif type=='ga'
            typ='gau';
        else
            typ='unk';
        end
    elseif size(type,2)==3
        if ((type=='gau')|(type=='dxg')|(type=='xxg'))
            typ=type;
        else
            typ='unk';
        end
    end
    if typ=='unk'
        Info='Valid filter types are gau,{xg|dxg},xxg'  
        return
    end
end

siz =[1,-1];
if (typ == 'dyg')
    siz =[-1,1];
end

if nargin>2
    siz=sizev;
end

if siz(1)<0 siz(1)=1+2*round(3*sm); end
if siz(2)<0 siz(2)=1+2*round(3*sm); end


[x,y]=meshgrid(-(siz(2)-1)/2:(siz(2)-1)/2,-(siz(1)-1)/2:(siz(1)-1)/2);

if (typ == 'gau')
    h = exp(-(x.*x + y.*y)/(2*sm*sm));
    h = h/sum(sum(h));
end

if (typ == 'dxg')
    h = x.*exp(-(x.*x + y.*y)/(2*sm*sm));
    h = h/sum(sum(abs(h)))/2;
end

if (typ == 'xxg')
    h = x.*x.*exp(-(x.*x + y.*y)/(2*sm*sm));
    h = h/sum(sum(abs(h)));
end




