%% TOMHTASSIGNMENT Track oriented MHT assignment
%% Form
%   d = TOMHTAssignment( trk, M, glpkParams );
%
%% Description
% Track oriented MHT assignment. Generates hypotheses.
%
% The "b" matrix represents a stacked set of track-trees.
% Each row is a different path through a track-tree
% Each column is a different scan
% Values in matrix are index of measurement for that scan
% 
% A valid hypothesis is a combination of rows of b (a combination of
% track-tree paths), such that the same measurement is not repeated.
% 
% Solution vector "x" is 0|1 array that selects a set of track-tree-paths.
% 
% Objective is to find the hypothesis that maximizes total score.
%
%% Inputs
%   trk         (.)       Data structure array of track information
%                         From this data we will obtain:
%   b           (nT,nS)   Matrix of measurement IDs across scans
%   trackScores (1,nT)    Array of total track scores
%   treeIDs     (1,nT)    Array of track ID numbers. A common ID across
%                         multiple tracks means they are in the same
%                         track-tree.
%   M           (1,1)     Number of hypotheses to generate. 
%   glpkParams  (.)       Data structure with glpk parameters.
%
%%  Outputs
%   d           (.)     Data structure with fields:
%                         .nT     Number of tracks
%                         .nS     Number of scans
%                         .M      Number of hypotheses
%                         .pairs  Pairs of hypotheses for score constraints
%                         .nPairs Number of pairs
%                         .A      Constraint matrix for optimization
%                         .b      Constraint vector for optimization
%                         .c      Cost vector for optimization
%                         .lb     lower bounds on solution vector
%                         .ub     upper bounds on solution vector
%                         .conType  Constraint type array
%                         .varType  Variable type array
%                         .x        Solution vector for optimization
%                         .hypothesis(:)  Array of hypothesis data
%   
%     d.hypothesis(:)   Data strcuture array with fields:
%                     .treeID       Vector of track-tree IDs in hypothesis
%                     .trackIndex   Vector of track indices in hypothesis.
%                                   Maps to rows of "b" matrix.
%                     .tracks       Set of tracks in hypothesis. These are
%                                   the selected rows of "b" matrix.
%                     .trackScores  Vector of scores for selected tracks.
%                     .score        Total score for hypothesis.
%
%% References
% 	Blackman, S. and R. Popoli, "Design and Analysis of  Modern
%  	Tracking Systems," Artech House, 1999.

function d = TOMHTAssignment( trk, M, glpkParams )

%==================================
%     --- OPTIONS --- 
%
%   Prevent tracks with all zeros 
%   from being selected?
%
preventAllZeroTracks = 0;
%
%
%
%   Choose a scoring method:
%     log-LR    sum of log of likelihood ratios
%     LR        sum of likelihood ratios
%     prob      sum of probabilities
%
scoringMethod = 'log-LR'; 
%
%==================================



% how many solutions to generate?
if( nargin<2 )
  M = 2;
end

% GLPK parameters
if( nargin<5 )
  % Searching time limit, in seconds. 
  %   If this value is positive, it is decreased each 
  %   time when one simplex iteration has been performed by the
  %   amount of time spent for the iteration, and reaching zero 
  %   value signals the solver to stop the search. Negative 
  %   value means no time limit.
  glpkParams.tmlim = 10;  
  
  % Level of messages output by solver routines:
  %   0 - No output.
  %   1 - Error messages only.
  %   2 - Normal output.
  %   3 - Full output (includes informational messages).
  glpkParams.msglev = 0;

end

% extract "b" matrix
%[b,bSens,bScan] = MHTTrkToB(trk);
b = MHTTrkToB(trk);

% the track tree IDs
treeIDs = [trk.treeID];

scans = unique([trk.scanHist]);
scan = max(scans);

% the track scores
switch lower(scoringMethod)
  case 'log-lr'
    % the "scoreTotal" field is the sum of log likelihood ratios
    trackScores = [trk.scoreTotal];
  case 'lr'
    % Redefine scores this way rather than sum of log of each scan score
    trackScores = zeros(1,nT);
    for j=1:nT
      if( ~isempty(trk(j).scanHist) )
        trackScores(j) = sum(trk(j).score(trk(j).scanHist(1):end));
      else
        trackScores(j) = sum(trk(j).score);
      end
    end
  case 'prob'
    error('Probability scoring not implemented yet.')
end

% remove occurrence of "inf"
kinf = find(isinf(trackScores));
trackScores(kinf) = sign(trackScores(kinf))*1e8;


% remove treeIDs column from b
b = b(:,2:end);

[nT,nS] = size(b);

nCon = 0;   % number of constraints not known yet. compute below
nVar = nT;  % number of variables is equal to total # track-tree-paths

% compute number of constraints
for i=1:nS  
  % number of measurements taken for this scan
  nMeasForThisScan = max(b(:,i));
  nCon = nCon + nMeasForThisScan;
end

% Initialize A, b, c
d.A = zeros(nCon,nVar*M);
d.b = zeros(nCon,1);
d.c = zeros(nVar*M,1);
d.conType = char(zeros(1,nCon));
d.varType = char(zeros(1,nVar));
for i=1:M
  col0 = (i-1)*nT;
  for j=1:nT
    d.varType(col0+j) = 'B'; % all binary variables
    d.c(col0+j) = trackScores(j);
  end
end

conIndex = 0;

col0 = 0;

% find set of tracks that have all zeros, if any
bSumCols = sum(b,2);
kAllZeroTracks = find(bSumCols==0);

for mm = 1:M

  % **** OBJECT ID CONSTRAINTS ****
  % for each track-tree ID
  treeIDsU = unique(treeIDs);
  for i=1:length(treeIDsU)
    rows = find(treeIDs==treeIDsU(i));
    
    % for each row of b with this track ID
    conIndex = conIndex+1;
    for j=rows
      d.A(conIndex,col0+j) = 1;
      d.b(conIndex,1)        = 1;
      d.conType(conIndex)   = 'U'; % upper bound: A(conIndex,:)*x <= 1
    end
  end
    
  % **** MEASUREMENT INDEX CONSTRAINTS ****
  % for each column (unique sensor/scan combination)
  for i=1:nS
    
    % measurement index values for this scan
    measIndex = unique(b(:,i))';
    measIndex = measIndex(measIndex~=0);
        
    % for each measurement (not 0)
    for k=measIndex
      
      % get rows of b matrix with this measurement index
      bRowsWithMeasK = find(b(:,i)==k);
      
      conIndex = conIndex+1;
      
      % for each row
      for j = bRowsWithMeasK
        
        d.A(conIndex,col0+j)  = 1;
        d.conType(conIndex)   = 'U'; % upper bound: A(conIndex,:)*x <= 1
        
      end
      d.b(conIndex,1) = 1;
      
    end
  end
  
  % prevent tracks with all zero measurements from being selected
  if( preventAllZeroTracks )
    for col = kAllZeroTracks
      conIndex = conIndex+1;
      d.A(conIndex,col) = 1;
      d.b(conIndex,1) = 0;
      d.conType(conIndex) = 'S';
    end
  end
  
  % must select at least one track for each hypothesis
  conIndex = conIndex + 1;
  d.A( conIndex, col0+(1:nT) ) = 1;
  d.b( conIndex, 1 ) = 1;
  d.conType(conIndex) = 'L';
  
  col0 = col0 + nT;
  
end

% variable bounds
d.lb = zeros(size(d.c));
d.ub = ones(size(d.c));

% add set of constraints / vars for each pair of solutions
if( M>1 )
  pairs = nchoosek(1:M,2);
  nPairs = size(pairs,1);
  
  for i=1:nPairs
    k1 = pairs(i,1);
    k2 = pairs(i,2);
    xCol1 = (k1-1)*nT+1 : k1*nT;
    xCol2 = (k2-1)*nT+1 : k2*nT;
    
    % enforce second score to be less than first score
    % c1*x1 - c2*x2 >= tol
    conIndex = conIndex + 1;
    d.A(conIndex,xCol1) = d.c(xCol1);
    d.A(conIndex,xCol2) = -d.c(xCol2);
    d.b(conIndex)       = 10;           % must be non-negative and small
    d.conType(conIndex) = 'L';
    
  end
else
  pairs = [];
  nPairs = 0;
end

if( nT>1 )
  
  % call glpk to solve for optimal hypotheses
  %glpkParams.msglev = 3; % use this for detailed GLPK printout  
  
  d.A( abs(d.A)<eps ) = 0;
  d.b( abs(d.b)<eps ) = 0;
  
  [d.x,~,status] = glpk(d.c,d.A,d.b,d.lb,d.ub,d.conType,d.varType,-1,glpkParams);
  switch status
    case 1
      MLog('add',sprintf('GLPK: 1: solution is undefined.\n'),scan);
    case 2
      MLog('add',sprintf('GLPK: 2: solution is feasible.\n'),scan);
    case 3
      MLog('add',sprintf('GLPK: 3: solution is infeasible.\n'),scan);
    case 4
      MLog('add',sprintf('GLPK: 4: no feasible solution exists.\n'),scan);
    case 5
      MLog('add',sprintf('GLPK: 5: solution is optimal.\n'),scan);
    case 6
      MLog('add',sprintf('GLPK: 6: solution is unbounded.\n'),scan);
    otherwise
      MLog('add',sprintf('GLPK: %d\n',status),scan);
  end
  
else
  
  d.x = ones(M,1);
  
end

d.nT = nT;
d.nS = nS;
d.M = M;
d.pairs = pairs;
d.nPairs = nPairs;
d.trackMat = b;

for mm=1:M
  rows = (mm-1)*nT+1 : mm*nT;
  sel = find(d.x(rows));
  d.hypothesis(mm).treeID       = treeIDs(sel);
  d.hypothesis(mm).tracks       = b(sel,:);
  d.hypothesis(mm).meas = {};
  d.hypothesis(mm).scans = {};
  for j=1:length(sel)
    d.hypothesis(mm).meas{j}  = trk(sel(j)).measHist;
    d.hypothesis(mm).scans{j} = trk(sel(j)).scanHist;
  end
  d.hypothesis(mm).trackIndex   = sel;
  d.hypothesis(mm).trackScores  = trackScores(sel);
  d.hypothesis(mm).score        = sum(trackScores(sel));
end