
%% BACKPROPAGATIONNNT Backpropagation training code for use with the Trainer
%% Form
%   h = BackPropagationNNT( action, h, modifier )
%% Inputs
%   action      (1,:)  Action 'initialize', 'update'
%   h           (.)    Data structure
%   modifier    (1,4)  [left bottom width height]
%
%% Outputs
%   h           (.)    Updated data

function h = BackPropagationNNT( action, h, modifier )


if( nargin < 1 )
  action = 'initializeGUI';
end

if( nargin < 2 )
  h = GetNNTDataStructure;
end  

switch action

  case 'initialize prefs'
    h = InitializePreferences( h );

  case 'initializeGUI'
    [bP, h] = InitializeGUI( modifier, h );
    bP      = InitializeData( bP, h );
    
  otherwise
    bP = GetH( h.bPFrame );
    
    switch action
    
      case 'train'
        [bP, h] = Train( bP, h );
    
      case 'rate'
        bP = UpdateRate( bP );
        
      case 'default rate'
        [bP, h] = UpdatePreferences( bP, h );
        SetNNTDataStructure( h );
      
      case 'display'
        bP = Display( bP );
    
      case 'hide'
        Hide( bP.tag );

      case 'show'
        Show( bP.tag );
        bP = Display( bP );
    
      case 'initialize prefs GUI'
        bP = InitializePreferencesGUI( modifier, bP, h );
      
      case 'display prefs'
        bP = DisplayPreferences( bP, h );

      case 'show prefs'
        Show( bP.prefTag );
        bP = DisplayPreferences( bP, h );
      
      case 'hide prefs'
        Hide( bP.prefTag );
      
        
        
    end;
    
end;

% Store the data in the figure handle
%------------------------------------
if( ~strcmp( action, 'initialize prefs' ) )
  PutH( bP );
end

%---------------------------------------------------------------------------
%   Initialize the backpropagation display
%---------------------------------------------------------------------------
function [bP, h] = InitializeGUI( modifier, h )

defaultColor = [0.7333 0.7333 0.7333];
ltGrey       = [0.96 0.96 0.96];
white        = [1 1 1];
pink         = [1 0.9 0.9];
ltblue       = [0.9 0.9 1];

left   = modifier(1);
bottom = modifier(2);
width  = modifier(3);
height = modifier(4);
top    = height;

bP.tag           = GetNewTag( 'BackPropagation' );

labelProps        = {'Parent',h.fig,'Units','pixels','Style','text', ...
                     'BackgroundColor',ltGrey,'FontName','Helvetica', ...
                     'FontSize',10,'HorizontalAlignment','right', 'tag', bP.tag };

editProps         = labelProps;
editProps(5:10)   = {'Style','edit','BackgroundColor',white,'FontName','Courier'};

frameProps        = labelProps(1:12);
frameProps(5:8)   = {'Style','frame','BackgroundColor',ltGrey};

menuProps         = labelProps(1:12);             
menuProps(5:10)   = {'Style','popupmenu','BackgroundColor',defaultColor,'FontName','Courier'};

bP.frame          = uicontrol( frameProps{:}, 'Position', [left bottom width height ] );
h.bPFrame         = bP.frame;

bP.display.layerL = uicontrol( labelProps{:},...
                              'Position',[left+15 top-29 75 20 ],...
	                            'String','Layer');

layerString       = 1:h.network.layers;
layerString       = num2str(layerString');
                               
bP.display.layer  = uicontrol( menuProps{:},...
                              'Position',[left+95 top-25 55 20],...
                              'String', {'All',layerString},...
	                            'Callback', CreateCallbackString('display'));

bP.display.rateL  = uicontrol( labelProps{:},...
                              'Position',[left+15 top-25-29 75 20 ],...
	                            'String','Learning Rate');

bP.display.rate   = uicontrol( editProps{:},...
                              'Position',[left+95 top-25-25 55 20],...
	                            'Callback', CreateCallbackString('rate'));

set( bP.display.layer, 'Val', 1 );

%---------------------------------------------------------------------------
%   Initialize the backpropagation network
%---------------------------------------------------------------------------
function bP = InitializeData( bP, h )

if( ~isfield( bP, 'network' ) || isempty( bP.network ) )
  bP.network  = h.network.layer;
  bP.layers   = h.network.layers;
  for j = 1:bP.layers
    bP.network(j,1).alpha = h.preferences.defaultBPRate;
  end;
end;

%---------------------------------------------------------------------------
%   Train the network
%---------------------------------------------------------------------------
function [bP, h] = Train( bP, h )

h.train.network = [];
h.train.network = bP.network;

% Change all step functions to sigmoid logistics
%-----------------------------------------------
for j = 1:h.network.layers
  if( strcmp( h.train.network(j,1).type, 'step' ) )
    h.train.network(j,1).type = 'log';
    warndlg('The step activation function will be converted to a sigmoid logistic function for training.');
    waitfor(gcf)
  end;
end;

[w,h.train.error,h.train.network] = NeuralNetTraining( h.train.inputs(:,h.train.setOrder), h.train.desOutputs(:,h.train.setOrder), h.train.network );

for j = 1:h.network.layers
  bP.network(j,1).w       = w(j,1).w;
  h.network.layer(j,1).w  = w(j,1).w;
  bP.network(j,1).w0      = w(j,1).w0;
  h.network.layer(j,1).w0 = w(j,1).w0;
end;

%---------------------------------------------------------------------------
%   Modify learning rate
%---------------------------------------------------------------------------
function bP = UpdateRate( bP )

clear d
d.type        = 'scalar';
d.min         = 0;

[newRate, valid] = GetEntry( bP.display.rate, d );

if( ~valid )
  bP = Display(bP);
else
  newLayer = get( bP.display.layer, 'Val' ) - 1;

  if( newLayer == 0 )  % change all layers
    for j = 1:bP.layers
      bP.network(j,1).alpha = newRate;
    end;
  else
    bP.network(newLayer,1).alpha = newRate;
  end;
end;

%---------------------------------------------------------------------------
%   Update display
%---------------------------------------------------------------------------
function bP = Display( bP )

j = get( bP.display.layer, 'Val') - 1;

if( j == 0 )
  allSame = 1;
  for k = 2:bP.layers
    if( bP.network(k,1).alpha ~= bP.network(1,1).alpha )
      allSame = 0;
    end;
  end;

  if( allSame )
    set( bP.display.rate, 'String', num2str(bP.network(1,1).alpha) );
  else
    set( bP.display.rate, 'String', [] );
  end;

else
  set( bP.display.rate, 'String', num2str(bP.network(j,1).alpha) );
end;

%---------------------------------------------------------------------------
%   Initialize preferences
%---------------------------------------------------------------------------
function h = InitializePreferences( h )

if( ~isfield(h.preferences,'defaultBPRate') || isempty(h.preferences.defaultBPRate) )
  h.preferences.defaultBPRate = 0.5;
end;

%---------------------------------------------------------------------------
%   Initialize preferences GUI
%---------------------------------------------------------------------------
function bP = InitializePreferencesGUI( position, bP, h )

ltGrey       = [0.96 0.96 0.96];
white        = [1 1 1];

left   = position(1);
bottom = position(2);
width  = position(3);
height = position(4);
top    = height;

bP.prefTag      = GetNewTag('BackPropPrefs');

labelProps      = {'Parent',h.prefFig,'Units','pixels','Style','text', ...
                   'BackgroundColor',ltGrey,'FontName','Helvetica', ...
                   'FontSize',10,'HorizontalAlignment','right','tag',bP.prefTag};

editProps       = labelProps;
editProps(5:10) = {'Style','edit','BackgroundColor',white,'FontName','Courier'};

bP.defDisplay.rateL  = uicontrol( labelProps{:},...
                                 'Position',[left+55 top-120-29 100 20 ],...
	                               'String','Learning Rate');

bP.defDisplay.rate   = uicontrol( editProps{:},...
                                 'Position',[left+165 top-120-25 60 20],...
	                               'Callback', CreateCallbackString('default rate'));

%---------------------------------------------------------------------------
%   Update local copy of preferences 
%---------------------------------------------------------------------------
function [bP, h] = UpdatePreferences( bP, h )

% Set up data structure of valid input parameters
%------------------------------------------------
d.type        = 'scalar';
d.min         = 0;

[newRate, valid] = GetEntry( bP.defDisplay.rate, d );

if( ~valid )
  bP = DisplayPreferences( bP, h );
else
  h.preferences.defaultBPRate = newRate;
  h.preferences.newPref       = 1;
end;

%---------------------------------------------------------------------------
%   Display preferences 
%---------------------------------------------------------------------------
function bP = DisplayPreferences( bP, h )

set( bP.defDisplay.rate, 'String', num2str(h.preferences.defaultBPRate) );

%---------------------------------------------------------------------------
%   Get a new tag
%---------------------------------------------------------------------------
function tag = GetNewTag( name )

t   = clock;
tag = [name num2str([t(5:6) 100*rand])];

%---------------------------------------------------------------------------
%   Hide the gui
%---------------------------------------------------------------------------
function Hide( tag )

x = findobj( 'tag', tag );
set(x, 'visible', 'off' );

%---------------------------------------------------------------------------
%   Show the gui
%---------------------------------------------------------------------------
function Show( tag )

x = findobj( 'tag', tag );
set(x, 'visible', 'on' );

%---------------------------------------------------------------------------
%   Get the data structure stored in the frame
%---------------------------------------------------------------------------
function bP = GetH( frameH )

bP   = get( frameH, 'UserData' );

%---------------------------------------------------------------------------
%   Put the data structure into the user data
%---------------------------------------------------------------------------
function PutH( bP )

set( bP.frame, 'UserData', bP );

%---------------------------------------------------------------------------
%   Call back string without modifier
%---------------------------------------------------------------------------
function s = CreateCallbackString( action )

s = ['h = BackPropagationNNT(''' action ''');'];

%---------------------------------------------------------------------------
%   Get the neural net trainer data structure
%---------------------------------------------------------------------------
function h = GetNNTDataStructure

figH = findobj( allchild(0), 'flat', 'tag', 'Neural Net Trainer' );
d    = get( figH, 'UserData' );
h    = d.h;

%---------------------------------------------------------------------------
%   Store the neural net trainer data structure
%---------------------------------------------------------------------------
function SetNNTDataStructure( h )

d.h  = h;
figH = findobj( allchild(0), 'flat', 'tag', 'Neural Net Trainer' );
set( figH, 'UserData', d );

