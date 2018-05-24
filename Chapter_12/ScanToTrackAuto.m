%% SCANTOTRACKAUTO  Initializes a new track for an automobile
%% Form
%   trk = ScanToTrackAuto( xMeas, d, scan0, treeID, tag )
%
%% Description
%   Initializes a new track for an automobile from radar measurements.
%
%   The new state estimate is [x;y;vX;vY]. It is derived from the
%   radar measurement by directly computing x and y and assuming that
%   the range rate is entirely along x. x is the direction along the
%   highway.
%

%% Inputs
%   xMeas   (1,1)   Position measurement data
%   d       (1,1)   Data structure
%                   .x      (6,1) State of tracking car
%                   .filter	(1,1) Filter data structure
%   scan0   (1,1)   Scan number at which this track is created
%   treeID	(1,1)   Track-tree ID. The track is inside this tree.
%   tag     (1,1)   Unique tag to distinguish from all other tracks
%   
%% Outputs
%   trk     (1,1)   Track data structure
%
function trk = ScanToTrackAuto( xMeas, d, scan0, treeID, tag )

if( nargin < 4 )
  treeID = 0;
  warning(1,'New track made with no track tree ID. Setting to 0.');
end

if( nargin < 5 )
  tag = 0;
  warning(1,'New track made with no track tag. Setting to 0.');
end

% Compute the initial state estimate
range       = xMeas.data(1);
rangeRate   = xMeas.data(2);
azimuth     = xMeas.data(3);
c           = cos(d.theta);
s           = sin(d.theta);
cCarToI     = [c -s;s c];
u           = [cos(azimuth);sin(azimuth)];
dR          = range*u;
x           = zeros(4,1);
x(1:2,1)    = cCarToI*dR;
x(3 ,1)     = rangeRate*cos(azimuth);

% Compute the covariance from the measurement noise
r           = d.filter.r;
range       = sqrt(r(1,1));
rangeRate   = sqrt(r(2,2));
azimuth     = sqrt(r(3,3));
u           = [cos(azimuth);sin(azimuth)];
cCarToI     = [c -s;s c];
dR          = range*u;
p           = diag([cCarToI*dR;rangeRate;rangeRate].^2);

trk         = MHTInitializeTrk(d.filter);

% Assemble the trk data structure
trk.filter      = d.filter;
trk.filter.m    = x;
trk.filter.x    = x;
trk.filter.p    = p;
trk.mP          = x;
trk.pP          = p;
trk.m           = x;
trk.p           = p;
trk.meas        = [];

trk.score       = 0;
trk.scoreTotal	= 0;
trk.treeID      = treeID;
trk.scanHist    = [];
trk.measHist    = [];
trk.mHist       = [];
trk.d           = 0;
trk.new         = [];
trk.gate        = [];
trk.tag         = tag;
trk.scan0       = scan0;
