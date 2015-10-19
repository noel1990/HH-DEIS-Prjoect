function [ ok ] = freePassage()

[nMsgType,dID, dX, dY, nYear, nMonth,nDay, nHour, nMinute, fSeconds]=call_server(2, 4);

if dX == 0
    ok = 1;
else
    ok = 0;
end



end
