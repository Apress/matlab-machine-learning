%% MHTINITIALIZETRK Initialize the trk data structure.
%
%% Form:
%  trk = MHTInitializeTrk( f )
%
%% Description
% Initialize the trk data structure.
%
%% Inputs
%   f	  (1,1) Filter data structure
%
%% Outputs
%   trk	 (.)  Data structure
%

function trk = MHTInitializeTrk( f ) 

% Error message
if( nargin < 1 )
    error('One argument is required');
end


trk.filter      = f;
trk.mP          = trk.filter.x;
trk.pP          = trk.filter.p;
trk.m           = trk.filter.x;
trk.p           = trk.filter.p;
trk.meas        = [];
trk.score       = 0;
trk.scoreTotal	= 0;
trk.treeID      = 1;
trk.scanHist    = [];
trk.measHist    = [];
trk.mHist       = [];
trk.d           = [];
trk.new         = [];
trk.gate        = [];
trk.tag         = 0;
trk.scan0       = 0;

