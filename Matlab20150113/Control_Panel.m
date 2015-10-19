function varargout = Control_Panel(varargin)
%CONTROL_PANEL M-file for Control_Panel.fig
%      CONTROL_PANEL, by itself, creates a new CONTROL_PANEL or raises the existing
%      singleton*.
%
%      H = CONTROL_PANEL returns the handle to a new CONTROL_PANEL or the handle to
%      the existing singleton*.
%
%      CONTROL_PANEL('Property','Value',...) creates a new CONTROL_PANEL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Control_Panel_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CONTROL_PANEL('CALLBACK') and CONTROL_PANEL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CONTROL_PANEL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Control_Panel

% Last Modified by GUIDE v2.5 05-Dec-2014 03:49:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Control_Panel_OpeningFcn, ...
    'gui_OutputFcn',  @Control_Panel_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Control_Panel is made visible.
function Control_Panel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
clc;
global Stop_Signal;
global Running;
Running = 0;
Stop_Signal = 0;
handles.StartX = 400;
handles.StartY = 400;
handles.StartA = 0;
handles.EndX   = 2500;
handles.EndY   = 2000;
handles.EndA   = 0;
handles.Sample_Qty = 30;

global position_counter;
global position_list;
position_counter = 1;
position_list = [handles.EndX handles.EndY];

set(handles.startpx,'String',handles.StartX);
set(handles.startpy,'String',handles.StartY);
set(handles.startpa,'String',handles.StartA);
set(handles.nextpx,'String',handles.EndX);
set(handles.nextpy,'String',handles.EndY);
set(handles.nextpa,'String',handles.EndA);
set(handles.sampleQty,'String',handles.Sample_Qty);

axes(handles.Path_Figure); hold on;
path_plot;
% Choose default command line output for Control_Panel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Control_Panel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Control_Panel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StartBtn.
function StartBtn_Callback(hObject, eventdata, handles)
% hObject    handle to StartBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stop_Signal;
global Running;
global Pie_curx;
global Pie_cury;
global Pie_cura;
global position_counter;
global position_list;
if Running==0
    
    Running = 1;
    Stop_Signal = 0;
    Spline_Visit_Index = 1;
    curx = 0; cury = 0; cura = 0;
    
    % state variable
    First_Time = 1;    %% Global first time when the robot is started
    First_Time_To_Decide_Passage_Usage = 1;   %% First time for deciding usage of passage
    STATE.PassageUse = 0;
    STATE.NeedToFreePassage = 0;
    STATE.SetPointBeforeTarget = 1;
    STATE.Avoiding_Obstacle = 0;
    STATE.Waiting = 0;
    STATE.NewPosition = 1;  %% When the robot receives a new position
    STATE.NeedToGoOutside = 0;
    STATE.LastTimeOutside = 0;
    STATE.Action = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1: Going To Wait Point
    % 2: Going Through the passage
    % 3: Going to the target point
    % 4: Finish
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    position_list = [ 120 120;
        1000 400;
        1000 1200;
        120 920;
        600 1720];
    target_point  = round([3200-position_list(1,1)*2,position_list(1,2)*2]/10);
    handles.EndX = target_point(1,1);
    handles.EndY = target_point(1,2);
    handles.EndA = 0;
    
    %     if (strcmp(get(handles.InputSwitch,'String'),'Server'))
    %         % Receive the first point from server
    %         position_list = [];
    %         P = getNextPos(1);
    %         position_list(end+1,:) = [P(1) P(2) 0];
    %         handles.EndX = P(1);
    %         handles.EndY = P(2);
    %         handles.EndA = 0;
    %     end
    %
    %     if ~isempty(instrfind)
    %         fclose(instrfind);
    %     end
    
    try
        init_serial;
    catch
        close_serial;
        init_serial;
    end
    
    clc;
    %    Spline_Qty = size(handles.Spline_Points,1);
    
    Sync_when_stop;
    handles.StartX = Pie_curx;
    handles.StartY = Pie_cury;
    handles.StartA = Pie_cura;
    
    set(handles.currentX,'String',Pie_curx);
    set(handles.currentY,'String',Pie_cury);
    set(handles.currentA,'String',Pie_cura);
    set(handles.startpx,'String',handles.StartX);
    set(handles.startpy,'String',handles.StartY);
    set(handles.startpa,'String',handles.StartA);
    set(handles.nextpx,'String',handles.EndX);
    set(handles.nextpy,'String',handles.EndY);
    set(handles.nextpa,'String',handles.EndA);
    
    while (~Stop_Signal)
        disp('start');
        pause(0.01);
        if First_Time_To_Decide_Passage_Usage == 1
            First_Time_To_Decide_Passage_Usage = 0;
            if OutSide([handles.EndX handles.EndY])
                STATE.NeedToGoOutside = 1;
                %                 STATE.SkipSyncWhenStop = 1;
            else
                STATE.NeedToGoOutside = 0;
                %                 STATE.SkipSyncWhenStop = 0;
            end
            
            if (curx<160 && handles.EndX>160)||(curx>160 && handles.EndX<160)
                STATE.PassageUse = 1;
                STATE.Action = 1;  %% go to wait point
            else
                STATE.PassageUse = 0;
                if STATE.NeedToGoOutside
                    STATE.Action = 4;  %% go to target point outside
                else
                    STATE.Action = 3;  %% go to target point inside
                end
            end
            
        end
        if gca ~= handles.Path_Figure
            axes(handles.Path_Figure);
        end
        cla;
        draw_field();
        
        %          try
        %         	load('image/imgdata.mat');
        %             delete('image/imgdata.mat');
        %             data_ok = 1;
        %         catch
        %             data_ok = 0;
        %         end
        %
        %         if( data_ok == 1 )
        %             data_ok = 0;
        %
        %             robot_info = imgdata_read(robot_list);
        %             handles.OtherPIE = [];
        %         draw_robot([robot_info(kk,2) robot_info(kk,3)],robot_info(kk,4)*pi/180,-1);
        %         text(robot_info(kk,2), robot_info(kk,3), sprintf('%d',robot_info(kk,1)),'Color','k');
        %         handles.OtherPIE(end+1,:) = [robot_info(kk,2) robot_info(kk,3)];
        %       draw_otherpie_security_circle;
        %         draw_robot([x y],a*pi/180,col_info);
        %         text( 900, 2600, sprintf('X: %.0f',x),'Color','m' );
        %         text( 1400, 2600, sprintf('Y: %.0f',y),'Color','m' );
        %         text( 1900, 2600, sprintf('A: %.1f',a),'Color','m' );
        %         text( 1500, -200, sprintf('Moving...'),'Color','k' );
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 1: Going To Wait Point
        % 2: Going Through the passage
        % 3: Going to the target point
        % 4: Finish
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        switch STATE.Action
            case 1
                disp('Going To Wait Point');
                
            case 2
                disp('Going Through the passage');
            case 3
                disp('Going to the target point');
            case 4
                disp('Finish');
        end
    end
    
end
% --- Executes on button press in StopBtn.
function StopBtn_Callback(hObject, eventdata, handles)
% hObject    handle to StopBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stop_Signal;
Stop_Signal = 1;
close_serial;


function startpx_Callback(hObject, eventdata, handles)
% hObject    handle to startpx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startpx as text
%        str2double(get(hObject,'String')) returns contents of startpx as a double
handles.StartX = str2double(get(hObject,'String'));
path_plot;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function startpx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startpx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startpy_Callback(hObject, eventdata, handles)
% hObject    handle to startpy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startpy as text
%        str2double(get(hObject,'String')) returns contents of startpy as a double
handles.StartY = str2double(get(hObject,'String'));
path_plot;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function startpy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startpy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startpa_Callback(hObject, eventdata, handles)
% hObject    handle to startpa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startpa as text
%        str2double(get(hObject,'String')) returns contents of startpa as a double
handles.StartA = Ang_Norm_D(str2double(get(hObject,'String')));
set(handles.StartA_Text,'String',handles.StartA);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.EndA   = handles.StartA + handles.dA;
% if(handles.EndA > 180)
%     handles.EndA = handles.EndA - 360;
% end
% if(handles.EndA < -180)
%     handles.EndA = handles.EndA + 360;
% end
% set(handles.EndA_Text,'String',handles.EndA);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_plot;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function startpa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startpa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nextpx_Callback(hObject, eventdata, handles)
% hObject    handle to nextpx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nextpx as text
%        str2double(get(hObject,'String')) returns contents of nextpx as a double
handles.EndX = str2double(get(hObject,'String'));
path_plot;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nextpx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nextpx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nextpy_Callback(hObject, eventdata, handles)
% hObject    handle to nextpy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nextpy as text
%        str2double(get(hObject,'String')) returns contents of nextpy as a double
handles.EndY = str2double(get(hObject,'String'));
path_plot;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nextpy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nextpy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nextpa_Callback(hObject, eventdata, handles)
% hObject    handle to nextpa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nextpa as text
%        str2double(get(hObject,'String')) returns contents of nextpa as a double
handles.EndA = Ang_Norm_D(str2double(get(hObject,'String')));
set(handles.EndA_Text,'String',handles.EndA);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles.StartA   = handles.EndA - handles.dA;
% if(handles.StartA > 180)
%     handles.StartA = handles.StartA - 360;
% end
% if(handles.StartA < -180)
%     handles.StartA = handles.StartA + 360;
% end
% set(handles.StartA_Text,'String',handles.StartA);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path_plot;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function nextpa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nextpa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sampleQty_Callback(hObject, eventdata, handles)
% hObject    handle to sampleQty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sampleQty as text
%        str2double(get(hObject,'String')) returns contents of sampleQty as a double
handles.Sample_Quantity = round(str2double(get(hObject,'String')));

set(handles.sampleQty,'String',handles.Sample_Qty);
path_plot;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sampleQty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampleQty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentX_Callback(hObject, eventdata, handles)
% hObject    handle to currentX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentX = str2double(get(hObject,'String'));
path_plot;
% Hints: get(hObject,'String') returns contents of currentX as text
%        str2double(get(hObject,'String')) returns contents of currentX as a double


% --- Executes during object creation, after setting all properties.
function currentX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentY_Callback(hObject, eventdata, handles)
% hObject    handle to currentY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentY = str2double(get(hObject,'String'));
path_plot;
% Hints: get(hObject,'String') returns contents of currentY as text
%        str2double(get(hObject,'String')) returns contents of currentY as a double


% --- Executes during object creation, after setting all properties.
function currentY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function currentA_Callback(hObject, eventdata, handles)
% hObject    handle to currentA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentA = str2double(get(hObject,'String'));
path_plot;
% Hints: get(hObject,'String') returns contents of currentA as text
%        str2double(get(hObject,'String')) returns contents of currentA as a double


% --- Executes during object creation, after setting all properties.
function currentA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
