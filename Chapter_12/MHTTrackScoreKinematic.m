%% MHTTRACKSCOREKINEMATIC Kinematic track score
%
%% Form:
%  lR = MHTTrackScoreKinematic( y, h, r, p, v )
%
%% Description
% Kinematic track score. This is the likelihood ratio for the kinematics.
% Assumes a Gaussian distribution for false returns.
%
% Type TrackScoreKinematic for a demo with a decreasing covariance
% matrix for a 1D problem and a fixed residual error.
%
%% Inputs
%   y         (m,1) Measurement residual vector
%   h         (m,n) Measurement matrix
%   r         (m,m) Measurement covariance matrix
%   p         (n,n) Covariance matrix
%   pD        (1,1) Probability of detection on 1 scan
%
%% Outputs
%   lR        (1,1) Likelihood ratio
%
%% References
% Blackman, S. and R. Popoli, "Design and Analysis of  Modern
% Tracking Systems," Artech House, 1999.

function lR = MHTTrackScoreKinematic( y, h, r, p, pD )

% Demo
if( nargin < 1 )
  Demo
   return
end

% The first branch is when there are no measurements
if( isempty(y) )
    lR = 1 - pD;
else

    % Length of the measurement vector
    M  = length(y);

    % Measurement residual covariance matrix
    s  = h*p*h' + r;

    % Normalized statistical distance
    d2 = y'*(s\y);

    % The likelihood ratio
    lR = pD*exp(-0.5*d2)/((2*pi)^(0.5*M)*sqrt(det(s)));
end

%% MHTTrackScoreKinematic>>Demo
function Demo
% Demo

h    = [1 0];
r    = 0.001;
n    = 100;
pD	= 0.9;
p    = diag([1 0.1]);
y    = 0.1;
pN   = zeros(1,n);
lR   = zeros(1,n);
   
for k = 1:n
	pN(k) = norm(p);
	lR(k) = MHTTrackScoreKinematic( y, h, r, p, pD );
	 p     = p*0.8;
end
PlotSet(pN,lR,'x label', 'Norm(p)', 'y label','LR','figure title','Track Score', 'plot type', 'ylog');

