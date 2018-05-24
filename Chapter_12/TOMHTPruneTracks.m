%% TOMHTPRUNETRACKS Track pruning algorithsm
%% Form
%   [tracksP,keep,prune,d] = TOMHTPruneTracks( tracks, soln );
%
%% Description
% Track-oriented MHT - track pruning algorithm.
%
% Keep the following tracks
% * Tracks with the "N" highest scores
% * Tracks in the "M best" hypotheses
% * Tracks that have:
% 1. track ID, and
% 2. the first "P" measurements
% found in "M best" hypotheses
%
%% Inputs
%   tracks    (.)     Data structure array of tracks
%   soln      (.)     Solution from TOMHTAssignment
%   scan0     (1,1)   Starting scan index. This is the depth in the
%                     track-tree at which point # scans to match is added.
%   opts      (.)     Options
%                         .nHighScoresToKeep  
%                         .nFirstMeasMatch  
%
%% Outputs
%   tracksP   (.)     Data structure array of tracks after pruning.
%   keep      (1,:)   Index list of original tracks we kept
%   prune     (1,:)   Index list of original tracks we pruned
%   dPrune    (.)     Data structure to record how "keep" indices were
%                     found:
%                       .bestTrackScores  
%                       .bestHypFullTracks
%                       .bestHypPartialTracks
%

function [tracksP,keep,prune,d] = TOMHTPruneTracks( tracks, soln, scan0, opts )

% default value for starting scan index
if( nargin<3 )
  scan0 = 0;
end

% default algorithm options
if( nargin<4 )
  opts.nHighScoresToKeep  = 5;
  opts.nFirstMeasMatch    = 3;
end

% increment the # scans to match
opts.nFirstMeasMatch = opts.nFirstMeasMatch + scan0;

% output structure to record which criteria resulted in preservation of
% which tracks
d.bestTrackScores       = [];
d.bestHypFullTracks     = [];
d.bestHypPartialTracks  = [];

% number of hypotheses, tracks, scans
nHyp    = length(soln.hypothesis);
nTracks = length(tracks);
scanSet = [];
for j=1:length(soln.hypothesis(1).scans)
  scanSet = [scanSet, soln.hypothesis(1).scans{j}];
end
scanSet = unique(scanSet);
nScans  = length(scanSet);

% must limit # required matching measurements to # scans
if( opts.nFirstMeasMatch > nScans )
  opts.nFirstMeasMatch = nScans;
end

% if # high scores to keep equals or exceeds # tracks
% then just return original tracks
if( opts.nHighScoresToKeep > nTracks )
  tracksP = tracks;
  keep    = 1:length(tracks);
  prune   = [];
  d.bestTrackScores = keep;
  return;
end

% get needed vectors out of trk array
scores    = [tracks.scoreTotal];
treeIDs  = [tracks.treeID];

% get list of all treeIDs in hypotheses
treeIDsInHyp = [];
for j=1:nHyp
  treeIDsInHyp = [treeIDsInHyp, soln.hypothesis(j).treeID];
end
treeIDsInHyp = unique(treeIDsInHyp);

% create a matrix of hypothesis data with ID and tracks
hypMat = [soln.hypothesis(1).treeID', soln.hypothesis(1).tracks];
for j=2:nHyp
  for k=1:length(soln.hypothesis(j).treeID)
    % if this track ID is not already included,
    if( all(soln.hypothesis(j).treeID(k) ~= hypMat(:,1)) )
      % then append this row to bottom of matrix
      hypMat = [hypMat; ...
        soln.hypothesis(j).treeID(k), soln.hypothesis(j).tracks(k,:)];
    end
  end
end
      
% Initialize "keep" array to all zeros
keep    = zeros(1,nTracks);

% Keep tracks with the "N" highest scores
if( opts.nHighScoresToKeep>0 )
  
  [~,ks] = sort(scores,2,'descend');
  index = ks(1:opts.nHighScoresToKeep);
  keep( index ) = 1;
  
  d.bestTrackScores = index(:)';
end

% Keep tracks in the "M best" hypotheses
for j=1:nHyp
  index = soln.hypothesis(j).trackIndex;
  keep( index ) = 1;
  
  d.bestHypFullTracks = index(:)';
end

    
% If we do not require any measurements to match,
% then include ALL tracks with an ID contained in "M best hypotheses"
if( opts.nFirstMeasMatch == 0 )
  
  % This means we include the entire track-tree for those IDs in included
  % in the set of best hypotheses.
  for k = 1:length(trackIDsInHyp)
    index = find(treeIDs == trackIDsInHyp(k));
    keep( index ) = 1;
    
    d.bestHypPartialTracks = index(:)';
  end
  
  % If the # measurements we require to match is equal to # scans, then
  % this is equivalent to the set of tracks in the hypothesis solution.
elseif( opts.nFirstMeasMatch == nScans )
  % We have already included these tracks, so nothing more to do here.
  
else
  % Otherwise, we have some subset of measurements to match.
  % Find the set of tracks that have:
  %     1. track ID and
  %     2. first "P" measurements
  % included in "M best" hypotheses
  nTracksInHypSet = size(hypMat,1);
  tagMap = rand(opts.nFirstMeasMatch+1,1);
  trkMat = MHTTrkToB( tracks );
  trkTag = trkMat(:,1:opts.nFirstMeasMatch+1)*tagMap;
  for j=1:nTracksInHypSet
    hypTrkTag = hypMat(j,1:opts.nFirstMeasMatch+1)*tagMap;
    index = find( trkTag == hypTrkTag );
    keep( index ) = 1;
    
    d.bestHypPartialTracks = [d.bestHypPartialTracks, index(:)'];
  end
  d.bestHypPartialTracks = sort(unique(d.bestHypPartialTracks));
  
end  
  
% prune index list is everything not kept
prune = ~keep;

% switch from logical array to index
keep  = find(keep);
prune = find(prune);

% return only those tracks we want to keep
tracksP = tracks(keep);