global COM_1;
global Next_Index;
global collision;
COM_1 = serial('COM1','BaudRate',115200);
COM_1.Terminator = 'CR/LF';
%COM_1.Terminator = 'LF';
%COM_1.Timeout = 1;
COM_1.InputBufferSize = 4096;
COM_1.BytesAvailableFcnMode = 'terminator';
COM_1.BytesAvailableFcn = @data_callback;
fopen(COM_1);


Next_Index = 0;
collision = [0,0,0,0,0];
% if isobject(COM_1)
%     if isvalid(COM_1)
%         fclose(COM_1);
%     end
%     delete(COM_1);
% end
% clear COM_1;

