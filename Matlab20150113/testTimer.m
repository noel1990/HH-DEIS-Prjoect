
parameter = initial_pro();

% start timer
T=timer('Name','mytimer','TimerFcn',@mainfun1,'StartDelay',0.5,'ExecutionMode','fixedSpacing','Busymode','drop','Period',0.3);
T.Period = 1;
T.ExecutionMode = 'fixedSpacing';
T.TimerFcn={'mainfun1',parameter};
start(T);
data=[];
while isvalid(T)
    %pause(0.1)
    data=T.userdata;
    if(~isempty(data))
        disp(data);
        data=[];
    end
    
end