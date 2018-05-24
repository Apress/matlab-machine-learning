%% MHTTRACKMGMT Perform track reduction and track pruning
%% Form
%   [b, trk, sol, hyp] = MHTTrackMgmt( b, trk, zScan, d, scan, t )
%
%% Description
% Manage Track-Oriented Multiple Hypothesis Testing tracks.
%
% Performs track reduction and track pruning. 
%
% It creates new tracks each scan. A new track is created
% - for each measurement
% - for any track which has more than one measurement in its gate
% - for each existing track with a "null" measurement.
%
% Tracks are pruned to eliminate those of low probability and find the
% hypothesis which includes consistent tracks. Consistent tracks do 
% not share any measurements.
%
% This is typically used in a loop in which each step has new
% measurements, known as "scans". Scan is radar terminology for a 
% rotating antenna beam. A scan is a set of sensor data taken at the
% ame time.
%
% The simulation can go in ths loop to generate y or you can run the
% simulation separately and store the measurements in y. This can be
% helpful when you are debugging your MHT code.
%
% For real time systems y would be read in from your sensors. The MHT
% code would update every time you received new measurements.
%
%  zScan = [];
%   
%  for k = 1:n
%    zScan = AddScan( y(:,k), [], [], [], zScan ) ;         
%    [b, trk, sol, hyp] = MHTTrackMgmt( b, trk, zScan, trkData, k, t );
%            
%    MHTGUI(trk,sol);
%           
%    for j = 1:length(trk)
%      trkData.fScanToTrackData.v =  myData
%    end
%    if( ~isempty(zScan) && makePlots )
%      TOMHTTreeAnimation( 'update', trk );
%    end
%   
%    t = t + dT;
%	 end
%
% The reference provides good background reading but the code in this
% function is not based on the reference. Other good references are 
% books and papers by Blackman.
%
% To run this software you will need GLPK.
% You will need glpk.m and its associated mex file for your machine. For
% example, for a Mac you need the mex file glpkcc.mexmaci64. For more
% information https://www.gnu.org/software/glpk/
%
%% Inputs
%   b        (m,n)  [scans, tracks]
%   trk      (:)    Track data structure
%   zScan    (1,:)  Scan data structure
%   d        (1,1)  Track management parameters
%   scan     (1,1)  The scan id
%   t        (1,1)  Time
%
%% Outputs
%   b        (m,1)  [scans, tracks]
%   trk      (:)    Track data structure
%   sol      (.)    Solution data structure from TOMHTAssignment
%   hyp      (:)    Hypotheses
%
%% Reference
% A. Amditis1, G. Thomaidis1, P. Maroudis, P. Lytrivis1 and
% G. Karaseitanidis1, "Multiple Hypothesis Tracking
% Implementation," www.intechopen.com.

function [b, trk, sol, hyp] = MHTTrackMgmt( b, trk, zScan, d, scan, t )

% Warn the user that this function does not have a demo
if( nargin < 1 )
    disp('Error: 6 inputs are required');
    return;
end

MLog('add',sprintf('============= SCAN %d ==============',scan),scan);
          
% Add time to the filter data structure
for j = 1:length(trk)
	trk(j).filter.t = t;
end

% Remove tracks with an old scan history
earliestScanToKeep = scan-d.nScan;
keep = zeros(1,length(trk));
for j=1:length(trk)
  if( isempty(trk(j).scanHist) || max(trk(j).scanHist)>=earliestScanToKeep )
    keep(j) = 1;
  end
end
if any(~keep)
  txt = sprintf('DELETING %d tracks with old scan histories.\n',length(find(~keep)));
  MLog('add',txt,scan);
end
trk = trk( find(keep) );  
nTrk = length(trk);

% Remove old scanHist and measHist entries
for j=1:nTrk
  k = find(trk(j).scanHist<earliestScanToKeep);
  if( ~isempty(k) )
    trk(j).measHist(k)  = [];
    trk(j).scanHist(k)  = [];
  end
end

% Above removal of old entries could result in duplicate tracks
dup = CheckForDuplicateTracks( trk, d.removeDuplicateTracksAcrossAllTrees );
trk = RemoveDuplicateTracks( trk, dup, scan );
nTrk = length(trk);

% Perform the Kalman Filter prediction step
for j = 1:nTrk
	trk(j).filter	= feval( d.predict, trk(j).filter );
	trk(j).mP       = trk(j).filter.m;
	trk(j).pP       = trk(j).filter.p;
	trk(j).m        = trk(j).filter.m;
	trk(j).p        = trk(j).filter.p;
end

% Track assignment
% 1. Each measurement creates a new track
% 2. One new track is created by adding a null measurement to each existing
%    track
% 3. Each measurement within a track's gate is added to a track. If there
%    are more than 1 measurement for a track create a new track.
%
% Assign to a track. If one measurement is within the gate we just assign
% it. If more than one we need to create a new track
nNew      = 0;
newTrack	= [];
newScan   = [];
newMeas   = [];
nS        = length(zScan);

maxID = 0;
maxTag = 0;
for j = 1:nTrk
	trk(j).d = zeros(1,nS);
	trk(j).new = [];
	for i = 1:nS
    trk(j).filter.x = trk(j).m;
    trk(j).filter.y = zScan(i).data;
    trk(j).d(i)	= feval( d.fDistance,  trk(j).filter );
  end
	trk(j).gate	= trk(j).d < d.gate;
	hits        = find(trk(j).gate==1);
	trk(j).meas	= [];
	lHits       = length(hits);
	if( lHits > 0 )
    if( lHits > 1)
      for k = 1:lHits-1
        newTrack(end+1) = j;
      	newScan(end+1)  = trk(j).gate(hits(k+1));
        newMeas(end+1)  = hits(k+1);
      end
      nNew = nNew + lHits - 1;
    end
    trk(j).meas             = hits(1);
    trk(j).measHist(end+1)  = hits(1);
    trk(j).scanHist(end+1)  = scan;
    if( trk(j).scan0 == 0 )
      trk(j).scan0 = scan;
    end
  end
	maxID = max(maxID,trk(j).treeID);
	maxTag = max(maxTag,trk(j).tag);
end
nextID = maxID+1;
nextTag = maxTag+1;

% Create new tracks assuming that existing tracks had no measurements
nTrk0 = nTrk;
for j = 1:nTrk0
  
  if( ~isempty(trk(j).scanHist) && trk(j).scanHist(end) == scan )
  
    % Add a copy of track "j" to the end with NULL measurement
    nTrk                        = nTrk + 1;
    trk(nTrk)                   = trk(j);
    trk(nTrk).meas              = [];
    trk(nTrk).treeID            = trk(nTrk).treeID; % Use the SAME track tree ID
    trk(nTrk).scan0             = scan;
    trk(nTrk).tag               = nextTag;
    
    nextTag = nextTag + 1;      % increment next tag number
    
    % The track we copied already had a measurement appended for this
    % scan, so replace these entries in the history
    trk(nTrk).measHist(end)     = 0;
    trk(nTrk).scanHist(end)     = scan;
    
  end
  
end

% Do this to notify us if any duplicate tracks are created
dup   = CheckForDuplicateTracks( trk );
trk   = RemoveDuplicateTracks( trk, dup, scan );


% Add new tracks for existing tracks which had multiple measurements
if( nNew > 0 )
	nTrk = length(trk);
    for k = 1:nNew
        j                     = k + nTrk;
        trk(j)                = trk(newTrack(k));
        trk(j).meas           = newMeas(k);
        trk(j).treeID         = trk(j).treeID;    % Use the SAME track tree ID
        trk(j).measHist(end)  = newMeas(k);       % replace last measHist with this one
        trk(j).scanHist(end)  = scan;             % this should be the same number
        trk(j).scan0          = scan;
        trk(j).tag            = nextTag;

        nextTag = nextTag + 1;                    % increment next tag number
        
    end
end

% Do this to notify us if any duplicate tracks are created
dup   = CheckForDuplicateTracks( trk );
trk   = RemoveDuplicateTracks( trk, dup, scan );
nTrk  = length(trk);

% Create a new track for every measurement
for k = 1:nS
	nTrk                = nTrk + 1;  
    
    % Use next track ID
    trkF                = feval(d.fScanToTrack, zScan(i), d.fScanToTrackData, scan, nextID, nextTag );
    if( isempty(trk) )
        trk = trkF;
    else
        trk(nTrk) = trkF;
    end
    trk(nTrk).meas      = k;
    trk(nTrk).measHist  = k;
    trk(nTrk).scanHist	= scan;
    nextID              = nextID + 1;   % increment next track-tree ID
    nextTag             = nextTag + 1;  % increment next tag number
end

% Exit now if there are no tracks
if( nTrk == 0 )
  b     = [];
  hyp	= [];
  sol	= [];
  return;
end

% Do this to notify us if any duplicate tracks are created
dup   = CheckForDuplicateTracks( trk );
trk   = RemoveDuplicateTracks( trk, dup, scan );
nTrk  = length(trk);


% Remove any tracks that have all NULL measurements
kDel = [];
if( nTrk > 1 ) % do this to prevent deletion of very first track
  for j=1:nTrk
    if( ~isempty(trk(j).measHist) && all(trk(j).measHist==0) )
      kDel = [kDel j];
    end
  end
  if( ~isempty(kDel) )
    keep = setdiff(1:nTrk,kDel);
    trk = trk( keep );
  end
  nTrk = length(trk);
end


% Compute track scores for each measurement
for j = 1:nTrk
	if( ~isempty(trk(j).meas ) )
    i = trk(j).meas;
    trk(j).score(scan)	= MHTTrackScore( zScan(i), trk(j).filter, d.pD, d.pFA, d.pH1, d.pH0 );
  else
    trk(j).score(scan)	= MHTTrackScore( [],       trk(j).filter, d.pD, d.pFA, d.pH1, d.pH0 );        
	end
end

% Find the total score for each track
nTrk = length(trk);
for j = 1:nTrk
    if( ~isempty(trk(j).scanHist) )
      k1 = trk(j).scanHist(1);
      k2 = length(trk(j).score);
      kk = k1:k2;
      
      if( k1<length(trk(j).score)-d.nScan )
        error('The scanHist array spans back too far.')
      end
      
    else
      kk = 1;
    end
        
    trk(j).scoreTotal = MHTLLRUpdate( trk(j).score(kk) );
    
    % Add a weighted value of the average track score
    if( trk(j).scan0 > 0 )
      kk2 = trk(j).scan0 : length(trk(j).score);
      avgScore = min(0,MHTLLRUpdate( trk(j).score(kk2) ) / length(kk2));
      trk(j).scoreTotal = trk(j).scoreTotal + d.avgScoreHistoryWeight * avgScore;
    end
    
end

% Update the Kalman Filters
for j = 1:nTrk
	if( ~isempty(zScan) && ~isempty(trk(j).meas) )
        trk(j).filter.y         = zScan(trk(j).meas).data;
        trk(j).filter           = feval( d.update, trk(j).filter );
        trk(j).m                = trk(j).filter.m;
        trk(j).p                = trk(j).filter.p;
        trk(j).mHist(:,end+1)	= trk(j).filter.m;
	end
end

% Examine the tracks for consistency
duplicateScans = zeros(1,nTrk);
for j=1:nTrk
  if( length(unique(trk(j).scanHist)) < length(trk(j).scanHist))
    duplicateScans(j)=1;
  end
end
   
% Update the b matrix and delete the oldest scan if necessary
b = MHTTrkToB( trk );

rr = rand(size(b,2),1);
br = b*rr;
if( length(unique(br))<length(br) )
  MLog('add',sprintf('DUPLICATE TRACKS!!!\n'),scan);
end

% Solve for "M best" hypotheses
sol = TOMHTAssignment( trk, d.mBest );

% prune by keeping only those tracks whose treeID is present in the list of
% "M best" hypotheses
trk0 = trk;
if( d.pruneTracks )
  [trk,kept,pruned] = TOMHTPruneTracks( trk, sol, d.hypScanLast );
  b                 = MHTTrkToB( trk );
  
  % Do this to notify us if any duplicate tracks are created
  dup   = CheckForDuplicateTracks( trk );
  trk   = RemoveDuplicateTracks( trk, dup, scan );

  
  % Make solution data compatible with pruned tracks
  if( ~isempty(pruned) )
    for j=1:length(sol.hypothesis)
      for k = 1:length(sol.hypothesis(j).trackIndex)
        sol.hypothesis(j).trackIndex(k) = find( sol.hypothesis(j).trackIndex(k) == kept );
      end
    end
  end
  
end

if( length(trk)<length(trk0) )
  txt = sprintf('Pruning: Reduce from %d to %d tracks.\n',length(trk0),length(trk));
  MLog('add',txt,scan);
else
  MLog('add',sprintf('Pruning: All tracks survived.\n'),scan);
end

% Form hypotheses
hyp = sol.hypothesis(1);

%% MHTTrackMgmt>>RemoveDuplicateTracks
function trk = RemoveDuplicateTracks( trk, dup, scan )
% Remove duplicate tracks

if( ~isempty(dup) )
  MLog('update',sprintf('DUPLICATE TRACKS: %s\n',mat2str(dup)),scan);
  kDup = unique(dup(:,2));
  kUnq = setdiff(1:length(trk),kDup);
  trk(kDup) = [];
  dup2 = CheckForDuplicateTracks( trk );
  if( isempty(dup2) )
    txt = sprintf('Removed %d duplicates, kept tracks: %s\n',length(kDup),mat2str(kUnq));
    MLog('add',txt,scan);
  else
    error('Still have duplicates. Something is wrong with this pruning.')
  end
end
