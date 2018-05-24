function NeuralNetTrainer( action, modifier )

%% NEURALNETTRAINER This graphically interactive function trains simple neural nets.
%% Form
%   NeuralNetTrainer( action, modifier  )
%% Inputs
%   action   (1,:)   Action to be taken by the developer (used mostly
%                    for callbacks)
%% Outputs
%   None

%% Copyright
% Copyright (c) 1998,1999, 2016 Princeton Satellite Systems, Inc.
% All rights reserved.

% Not a stand-alone application
%------------------------------
if( nargin < 1 )
  errordlg({'The Neural Net Trainer is one of the integrated neural net tools.',...
    'It can only be accessed through the Neural Net Developer.'});
  return
end

% Perform actions
%----------------
switch action
  
  case 'initialize'
    d.h = InitializeGUI;
    
  otherwise
    d = GetDataStructure;
    
    switch action
      
      case 'new'
        d.h = New( 'new',   d.h );
        
      case 'load'
        d.h = Load( 'load',   d.h );
        
      case 'save'
        d.h = Save( 'save',   d.h );
        
      case 'help'
        d.h = Help( modifier,   d.h );
        
      case 'close'
        d.h = Close( 'close',   d.h );
        
      case 'train'
        d.h = Train( modifier, d.h );
        
      case 'test'
        d.h = Test( modifier, d.h );
        
      case 'results'
        d.h = Results( modifier, d.h );
        
      case 'trainsets'
        d.h = TrainSets( modifier, d.h );
        
      case 'method'
        d.h = Method( modifier, d.h );
        
      case 'preferences'
        d.h = Preferences( modifier, d.h );
        
      case 'data'
        d.h = Data( modifier, d.h );
        
      otherwise
        
    end
    
end

% Store the data in the figure handle
%------------------------------------
if( ~strcmp( action, 'close' ) )
  set( d.h.fig, 'UserData', d );
end

% Update the picture
%-------------------
drawnow

%---------------------------------------------------------------------------
%   Initialize the display
%---------------------------------------------------------------------------
function h = InitializeGUI

ltblue       = [0.9 0.9 1];

height       = 500;
width        = 420;

figureProps  = {'Units','pixels','NumberTitle', 'off','Color',ltblue};

h.dFig = findobj( allchild(0), 'flat', 'tag', 'Neural Net Developer' );

% Initialize the training window
%-------------------------------
p     = get( h.dFig, 'position' );
p(1)  = p(1) + 50;
p(2)  = p(2) - 15;
h.fig = figure( figureProps{:},...
  'Name','Neural Net Trainer',...
  'Tag','Neural Net Trainer',...
  'Position',[p(1:2) width height],...
  'CloseRequestFcn', Callback2('close','close train'));

h = Preferences( 'initialize', h );
h =        Data( 'initialize', h );

h =         New( 'initialize', h );
h =        Load( 'initialize', h );
h =        Save( 'initialize', h );
h =        Help( 'initialize', h );
h =       Close( 'initialize', h );

h =       Train( 'initialize', h );
h =     Results( 'initialize', h );
h =        Test( 'initialize', h );

h =   TrainSets( 'initialize', h );
h =      Method( 'initialize', h );

%---------------------------------------------------------------------------
%   Training Sets
%---------------------------------------------------------------------------
function h = TrainSets( action, h )

ltGrey       = [0.96 0.96 0.96];
white        = [1 1 1];

labelProps         = {'Parent',h.fig,'Units','pixels','Style','text', ...
  'BackgroundColor',ltGrey,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','center'};

editProps          = labelProps;
editProps(5:10)    = {'Style','edit','BackgroundColor',white,'FontName','Courier'};

frameProps         = labelProps(1:12);
frameProps(5:8)    = {'Style','frame','BackgroundColor',ltGrey};

switch action
  case 'initialize'
    height = 230;
    width  = 410;
    bottom = 260;
    top    = 490;
    left   = 10;
    
    % UIControls
    %-----------
    uicontrol('Parent',h.fig,'visible','off');
    
    h.trainFrame   = uicontrol( frameProps{:}, 'Position', [left bottom width height ] );
    
    uicontrol( labelProps{1:12}, 'FontSize',14,'FontWeight','bold',...
      'Position',[left+5 top-29 width-10 20 ],...
      'String','Training Sets');
    
    uicontrol( labelProps{:},...
      'Position',[left+10 bottom+140 40 20],...
      'String', 'Inputs');
    
    h.trainInputs  = uicontrol( editProps{:},'HorizontalAlignment','Left',...
      'Max',2,...
      'Position',[left+55 bottom+120 210 70],...
      'Callback', Callback2('trainsets','trainInputs'));
    
    uicontrol( labelProps{:},...
      'Position',[left+10 bottom+45 40 40],...
      'String', 'Desired Outputs');
    
    uicontrol( labelProps{:},...
      'Position',[left+25 bottom+5 260 20],...
      'String','Set Number');
    
    h.trainOutputs = uicontrol( editProps{:},'HorizontalAlignment','Left',...
      'Max',2,...
      'Position',[left+55 bottom+40 210 70],...
      'Callback', Callback2('trainsets','trainOutputs'));
    
    uicontrol( labelProps{:},...
      'Position',[left+300 top-50-29 100 30],...
      'String','Number of Training Runs');
    
    h.trainRuns    = uicontrol( editProps{:},...
      'Position',[left+320 top-70-29 60 20],...
      'Callback', Callback2('trainsets','trainRuns'));
    
    uicontrol( labelProps{:},...
      'Position',[left+300 top-105-29 100 20],...
      'String','Training Sets In Use');
    
    h.trainSets    = uicontrol( editProps{:},...
      'Position',[left+300 top-120-29 100 20],...
      'Callback', Callback2('trainsets','trainSets'));
    
    uicontrol( labelProps{:},...
      'Position',[left+300 top-155-29 100 20],...
      'String','Testing Sets In Use');
    
    h.testSets     = uicontrol( editProps{:},...
      'Position',[left+300 top-170-29 100 20],...
      'Callback', Callback2('trainsets','testSets'));
    
    h              = TrainSets( 'displayTrainSets', h );
    
  case 'displayTrainSets'
    
    set( h.trainInputs,  'String', num2str(h.train.inputs) );
    set( h.trainOutputs, 'String', num2str(h.train.desOutputs) );
    set( h.trainRuns,    'String', num2str(h.train.runs) );
    set( h.trainSets,    'String', num2str(h.train.trainSets) );
    set( h.testSets,     'String', num2str(h.train.testSets) );
    
  case 'trainInputs'
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'matrix';
    d.empty   = 'yes';
    
    [newInputs, valid] = GetEntry( h.trainInputs, d );
    
    % Update inputs
    %--------------
    if( ~valid )
      waitfor(gcf);
    else
      h.train.inputs = newInputs;
    end;
    h = TrainSets('displayTrainSets',h);
    
  case 'trainOutputs'
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'matrix';
    d.empty   = 'yes';
    
    [newOutputs, valid] = GetEntry( h.trainOutputs, d );
    
    % Update outputs
    %---------------
    if( ~valid )
      waitfor(gcf);
    else
      h.train.desOutputs = newOutputs;
    end;
    h = TrainSets('displayTrainSets',h);
    
  case 'trainRuns'
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;
    
    [newRuns, valid] = GetEntry( h.trainRuns, d );
    
    % Update number of training runs
    %-------------------------------
    if( ~valid )
      h = TrainSets('displayTrainSets',h);
    else
      h.train.runs = newRuns;
    end;
    
  case 'trainSets'
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type        = 'vector';
    d.integer     = 'yes';
    d.min         = 0;
    d.maxElements = inf;
    
    [newTrainSets, valid] = GetEntry( h.trainSets, d );
    
    % Update training sets
    %---------------------
    if( ~valid )
      h = TrainSets('displayTrainSets',h);
    else
      h.train.trainSets = unique(newTrainSets');
      h = TrainSets('displayTrainSets',h);
    end;
    
  case 'testSets'
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type        = 'vector';
    d.integer     = 'yes';
    d.min         = 0;
    d.maxElements = inf;
    
    [newTestSets, valid] = GetEntry( h.testSets, d );
    
    % Update testing sets
    %--------------------
    if( ~valid )
      h = TrainSets('displayTrainSets',h);
    else
      h.train.testSets = unique(newTestSets');
      h = TrainSets('displayTrainSets',h);
    end;
    
end;


%---------------------------------------------------------------------------
%   Methodology Window
%---------------------------------------------------------------------------
function h = Method( action, h )

defaultColor = [0.7333 0.7333 0.7333];
ltGrey       = [0.96 0.96 0.96];

labelProps         = {'Parent',h.fig,'Units','pixels','Style','text', ...
  'BackgroundColor',ltGrey,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','right'};

frameProps         = labelProps(1:12);
frameProps(5:8)    = {'Style','frame','BackgroundColor',ltGrey};

menuProps          = labelProps(1:12);
menuProps(5:10)    = {'Style','popupmenu','BackgroundColor',defaultColor,'FontName','Courier'};

switch action
  case 'initialize'
    height = 240;
    width  = 210;
    bottom = 0;
    top    = height;
    left   = 10;
    
    w = what('TrainingMethods');
    trainString = cell(1,length(w.m));
    for i = 1:length(w.m)
      if ~strcmp(w.m{i},'Contents.m')
        trainString{i} = w.m{i}(1:end-5);
      end
    end
    
    % UIControls
    %-----------
    uicontrol( frameProps{:}, 'Position', [left bottom width height ] );
    
    uicontrol( labelProps{1:12}, 'FontSize',14,'HorizontalAlignment','center','FontWeight','bold',...
      'Position',[left+5 top-29 width-10 20 ],...
      'String','Training Method');
    
    h.trainTypes   = uicontrol( menuProps{:},...
      'Position',[left+25 top-30-25 160 20],...
      'String', trainString,...
      'Callback', Callback2('method', 'changeMethod'));
    
    h              = Method( 'setUpMethodDisplay', h );
    h              = Method( 'displayMethod', h );
    
  case 'displayMethod'
    set( h.trainTypes, 'Val', Method2Num( h.train.method ) );
    h = feval( [h.train.method 'NNT'],'show', h );
    
  case 'clearMethodDisplay'
    h = feval( [h.train.method 'NNT'],'hide', h );
    
  case 'setUpMethodDisplay'
    
    height = 185;
    width  = 210;
    bottom = 0;
    left   = 10;
    
    w = what('TrainingMethods');
    for i = 1:length(w.m)
      if ~strcmp(w.m{i},'Contents.m')
        h = feval( w.m{i}(1:end-2),'initializeGUI', h, [left bottom width height] );
        h = feval( w.m{i}(1:end-2),'hide', h );
      end
    end
    
  case 'changeMethod'
    if( ~strcmp( h.train.method, popupstr(h.trainTypes) ) )
      h              = Method( 'clearMethodDisplay', h );
      h.train.method = popupstr(h.trainTypes);
      h              = Method( 'displayMethod', h );
    end;
    
end;


%---------------------------------------------------------------------------
%   Train button
%---------------------------------------------------------------------------
function h = Train( action, h )

blue         = [0.7 0.7 1];

buttonProps  = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',blue,'FontName','Helvetica', ...
  'FontSize',12,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.trainb = uicontrol( buttonProps{:},...
      'Position',[240 190 80 50],...
      'String', 'Train',...
      'Callback', Callback2('train','train'));
    
  case 'train'
    
    % Check number of input and output sets
    %--------------------------------------
    [inRows,inCols]   = size( h.train.inputs );
    [outRows,outCols] = size( h.train.desOutputs );
    
    if( inCols ~= outCols )
      errordlg('The number of input sets and output sets must be equal','Error','modal');
      waitfor(gcf);
      
    elseif( inRows ~= h.network.layer(1,1).inputs )
      errordlg('Incorrect number of inputs in training sets','Error','modal');
      
    elseif( outRows ~= h.network.layer(h.network.layers,1).outputs )
      errordlg('Incorrect number of outputs in training sets','Error','modal');
      
      % Check list of training sets
      %----------------------------
    elseif( min(h.train.trainSets) == 0 )
      if( length(h.train.trainSets) > 1 )
        errordlg('Training set numbering begins at 1','Error','modal');
      else
        errordlg('No training sets are specified for use','Error','modal');
      end;
      waitfor(gcf);
      
    elseif( max(h.train.trainSets) > inCols )
      errordlg('Undefined training set is specified for use','Error','modal');
      waitfor(gcf);
      
      % Create training set
      %--------------------
    else
      h.train.setOrder = ceil(rand(1,h.train.runs)*inCols);
      
      h = feval( [h.train.method 'NNT'],'train', h);
      h = Data( 'set network data', h );
      
      if( h.preferences.autoPlotTrain )
        h = Results( 'plot train results', h );
      end;
      
    end;
    
    
end

%---------------------------------------------------------------------------
%   Results button
%---------------------------------------------------------------------------
function h = Results( action, h )

defaultColor = [0.7333 0.7333 0.7333];
ltGrey       = [0.96 0.96 0.96];
red          = [0.95 0.2 0.25];
green        = [0 1 0];
dkgreen      = [0 0.66 0];

figureProps  = {'Units','pixels','NumberTitle', 'off','Color',dkgreen};

buttonProps  = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',dkgreen,'FontName','Helvetica', ...
  'FontSize',12,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.results  = uicontrol( buttonProps{:},...
      'Position',[240 120 80 50],...
      'String', 'Plot Results',...
      'Callback', Callback2('results','get results'));
    
  case 'get results'
    if( ( ~isfield(h.train,'network')     || isempty(h.train.network) ) && ...
        ( ~isfield(h.train,'testOutputs') || isempty(h.train.testOutputs) )  )
      errordlg('The network must first be trained or tested','Error','modal');
    else
      % Display plotting preferences window
      %------------------------------------
      p2         = get( h.fig, 'position' );
      p(1)       = p2(1) + 50;
      p(2)       = p2(2) - 20;
      width1     = 400;
      height1    = 280;
      left       = 10;
      
      h.plotFig  = figure( figureProps{:},...
        'Name','Plot Results',...
        'Tag','Neural Net Plotting Preferences',...
        'Position',[p(1) p(2) width1 height1],...
        'CloseRequestFcn', Callback2('results','close preferences'));
      
      labelProps           = {'Parent',h.plotFig,'Units','pixels','Style','text', ...
        'BackgroundColor',ltGrey,'FontName','Helvetica', ...
        'FontSize',10,'HorizontalAlignment','right'};
      
      buttonProps          = labelProps(1:12);
      buttonProps(5:8)     = {'Style','pushbutton','BackgroundColor',defaultColor};
      
      h         = PlotPreferences( 'initialize', h, h.plotFig, [left height1-220-10] );
      
      if( ~isfield(h.train,'network') || isempty(h.train.network) )
        h = PlotPreferences( 'disable training', h, h.plotFig );
      elseif( ~isfield(h.train,'testOutputs') || isempty(h.train.testOutputs) )
        h = PlotPreferences( 'disable testing', h, h.plotFig );
      end;
      
      
      % Buttons
      %--------
      width     = 80;
      space     = (width1 - 2*width - 10) / 3;
      
      h.plotOK  = uicontrol( buttonProps{:},...
        'Position',[left+space 0 width 40],...
        'BackgroundColor',green,...
        'String', 'Plot',...
        'Callback', Callback2('results','plot'));
      
      h.plotCancel = uicontrol( buttonProps{:},...
        'Position',[left+width+2*space 0 width 40],...
        'BackgroundColor',red,...
        'String','Cancel',...
        'Callback', Callback2('results','close preferences'));
      
    end;
    
  case 'plot'
    
    h = Results( 'close preferences', h );
    
    if( isfield(h.train,'network') && ~isempty(h.train.network) )
      h = Results( 'plot train results', h );
    end;
    if( isfield(h.train,'testOutputs') && ~isempty(h.train.testOutputs) )
      h = Results( 'plot test results', h );
    end;
    
  case 'plot train results'
    % Determine if results window already exists
    %-------------------------------------------
    h.resultsFig = findobj(allchild(0),'flat','Tag','Neural Net Training Results');
    
    if( ~isempty(h.resultsFig) )
      h = Results('close results',h);
    end;
    
    % Parameters for all plots
    %-------------------------
    [m,n] = size( h.train.error );
    x     = 1:h.preferences.plotEveryNPoints:n;
    nPts  = length(x);
    if( x(nPts) ~= n )     % ensure the last point is plotted
      nPts    = nPts + 1;
      x(nPts) = n;
    end;
    
    % Plot Training Error Magnitude
    %------------------------------
    if( h.preferences.plotTrainErrMag )
      tempH = PlotSet(x,h.train.error(:,x),'x label','Run',...
        'y label',cellstr(num2str((1:m)')),...
        'figure title','Training Error');
      set( tempH, 'NumberTitle', 'off' );
      set( tempH, 'Tag', 'Neural Net Training Results' );
      h.resultsFig = [tempH; h.resultsFig];
    end;
    
    % Plot RMS Training Error
    %------------------------
    if( h.preferences.plotTrainErrRMS )
      if( m == 1 )
        eRMS = abs( h.train.error(:,x) );
      else
        errors = h.train.error(:,x);
        eRMS  = sqrt(sum(errors.^2));
      end;
      tempH = PlotSet(x,eRMS,'x label','Run','y label','RMS Error',...
        'figure title','RMS Training Error', 'plot type', 'ylog');
      set( tempH, 'NumberTitle', 'off' );
      set( tempH, 'Tag', 'Neural Net Training Results' );
      h.resultsFig = [tempH; h.resultsFig];
    end;
    
    % Plot Weights
    %-------------
    if( h.preferences.plotTrainWeights )
      for j = 1:h.network.layers
        w       = [];
        yIndex  = {};
        [p,q]   = size(h.train.network(j,1).w);
        index   = (1:p*q)';
        for k = 1:nPts
          temp   = h.train.network(j,x(k)).w';
          w(:,k) = temp(index); %#ok<AGROW>
        end;
        for k = 1:p
          val  = (k-1)*q;
          yIndex = [yIndex {( val+1 ):(val+q)}]; %#ok<AGROW>
        end;
        tempH = PlotSet(x,w,'x label','Run',...
          'y label',cellstr(num2str((1:h.train.network(j,1).outputs)')),...
          'figure title',['Node Weights for Layer ' num2str(j)],...
          'plot set',yIndex);
        set( tempH, 'NumberTitle', 'off' );
        set( tempH, 'Tag', 'Neural Net Training Results' );
        h.resultsFig = [tempH; h.resultsFig];
        % New figure: weights as image
        newH = figure('name',['Weight Images for Layer ' num2str(j)]);
        endWeights = [h.train.network(j,1).w(:);h.train.network(j,end).w(:)];
        minW = min(endWeights);
        maxW = max(endWeights);
        subplot(1,2,1)
        imagesc(h.train.network(j,1).w,[minW maxW])
        colorbar
        ylabel('Output Node')
        xlabel('Input Node')
        title('Weights Before Training')
        subplot(1,2,2)
        imagesc(h.train.network(j,end).w,[minW maxW])
        colorbar
        xlabel('Input Node')
        title('Weights After Training')
        colormap hsv
        set( newH, 'NumberTitle', 'off' );
        set( newH, 'Tag', 'Neural Net Training Results' );
        h.resultsFig = [newH; h.resultsFig];
        
      end;
    end;
    
    % Plot Thresholds
    %----------------
    if( h.preferences.plotTrainThresh )
      for j = 1:h.network.layers
        w0      = [];
        for k = 1:nPts
          w0(:,k) = h.train.network(j,x(k)).w0; %#ok<AGROW>
        end;
        tempH = PlotSet(x,w0,'x label','Run',...
          'y label',cellstr(num2str((1:h.train.network(j,1).outputs)')),...
          'figure title',['Node Biases for Layer ' num2str(j)]);
        set( tempH, 'NumberTitle', 'off' );
        set( tempH, 'Tag', 'Neural Net Training Results' );
        h.resultsFig = [tempH; h.resultsFig];
      end;
    end;
    
  case 'plot test results'
    h.testFig = findobj(allchild(0),'flat','Tag','Neural Net Training Tests');
    
    if( ~isempty(h.testFig) )
      h = Results('close test results',h);
    end;
    
    % Parameters for all plots
    %-------------------------
    [m,~] = size( h.train.testErrors );
    [sortedTests,iTest] = sort(h.train.testSets);
    
    if( h.preferences.plotTestOutput )
      tempH = PlotSet( sortedTests, h.train.testOutputs(:,iTest),...
        'x label','Test Input Set','y label', cellstr(num2str((1:m)')),...
        'figure title', 'Test Output' );
      
      if( h.preferences.plotTestDesOutput )
        testAxes = get(tempH, 'children');
        testAxes = flipud(testAxes(1:m));
        for k = 1:m
          axes(testAxes(k)); %#ok<LAXES>
          hold on;
          plot( h.train.testSets(iTest), h.train.desOutputs(k,h.train.testSets(iTest)), 'r--*');
          hold off;
        end;
        axes(testAxes(1));
        legend('Actual','Desired');
      end;
      
      set(tempH, 'NumberTitle', 'off');
      set(tempH, 'Tag', 'Neural Net Training Tests');
      h.testFig = [tempH; h.testFig];
      
    end;
    
    % Plot Testing Error Magnitude
    %-----------------------------
    if( h.preferences.plotTestErrMag )
      tempH = PlotSet(sortedTests,h.train.testErrors(:,iTest),...
        'x label','Run','y label',cellstr(num2str((1:m)')),...
        'figure title', 'Test Error');
      set( tempH, 'NumberTitle', 'off' );
      set( tempH, 'Tag', 'Neural Net Training Tests' );
      h.testFig = [tempH; h.testFig];
    end;
    
    % Plot RMS Testing Error
    %-----------------------
    if( h.preferences.plotTestErrRMS )
      if( m == 1 )
        eRMS = abs( h.train.testErrors );
      else
        eRMS  = mag( h.train.testErrors );
      end;
      tempH = PlotSet(sortedTests,eRMS(:,iTest),...
        'x label','Run','y label','RMS Error','plot title','RMS Testing Error',...
        'plot type','ylog','figure title','RMS Test Error');
      set( tempH, 'NumberTitle', 'off' );
      set( tempH, 'Tag', 'Neural Net Training Tests' );
      h.testFig = [tempH; h.testFig];
    end;
    
  case 'close results'
    close( h.resultsFig );
    h.resultsFig = [];
    
  case 'close test results'
    close( h.testFig );
    h.testFig = [];
    
  case 'close preferences'
    if isfield(h,'plotFig')
      delete( h.plotFig );
      h.plotFig = [];
    end
    
end

%---------------------------------------------------------------------------
%   Test button
%---------------------------------------------------------------------------
function h = Test( action, h )

defaultColor = [0.7333 0.7333 0.7333];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',defaultColor,'FontName','Helvetica', ...
  'FontSize',12,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.test     = uicontrol( buttonProps{:},...
      'Position',[240 50 80 50],...
      'String', 'Test',...
      'Callback', Callback2('test','get test'));
    
  case 'get test'
    % Check list of testing sets
    %---------------------------
    [~,inCols]  = size( h.train.inputs );
    
    if( min(h.train.testSets) == 0 )
      if( length(h.train.testSets) > 1 )
        errordlg('Testing set numbering begins at 1','Error','modal');
      else
        errordlg('No testing sets are specified for use','Error','modal');
      end;
      waitfor(gcf);
      
    elseif( max(h.train.testSets) > inCols )
      errordlg('Undefined testing set is specified for use','Error','modal');
      waitfor(gcf);
      
    else
      h.train.testOutputs = NeuralNetMLFF( h.train.inputs(:,h.train.testSets), h.network );
      h.train.testErrors  = h.train.testOutputs - h.train.desOutputs(:,h.train.testSets);
      if( h.preferences.autoPlotTest )
        h = Results( 'plot test results', h );
      end;
    end;
    
end

%---------------------------------------------------------------------------
%   Preferences button and window
%---------------------------------------------------------------------------
function h = Preferences( action, h )


defaultColor = [0.7333 0.7333 0.7333];
ltGrey       = [0.96 0.96 0.96];
white        = [1 1 1];
red          = [0.95 0.2 0.25];
yellow       = [1 1 0.6];
green        = [0.25 0.85 0.25];

figureProps  = {'Units','pixels','NumberTitle', 'off','Color',yellow};


switch action
  
  case 'initialize'
    
    buttonProps = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
      'BackgroundColor',defaultColor,'FontName','Helvetica', ...
      'FontSize',10,'HorizontalAlignment','center'};
    
    h.pref      = uicontrol( buttonProps{:},'BackgroundColor',yellow,...
      'Position',[240 0 80 40],...
      'String','Preferences',...
      'Callback', Callback2('preferences','get preferences'));
    
    % Load saved preferences if they exist
    %-------------------------------------
    if( exist('NNTrainPreferences.mat','file') )
      vars = load('NNTrainPreferences');
      
      names = fieldnames( vars.nnTrainPref );
      for j = 1:length(names)
        h.preferences.(names{j}) = vars.nnTrainPref.(names{j});
      end;
      
      tempPath              = fileparts( which('NNTrainPreferences.mat') );
      h.preferences.file    = fullfile(tempPath,'NNTrainPreferences');
      
    else
      w = what(fullfile('OA','NeuralNets'));
      if isempty(w)
        tempPath = cd;
        h.preferences.file = fullfile(tempPath,'NNTrainPreferences');
      else
        h.preferences.file = fullfile(w(1).path,'NNTrainPreferences');
      end
      
      % Default Values
      %---------------
      h.preferences.defaultRuns       = 2000;
      h.preferences.defaultTrainSets  = 0;
      h.preferences.defaultTestSets   = 0;
      h.preferences.defaultMethod     = 'BackPropagation';
      
      % Plotting preferences
      %---------------------
      h.preferences.autoPlotTrain     = 0;
      h.preferences.autoPlotTest      = 1;
      
      h.preferences.plotTrainErrMag   = 1;
      h.preferences.plotTrainErrRMS   = 1;
      h.preferences.plotTrainWeights  = 1;
      h.preferences.plotTrainThresh   = 1;
      h.preferences.plotEveryNPoints  = 10;
      
      h.preferences.plotTestErrMag    = 0;
      h.preferences.plotTestErrRMS    = 0;
      h.preferences.plotTestOutput    = 0;
      h.preferences.plotTestDesOutput = 0;
      
    end;
    
    % Load training method specific preferences if they don't exist
    %--------------------------------------------------------------
    
    w = what('TrainingMethods');
    for i = 1:length(w.m)
      if ~strcmp(w.m{i},'Contents.m')
        h = feval(w.m{i}(1:end-2),'initialize prefs',h);
      end
    end
    
  case 'get preferences'
    
    % Determine if preferences window already exists
    %-----------------------------------------------
    h.prefFig = findobj(allchild(0),'flat','Tag','Neural Net Training Preferences');
    
    if( isempty(h.prefFig) )
      h.preferences.newPref = 0;
      
      p2         = get( h.fig, 'position' );
      p(1)       = p2(1) + 50;
      p(2)       = p2(2) - 20;
      width1     = 400;
      height1    = 440;
      left1      = 10;
      height     = 220;
      bottom     = height1 - height - 10;
      bottom1    = bottom;
      
      h.prefFig  = figure( figureProps{:},...
        'Name','Neural Net Training Preferences',...
        'Tag','Neural Net Training Preferences',...
        'Position',[p(1) p(2) width1 height1],...
        'CloseRequestFcn', Callback2('preferences','close preferences'));
      
      labelProps           = {'Parent',h.prefFig,'Units','pixels','Style','text', ...
        'BackgroundColor',ltGrey,'FontName','Helvetica', ...
        'FontSize',10,'HorizontalAlignment','right'};
      
      editProps            = labelProps;
      editProps(5:10)      = {'Style','edit','BackgroundColor',white,'FontName','Courier'};
      
      menuProps            = labelProps(1:12);
      menuProps(5:10)      = {'Style','popupmenu','BackgroundColor',defaultColor,'FontName','Courier'};
      
      frameProps           = labelProps(1:12);
      frameProps(5:8)      = {'Style','frame','BackgroundColor',ltGrey};
      
      buttonProps          = labelProps(1:12);
      buttonProps(5:8)     = {'Style','pushbutton','BackgroundColor',defaultColor};
      
      h = PlotPreferences( 'initialize', h, h.prefFig, [left1 bottom] );
      
      % Training Preferences
      %---------------------
      left   = left1;
      bottom = 0;
      height = bottom1 - 10;
      width  = width1-100;
      top    = height - 10;
      
      uicontrol( frameProps{:},...
        'Position',[left  bottom  width height] );
      
      uicontrol( labelProps{:},'FontSize',14,'FontWeight','bold',...
        'Position',[left+5 top-20 width-left-10 20 ],...
        'HorizontalAlignment','center',...
        'String','Default Training Parameters');
      
      uicontrol( labelProps{:},...
        'Position',[left+5 top-35-29 150 20],...
        'String','Number of Training Runs');
      
      h.defTrainRuns = uicontrol( editProps{:},...
        'Position',[left+165 top-35-25 60 20],...
        'Callback', Callback2('preferences','trainRuns'));
      
      uicontrol( labelProps{:},...
        'Position',[left+5 top-85-27 95 20 ],...
        'String','Training Method');
      
      h.defMethod    = uicontrol( menuProps{:},...
        'Position',[left+110 top-85-25 160 20],...
        'String', 'BackPropagation',...
        'Callback', Callback2('preferences', 'changeMethod'));
      
      h              = Preferences( 'setUpMethodDisplay', h );
      
      h              = Preferences( 'displayMethod', h );
      
      
      
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
    
  case 'setUpMethodDisplay'
    
    height = 200;
    width  = 300;
    bottom = 0;
    left   = 10;
    
    w = what('TrainingMethods');
    for i = 1:length(w.m)
      if ~strcmp(w.m{i},'Contents.m')
        h = feval( w.m{i}(1:end-2),'initialize prefs GUI', h, [left bottom width height] );
        h = feval( w.m{i}(1:end-2),'hide prefs', h );
      end
    end
    
  case 'displayMethod'
    set( h.defTrainRuns, 'String', num2str(h.preferences.defaultRuns) );
    set( h.defMethod, 'Val', Method2Num( h.preferences.defaultMethod) );
    
    h = feval( [h.preferences.defaultMethod 'NNT'],'show prefs', h );
    
  case 'trainErrMag'
    h.preferences.plotTrainErrMag = get(h.defTrainErrMag,'Val');
    h.preferences.newPref         = 1;
    
  case 'trainErrRMS'
    h.preferences.plotTrainErrRMS = get(h.defTrainErrRMS,'Val');
    h.preferences.newPref         = 1;
    
  case 'trainWeights'
    h.preferences.plotTrainWeights = get(h.defTrainWeights,'Val');
    h.preferences.newPref          = 1;
    
  case 'trainThresh'
    h.preferences.plotTrainThresh = get(h.defTrainThresh,'Val');
    h.preferences.newPref         = 1;
    
  case 'trainAuto'
    h.preferences.autoPlotTrain = get(h.defTrainAuto,'Val');
    h.preferences.newPref       = 1;
    
  case 'testErrMag'
    h.preferences.plotTestErrMag = get(h.defTestErrMag,'Val');
    h.preferences.newPref        = 1;
    
  case 'testErrRMS'
    h.preferences.plotTestErrRMS = get(h.defTestErrRMS,'Val');
    h.preferences.newPref        = 1;
    
  case 'testOutput'
    h.preferences.plotTestOutput = get(h.defTestOutput,'Val');
    h.preferences.newPref        = 1;
    set(h.defTestDesOutput,'Enable',Num2OnOff(h.preferences.plotTestOutput));
    
  case 'testDesOutput'
    h.preferences.plotTestDesOutput = get(h.defTestDesOutput,'Val');
    h.preferences.newPref           = 1;
    
  case 'testAuto'
    h.preferences.autoPlotTest = get(h.defTestAuto,'Val');
    h.preferences.newPref      = 1;
    
  case 'trainNPoints'
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;
    
    [newPts, valid] = GetEntry( h.defEveryNPoints, d );
    
    % Update number of training runs
    %-------------------------------
    if( ~valid )
      set( h.defEveryNPoints,'String',num2str(h.preferences.plotEveryNPoints) );
    else
      h.preferences.plotEveryNPoints = newPts;
      h.preferences.newPref          = 1;
    end;
    
  case 'trainRuns'
    % Set up data structure of valid input parameters
    %------------------------------------------------
    clear d
    d.type    = 'scalar';
    d.integer = 'yes';
    d.min     = 1;
    
    [newRuns, valid] = GetEntry( h.defTrainRuns, d );
    
    % Update number of training runs
    %-------------------------------
    if( ~valid )
      h = Preferences( 'displayMethod', h );
    else
      h.preferences.defaultRuns = newRuns;
      h.preferences.newPref     = 1;
    end;
    
    
  case 'save preferences'
    
    h.preferences.newPref = 0;
    
    names = fieldnames( h.preferences );
    for j = 1:length(names)
      nnTrainPref.(names{j}) = h.preferences.(names{j}); %#ok<STRNU>
    end
    
    save(h.preferences.file, 'nnTrainPref');
    clear nnTrainPref;
    
  case 'help preferences'
    HelpSystem('initialize','OnlineHelp','Training Preferences')
    
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
%   New button
%---------------------------------------------------------------------------
function h = New( action, h )

defaultColor = [0.7333 0.7333 0.7333];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',defaultColor,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.new  = uicontrol( buttonProps{:},...
      'Position',[ 340 200 80 40 ],...
      'String', 'New',...
      'Callback', Callback2('new','new'));
    
  case 'new'
    h = Data('initialize', h );
    h = TrainSets( 'displayTrainSets', h );
    h = Method( 'setUpMethodDisplay', h );
    h = Method( 'displayMethod', h );
    
end

%---------------------------------------------------------------------------
%   Load button
%---------------------------------------------------------------------------
function h = Load( action, h )

defaultColor = [0.7333 0.7333 0.7333];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',defaultColor,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.load     = uicontrol( buttonProps{:},...
      'Position',[340 150 80 40],...
      'String', 'Load',...
      'Callback', Callback2('load','load'));
  case 'load'
    [filename, pathname] = uigetfile([h.network.path '*TS.mat'],'Choose a file');
    if ~ischar(filename) || ~ischar(pathname)
      return
    end
    fname = fullfile(pathname, filename);
    temp = load(fname);
    
    s = strfind(filename, '.mat');
    names = fieldnames( temp.(filename(1:s-1)) );
    for j = 1:length(names)
      h.train.(names{j}) = temp.(filename(1:s-1)).(names{j});
    end
    
    set(h.fig,'Name',['Neural Net Trainer: ' filename(1:s-1)])
    
    h = Data( 'get network data', h );
    h = TrainSets( 'displayTrainSets', h );
    h = Method( 'changeMethod', h );
    
end

%---------------------------------------------------------------------------
%   Save button
%---------------------------------------------------------------------------
function h = Save( action, h )

defaultColor = [0.7333 0.7333 0.7333];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',defaultColor,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.save     = uicontrol( buttonProps{:},...
      'Position',[340 100 80 40],...
      'String', 'Save',...
      'Callback', Callback2('save','save'));
    
  case 'save'
    [filename, pathname] = uiputfile([h.network.path '*TS.mat'],'Save As');
    if ~ischar(filename) || ~ischar(pathname)
      return
    end
    filename = [filename 'TS'];
    data = struct;
    data.inputs = h.train.inputs;
    data.desOutputs = h.train.desOutputs;
    data.testSets = h.train.testSets;
    data.trainSets = h.train.trainSets;
    assignin('caller',filename,data);
    save(fullfile(pathname, filename),filename);
    set(h.fig,'Name',['Neural Net Trainer: ' filename]);
    
end

%---------------------------------------------------------------------------
%   Close button
%---------------------------------------------------------------------------
function h = Close( action, h )

red          = [0.95 0.2 0.25];

buttonProps        = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',red,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.close = uicontrol( buttonProps{:},...
      'Position',[340 50 80 40],...
      'String','CLOSE',...
      'Callback', CreateCallbackString( 'close'));
    
  case 'close'
    figs         = allchild(0);
    h.trainFig   = findobj(figs,'flat','Tag','Neural Net Trainer');
    h.prefFig    = findobj(figs,'flat','Tag','Neural Net Training Preferences');
    h.resultsFig = findobj(figs,'flat','Tag','Neural Net Training Results');
    h.testFig    = findobj(figs,'flat','Tag','Neural Net Training Tests');
    
    if( ~isempty(h.resultsFig) )
      h = Results( 'close results', h );
    end
    if( ~isempty(h.testFig) )
      h = Results( 'close test results', h );
    end
    if( ~isempty(h.prefFig) )
      h = Preferences( 'close preferences', h );
    end
    if( ~isempty(h.trainFig) )
      figure(h.trainFig);
      closereq;
    end;
    
end

%---------------------------------------------------------------------------
%   Help button
%---------------------------------------------------------------------------
function h = Help( action, h )

green        = [0.25 0.9 0.25];
buttonProps  = {'Parent',h.fig,'Units','pixels','Style','pushbutton',...
  'BackgroundColor',green,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','center'};

switch action
  case 'initialize'
    h.help = uicontrol( buttonProps{:},...
      'Position',[340 0 80 40],...
      'String','HELP',...
      'enable','off',...
      'Callback', Callback2( 'help','get help'));
    
  case 'get help'
    HelpSystem('initialize','OnlineHelp','Neural Net Trainer')
end

%---------------------------------------------------------------------------
%   Network Data
%---------------------------------------------------------------------------
function h = Data( action, h )

switch action
  case 'initialize'
    
    % Get the network information from the developer window
    %------------------------------------------------------
    h = Data( 'get network data', h );
    
    % Initial training parameters
    %----------------------------
    h.train.runs       = h.preferences.defaultRuns;
    h.train.trainSets  = h.preferences.defaultTrainSets;
    h.train.testSets   = h.preferences.defaultTestSets;
    h.train.method     = h.preferences.defaultMethod;
    
    h.train.inputs     = [];
    h.train.desOutputs = [];
    
  case 'get network data'
    
    temp      = get(h.dFig,'UserData');
    h.network = temp.h.network;
    clear temp;
    
  case 'set network data'
    
    temp           = get(h.dFig,'UserData');
    temp.h.network = h.network;
    set( h.dFig,'UserData',temp );
    clear temp;
    
    % Update Neural Net Developer Display
    %------------------------------------
    NeuralNetDeveloper('network','displayNetwork');
    NeuralNetDeveloper('layer','displayLayer');
    NeuralNetDeveloper('topology','drawNetwork');
    
    figure( h.fig );
    
end;

%---------------------------------------------------------------------------
%   Plotting Preferences Frame
%---------------------------------------------------------------------------
function h = PlotPreferences( action, h, pFig, pLoc )

ltGrey       = [0.96 0.96 0.96];
white        = [1 1 1];

labelProps           = {'Parent',pFig,'Units','pixels','Style','text', ...
  'BackgroundColor',ltGrey,'FontName','Helvetica', ...
  'FontSize',10,'HorizontalAlignment','right'};

editProps            = labelProps;
editProps(5:10)      = {'Style','edit','BackgroundColor',white,'FontName','Courier'};

frameProps           = labelProps(1:12);
frameProps(5:8)      = {'Style','frame','BackgroundColor',ltGrey};

checkboxProps        = labelProps;
checkboxProps(5:6)   = {'Style','checkbox'};

switch action
  
  case 'initialize'
    
    width     = 390;
    height    = 220;
    left      = pLoc(1);
    bottom    = pLoc(2);
    top       = bottom+height;
    
    % Plotting Preferences
    %---------------------
    uicontrol( frameProps{:},...
      'BackgroundColor',white,...
      'Position',[left  bottom  width height] );
    
    uicontrol( labelProps{:},'FontSize',14,'FontWeight','bold',...
      'Position',[left+5 top-30 width-left-10 20 ],...
      'HorizontalAlignment','center',...
      'BackgroundColor',white,...
      'String','Plotting Preferences');
    
    % Training Plots
    %---------------
    left   = left+10;
    bottom = bottom+10;
    width  = (width - 3*10) / 2;
    height = height - 40;
    top    = top - 30;
    
    uicontrol( frameProps{:}, 'Position', [left bottom width height ] );
    
    h.defTrainTitle   = uicontrol( labelProps{1:12}, 'FontSize',12,'HorizontalAlignment','center',...
      'Position',[left+5 top-29 width-10 20 ],...
      'String','Training Plots');
    
    h.defTrainPre     = uicontrol( labelProps{:},'HorizontalAlignment','left',...
      'Position',[left+10 top-25-27 width-20 20 ],...
      'String','Check box to select default plots');
    
    h.defTrainErrMag  = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-40-25 width-30 20],...
      'String','Output Error',...
      'Val', h.preferences.plotTrainErrMag,...
      'Callback', Callback2('preferences','trainErrMag'));
    
    h.defTrainErrRMS  = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-60-25 width-30 20],...
      'String','Output RMS Error',...
      'Val', h.preferences.plotTrainErrRMS,...
      'Callback', Callback2('preferences','trainErrRMS'));
    
    h.defTrainWeights = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-80-25 width-30 20],...
      'String','Node Weights',...
      'Val', h.preferences.plotTrainWeights,...
      'Callback', Callback2('preferences','trainWeights'));
    
    h.defTrainThresh  = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-100-25 width-30 20],...
      'String','Node Biases',...
      'Val', h.preferences.plotTrainThresh,...
      'Callback', Callback2('preferences','trainThresh'));
    
    h.defTrainAuto    = uicontrol( checkboxProps{:},...
      'Position',[left+10 top-125-25 width-20 20],...
      'String','Automatically plot after training',...
      'Val', h.preferences.autoPlotTrain,...
      'Callback', Callback2('preferences','trainAuto'));
    
    h.defPointsPre    = uicontrol( labelProps{:},'HorizontalAlignment','left',...
      'Position',[left+10 top-150-25 47 20 ],...
      'String','Plot every');
    
    h.defEveryNPoints = uicontrol( editProps{:},'HorizontalAlignment','center',...
      'Position',[left+10+47+5 top-150-22 40 20],...
      'String',num2str(h.preferences.plotEveryNPoints),...
      'Callback', Callback2('preferences','trainNPoints'));
    
    h.defPointsPost   = uicontrol( labelProps{:},'HorizontalAlignment','left',...
      'Position',[left+10+47+40+10 top-150-25 50 20 ],...
      'String','points');
    
    % Testing Plots
    %--------------
    left   = left + width + 10;
    
    uicontrol( frameProps{:}, 'Position', [left bottom width height ] );
    
    h.defTestTitle     = uicontrol( labelProps{:}, 'FontSize',12,'HorizontalAlignment','center',...
      'Position',[left+5 top-29 width-10 20 ],...
      'String','Testing Plots');
    
    h.defTestPre       = uicontrol( labelProps{:},'HorizontalAlignment','left',...
      'Position',[left+10 top-25-27 width-20 20 ],...
      'String','Check box to select default plots');
    
    h.defTestErrMag    = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-40-25 width-30 20],...
      'String','Output Error',...
      'Val', h.preferences.plotTestErrMag,...
      'Callback', Callback2('preferences','testErrMag'));
    
    h.defTestErrRMS    = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-60-25 width-30 20],...
      'String','Output RMS Error',...
      'Val', h.preferences.plotTestErrRMS,...
      'Callback', Callback2('preferences','testErrRMS'));
    
    h.defTestOutput    = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-80-25 width-30 20],...
      'String','Output',...
      'Val', h.preferences.plotTestOutput,...
      'Callback', Callback2('preferences','testOutput'));
    
    h.defTestDesOutput = uicontrol( checkboxProps{:},...
      'Position',[left+20 top-100-25 width-30 20],...
      'String','Desired Output',...
      'Val', h.preferences.plotTestDesOutput,...
      'Enable',Num2OnOff( h.preferences.plotTestOutput ),...
      'Callback', Callback2('preferences','testDesOutput'));
    
    h.defTestAuto      = uicontrol( checkboxProps{:},...
      'Position',[left+10 top-125-25 width-20 20],...
      'String','Automatically plot after testing',...
      'Val', h.preferences.autoPlotTest,...
      'Callback', Callback2('preferences','testAuto'));
    
  case 'disable training'
    
    set( h.defTrainTitle, 'Enable', 'off' );
    set( h.defTrainPre, 'Enable', 'off');
    set( h.defTrainErrMag, 'Enable', 'off' );
    set( h.defTrainErrRMS, 'Enable', 'off' );
    set( h.defTrainWeights, 'Enable', 'off' );
    set( h.defTrainThresh, 'Enable', 'off' );
    set( h.defTrainAuto, 'Enable', 'off' );
    set( h.defPointsPre, 'Enable', 'off' );
    set( h.defEveryNPoints, 'Enable', 'off' );
    set( h.defPointsPost, 'Enable', 'off' );
    
  case 'disable testing'
    
    set( h.defTestTitle, 'Enable', 'off' );
    set( h.defTestPre, 'Enable', 'off');
    set( h.defTestErrMag, 'Enable', 'off' );
    set( h.defTestErrRMS, 'Enable', 'off' );
    set( h.defTestOutput, 'Enable', 'off' );
    set( h.defTestDesOutput, 'Enable', 'off' );
    set( h.defTestAuto, 'Enable', 'off' );
end;

%---------------------------------------------------------------------------
%   Get the data structure stored in the figure window
%---------------------------------------------------------------------------
function d = GetDataStructure

figH = findobj( allchild(0), 'flat', 'tag', 'Neural Net Trainer' );
d    = get( figH, 'UserData' );

%---------------------------------------------------------------------------
%   Call back string without modifier
%---------------------------------------------------------------------------
function s = CreateCallbackString( action )

s = ['NeuralNetTrainer(''' action ''')'];

%---------------------------------------------------------------------------
%   Call back string with modifier
%---------------------------------------------------------------------------
function s = Callback2( action, modifier )
s = ['NeuralNetTrainer( ''' action ''',''' modifier ''')'];

%---------------------------------------------------------------------------
%   Training Method to Number
%---------------------------------------------------------------------------
function x = Method2Num( s )

w = what('TrainingMethods');
for i = 1:length(w.m)
  if( strcmp( s, w.m{i}(1:end-5) ) )
    x = i;
  end;
end

%---------------------------------------------------------------------------
%   Number to On/Off Function
%---------------------------------------------------------------------------
function s = Num2OnOff( x )

if( x )
  s = 'on';
else
  s = 'off';
end;

