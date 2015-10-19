function [ p ] = getNextPos( arg )

persistent data;
persistent counter;

if( arg )
    [nMsgType,dID, dX, dY, nYear, nMonth,nDay, nHour, nMinute, fSeconds]=call_server(1, 4);
    p(1) = dY;
    p(2) = dX;
    p = ServerTranslate(p);
else
    if( isempty(data) )
        data = load('PIE_pos.txt');
        counter = 0;
    end
    counter = counter +1;
    if( counter > size(data,2)/2 )
        counter = 1;
    end
    p1 = 2*counter-1;
    p2 = 2*counter;
    
    p(1) = data(3,p1);
    p(2) = data(3,p2);

end

end
