function [admit] = requestPassage()

[nMsgType,dID, dX, dY, nYear, nMonth,nDay, nHour, nMinute, fSeconds]=call_server(2, 4);

if dX == 4
    admit = 1;
else
    admit = 0;
end

end