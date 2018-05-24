function varargout = SimGUI(varargin)
% SIMGUI MATLAB code for SimGUI.fig
%      SIMGUI, by itself, creates a new SIMGUI or raises the existing
%      singleton*.
%
%      H = SIMGUI returns the handle to a new SIMGUI or the handle to
%      the existing singleton*.
%
%      SIMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMGUI.M with the given input arguments.
%
%      SIMGUI('Property','Value',...) creates a new SIMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SimGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SimGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SimGUI

% Last Modified by GUIDE v2.5 25-Sep-2016 12:32:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SimGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before SimGUI is made visible.
function SimGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for SimGUI
handles.output = hObject;

% Get the default data
handles.simData = SecondOrderSystemSim;

% Set the default states
set(handles.editDuration,'string',num2str(handles.simData.tEnd));
set(handles.editUndamped,'string',num2str(handles.simData.omega));
set(handles.editPulseStart,'string',num2str(handles.simData.tPulseBegin));
set(handles.editPulseEnd,'string',num2str(handles.simData.tPulseEnd));
set(handles.editDamping,'string',num2str(handles.simData.zeta));
set(handles.editInputFrequency,'string',num2str(handles.simData.omegaU));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SimGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SimGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in step.
function step_Callback(hObject, eventdata, handles)

if( get(hObject,'value') )
  handles.simData.input = 'step';
  guidata(hObject, handles);
end


% --- Executes on button press in pulse.
function pulse_Callback(hObject, eventdata, handles)

if( get(hObject,'value') )
  handles.simData.input = 'pulse';
	guidata(hObject, handles);
end

% --- Executes on button press in sinusoid.
function sinusoid_Callback(hObject, eventdata, handles)

if( get(hObject,'value') )
  handles.simData.input = 'sinusoid';
	guidata(hObject, handles);
end


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)

[xP, t, tL] = SecondOrderSystemSim(handles.simData);

axes(handles.position)
plot(t,xP(1,:));
ylabel('Position')
grid

axes(handles.input)
plot(t,xP(2,:));
xlabel(tL);
ylabel('input');
grid


function editDuration_Callback(hObject, eventdata, handles)

handles.simData.tEnd = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editUndamped_Callback(hObject, eventdata, handles)

handles.simData.omega = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editUndamped_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPulseStart_Callback(hObject, eventdata, handles)

handles.simData.tPulseStart = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPulseStart_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editPulseEnd_Callback(hObject, eventdata, handles)

handles.simData.tPulseEnd = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editPulseEnd_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editDamping_Callback(hObject, eventdata, handles)

handles.simData.zeta = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDamping_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editInput_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function editInput_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over step.
function step_ButtonDownFcn(hObject, eventdata, handles)



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pulse.
function pulse_ButtonDownFcn(hObject, eventdata, handles)



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over sinusoid.
function sinusoid_ButtonDownFcn(hObject, eventdata, handles)



function editInputFrequency_Callback(hObject, eventdata, handles)

handles.simData.omegaU = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editInputFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editInputFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
