function [ inim ] = mark_obj(inim,oo )
%(C) Josef Bigun 2009, 2010
%MARK_OBJ Marks objects o, by tiny crosses in inim
%   o is a list of object coordinates in its rows. The
%   first column is row coordinate and the second column is column coordinate.
nsc=8;
o=int32(round(oo));
for k=1:size(o,1)
%     [o(k,1),o(k,2)]
inim(o(k,1), (o(k,2)-nsc):(o(k,2)+nsc))=0;
inim((o(k,1)-nsc):(o(k,1)+nsc),o(k,2))=0;
end

end

