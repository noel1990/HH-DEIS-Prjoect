clc;
clear;

% 
parameter = initial_pro();
% 
%  T=timer('Name','mytimer','TimerFcn',@mainfun,'StartDelay',1,'ExecutionMode','fixedrate','Busymode','drop','Period',2);
% % 
% T.TimerFcn={'mainfun',parameter};
% T.UserData = 'continue';
% % 
% start(T);


% 

for i =1:300
    
  
    [parameter]=mainfun(parameter);
  
    
end

% 
% % 
% while(strcmp(T.UserData,'continue'))
%  pause(0.2);
%  disp('OK');
% 
% end



stop(T);
