%% MHTGUI Graphical user interface for MHT
%% Forms
%   MHTGUI            Initialize blank MHTGUI if it does not yet exist;
%                     bring existing MHTGUI window to the front.
%   MHTGUI(trk)       Update the GUI with given track data. 
%   MHTGUI(trk,hyp)   Update the GUI with given track and hypothesis data.
%   MHTGUI(trk,hyp,'hide')    Update the GUI with given data but do not
%                             bring it to the front.
%
%% Description
% A graphical user interface (GUI) for multiple hypothesis testing (MHT)
%
%% Inputs
%   trk       (.)   Track data structure array. See MHTTrackMgmt.m
%   hyp       (.)   Hypothesis data structure.  See TOMHTAssignment.m
%   option    ''    Optional argument to specify window visibility. Use
%                   this with "hide" to prevent flashing window during 
%                   repeated updates of the MHTGUI in a simulation loop.
%
%% Outputs
%   None

function varargout = MHTGUI(varargin)

% Last Modified by GUIDE v2.5 08-Jul-2013 09:38:36

% Bypass GUI initialization if called with "hide" or "update" as 3rd input
if( nargin>2 && (strcmpi(varargin{3},'hide') || strcmpi(varargin{3},'update')) )
  hObject = getappdata(0,getToken('MHTGUI.fig'));
  handles = guidata(hObject);
  MHTGUI_OpeningFcn(hObject,[],handles,varargin{:});
  return;  
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MHTGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MHTGUI_OutputFcn, ...
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


% --- Executes just before MHTGUI is made visible.
function MHTGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MHTGUI (see VARARGIN)

% MHTGUI may have been called with first two inputs as 'visible','off' to
% keep it from flashing. If so, ignore these first two inputs.
if( length(varargin)>2 && strcmpi(varargin{1},'visible') )
  for j=1:length(varargin)-2
    inputs{j} = varargin{2+j};
  end
else
  inputs = varargin;
end

% Choose default command line output for MHTGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if( length(inputs)<1 )
  %set(handles.fig,'units','pixels');
  movegui(handles.fig,'northwest');
  return
end

StoreTracks( handles, inputs{1} );
if( length(inputs)>1 )
  StoreSolution( handles, inputs{2} );
end

UpdateSummary(    handles );
UpdateTrackTable( handles );
UpdateHypTable(   handles );


% --- Outputs from this function are returned to the command line.
function varargout = MHTGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in viewTrackTree.
function viewTrackTree_Callback(hObject, eventdata, handles)
% hObject    handle to viewTrackTree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trk = GetTracks(handles);
MHTTreeDiagram(trk,[],1);
  
% --- Executes on button press in computeHypothesis.
function computeHypothesis_Callback(hObject, eventdata, handles)
% hObject    handle to computeHypothesis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trk = GetTracks(handles);
sol = TOMHTAssignment(trk,1);
StoreSolution( handles, sol );
UpdateHypTable(handles);

% --- Executes on button press in pruneTracks.
function pruneTracks_Callback(hObject, eventdata, handles)
% hObject    handle to pruneTracks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trk = GetTracks(handles);
sol = TOMHTAssignment( trk,  1 );
trks = TOMHTPruneTracks( trk, sol, 1 );

StoreTracks( handles, trks );
UpdateTrackTable( handles )

%--------------
% update summary
%--------------
function UpdateSummary( handles )

trk = GetTracks(handles);
set(handles.numberOfTracks,'string',[int2str(length(trk)),' ']);

if( isempty(trk) )
  scans = [];
else
  scans = unique([trk.scanHist]);
end
nScan = length(scans);
set(handles.numberOfScans,'string',[int2str(nScan),' ']);
if( nScan==0 )
  set(handles.activeScanHistory,'string',sprintf('- '));
else
  set(handles.activeScanHistory,'string',sprintf('%d-%d ',scans(1),scans(end)));
end

%--------------
% update track table
%--------------
function UpdateTrackTable( handles )

trk = GetTracks(handles);
MHTTrackTable(handles.trackTable,trk);


%--------------
% update hypothesis table
%--------------
function UpdateHypTable( handles )

trk = GetTracks(handles);
hyp = GetHypothesis(handles);
if( ~isempty(hyp) )
  MHTTrackTable(handles.hypTable,trk,hyp.trackIndex);
end


%------------------
% Store solution
%------------------
function StoreSolution( handles, sol )
u = get(handles.fig,'userdata');
u.sol = sol;
set(handles.fig,'userdata',u);

if( isempty(sol) )
  set(handles.hypMenu,'value',1,'string',{'-'})
else
  list = cell(1,length(sol.hypothesis));
  for j=1:length(list)
    list{j} = sprintf('Hypothesis %d of %d',j,length(list));
  end
  set(handles.hypMenu,'string',list,'value',1);
end

%------------------
% Store tracks
%------------------
function StoreTracks( handles, trks )
u = get(handles.fig,'userdata');
if isempty(u)
  u = struct('trk',trks);
else
  u.trk = trks;
end
set(handles.fig,'userdata',u);

%------------------
% Get solution
%------------------
function sol = GetSolution( handles )
u = get(handles.fig,'userdata');
sol = [];
if( isfield(u,'sol') )
  sol = u.sol;
end

%------------------
% Get hypothesis
%------------------
function hyp = GetHypothesis( handles )
u = get(handles.fig,'userdata');
hyp = [];
if( isfield(u,'sol') && ~isempty(u.sol) )
  k = get(handles.hypMenu,'value');
  hyp = u.sol.hypothesis(k);
end

%------------------
% Get tracks
%------------------
function trk = GetTracks( handles )
u = get(handles.fig,'userdata');
trk = [];
if( isfield(u,'trk') )
  trk = u.trk;
end


% --- Executes on selection change in hypMenu.
function hypMenu_Callback(hObject, eventdata, handles)
% hObject    handle to hypMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hypMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hypMenu

UpdateHypTable(handles);

% --- Executes during object creation, after setting all properties.
function hypMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hypMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(handles.fig)


% --- Executes on button press in resumeButton.
function resumeButton_Callback(hObject, eventdata, handles)
% hObject    handle to resumeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.fig)


function token = getToken(filename)
% We will use this token, based on the base name of the file
% (without path or extension) to track open instances of figure.
fname = genvarname(filename);         % convert the file name to a valid field name
fname = fliplr(fname);            % file name is more important
token = ['OpenFig_' fname '_SINGLETON']; % hide leading kruft
token = token(1:min(end, namelengthmax));
