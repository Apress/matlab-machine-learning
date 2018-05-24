
%% MHTTREEDIAGRAM Generates a tree diagram for MHT tracks.
%%  Form
%   MHTTreeDiagram( n, w, update )
%
%% Description
% Generates a tree diagram for MHT tracks.
%
% w is optional, the defaults are:
%
%       .name      = 'Tree';
%       .width     = 400;
%       .fontName  = 'Times';
%       .fontSize  = 10;
%       .linewidth = 1;
%       .linecolor = 'r';
%       .rootSizeRatio = 1.5;
%
% Type MHTTreeDiagram for a demo using a matrix input.
%
%% Inputs
%   tracks    (.)   Data structure array of track information, OR:
%             {:}   Cell array of tree node data, OR:
%            (:,:)  Matrix of track data with track IDs in first column
%     
%   w        (1,1)  Diagram data structure
%                   .name      (1,:) Tree name
%                   .width     (1,1) Circle width
%                   .fontName  (1,:) Font name
%                   .fontSize  (1,1) Font size
%                   .linewidth (1,1) Line width
%                   .linecolor (1,1) Line color, char or numeric
%                   .rootSizeRatio (1,1)
%   update   (1,1)  If entered update an existing plot
%
%% Outputs
%   None
%

function MHTTreeDiagram( tracks, w, update )

persistent figHandle axTree


% Demo
%-----
if( nargin < 1 )
	m =  [  1      1     1     1     1;...
          13     2     2     2     2;...
          41     0     0     1     2;...
          43     0     0     0     1;...
          44     0     0     0     2];
  
  MHTTreeDiagram( m )
  return;
end

% Defaults
%---------
if( nargin < 2 )
	w = [];
end

if( nargin < 3 )
	update = 0; 
end

if( isempty(w) )
  w.name      = 'Tree';
  w.width     = .5;
  w.fontName  = 'Times';
  w.fontSize  = 10;
  w.linewidth = 1;
  w.linecolor = 'r';
  w.rootSizeRatio = 1.5;
end

% Handle input data correctly
%----------------------------
if( isstruct(tracks) )
  trk       = tracks;
  mat       = MHTTrkToB(trk);
  [mat,ks]  = MHTMatrixSortRows(mat);
  tree      = MHTMatrixTreeConvert(mat);
  trk       = trk(ks);
elseif( iscell(tracks) )
  trk       = [];
  tree      = tracks;
  mat       = MHTMatrixTreeConvert(tree);
elseif( isnumeric(tracks) )
  trk       = [];
  mat       = tracks;
  mat       = MHTMatrixSortRows(mat);
  tree      = MHTMatrixTreeConvert(mat);  
end

% Get figure ready
%-----------------
if( ~update || ~IsValidHandle(figHandle) ) 
	figHandle = figure('name',w.name);
	movegui(figHandle,'northeast');
	set(figHandle,'color','w','tag','MHTTrackTree');
	axTree = axes('parent',figHandle);
	axis off
    uicontrol(figHandle,'units','normalized','style','togglebutton',...
    'position',[.02 .9 .1 .08],'string','Explore...','callback',@ToggleDatatips)
else
    ch = get(axTree,'children');
    delete(ch);
end

% If no data is given, return now
%--------------------------------
if( isempty(mat) || isstruct(trk) && isempty([trk.scanHist]) )
	return
end

% Number of tracks and scans
%---------------------------
if( isstruct(tracks) )
    nT = length(tracks);
    nS = length(unique([tracks.scanHist]));
else
    [nT, nS] = size(mat);
end

% Track scores
%-------------
trackScores = [];
if( ~isempty(trk) )
  trackScores = [trk.scoreTotal];
end

% Extract the track IDs
%----------------------
trackIDs = mat(:,1);

% Number of track-trees and number of leaf-nodes for each tree
%-------------------------------------------------------------
trackIDsU   = unique(trackIDs);
nTrackTrees	= length(trackIDsU);
nLeafNodes  = zeros(1,nTrackTrees);
treeDepth   = zeros(1,nTrackTrees);
trackRows   = cell(1,nTrackTrees);
firstScan   = ones(1,nTrackTrees)*inf;
for j=1:nTrackTrees
  trackRows{j}  = find( trackIDsU(j) == trackIDs );
  for k=1:length(trackRows{j})
    v = find(mat(trackRows{j}(k),2:end)>0,1);
    if( isempty(v) )
      v = inf;
    end
    firstScan(trackRows{j}(k)) = v;
  end
  nLeafNodes(j) = length(trackRows{j});
  treeDepth(j)  = nS-min(firstScan(trackRows{j}))+1;
end

if( ~isempty(trk) )
    scans = unique([trk.scanHist]);
else
    scans = [];
end

w.xScale = 1;
w.yScale = nS/nT;

if( w.yScale>1 )
  w.width = w.width/w.yScale;
end

% Get all track-tree roots
%-------------------------
roots = []; 
for j=1:length(tree), 
  if( isempty(tree{j}.parent) ), 
    roots(end+1)=j; 
  end
end

% Draw the tree
%--------------
set(axTree,'xlim',[-1 nT+nTrackTrees+1],'ylim',[-1.5 nS+1],...
  'units','normalized','position',[.1 .05 .8 .9],'visible','off');
axes(axTree)

for k=1:nS+1
  
  % Determine the correct label
  %----------------------------
  if( k>1 )
    y = nS+1-k;
    if( isempty(scans) )
      label = '--';
    else      
      label = sprintf('Scan %d',scans(k-1));
    end
    text(-.5,y,label,'fontname',w.fontName,'fontsize',w.fontSize);
  end

end
hold on

x0 = 0;
y0 = 0;
for j=1:nTrackTrees
  
  k = roots(j);
  [scanIndex,nodeSet] = TreeStructure( tree{k}.scan, {k}, tree, k );
  [scanIndex,ks] = sort(scanIndex,2,'descend');
  nodeSet = nodeSet(ks);
    
  
  % Start at the leaf nodes and go up
  %----------------------------------
  xx0 = x0;
  for k = 1:length(scanIndex)
  
    yy0 = nS+1-scanIndex(k);
    if( k>1 && diff(scanIndex(k-1:k))<0 )
      xx0 = x0;
    end      
    
    for p=1:length(nodeSet{k})
      
      % Center above children
      %----------------------
      if( ~isempty( tree{nodeSet{k}(p)}.childNodes ) )
        nCh = length(tree{nodeSet{k}(p)}.childNodes);
        xCh = zeros(1,nCh);
        for z=1:nCh
          xCh(z)=tree{tree{nodeSet{k}(p)}.childNodes(z)}.xC;
        end
        xx0 = mean( xCh );
      else
        xx0 = xx0 + 1;
      end
      
      % Record x and y
      %---------------
      tree{nodeSet{k}(p)}.xC = xx0;
      tree{nodeSet{k}(p)}.yC = yy0;
      
      % Draw the node
      %--------------
      isRoot = isempty(tree{nodeSet{k}(p)}.parent);
      DrawMyNode(xx0,yy0,tree{nodeSet{k}(p)}.name,w,isRoot);
      
    end
    
  end
  
  x0 = x0 + nLeafNodes(j)+1;
end


% Connect the nodes
%------------------
for k = 1:length(tree)
  if( ~isempty(tree{k}.parent) )
    ConnectMyNode( tree{k}, tree{tree{k}.parent},w );
  end
end

% Draw score bars underneath each track
%--------------------------------------
if( ~isempty(trackScores) )
  x0 = 1;
  y0 = -1.25;
  % Normalize track scores
  %-----------------------
  if( all(isinf(trackScores)) )
    scores = zeros(size(trackScores));
  else
    scores = trackScores/max(abs(trackScores(~isinf(trackScores))));
  end
  kTrack = 1;
  for j=1:nT
    if( j>sum(nLeafNodes(1:kTrack)) )
      kTrack = kTrack+1;
    end
    x = x0+(j-1)+kTrack-1+[-1 1 1 -1]/4;
    y = y0+[0 0 1 1]*scores(j);
    sb(j) = fill(x,y,'b');
    set(sb(j),'userdata',trackScores(j),'buttondownfcn','disp(get(gco,''userdata''))')
  end
end

axis off
%axis image

h = datacursormode(figHandle);
set(h,'UpdateFcn',@DataCursorUpdateFcn,'SnapToDataVertex','on','displaystyle','window');
%drawnow


%------------------------------------------------------
% Check if handle is a valid MHTTrackTree figure window
%------------------------------------------------------
  function v = IsValidHandle( h )
    v = 1;
    if( isempty(h) || ~ishandle(h) || ~strcmp(get(h,'tag'),'MHTTrackTree') )
      v = 0;
    end
    return;
    

  function ToggleDatatips(varargin)
    if( get(gco,'value') )
      datacursormode on
    else
      datacursormode off
    end
    


%--------------------------------------------------------------------------
%	Draw a node. This is a circle with a number in the middle.
%--------------------------------------------------------------------------
function h = DrawMyNode( x0, y0, k, w, isRoot )

if( ~isRoot )
  n = 25;
  a = linspace(0,2*pi*(1-1/n),n);
  xa = cos(a);
  ya = sin(a);
  lw = .5;
  fw = 'normal';
  
else
  xa = [-1 1 1 -1 -1]*w.rootSizeRatio;
  ya = [-1 -1 1 1 -1]*w.rootSizeRatio;
  lw = 3;
  fw = 'bold';
end

x = w.xScale*w.width*xa/2 + x0;
y = w.yScale*w.width*ya/2 + y0;
h = fill(x,y,'w','linewidth',lw);
  
text(x0,y0,sprintf('%d',k),'fontname',w.fontName,'fontsize',w.fontSize,...
  'horizontalalignment','center','fontweight',fw);


%--------------------------------------------------------------------------
%	Connect a node to its parent
%--------------------------------------------------------------------------
function ConnectMyNode( n, nP, w )

if( isempty(nP.parent) )
  f = w.rootSizeRatio;
else
  f = 1;
end

x = [n.xC nP.xC];
y = [n.yC+w.yScale*w.width/2 nP.yC-w.yScale*w.width/2*f];

line(x,y,'linewidth',w.linewidth,'color',w.linecolor);


%--------------------------------------------------------------------------
%	Recursively build track-tree structure
%--------------------------------------------------------------------------
function [scanIndex,nodeSet] = TreeStructure( scanIndex, nodeSet, tree, node )

if( isempty( tree{node}.childNodes ) )
  return
end

scanIndex(end+1) = tree{node}.scan+1;
nodeSet{end+1}   = tree{node}.childNodes;

for k=tree{node}.childNodes
  [scanIndex,nodeSet] = TreeStructure( scanIndex, nodeSet, tree, k );
end

%-------------------------
% data cursor update fcn
%-------------------------
function [txt] = DataCursorUpdateFcn(obj,event_obj)
% Display 'Time' and 'Amplitude'
pos = get(event_obj,'Position');

x = pos(1);
y = pos(2);
d = GetTrackInfo( x, y );

if( isempty(d) )
  txt = {''};
  return
end

txt = {...
  ['Track ID:    ',num2str(d.trackID)],...
  ['Scan #:      ',num2str(d.scan)],...
  ['Meas #:      ',num2str(d.meas)],...
  ['Score:       ',num2str(d.score)],...
  ['Track Score: ',num2str(d.trackScore)]};
    
%-------------------------
% Get track info from a clicked position on the axis
%-------------------------
function d = GetTrackInfo( x, y )

xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
if( x<xlim(1) || x>xlim(2) || y<ylim(1) || y>ylim(2) )
  d=[];
  return
end

% TODO: finish implementation
d.trackID = -1;
d.scan    = -1;
d.meas    = -1;
d.score   = -1;
d.trackScore = -1;      
