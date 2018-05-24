%% MHTInitialTrackScore - initialize the track score
%% Form
%   lR = MHTInitialTrackScore( betaNT, vC, pD, pFA, pH1, pH0 )
%
%% Description
%   Initialize the track likelihood ratio.
%
%   Type MHTInitialTrackScore for a demo showing the effect of pD.
%
%% Inputs
%   betaNT	(1,1) New target density 
%   vC      (1,1) Control volume
%   pD      (1,1) Probability of detection 
%   pFA     (1,1) Probability of false alarm
%   pH1     (1,1) Probability of a signal if a target is present 
%   pH0     (1,1) Probability of a signal if a target is absent
%
%% Outputs
%   lR      (1,1) Initial Likelihood ratio
%
%% References
% Blackman, S. and R. Popoli, "Design and Analysis of  Modern
% Tracking Systems," Artech House, 1999, p. 331.

function lR = MHTInitialTrackScore( betaNT, vC, pD, pFA, pH1, pH0 )

% Demo
if( nargin < 1 )
  Demo
	return
end

lR = betaNT.*vC.*MHTTrackScoreSignal( pD, pFA, pH1, pH0 );

%% MHTInitialTrackScore>>Demo
function Demo
% Create a track score
pD       = linspace(0.1,1);
pFA      = 0.01;
pH1      = 0.9;
pH0      = 0.1;
vC       = 10;
betaNT	= 1;
llR = log(MHTInitialTrackScore( betaNT, vC, pD, pFA, pH1, pH0 ));
PlotSet(pD,llR,'x label','Probability of Detection','y label',...
  'Log Likelihood','figure title','Initial Track Core');

