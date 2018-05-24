%% NEURALNETDEVELOPER This function builds, trains, and simulates simple neural nets.
%% Form
%  NeuralNetDeveloper( action, modifier  )
%-------------------------------------------------------------------------------
%% Inputs
%   action          (1,:)   Action to be taken by the developer (used mostly
%                           for callbacks)
%% Outputs
%   None

%% Copyright
% Copyright (c) 1998,1999, 2016 Princeton Satellite Systems, Inc. 
% All rights reserved.

function NeuralNetDeveloper( action, modifier )

% Initialize the Neural Net Developer
%------------------------------------
if( nargin < 1 )
  d.h = InitializeGUI;
  set( d.h.fig, 'UserData', d );
  action = 'none';
end

d = GetDataStructure;

% Perform actions
%----------------
switch action

  case 'new'
    d.h = New( 'new',   d.h );

  case 'open'
    d.h = Open( 'open',   d.h );

  case 'save'
    d.h = Save( 'save',   d.h );

  case 'help'
    d.h = Help( modifier,   d.h );

  case 'quit'
    d.h = Quit( 'quit',   d.h );

  case 'preferences'
    d.h = Preferences( modifier, d.h );

  case 'network'
    d.h = Network( modifier, d.h );
    
  case 'layer'
    d.h = Layer( modifier, d.h );
    
  case 'node'
    d.h = Node( modifier, d.h );
    
  case 'topology'
    d.h = Topology( modifier, d.h );

  case 'train'
    d.h = Train( modifier, d.h );
    
  case 'simulate'
    d.h = Simulate( modifier, d.h );
    
  case 'none'

  otherwise

end

% Store the data in the figure handle
%------------------------------------
if( ~strcmp( action, 'quit' ) )
  set( d.h.fig, 'UserData', d );
end

% Update the picture
%-------------------
drawnow

%---------------------------------------------------------------------------
%   Initialize the display
%---------------------------------------------------------------------------
function h = InitializeGUI

% The figure window
%------------------
          set(0,'units','pixels');
p       = get(0,'screensize');
height  = 500;
width   = 540;
bottom  = p(4) - height-200;
ltgreen = [0.9 1 0.9];
h.fig   = figure('name','Neural Net Developer','Units','pixels',...
                 'Position',[40 bottom width height ],'color',ltgreen,...
                 'NumberTitle','off','Tag', 'Neural Net Developer',...
                 'CloseRequestFcn', CreateCallbackString('quit') );

				 
% Initialize the development window and the network data
%-------------------------------------------------------
h = Preferences( 'initialize', h );
h =        Data( 'initialize', h );
h =     Network( 'initialize', h );
h =       Layer( 'initialize', h );
h =        Node( 'initialize', h );
h =    Topology( 'initialize', h );
h =       Train( 'initialize', h );
h =    Simulate( 'initialize', h );
h =         New( 'initialize', h );
h =        Open( 'initialize', h );
h =        Save( 'initialize', h );
h =        Help( 'initialize', h );
h =        Quit( 'initialize', h );
h =    Topology( 'drawNetwork',h );

%---------------------------------------------------------------------------
%   Network Statistics Display Area
%---------------------------------------------------------------------------
function h = Network( action, h )

defaultColor = [0.7333 0.7333 0.7333];
bColor       = [0.96 0.96 0.96];
white        = [1 1 1];

labelProps         = {'Parent',h.fig,'Units','pixels','Style','text', ...
                      'BackgroundColor',bColor,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',10,'HorizontalAlignment','right'};

editProps          = labelProps;
editProps(5:10)    = {'Style','edit','BackgroundColor',white,'FontName','helvetica'};

menuProps          = labelProps(1:14);             
menuProps(5:10)    = {'Style','popupmenu','BackgroundColor',defaultColor,'FontName','helvetica'};

frameProps         = labelProps(1:14);
frameProps(5:8)    = {'Style','frame','BackgroundColor',bColor};

displayProps       = labelProps;
displayProps(7:10) = {'BackgroundColor',defaultColor,'FontName','helvetica'};

% buttonProps        = labelProps(1:14);
% buttonProps(5:8)   = {'Style','pushbutton','BackgroundColor',defaultColor};

switch action
  case 'initialize'
 	  p      = get( h.fig, 'position' );
    top    = p(4) - 10;
    width  = ( p(3)-10*3 ) / 3;
    bottom = 270;
    left   = 10;
    
    % UIControls
    %-----------
                     uicontrol('Parent',h.fig,'visible','off');

                     uicontrol( frameProps{:}, 'Position', [left bottom width top-270 ] );

                     uicontrol( labelProps{:}, 'FontSize',12,'HorizontalAlignment','center',...
                               'Position',[left+5 top-29 width-10 20 ],...
                               'String','Network');

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-30-28 30 20 ],...
	                             'String','Type');

    h.netTypes     = uicontrol( menuProps{:},...
                               'Position',[left+40 top-30-25 120 20],...
	                             'String', 'MLFF (Multi-Layer Feed-Forward)');

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-55-29 75 20 ],...
	                             'String','Inputs');

    h.netInputs    = uicontrol( editProps{:},...
                               'Position',[left+85 top-55-25 55 20],...
	                             'Callback', Callback2('network','netInputs'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-80-29 75 20 ],...
	                             'String','Outputs');

    h.netOutputs   = uicontrol( editProps{:},...
                               'Position',[left+85 top-80-25 55 20],...
	                             'Callback', Callback2('network','netOutputs'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-105-29 75 20 ],...
	                             'String','Hidden Layers');

    h.netLayers    = uicontrol( editProps{:},...
                               'Position',[left+85 top-105-25 55 20],...
	                             'Callback', Callback2('network','netLayers'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-130-29 75 20 ],...
	                             'String','Total Layers');

                     uicontrol( displayProps{:},...
                               'Position',[left+85 top-130-25 55 20]);

    h.totalLayers  = uicontrol( displayProps{:},...
                               'Position',[left+85 top-130-19 55 10]);
    
    h              = Network('displayNetwork',h);

  case 'displayNetwork'

    set( h.netInputs,   'String', num2str( h.network.layer(1,1).inputs ) );
    set( h.netOutputs,  'String', num2str( h.network.layer( h.network.layers,1 ).outputs ) );
    set( h.netLayers,   'String', num2str( h.network.layers - 1 ) );
    set( h.totalLayers, 'String', num2str( h.network.layers ) );
        
  case 'netInputs'
    
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;

    [newInputs, valid] = GetEntry( h.netInputs, d );

    % Update number of inputs
    %------------------------
    if( ~valid )
      waitfor(gcf);
      h = Network('displayNetwork',h);
    else
      oldInputs                   = h.network.layer(1,1).inputs;
      h.network.layer(1,1).inputs = newInputs;

      % Actions if inputs added 
      %------------------------
      if( oldInputs < newInputs )
        x.layer = 1;
        x.x     = (oldInputs+1):newInputs;
        h       = Data( 'addInputColumn', h, x );
        h.saved = 0;

      % Actions if inputs deleted 
      %--------------------------
      elseif( newInputs < oldInputs )
        x.layer = 1;
        x.x     = (newInputs+1):oldInputs;
        h       = Data( 'deleteInputColumn', h, x);
        h.saved = 0;
      end;

      h = Layer('displayLayer',h); % Update layer statistics display if necessary
      h = Topology('drawNetwork',h);
    end;

  case 'netOutputs'
    
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;

    [newOutputs, valid] = GetEntry( h.netOutputs, d );

    % Update number of outputs
    %-------------------------
    if( ~valid )
      waitfor(gcf);
      h = Network('displayNetwork',h);
    else
      oldOutputs                                  = h.network.layer(h.network.layers,1).outputs;
      h.network.layer(h.network.layers,1).outputs = newOutputs;

      % Actions if outputs added 
      %-------------------------
      if( oldOutputs < newOutputs )
        x.layer = h.network.layers;
        x.x     = (oldOutputs+1):newOutputs;
        h       = Data( 'addOutputRow', h, x );
        h.saved = 0;

      % Actions if outputs deleted 
      %---------------------------
      elseif( newOutputs < oldOutputs )
        x.layer = h.network.layers;
        x.x     = (newOutputs+1):oldOutputs;
        h       = Data( 'deleteOutputRow', h, x);
        h.saved = 0;
      end;

      h = Layer('displayLayer',h); % Update layer statistics display if necessary
      h = Topology('drawNetwork',h);
    end;

  case 'netLayers'
    
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 0;

    [layers, valid] = GetEntry( h.netLayers, d );

    % Update number of layers
    %------------------------
    if( ~valid )
      waitfor(gcf);
      h = Network('displayNetwork',h);
    else
      oldLayers = h.network.layers;
      newLayers = layers + 1;

      % Actions if layers deleted 
      %--------------------------
      if( oldLayers > newLayers )     
        x = (newLayers+1):oldLayers;
        h = Data('deleteLayer',h,x);    % clear the network data structure
        h.saved = 0;

      % Actions if layers added
      %------------------------
      elseif( oldLayers < newLayers )
        x = (oldLayers):(newLayers-1);
        h = Data('addLayer',h,x);
        h.saved = 0;

      end;
      
      % Update Displays
      %----------------
      h = Network('displayNetwork',h);
      h = Layer('displayLayer',h);
      h = Topology('drawNetwork',h);

    end;

end

%---------------------------------------------------------------------------
%   Layer Statistics Display Area
%---------------------------------------------------------------------------
function h = Layer( action, h )

defaultColor = [0.7333 0.7333 0.7333];
bColor       = [0.96 0.96 0.96];
white        = [1 1 1];

labelProps         = {'Parent',h.fig,'Units','pixels','Style','text', ...
                      'BackgroundColor',bColor,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',10,'HorizontalAlignment','right'};
                        
editProps          = labelProps;
editProps(5:10)    = {'Style','edit','BackgroundColor',white,'FontName','helvetica'};

menuProps          = labelProps(1:14);             
menuProps(5:10)    = {'Style','popupmenu','BackgroundColor',defaultColor,'FontName','helvetica'};

frameProps         = labelProps(1:14);
frameProps(5:8)    = {'Style','frame','BackgroundColor',bColor};

displayProps       = labelProps;
displayProps(7:10) = {'BackgroundColor',defaultColor,'FontName','helvetica'};

buttonProps        = labelProps(1:14);
buttonProps(5:8)   = {'Style','pushbutton','BackgroundColor',defaultColor};

switch action

  case 'initialize'
 	  p      = get( h.fig, 'position' );
    top    = p(4) - 10;
    bottom = 270;
    width  = ( p(3)-10*3 ) / 3;
    left   = width+10*2;
    
    layerString    = 1:h.network.layers;
    layerString    = num2str(layerString');
                               
    % UIControls
    %-----------
                     uicontrol( frameProps{:},...
                               'Position',[left bottom width top-270 ]);

                     uicontrol( labelProps{:}, 'FontSize',12,...
                               'Position',[left+5 top-29 70 20 ],...
	                             'String','Layer');

    h.dispLayer    = uicontrol( menuProps{:}, 'FontSize',12,...
                               'Position',[left+80 top-29 60 20],...
                               'String', {layerString},...
	                             'Callback', Callback2('layer','displayLayer'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-45-25 50 40 ],...
	                             'String','Activation Function');

    h.layerFctn    = uicontrol( menuProps{:},...
                               'Position',[left+60 top-30-25 95 20],...
                               'String', {'Logistic','Sigmoid-Mag','Sign','Step','Linear','Tanh'},...
                               'Val',ActFctn2Num(h.network.layer(1,1).type),...
                               'Callback', Callback2('layer','activationFunction'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-55-29 65 20 ],...
	                             'String','Nodes');

    h.layerNodes   = uicontrol( editProps{:},...
                               'Position',[left+75 top-55-25 55 20],...
	                             'Callback', Callback2('layer','nodes'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-80-29 65 20 ],...
	                             'String','Inputs');

                     uicontrol( displayProps{:},...
                               'Position',[left+75 top-80-25 55 20]);

    h.layerInputs  = uicontrol( displayProps{:},...
                               'Position',[left+75 top-80-19 55 10]);

    h.addLayer     = uicontrol( buttonProps{:},...
                               'Position',[left+45 top-160 80 20 ],...
	                             'String','Add Layer',...
                               'Enable','off',...
                               'Callback', Callback2('layer','addLayer'));

    h.deleteLayer  = uicontrol( buttonProps{:},...
                               'Position',[left+45 top-185 80 20],...
	                             'String','Delete Layer',...
                               'Enable','off',...
                               'Callback', Callback2('layer','deleteLayer'));

    set( h.dispLayer, 'Val', 1 );
    
  case 'displayLayer'

    % Update the number of layers in the popupmenu
    %---------------------------------------------
    layerString = 1:h.network.layers;
    layerString = num2str(layerString');
    
    n = get(h.dispLayer,'Val');
    n = min( n, size(layerString,1) );
    
    set( h.dispLayer, 'Val', n );
    set( h.dispLayer, 'String', layerString );

    % Display layer parameters
    %-------------------------
    set( h.layerInputs, 'String', num2str( h.network.layer(n,1).inputs   ) );
    set( h.layerNodes,  'String', num2str( h.network.layer(n,1).outputs  ) );
    set( h.layerFctn,   'Val',    ActFctn2Num( h.network.layer(n,1).type ) );

    % Update node statistics display
    %-------------------------------
    h = Node('displayNode',h);

  case 'activationFunction'  

    n = get(h.dispLayer,'Val');

    % Update activation function
    %---------------------------
    x                         = get(h.layerFctn,'Val');
    h.network.layer(n,1).type = Num2ActFctn( x );
    h.saved = 0;
    
  case 'nodes'

    n  = get(h.dispLayer,'Val');
    %sx = get(h.layerNodes,'String');

    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type     = 'scalar';
    d.integer  = 'yes';
    d.min      = 1;

    [newNodes, valid] = GetEntry( h.layerNodes, d );

    % Update number of nodes
    %-----------------------
    if( ~valid )
      waitfor(gcf);
      h = Layer('displayLayer',h);
      return;
    else
      oldNodes = h.network.layer(n,1).outputs;

      % Delete Nodes
      %-------------
      if( oldNodes > newNodes )
        x.layer = n;
        x.x     = (newNodes+1):oldNodes;
        h       = Data('deleteNode',h,x);
        h.saved = 0;
        
      % Add Nodes
      %----------
      elseif( oldNodes < newNodes )
        x.layer = n;
        x.x     = (oldNodes+1):newNodes;
        h       = Data('addNode',h,x);
        h.saved = 0;

      end;

      % Update Displays
      %----------------
      h = Network('displayNetwork',h);
      h = Layer('displayLayer',h);
      h = Topology('drawNetwork',h);

    end;

  case 'clearLayer'   

    % Clear the layer statistics display
    %-----------------------------------
    set( h.dispLayer,   'Val', 1);
    h = Layer('displayLayer',h);

  case 'addLayer'
        warndlg({'This feature not yet available'})

    
  case 'deleteLayer'
        warndlg({'This feature not yet available'})

                             
end

%---------------------------------------------------------------------------
%   Node Statistics Display Area
%---------------------------------------------------------------------------
function h = Node( action, h )

defaultColor = [0.7333 0.7333 0.7333];
bColor       = [0.96 0.96 0.96];
white        = [1 1 1];

labelProps         = {'Parent',h.fig,'Units','pixels','Style','text', ...
                      'BackgroundColor',bColor,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',10,'HorizontalAlignment','right'};
                        
editProps          = labelProps;
editProps(5:10)    = {'Style','edit','BackgroundColor',white,'FontName','helvetica'};

menuProps          = labelProps(1:14);             
menuProps(5:10)    = {'Style','popupmenu','BackgroundColor',defaultColor,'FontName','helvetica'};

frameProps         = labelProps(1:14);
frameProps(5:8)    = {'Style','frame','BackgroundColor',bColor};

% displayProps       = labelProps;
% displayProps(7:10) = {'BackgroundColor',defaultColor,'FontName','helvetica'};

buttonProps        = labelProps(1:14);
buttonProps(5:8)   = {'Style','pushbutton','BackgroundColor',defaultColor};

switch action
  case 'initialize'

 	  p      = get( h.fig, 'position' );
    top    = p(4) - 10;
    bottom = 270;
    width  = ( p(3)-10*3 ) / 3;
    left   = 2*width+10*3;
    
    nodeString = 1:h.network.layer(1,1).outputs;
    nodeString = num2str(nodeString');
    
    inputString = 1:h.network.layer(1,1).inputs;
    inputString = num2str(inputString');
                               
   % UIControls
   %-----------
                     uicontrol( frameProps{:},...
                               'Position',[left bottom width top-270 ]);

                     uicontrol( labelProps{:},'FontSize',12,...
                               'Position',[left+5 top-29 65 20 ],...
	                             'String','Node');

    h.dispNode     = uicontrol( menuProps{:},'FontSize',12,...
                               'Position',[left+75 top-29 60 20],...
                               'String', nodeString,...
                               'Callback', Callback2('node','displayNode'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-30-29 65 20 ],...
	                             'String','Bias');

    h.nodeThresh   = uicontrol( editProps{:},...
                               'Position',[left+75 top-30-25 55 20],...
                               'Callback', Callback2('node', 'threshold'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-55-29 65 20 ],...
	                             'String','Input');

    h.nodeInput    = uicontrol( menuProps{:},...
                               'Position',[left+75 top-55-29 60 20],...
                               'String', inputString,...
	                             'Callback', Callback2('node','nodeInput'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-80-29 65 20 ],...
	                             'String','Weight');

    h.nodeWeight   = uicontrol( editProps{:},...
                               'Position',[left+75 top-80-25 55 20],...
	                             'Callback', Callback2('node','weight'));

    h.addNode      = uicontrol( buttonProps{:},...
                               'Position',[left+45 top-160 80 20 ],...
	                             'String','Add Node',...
                               'Enable','off',...
                               'Callback', Callback2('node','addNode'));

    h.deleteNode   = uicontrol( buttonProps{:},...
                               'Position',[left+45 top-185 80 20],...
	                             'String','Delete Node',...
                               'Enable','off',...
                               'Callback', Callback2('node','deleteNode'));

    h.initWeight   = uicontrol( buttonProps{:},...
                               'Position',[left+45 top-210 80 20],...
	                             'String','Initialize Weights',...
                               'Callback', Callback2('node','initWeights'));

    set( h.dispNode, 'Val', 1 );
    set( h.nodeInput, 'Val', 1 );
    
    h = Layer('displayLayer',h);
    h = Node( 'displayNode', h );
    
  case 'displayNode'
    j = get(h.dispLayer,'Val');
    
    % Update the number of nodes in the popupmenu
    %--------------------------------------------
    nodeString = 1:h.network.layer(j,1).outputs;
    nodeString = num2str(nodeString');
    
    n = get(h.dispNode, 'Val');
    n = min( n, size(nodeString,1) );
    
    set( h.dispNode, 'Val', n );
    set( h.dispNode, 'String', nodeString );

    % Display the values
    %-------------------
    set( h.nodeThresh, 'String', num2str( h.network.layer(j,1).w0(n) ) )
    h = Node('nodeInput',h);
    
  case 'threshold'
    j = get(h.dispLayer,'Val');
    n = get(h.dispNode, 'Val');
    %sx = get(h.nodeThresh, 'String');

    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type     = 'scalar';
    d.integer  = 'no';
    d.empty    = 'no';

    [x, valid] = GetEntry( h.nodeThresh, d );

    if( ~valid )
      waitfor(gcf);
      h = Node('displayNode',h);
    else
      h.network.layer(j,1).w0(n) = x;
      h = Topology('drawNetwork',h);
    end;

  case 'nodeInput'
    j = get(h.dispLayer,'Val');
    n = get(h.dispNode, 'Val');

    % Update the number of inputs in the popupmenu
    %---------------------------------------------
    inputString = 1:h.network.layer(j,1).inputs;
    inputString = num2str(inputString');
    
    m = get(h.nodeInput,'Val');
    m = min( m, size(inputString,1) );
    
    set( h.nodeInput, 'Val', m );
    set( h.nodeInput, 'String', inputString );

    % Display values
    %---------------
    set( h.nodeWeight, 'String', num2str( h.network.layer(j,1).w(n,m) ) );

  case 'weight'
    j  = get(h.dispLayer,  'Val');
    m  = get(h.nodeInput,  'Val');
    n  = get(h.dispNode,   'Val');

    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type     = 'scalar';
    d.integer  = 'no';
    d.empty    = 'no';

    [x, valid] = GetEntry( h.nodeWeight, d );

    if( ~valid )
      h = Node('displayNode',h);
      waitfor(gcf);
    else
      h.network.layer(j,1).w(n,m) = x;
      h = Topology('drawNetwork',h);
    end;

  case 'clearNode'
    set(h.dispNode,   'Val', 1);
    h = Node('clearWeights',h);

  case 'clearWeights'
    set(h.nodeInput,  'Val', 1);
    h = Node('displayNode',h);
    
  case 'addNode'
        warndlg({'This feature not yet available'})

  
  case 'deleteNode'
        warndlg({'This feature not yet available'})

  case 'initWeights'
    if( h.preferences.initWarning )
      confirm = questdlgwarn( 'Reinitialize all weights and biases?', 'Warning', 'Yes', 'No', 'Don''t ask me again', 'No');
      switch confirm
        case 'No'
          return;
        case 'Don''t ask me again'
          h.preferences.initWarning = 0;
      end;
    end;

    for j = 1:h.network.layers

      if( strcmp(h.preferences.defaultWeights,'zero') )
        h.network.layer(j,1).w  = zeros(h.network.layer(j,1).outputs,h.network.layer(j,1).inputs);
      else
        h.network.layer(j,1).w  = rand(h.network.layer(j,1).outputs,h.network.layer(j,1).inputs) - 0.5;
      end;

      if( strcmp(h.preferences.defaultThresh,'zero') )
        h.network.layer(j,1).w0 = zeros(h.network.layer(j,1).outputs,1);
      else
        h.network.layer(j,1).w0 = rand(h.network.layer(j,1).outputs,1) - 0.5;
      end;

    end;

    h = Node('displayNode',h);
    h = Topology('drawNetwork',h);
end

%---------------------------------------------------------------------------
%   Scrolling Topology/Diagram function
%---------------------------------------------------------------------------
function h = Topology( action, h )

%defaultColor = [0.7333 0.7333 0.7333];
bColor       = [0.96 0.96 0.96];
white        = [1 1 1];
ltgreen      = [0.9 1 0.9];

labelProps         = {'Parent',h.fig,'Units','pixels','Style','text', ...
                        'BackgroundColor',bColor,'FontName','Helvetica', ...
                        'fontunits','pixels','FontSize',10,'HorizontalAlignment','right'};

editProps          = labelProps;
editProps(5:10)    = {'Style','edit','BackgroundColor',white,'FontName','Helvetica'};

% frameProps         = labelProps(1:14);
% frameProps(5:8)    = {'Style','frame','BackgroundColor',bColor};
% 
% sliderProps        = {'Parent',h.fig,'Units','pixels','Style','slider', ...
%                       'Max',1,'Min',0,'Value',0};
switch action
  case 'initialize'

    % UIControls
    %-----------
                     uicontrol( labelProps{:},'BackgroundColor',ltgreen,'HorizontalAlignment','left',...
                               'Position',[10 240 25 17 ],...
	                             'String','Path');

    h.path         = uicontrol( editProps{:},'BackgroundColor',bColor,'HorizontalAlignment','left',...
	                             'Position',[40 242 290 20], ...
                               'Callback', Callback2('topology','path'));

%     h.scrollup     = uicontrol( sliderProps{:},'value',1,...
% 	                             'Position',[330 20 20 220],...
%                                'Callback', Callback2('edit','scroll'));
% 	 
%     h.scrollacross = uicontrol( sliderProps{:},...
% 	                             'Position',[10 0 320 20],...
%                                'Callback', Callback2('edit','scroll'));

    h.axes         = axes( 'Parent', h.fig, 'box', 'on', 'units','pixels','fontunits','pixels',...
                           'Position', [20 15 330 220], 'color', bColor);

    h = Topology('displayPath',h);

  case 'drawNetwork'

    green = [0 0.7 0];
    blue  = [0 0   1];
    red   = [1 0   0];

    % Find max number of nodes
    %-------------------------
    maxNodes = h.network.layer(1,1).inputs;
    for j = 1:h.network.layers
      if( h.network.layer(j,1).outputs > maxNodes )
        maxNodes = h.network.layer(j,1).outputs;
      end;
    end;

    yLim = [0 maxNodes+1];
    xLim = [-1 h.network.layers+1];

    % Clear and prepare axes
    %-----------------------
    axes(h.axes);
    cla;
    axis ij;
    hold on;

    % Compute input locations
    %------------------------
    xPlot(1).x = zeros(h.network.layer(1,1).inputs,1);
 
    if( h.network.layer(1,1).inputs == maxNodes )
      xPlot(1).y = 1:h.network.layer(1,1).inputs;
    else
      diff   = (maxNodes-1) / (h.network.layer(1,1).inputs+1);
      xPlot(1).y = 1 + diff*(1:h.network.layer(1,1).inputs);
    end;

    xPlot(1).y     = xPlot(1).y(:);
    xPlot(1).color = ones(length(xPlot(1).y),1)*green;

    % Compute node locations
    %-----------------------
    for j = 1:h.network.layers
      xPlot(j+1).x = j*ones(h.network.layer(j,1).outputs,1); %#ok<*AGROW>

      if( h.network.layer(j,1).outputs == maxNodes )
        xPlot(j+1).y = 1:h.network.layer(j,1).outputs;
      else
        diff       = (maxNodes-1) / (h.network.layer(j,1).outputs+1);
        xPlot(j+1).y = 1 + diff*(1:h.network.layer(j,1).outputs);
      end;

      xPlot(j+1).y     = xPlot(j+1).y(:);
      xPlot(j+1).color = ones(length(xPlot(j+1).y),1)*blue;

      if( h.preferences.plotThresh )
        k                     = find( h.network.layer(j,1).w0 < 0 );
        xPlot(j+1).color(k,:) = ones(length(k),1)*red;
      end;

    end;

    % Plot inputs
    %------------
    plot( xPlot(1).x, xPlot(1).y, 'o', 'Color', green );
    plot( xPlot(1).x, xPlot(1).y, 'x', 'Color', green );
 
    % Plot nodes
    %-----------
    for j = 2:h.network.layers+1
      for k = 1:length(xPlot(j).y)
        plot( xPlot(j).x(k,:), xPlot(j).y(k,:), 'o', 'Color', xPlot(j).color(k,:) );
      end;
    end;
   
    % Plot neurons
    %-------------
    if( h.preferences.plotNeurons )

      xLim = [-0.5 xLim(2)];

      for j = 2:h.network.layers+1
        for k = 1:length(xPlot(j-1).y)
          for m = 1:length(xPlot(j).y)
            xNeuron  = [xPlot(j-1).x(k) xPlot(j).x(m)];
            yNeuron  = [xPlot(j-1).y(k) xPlot(j).y(m)];

            neuronColor = blue;
            if( h.preferences.plotWeights && ( h.network.layer(j-1,1).w(m,k) < 0 ) )
              neuronColor = red;
            end;

            plot( xNeuron, yNeuron, 'Color', neuronColor );
          end;
        end;
      end;

      % Plot outputs
      %-------------
      xPlot(h.network.layers+2).y = xPlot(h.network.layers+1).y; 
      xPlot(h.network.layers+2).x = xPlot(h.network.layers+1).x + 0.5;
      plot( xPlot(h.network.layers+2).x, xPlot(h.network.layers+2).y, 'mx')

      xOut = [xPlot(h.network.layers+1).x xPlot(h.network.layers+2).x];
      yOut = [xPlot(h.network.layers+1).y xPlot(h.network.layers+2).y];
      plot( xOut',yOut','m')


    end;

    % Clean up plot
    %--------------
    axis([xLim yLim]);
    set(h.axes, 'XTick', 0:h.network.layers);
    set(h.axes, 'YTick', 1:maxNodes);

  case 'path'
    p = get( h.path, 'String' );
    if exist(p,'dir')
      w = what(p);
      h.network.path = w.path;
      eval(['cd(''' h.network.path ''');'])
      set(h.path,'String',w.path)
    else
      warndlg('Invalid path name.')
    end

  case 'displayPath'
    set(h.path, 'String', h.network.path)
    cd(h.network.path)

end

%---------------------------------------------------------------------------
%   Train button
%---------------------------------------------------------------------------
function h = Train( action, h )

% defaultColor = [0.7333 0.7333 0.7333];
% bColor       = [0.96 0.96 0.96];
% white        = [1 1 1];
% pink         = [1 0.9 0.9];
% ltblue       = [0.9 0.9 1];
blue         = [0.7 0.7 1];

buttonProps  = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                'BackgroundColor',blue,'FontName','Helvetica', ...
                'fontunits','pixels','FontSize',12,'HorizontalAlignment','center'};

switch action
  case 'initialize'
 	  %p       = get( h.fig, 'position' );
	  h.train = uicontrol( buttonProps{:},...
                        'Position',[365 150 80 60],...
	                      'String', 'Train',...
                        'Callback', Callback2('train','get train'));
                        
  case 'get train'

    % Determine if training window already exists
    %--------------------------------------------
    h.trainFig = findobj(allchild(0),'flat','Tag','Neural Net Trainer');

    if( isempty(h.trainFig) )
      NeuralNetTrainer( 'initialize');
      h.trainFig = findobj(allchild(0),'flat','Tag','Neural Net Trainer');
    else
      figure( h.trainFig );
      NeuralNetTrainer( 'data', 'get network data' );
    end;

  case 'close train'
    NeuralNetTrainer('close');
    h.trainFig = [];
end

%---------------------------------------------------------------------------
%   Simulate button
%---------------------------------------------------------------------------
function h = Simulate( action, h )

defaultColor = [0.7333 0.7333 0.7333];
% bColor       = [0.96 0.96 0.96];
% white        = [1 1 1];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                      'BackgroundColor',defaultColor,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',12,'HorizontalAlignment','center'};

switch action
  case 'initialize'
 	  %p          = get( h.fig, 'position' );
	  h.sim      = uicontrol( buttonProps{:},...
                           'Position',[365 70 80 60],...
	                         'String', 'Simulate',...
                           'Enable','off',...
                           'Callback', Callback2('simulate','get sim'));
                           
  case 'get sim'
        warndlg({'This feature not yet available'})


  case 'close sim'
    close( h.simFig );
    h.simFig = [];
end

%---------------------------------------------------------------------------
%   New button
%---------------------------------------------------------------------------
function h = New( action, h )

defaultColor = [0.7333 0.7333 0.7333];
% bColor       = [0.96 0.96 0.96];
% white        = [1 1 1];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                      'BackgroundColor',defaultColor,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
 	  %p      = get( h.fig, 'position' );
	  h.new  = uicontrol( buttonProps{:},...
                       'Position',[ 460 200 80 40 ],...
	                     'String', 'New',...
                       'Callback', Callback2('new','new'));
                       
  case 'new'
    if ~h.saved
      buttonName = questdlg('Do you want to save the current network?');
      if strcmp( buttonName, 'Yes' )
        h = Save( 'save', h );
      elseif strcmp( buttonName, 'Cancel' )
        return;
      end
    end    
    h = Data( 'initialize', h );
    h = Network( 'displayNetwork', h );
    h = Topology( 'drawNetwork', h );
    h.saved = 1;

end

%---------------------------------------------------------------------------
%   Open button
%---------------------------------------------------------------------------
function h = Open( action, h )

defaultColor = [0.7333 0.7333 0.7333];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                      'BackgroundColor',defaultColor,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
	  h.open     = uicontrol( buttonProps{:},...
                           'Position',[460 150 80 40],...
	                         'String', 'Open',...
                           'Callback', Callback2('open','open'));
  case 'open'
    [filename, pathname] = uigetfile({'*.mat','MAT-files';...
                                      [h.network.path '*.mat'],'Networks'},...
                                      'Choose a file');
    if ~ischar(filename) || ~ischar(pathname)
      return
    end     
    fname = fullfile(pathname, filename);
    temp = load(fname);
    s = strfind(filename, '.mat');
    h.network = temp.(filename(1:s-1));
    clear temp
    set(h.fig,'Name',['Neural Net Developer: ' filename(1:s-1)])
    h.saved = 1;
    h.network.path = pathname;
    set(h.path,'string',pathname);       
    h = Network('displayNetwork', h);
    h = Topology('drawNetwork',h);
    h = Topology('displayPath',h);

end

%---------------------------------------------------------------------------
%   Save button
%---------------------------------------------------------------------------
function h = Save( action, h )

defaultColor = [0.7333 0.7333 0.7333];
% bColor       = [0.96 0.96 0.96];
% white        = [1 1 1];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                      'BackgroundColor',defaultColor,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',10,'HorizontalAlignment','center'};
                        
switch action
  case 'initialize'
%  	  p          = get( h.fig, 'position' );
	  h.save     = uicontrol( buttonProps{:},...
                           'Position',[460 100 80 40],...
	                         'String', 'Save',...
                           'Callback', Callback2('save','save'));
    h.saved    = 1;

  case 'save'
    [filename, pathname] = uiputfile([h.network.path '*.mat'],'Save As');
    if ~ischar(filename) || ~ischar(pathname)
      return
    end
    h.network.path = pathname;
    [~,name] = fileparts(filename);
    set(h.path,'string',pathname)
    eval([name ' = h.network;'])
    fname = fullfile(pathname, filename);
    eval(['save(''' fname ''',''' name ''');'])
    set(h.fig,'Name',['Neural Net Developer: ' filename])
    h.saved = 1;

end

%---------------------------------------------------------------------------
%   Quit button
%---------------------------------------------------------------------------
function h = Quit( action, h )

% defaultColor = [0.7333 0.7333 0.7333];
% bColor       = [0.96 0.96 0.96];
% white        = [1 1 1];
red          = [0.95 0.2 0.25];
  
buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                      'BackgroundColor',red,'FontName','Helvetica', ...
                      'fontunits','pixels','FontSize',10,'HorizontalAlignment','center'};
                        
switch action
  case 'initialize'
    quitString = CreateCallbackString('quit');
    h.quit     = uicontrol( buttonProps{:},...
                           'Position',[460 50 80 40],...
                           'String','QUIT',...
                           'Callback', quitString);
                       
  case 'quit'
    if ~h.saved
      buttonName = questdlg('Do you want to save the network before quitting?');
      if strcmp( buttonName, 'Yes' )
        h = Save( 'save', h );
      elseif strcmp( buttonName, 'Cancel' )
        return;
      end
    end
    figs       = allchild(0);
    h.prefFig  = findobj(figs,'flat','Tag','Neural Net Preferences');
    h.trainFig = findobj(figs,'flat','Tag','Neural Net Trainer');

    if( ~isempty(h.prefFig) )
        h = Preferences( 'close preferences', h );
    end
    if( ~isempty(h.trainFig) )
        h = Train( 'close train', h );
    end;

    closereq;

end

%---------------------------------------------------------------------------
%   Help button
%---------------------------------------------------------------------------
function h = Help( action, h )

green        = [0.25 0.9 0.25];
  
buttonProps  = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                'BackgroundColor',green,'FontName','Helvetica', ...
                'fontunits','pixels','FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.help = uicontrol( buttonProps{:},...
                       'Position',[460 0 80 40],...
                       'String','HELP',...
                       'enable','off',...
                       'Callback', Callback2( 'help','get help'));
                       
  case 'get help'
    HelpSystem('initialize','OnlineHelp','Neural Network Developer')

end

%---------------------------------------------------------------------------
%   Preferences button and window
%---------------------------------------------------------------------------
function h = Preferences( action, h )

defaultColor = [0.7333 0.7333 0.7333];
bColor       = [0.96 0.96 0.96];
white        = [1 1 1];
red          = [0.95 0.2 0.25];
yellow       = [1 1 0.6];  
green        = [0.25 0.85 0.25];

figureProps  = {'Units','pixels','NumberTitle', 'off','Color',yellow};

                        
switch action

  case 'initialize'

    buttonProps = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
                   'BackgroundColor',defaultColor,'FontName','Helvetica', ...
                   'fontunits','pixels','FontSize',10,'HorizontalAlignment','center'};
                        
    h.pref      = uicontrol( buttonProps{:},'BackgroundColor',yellow,...
                            'Position',[365 0 80 40],...
	                          'String','Preferences',...
                            'Callback', Callback2('preferences','get preferences'));

    h.preferences.initWarning = 1;  % warning for reinitialization of weights on

    % Load saved preferences if they exist
    %-------------------------------------
    if( exist('NNPreferences.mat','file') )
      vars = load('NNPreferences');

      names = fieldnames( vars.nnPref );
      for j = 1:length(names)
        h.preferences.(names{j}) = vars.nnPref.(names{j});
      end

      tempPath            = fileparts( which('NNPreferences.mat') );
      h.preferences.file  = fullfile(tempPath,'NNPreferences');

    else
      w = what('NeuralNets');
      if isempty(w)
        tempPath = cd;        
        h.preferences.file = fullfile(tempPath,'NNPreferences');
      else
         h.preferences.file = fullfile(w(1).path,'NNPreferences');
      end

      % Default Values
      %---------------
      h.preferences.defaultOutputs = 1;
      h.preferences.defaultInputs  = 4;
      h.preferences.defaultLayers  = 4;
      h.preferences.defaultNodes   = 2;
      h.preferences.defaultType    = 'MLFF';
      h.preferences.defaultActFctn = 'tanh';
      h.preferences.defaultWeights = 'rand';
      h.preferences.defaultThresh  = 'rand';

      % Plotting preferences
      %---------------------
      h.preferences.plotNeurons = 1;
      h.preferences.plotWeights = 1;
      h.preferences.plotThresh  = 1;

    end;

  case 'get preferences'

    % Determine if preferences window already exists
    %-----------------------------------------------
    h.prefFig = findobj(allchild(0),'flat','Tag','Neural Net Preferences');

    if( isempty(h.prefFig) )
      h.preferences.newPref = 0;

%       p1         = get( h.pref, 'position' );
      p2         = get( h.fig, 'position' );
      p(1)       = p2(1) + 50;
      p(2)       = p2(2) - 20;
      width1     = 360;
      height1    = 380;
      left1      = 10;
      top1       = height1 - 10;
      height     = 220;
      bottom     = height1 - height - 10;
      bottom1    = bottom;

      h.prefFig  = figure( figureProps{:},...
                          'Name','Neural Net Preferences',...
                          'Tag','Neural Net Preferences',...
                          'Position',[p(1) p(2) width1 height1],...
                          'CloseRequestFcn', Callback2('preferences','close preferences'));

      labelProps           = {'Parent',h.prefFig,'Units','pixels','Style','text', ...
                              'BackgroundColor',bColor,'FontName','Helvetica', ...
                              'fontunits','pixels','FontSize',10,'HorizontalAlignment','right'};

      editProps            = labelProps;
      editProps(5:10)      = {'Style','edit','BackgroundColor',white,'FontName','helvetica'};

      menuProps            = labelProps(1:14);             
      menuProps(5:10)      = {'Style','popupmenu','BackgroundColor',defaultColor,'FontName','helvetica'};

      frameProps           = labelProps(1:14);
      frameProps(5:8)      = {'Style','frame','BackgroundColor',bColor};

%       displayProps         = labelProps;
%       displayProps(7:10)   = {'BackgroundColor',defaultColor,'FontName','helvetica'};

      buttonProps          = labelProps(1:14);
      buttonProps(5:8)     = {'Style','pushbutton','BackgroundColor',defaultColor};

      checkboxProps        = labelProps;
      checkboxProps(5:8)   = {'Style','checkbox','BackgroundColor',white};
      checkboxProps(13:14) = {'FontSize',12};

      % Default Values
      %---------------
      left   = left1;
      top    = top1;
      width  = width1-left;

                uicontrol( frameProps{:},...
                          'BackgroundColor',white,...
                          'Position',[left  bottom  width height] );

                uicontrol( labelProps{:},'FontSize',14,'FontWeight','bold',...
                          'Position',[left+5 top-30 width-left-10 20 ],...
                          'HorizontalAlignment','center',...
                          'BackgroundColor',white,...
	                        'String','Default Values');

      % New Network
      %------------
      left   = left+10;
      bottom = bottom+10;
      width  = (width - 3*10) / 2;
      height = height - 40;
      top    = top - 30;

                     uicontrol( frameProps{:}, 'Position', [left bottom width height ] );

                     uicontrol( labelProps{1:14}, 'FontSize',12,'HorizontalAlignment','center',...
                               'Position',[left+5 top-29 width-10 20 ],...
                               'String','New Network');

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-30-28 30 20 ],...
	                             'String','Type');

      h.defTypes   = uicontrol( menuProps{:},...
                               'Position',[left+40 top-30-25 115 20],...
	                             'String', 'MLFF (Multi-Layer Feed-Forward)');

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-55-29 75 20 ],...
	                             'String','Inputs');

      h.defInputs  = uicontrol( editProps{:},...
                               'Position',[left+85 top-55-25 55 20],...
                               'String', num2str(h.preferences.defaultInputs),...
	                             'Callback', Callback2('preferences','netInputs'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-80-29 75 20 ],...
	                             'String','Outputs');

      h.defOutputs = uicontrol( editProps{:},...
                               'Position',[left+85 top-80-25 55 20],...
                               'String', num2str(h.preferences.defaultOutputs),...
	                             'Callback', Callback2('preferences','netOutputs'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-105-29 75 20 ],...
	                             'String','Hidden Layers');

      h.defLayers  = uicontrol( editProps{:},...
                               'Position',[left+85 top-105-25 55 20],...
                               'String', num2str(h.preferences.defaultLayers-1),...
	                             'Callback', Callback2('preferences','netLayers'));

      % New layer
      %----------
      left   = left + width + 10;
      height = (height-10)/2;
      bottom = bottom+height+10;

                     uicontrol( frameProps{:}, 'Position', [left bottom width height ] );

                     uicontrol( labelProps{:}, 'FontSize',12,'HorizontalAlignment','center',...
                               'Position',[left+5 top-29 width-10 20 ],...
	                             'String','New Layer');

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-45-25 50 40 ],...
	                             'String','Activation Function');

      h.defFctn    = uicontrol( menuProps{:},...
                               'Position',[left+60 top-30-25 95 20],...
                               'String', {'Logistic','Sigmoid-Mag','Sign','Step','Linear','Tanh'},...
                               'Val',ActFctn2Num(h.preferences.defaultActFctn),...
                               'Callback', Callback2('preferences','activationFunction'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-55-29 65 20 ],...
	                             'String','Nodes');

      h.defNodes   = uicontrol( editProps{:},...
                               'Position',[left+75 top-55-25 55 20],...
                               'String', num2str(h.preferences.defaultNodes),...
	                             'Callback', Callback2('preferences','nodes'));

      % New Node
      %---------
      bottom = bottom - height - 10;
      top    = top - height - 10;

                     uicontrol( frameProps{:}, 'Position', [left bottom width height ] );

                     uicontrol( labelProps{:}, 'FontSize',12,'HorizontalAlignment','center',...
                               'Position',[left+5 top-29 width-10 20 ],...
	                             'String','New Node');

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-30-29 55 20 ],...
	                             'String','Bias');

      h.defThresh  = uicontrol( menuProps{:},...
                               'Position',[left+65 top-30-25 75 20],...
                               'String', {'Random','Zero'},...
                               'Val',InitFctn2Num(h.preferences.defaultThresh),...
                               'Callback', Callback2('preferences', 'threshold'));

                     uicontrol( labelProps{:},...
                               'Position',[left+5 top-55-29 55 20 ],...
	                             'String','Weight');

      h.defWeight  = uicontrol( menuProps{:},...
                               'Position',[left+65 top-55-25 75 20],...
                               'String', {'Random','Zero'},...
                               'Val',InitFctn2Num(h.preferences.defaultWeights),...
	                             'Callback', Callback2('preferences','weight'));

      % Display parameters
      %-------------------
      left   = left1;
      bottom = 0;
      height = bottom1 - 10;
      width  = width1-100;
      top    = height - 10;

                uicontrol( frameProps{:},...
                          'BackgroundColor',white,...
                          'Position',[left  bottom  width height] );

                uicontrol( labelProps{:},'FontSize',14,'FontWeight','bold',...
                          'Position',[left+5 top-20 width-left-10 20 ],...
                          'HorizontalAlignment','center',...
                          'BackgroundColor',white,...
	                        'String','Display Options');

      h.plotNeurons = uicontrol( checkboxProps{:},...
                                'Position', [width/4 top-40-20 width/2 20],...
                                'String','Display Neurons',...
                                'Val',h.preferences.plotNeurons,...
                                'Callback', Callback2('preferences','display Neurons'));

      h.plotThresh  = uicontrol( checkboxProps{:},...
                                'Position', [width/4 top-65-20 width/2 20],...
                                'String','Display Biases',...
                                'Val',h.preferences.plotThresh,...
                                'Callback', Callback2('preferences','display Thresholds'));

      h.plotWeights = uicontrol( checkboxProps{:},...
                                'Position', [width/4 top-90-20 width/2 20],...
                                'String','Display Weights',...
                                'Val',h.preferences.plotWeights,...
                                'Callback', Callback2('preferences','display Weights'));


      % Buttons
      %--------
   	  h.savePref  = uicontrol( buttonProps{:},...
                              'Position',[width1-80 100 80 40],...
	                            'String', 'Save',...
                              'Callback', Callback2('preferences','save preferences'));

      h.closePref = uicontrol( buttonProps{:},...
                              'Position',[width1-80 50 80 40],...
                              'BackgroundColor',red,...
                              'String','CLOSE',...
                              'Callback', Callback2('preferences','close preferences'));
                       
      h.helpPref  = uicontrol( buttonProps{:},...
                              'Position',[width1-80 0 80 40],...
                              'BackgroundColor',green,...
                              'String','HELP',...
                              'Callback', Callback2('preferences','help preferences'));


    else
      figure( h.prefFig );
    end;

  case 'netInputs'
    % Set up valid parameters data structure
    %---------------------------------------
    clear d;
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;

    [x, valid] = GetEntry( h.defInputs, d );

    if( ~valid )
      set( h.defInputs, h.preferences.defaultInputs );
    else
      h.preferences.defaultInputs = x;
      h.preferences.newPref       = 1;
    end;

  case 'netOutputs'
    % Set up valid parameters data structure
    %---------------------------------------
    clear d;
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;

    [x, valid] = GetEntry( h.defOutputs, d );

    if( ~valid )
      set( h.defOutputs, h.preferences.defaultOutputs );
    else
      h.preferences.defaultOutputs = x;
      h.preferences.newPref        = 1;
    end;

  case 'netLayers'
    % Set up valid parameters data structure
    %---------------------------------------
    clear d;
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 0;

    [x, valid] = GetEntry( h.defLayers, d );

    if( ~valid )
      set( h.defLayers, h.preferences.defaultLayers-1 );
    else
      h.preferences.defaultLayers = x+1;
      h.preferences.newPref       = 1;
    end;

  case 'activationFunction'
    h.preferences.defaultActFctn = Num2ActFctn( get(h.defFctn,'Val') );
    h.preferences.newPref        = 1;

  case 'nodes'
    % Set up valid parameters data structure
    %---------------------------------------
    clear d;
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;

    [x, valid] = GetEntry( h.defNodes, d );

    if( ~valid )
      set( h.defNodes, h.preferences.defaultNodes );
    else
      h.preferences.defaultNodes = x;
      h.preferences.newPref      = 1;
    end;

  case 'threshold'
    h.preferences.defaultThresh  = Num2InitFctn( get(h.defThresh,'Val') );
    h.preferences.newPref        = 1;

  case 'weight'
    h.preferences.defaultWeights = Num2InitFctn( get(h.defWeight,'Val') );
    h.preferences.newPref        = 1;

  case 'display Neurons'
    h.preferences.plotNeurons = get(h.plotNeurons,'Val');
    h.preferences.newPref     = 1;
    h = Topology('drawNetwork', h);
    figure( h.prefFig );

  case 'display Thresholds'
    h.preferences.plotThresh = get(h.plotThresh,'Val');
    h.preferences.newPref    = 1;
    h = Topology('drawNetwork', h);
    figure( h.prefFig );

  case 'display Weights'
    h.preferences.plotWeights = get(h.plotWeights,'Val');
    h.preferences.newPref     = 1;
    h = Topology('drawNetwork', h);
    figure( h.prefFig );

  case 'save preferences'

    h.preferences.newPref = 0;

    names = fieldnames( h.preferences );
    for j = 1:length(names)
      eval(['nnPref.' names{j} ' = h.preferences.' names{j} ';']);
    end;

    save(h.preferences.file, 'nnPref');
    clear nnTrainPref;

  case 'help preferences'
    HelpSystem('initialize','OnlineHelp','Neural Net Preferences')


  case 'close preferences'

    figure( h.prefFig )

    if( h.preferences.newPref )
      saveQuest = questdlg('Save these preferences for future sessions?');

      switch saveQuest
        case 'Cancel'
          return;
     
        case 'Yes'
          h = Preferences('save preferences', h);

      end;

    end;
 
    delete( h.prefFig );
    h.prefFig = [];

end;

%---------------------------------------------------------------------------
%   Network Data
%---------------------------------------------------------------------------
function h = Data( action, h, modifier )

switch action
  case 'initialize'

    % Initial overall network parameters
    %-----------------------------------
    h.network.type    = h.preferences.defaultType;
    h.network.layers  = 0;
    w = what('NeuralNets');
    if isempty(w)
      h.network.path = cd;
    else
      h.network.path = w.path;
    end
  
    % Create default network
    %-----------------------
    x = 1:h.preferences.defaultLayers;
    h = Data( 'addLayer', h, x );

  case 'deleteLayer'
    x = sort( modifier );

    % Verify layers to be deleted
    %----------------------------
    if( x(1) < 1 )
      errordlg({'Layers to be deleted must be positive'})
      return;
    end;
 
    x = flipud( x(:) );
    if( x(1) > h.network.layers+1 )
      errordlg({'Attempt to delete non-existent layer'});
      return;
    end;

    for j = 1:length(x)

      % Delete last layer
      %------------------
      if( x(j) == h.network.layers )
        oldOutputs = h.network.layer(x(j)-1,1).outputs;
        newOutputs = h.network.layer(x(j),1).outputs;

        if( oldOutputs < newOutputs )
          temp.layer = x(j)-1;
          temp.x     = (oldOutputs+1):newOutputs;
          h          = Data( 'addOutputRow', h, temp );
        elseif( oldOutputs > newOutputs )
          temp.layer = x(j)-1;
          temp.x     = (newOutputs+1):oldOutputs;
          h          = Data( 'deleteOutputRow', h, temp );
        end;

        h.network.layer(x(j)-1,1).outputs = newOutputs;

      % Delete first layer
      %-------------------
      elseif( x(j) == 1 )              
        oldInputs = h.network.layer(x(j)+1,1).inputs;
        newInputs = h.network.layer(x(j),1).inputs;

        if( oldInputs < newInputs )
          temp.layer = x(j)+1;
          temp.x     = (oldInputs+1):newInputs;
          h          = Data( 'addInputColumn', h, temp );
        elseif( oldInputs > newInputs )
          temp.layer = x(j)+1;
          temp.x     = (newInputs+1):oldInputs;
          h          = Data( 'deleteInputColumn', h, temp );
        end;

        h.network.layer(x(j)+1,1).inputs  = newInputs;

      % Delete middle layer
      %--------------------
      else
        oldInputs = h.network.layer(x(j)+1,1).inputs;
        newInputs = h.network.layer(x(j),1).inputs;

        if( oldInputs < newInputs )
          temp.layer = x(j)+1;
          temp.x     = (oldInputs+1):newInputs;
          h          = Data( 'addInputColumn', h, temp );
        elseif( oldInputs > newInputs )
          temp.layer = x(j)+1;
          temp.x     = (newInputs+1):oldInputs;
          h          = Data( 'deleteInputColumn', h, temp );
        end;

        h.network.layer(x(j)+1,1).inputs  = h.network.layer(x(j),1).inputs;
      end;

      h.network.layer(x(j)) = [];
      h.network.layers      = h.network.layers - 1;

    end;

  case 'addLayer'             
    x         = sort( modifier );
    addLayers = length(x);

    % Verify layers to be added
    %--------------------------
    if( x(1) < 1 )
      errordlg({'Layers to be added must be positive'})
      return;
    elseif( x(1) > h.network.layers+1 )
      errordlg({'Gap in layer numbering at end of network'});
      return;
    end;
 
    for j = 2:addLayers
      if( x(j) ~= (x(j-1) + 1) )
        errordlg({'Attempt to add non-consecutive layers'});
        return;
      end;
    end;

    % Store useful data
    %------------------
    if( h.network.layers == 0 )
      inputs  = h.preferences.defaultInputs;
      outputs = h.preferences.defaultOutputs;
    else
      inputs  = h.network.layer(1,1).inputs;
      outputs = h.network.layer(h.network.layers,1).outputs;
    end;

    % Move layers above those to be added
    %------------------------------------
    if( x(1) <= h.network.layers )
      n                                        = x(1):h.network.layers;
      h.network.layer(n+addLayers,1)           = h.network.layer(n,1);

      oldInputs = h.network.layer(n(1)+addLayers,1).inputs;
      newInputs = h.preferences.defaultNodes;

      if( oldInputs < newInputs )
        temp.layer = n(1)+addLayers;
        temp.x     = (oldInputs+1):newInputs;
        h          = Data( 'addInputColumn', h, temp );
      elseif( oldInputs > newInputs )
        temp.layer = n(1)+addLayers;
        temp.x     = (newInputs+1):oldInputs;
        h          = Data( 'deleteInputColumn', h, temp );
      end;

      h.network.layer(n(1)+addLayers,1).inputs = newInputs;
    end;

    h.network.layers = h.network.layers+addLayers;

    % Insert the layers to be added 
    %------------------------------
    for j = 1:addLayers

      if( x(j) == 1 )
        h.network.layer(x(j),1).inputs  = inputs;
      else
        h.network.layer(x(j),1).inputs  = h.network.layer(x(j)-1,1).outputs;
      end;

      if( x(j) == h.network.layers )
        h.network.layer(x(j),1).outputs = outputs;
      else
        h.network.layer(x(j),1).outputs = h.preferences.defaultNodes;
      end;

      h.network.layer(x(j),1).type = h.preferences.defaultActFctn;

      if( strcmp(h.preferences.defaultWeights,'zero') )
        h.network.layer(x(j),1).w  = zeros(h.network.layer(x(j),1).outputs,h.network.layer(x(j),1).inputs);
      else
        h.network.layer(x(j),1).w  = rand(h.network.layer(x(j),1).outputs,h.network.layer(x(j),1).inputs) - 0.5;
      end;

      if( strcmp(h.preferences.defaultThresh,'zero') )
        h.network.layer(x(j),1).w0 = zeros(h.network.layer(x(j),1).outputs,1);
      else
        h.network.layer(x(j),1).w0 = rand(h.network.layer(x(j),1).outputs,1) - 0.5;
      end;

    end;


  case 'deleteNode'
    n = modifier.layer;

    % Verify layer
    %-------------
    if( isempty(n) || (n<1) || (n>h.network.layers) )
      errordlg({'Non-existent layer'});
      return;
    end;

    x           = sort( modifier.x );
    deleteNodes = length(x);

    % Verify nodes
    %-------------
    if( (x(1) < 1) || (x(deleteNodes) > h.network.layer(n,1).outputs) )
      errordlg({'Non-existent node'});
      return;
    end;

    h                            = Data( 'deleteOutputRow', h, modifier );
    h.network.layer(n,1).outputs = h.network.layer(n,1).outputs - deleteNodes;

    % Update number of inputs to next layer
    %--------------------------------------
    if( n < h.network.layers )
      modifier.layer                = n+1;
      h                             = Data( 'deleteInputColumn', h, modifier );
      h.network.layer(n+1,1).inputs = h.network.layer(n+1).inputs - deleteNodes;
    end;

  case 'addNode'   % always add nodes to bottom of layer
    n = modifier.layer;

    % Verify layer
    %-------------
    if( isempty(n) || (n<1) || (n>h.network.layers) )
      errordlg({'Non-existent layer'});
      return;
    end;

    x        = sort( modifier.x );
    addNodes = length(x);

    % Verify nodes to be added
    %--------------------------
    if( x(1) < 1 )
      errordlg({'Nodes to be added must be positive'})
      return;
    elseif( x(1) > h.network.layer(n,1).outputs+1 )
      errordlg({'Gap in node numbering at end of layer'});
      return;
    end;
 
    for j = 2:addNodes
      if( x(j) ~= (x(j-1) + 1) )
        errordlg({'Attempt to add non-consecutive nodes'});
        return;
      end;
    end;

    h                            = Data( 'addOutputRow', h, modifier );

    h.network.layer(n,1).outputs = h.network.layer(n,1).outputs + addNodes;

    % Update number of inputs to next layer
    %--------------------------------------
    if( n < h.network.layers )
      modifier.layer                = n+1;
      h                             = Data( 'addInputColumn', h, modifier );
      h.network.layer(n+1,1).inputs = h.network.layer(n+1).inputs + addNodes;
    end;

  case 'addInputColumn'
    if( strcmp(h.preferences.defaultWeights,'zero') )
      h.network.layer(modifier.layer,1).w(:,modifier.x) = zeros(h.network.layer(modifier.layer,1).outputs,length(modifier.x));
    else
      h.network.layer(modifier.layer,1).w(:,modifier.x) = rand(h.network.layer(modifier.layer,1).outputs,length(modifier.x)) - 0.5;
    end

  case 'deleteInputColumn'
    h.network.layer(modifier.layer,1).w(:,modifier.x) = [];

  case 'addOutputRow'
    if( strcmp(h.preferences.defaultWeights,'zero') )
      h.network.layer(modifier.layer,1).w(modifier.x,:) = zeros(length(modifier.x),h.network.layer(modifier.layer,1).inputs);
    else
      h.network.layer(modifier.layer,1).w(modifier.x,:) = rand(length(modifier.x),h.network.layer(modifier.layer,1).inputs) - 0.5;
    end

    if( strcmp(h.preferences.defaultThresh,'zero') )
      h.network.layer(modifier.layer,1).w0(modifier.x,:) = zeros(length(modifier.x),1);
    else
      h.network.layer(modifier.layer,1).w0(modifier.x,:) = rand(length(modifier.x),1) - 0.5;
    end

  case 'deleteOutputRow'
    h.network.layer(modifier.layer,1).w(modifier.x,:)  = [];
    h.network.layer(modifier.layer,1).w0(modifier.x,:) = [];

end;
  
%---------------------------------------------------------------------------
%   Get the data structure stored in the figure window
%---------------------------------------------------------------------------
function d = GetDataStructure

figH = findobj( allchild(0), 'flat', 'tag', 'Neural Net Developer' );
d    = get( figH, 'UserData' );


%---------------------------------------------------------------------------
%   Call back string without modifier
%---------------------------------------------------------------------------
function s = CreateCallbackString( action )
s = ['NeuralNetDeveloper(''' action ''')'];

%---------------------------------------------------------------------------
%   Call back string with modifier
%---------------------------------------------------------------------------
function s = Callback2( action, modifier )
s = ['NeuralNetDeveloper( ''' action ''',''' modifier ''')'];


%---------------------------------------------------------------------------
%   Number to Activation Function
%---------------------------------------------------------------------------
function s = Num2ActFctn( x )

switch x
  case 1
    s = 'log';
  case 2
    s = 'mag';
  case 3
    s = 'sign';
  case 4
    s = 'step';
  case 5
    s = 'sum';
  case 6
    s = 'tanh';
  otherwise
    s = 'tanh';
end;

%---------------------------------------------------------------------------
%   Activation Function to Number
%---------------------------------------------------------------------------
function x = ActFctn2Num( s )

switch s
  case 'log'
    x = 1;
  case 'mag'
    x = 2;
  case 'sign'
    x = 3;
  case 'step'
    x = 4;
  case 'sum'
    x = 5;
  case 'tanh'
    x = 6;
  otherwise
    x = 6;
end;

%---------------------------------------------------------------------------
%   Initialization Function to Number
%---------------------------------------------------------------------------
function x = InitFctn2Num( s )

switch s
  case 'rand'
    x = 1;
  case 'zero'
    x = 2;
  otherwise
    x = 1;
end;

%---------------------------------------------------------------------------
%   Number to Initialization Function
%---------------------------------------------------------------------------
function s = Num2InitFctn( x )

switch x
  case 1
    s = 'rand';
  case 2
    s = 'zero';
  otherwise
    s = 'rand';
end;

%---------------------------------------------------------------------------
%  Open a file
%---------------------------------------------------------------------------
function [fid, g, file] = OpenFile( path, file, suffix, name )

currentPath = cd;

if( ~isempty(path) )
  eval(['cd ''',path '''']);
end  

% If no file is specified bring up the GUI
%-----------------------------------------
if( isempty(path) || isempty(file) )
  [file, path] = uigetfile(['*.' suffix]', name); 
  if( file == 0 )
		fid = -1;
		g   = [];
    return
  end
end

k = strfind(file,'.');
if( isempty(k) )
  g    = file;
  file = [file '.d'];
else
  g    = file(1:(strfind(file,'.')-1));
end

if( isempty(path) )
  path = currentPath;
end

cd(path);
 
fid = fopen(file,'r');
if( fid == -1 )
  g = [];
  return;
end

cd(currentPath);

