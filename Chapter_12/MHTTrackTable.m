function t = MHTTrackTable( h, trk, k, pos )

%% MHTTRACKTABLE Generate a uitable object with measurement indices.
% Rows are labeled as <treeID>.<tag>
% Columns are labeled with scan ID.
% Contents of table cells are measurement IDs for each scan.
%
% Type MHTTrackTable for a demo. Creates 2 table windows.
%% Form:
%   t = MHTTrackTable( h,  trk, k, pos )  New table "t" in figure "h"
%   t = MHTTrackTable( [], trk, k, pos )  New table "t" in new figure
%       MHTTrackTable( t,  trk, k )       Update table "t" with "k" tracks
%       MHTTrackTable( t,  trk )          Update table "t" with all tracks
%% Inputs    
%   h         (1,1)   Figure handle or table handle
%   trk       (:)     Track data structure
%   k         (1,:)   Integer array. Set of tracks to include in table.
%   pos       (1,4)   Normalized position of table in figure.
%
%% Outputs
%   t         (1,1)   Graphics handle for uitable object.

% Demo
%-----
if( nargin < 1 )
  h = figure('name','MHT Track Table Demo');
  trk(1).scanHist     = [1 2 3 4];
  trk(1).measHist     = [0 0 0 1];
  trk(1).scoreTotal   = 50;
  trk(1).sensorHist	= [];
  trk(1).iD           = 11;
  trk(1).treeID       = 1;
  trk(1).tag          = 1;

  trk(2).scanHist     = [  2 3 4];
  trk(2).measHist     = [  1 0 1];
  trk(2).scoreTotal   = 90;
  trk(2).sensorHist   = [];
  trk(2).iD           = 22;
  trk(2).treeID       = 1;
  trk(2).tag          = 1;

  trk(3).scanHist     = [1 2 3 4];  
  trk(3).measHist     = [1 1 1 1];
  trk(3).scoreTotal   = 130;
  trk(3).sensorHist   = [];
  trk(3).iD           = 33;
  trk(3).treeID       = 1;
  trk(3).tag          = 1;

  MHTTrackTable(h,trk);

  h2 = figure('name','MHT Track Table Demo 2');
  MHTTrackTable(h2,trk,[1 3]);

  return
end
  
if( ~ishandle(h) )
  error('Must supply a valid figure handle or uitable handle.')
end

if( nargin<3 )
  k = 1:length(trk);
end

if( nargin<4 )
  pos = [];
end

if( isempty(h) )
  h = NewFig('MHT Track Table');
end
  
switch get(h,'type')
  case 'uitable'
    t = h;
  case 'figure'
    if( isempty(pos) )
      pos = [.1 .1 .8 .8]; 
    end
    t = uitable(h,'units','normalized','position',pos);
end

if( isempty(trk) )
  return;
end

% table data is cell array form of b matrix for selected subset of trk
% data structure array
trkk = trk(k);

bk = MHTTrkToB(trkk);

scanID  = unique([trkk.scanHist]);
treeID  = [trkk.treeID];
tag     = [trkk.tag];
scores  = [trkk.scoreTotal];

bk = bk(:,2:end); % take off prepended track IDs
[nT,nS] = size(bk);

rowNames = cell(1,nT);
colNames = cell(1,nS+1);

for i=1:nT
  rowNames{i} = sprintf('TRK %d.%d',treeID(i),tag(i));
end

if( isempty(scanID) )
  colNames{1} = '-';
else
  for j=1:nS
    colNames{j} = sprintf('S%d',scanID(j));
  end
end
colNames{end} = 'Score';

data = cell(nT,nS+1);
for i=1:nT
  for j=1:nS
    data{i,j} = bk(i,j);
  end
  data{i,nS+1} = scores(i);
end

set(t,'rowname',rowNames,'columnName',colNames,'data',data);

%--------------------------------------
% PSS internal file version information
%--------------------------------------
% $Date: 2017-01-13 11:26:32 -0500 (Fri, 13 Jan 2017) $
% $Revision: 43808 $
