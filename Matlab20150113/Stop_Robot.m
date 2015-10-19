coord_type = 0;
X_send = 1600;
Y_send = 100;
Dist_send = 0;
sendCoords(X_send,Y_send,Dist_send, coord_type );
if Sync_After_Stop_Done < 5
    Sync_when_stop;
    Sync_After_Stop_Done = Sync_After_Stop_Done + 1;
end