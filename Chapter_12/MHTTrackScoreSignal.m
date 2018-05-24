%% MHTTRACKSCORESIGNAL Signal track score
%% Form
%  llR = MHTTrackScoreSignal( pD, pFA, pH1, pH0 )
%
%% Description
% Signal track score. All inputs can be vectors but the must have the same
% dimension.
%
% Type MHTTrackScoreSignal for a demo showing the effect of pD.
%
%% Inputs
%   pD      (1,1) Probability of detection 
%   pFA     (1,1) Probability of false alarm
%   pH1     (1,1) Probability of a signal if a target is present 
%   pH0     (1,1) Probability of a signal if a target is absent
%
%% Outputs
%   lR      (1,1) Likelihood ratio
%
%% References
% Blackman, S. and R. Popoli, "Design and Analysis of  Modern
% Tracking Systems," Artech House, 1999, p. 330.
%
function lR = MHTTrackScoreSignal( pD, pFA, pH1, pH0 )

% Demo
if( nargin < 1 )
  Demo;
  return
end

lR = pD.*pH1./pFA./pH0;

%% MHTTrackScoreSignal>>Demo
function Demo
% Demo

pD  = linspace(0.1,1);
pFA = 0.01;
pH1 = 0.9;
pH0 = 0.1;
llR = log(MHTTrackScoreSignal( pD, pFA, pH1, pH0 ));
PlotSet(pD,llR,'x label','Probability of Detection',...
  'y label','Log Likelihood','figure title','Track Core Signal')
