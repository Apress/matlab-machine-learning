%% MHTTRKTOB  Converts a "trk" data structure to a "b" matrix.
%%  Form
%   b = MHTTrkToB( trk )
%
%% Description
% Converts a "trk" data structure to a "b" matrix.
%
% The bMeas or "b" matrix represents a stacked set of track-trees.
%
% * Each row is a different path through a track-tree.
% * Each column is a different scan/sensor combination.
% * Each value in the matrix is a measurement index for that scan. 
%
% The first column of the "b" matrix has the object ID for each track.
% Several tracks may have the same object ID. In this case, they represent
% alternative sets of measurements that may be attributed to the object.
%
% Type MHTTrkToB for a demo. Will draw the tree if there are no outputs.
%
%% Inputs    
%   trk       (:)    Track data structure array
%
%% Outputs
%   b         (:,:)   Matrix [tracks,measurements]
%   

function b = MHTTrkToB( trk )

if( nargin < 1 )
  Demo
  return;
end

% Handle empty tracks
%--------------------
if( isempty(trk) )
    b = [];
    return;
end

nT  = length(trk);

% Get the scanID list
%--------------------
scanID  = unique([trk.scanHist]);
nS      = length(scanID);
b       = zeros(nT,nS);
for i=1:nT
	if( ~isempty(trk(i).scanHist) )
    for j=1:length(trk(i).scanHist)
      s       = trk(i).scanHist(j);
      k       = find(s==scanID);
      b(i,k)	= trk(i).measHist(j);
    end
  else
    b(i,1) = 0;
	end
end
 
% Prepend track-tree IDs
b = [ [trk.treeID]', b ];

% If there are no outputs draw the tree
if( nargout < 1 )
    MHTMatrixTreeConvert( b );
    MHTTreeDiagram( trk );
    clear b;
end
%% MHTTrkToB>>Demo
function Demo
% Create a track data structure and generage the b matrix
k=1;
trk(k).measHist = [1 1 0 0]; k=k+1;
trk(k).measHist = [1 1 1 1]; k=k+1;
trk(k).measHist = [1 1 1 2]; k=k+1;
trk(k).measHist = [1 2 0 1]; k=k+1;
trk(k).measHist = [1 2 0 2]; k=k+1;
trk(k).measHist = [1 2 1 1]; k=k+1;
trk(k).measHist = [2 1 0 0]; k=k+1;
trk(k).measHist = [2 1 0 1]; k=k+1;
trk(k).measHist = [2 1 1 1]; k=k+1;
trk(k).measHist = [2 1 1 2]; k=k+1;
trk(k).measHist = [2 2 1 1]; k=k+1;
trk(k).measHist = [2 2 1 2]; k=k+1;
  
for i=1:k-1
  trk(i).scanHist = [5 6 7 8];
end
trk(k).measHist = [2   2 1];
trk(k).scanHist = [5   7 8];
k=k+1;
trk(k).measHist = [  1 1 1];
trk(k).scanHist = [  6 7 8];
k=k+1;
trk(k).measHist = [  1 1 2];
trk(k).scanHist = [  6 7 8];
  
for k=1:length(trk)
  trk(k).treeID = ceil(k/3);
end

% A track data structure
b = MHTTrkToB( trk );  
disp(b)
  
% Display the tree
n = MHTMatrixTreeConvert( b );
MHTTreeDiagram( n );

