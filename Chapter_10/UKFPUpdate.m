
%% UKFPUPDATE Unscented Kalman Filter parameter update step
%%  Form
%   d = UKFPUpdate( d )
%
%% Description
%   Implement an Unscented Kalman Filter for parameter estimation.
%   The filter uses numerical integration to propagate the state.
%   The filter propagates sigma points, points computed from the
%   state plus a function of the covariance matrix. For each parameter
%   there are two sigma parameters. The current estimated state must be
%   input each step.
%
%% Inputs
%   d	(1,1)	UKF data structure
%           .x      (n,1)       State
%           .p    	(n,n)       Covariance
%           .q      (n,n)       State noise covariance
%           .r      (m,m)       Measurement noise covariance
%           .wM    	(1,2n+1)    Model weights
%           .wC    	(1,2n+1)    Model weights
%           .f    	(1,:)       Pointer for the right hand side function
%           .fData	(.)         Data structure with data for f
%          	.hFun   (1,:)       Pointer for the measurement function
%          	.hData	(.)         Data structure with data for hFun
%         	.dT    	(1,1)       Time step (s)
%          	.t    	(1,1)       Time (s)
%         	.eta    (:,1)       Parameter vector
%          	.c    	(1,1)       Scaling constant
%           .lambda	(1,1)      	Scaling constant
%
%% Outputs
%   d	(1,1)	UKF data structure
%          	.p       (n,n)       Covariance
%         	.eta     (:,1)       Parameter vector
%
%% References
%   References: Van der Merwe, R. and Wan, E., "Sigma-Point Kalman Filters for
%               Probabilistic Inference in Dynamic State-Space Models".
%               Matthew C. VanDyke, Jana L. Schwartz, Christopher D. Hall,
%               "UNSCENTED KALMAN FILTERING FOR SPACECRAFT ATTITUDE STATE AND
%               PARAMETER ESTIMATION,"AAS-04-115.

function d = UKFPUpdate( d )

d.wA	= zeros(d.L,d.n);
D     = zeros(d.lY,d.n);
yD    = zeros(d.lY,1);

% Update the covariance
d.p   = d.p + d.q;

% Compute the sigma points
d     = SigmaPoints( d );

% We are computing the states, then the measurements
% for the parameters +/- 1 sigma
for k = 1:d.n
  d.fData.eta	= d.wA(:,k);
  x           = RungeKutta( d.f, d.t, d.x, d.dT, d.fData );
  D(:,k)      = feval( d.hFun, x, d.hData );
  yD          = yD + d.wM(k)*D(:,k);
end

pWD = zeros(d.L,d.lY);
pDD = d.r;
for k = 1:d.n
  wD	= D(:,k) - yD;
  pDD	= pDD + d.wC(k)*(wD*wD');
  pWD = pWD + d.wC(k)*(d.wA(:,k) - d.eta)*wD';
end

pDD = 0.5*(pDD + pDD');

% Incorporate the measurements
K       = pWD/pDD;
dY      = d.y - yD;
d.eta   = d.eta + K*dY;
d.p     = d.p - K*pDD*K';
d.p     = 0.5*(d.p + d.p'); % Force symmetry

%% Create the sigma points for the parameters
function d = SigmaPoints( d )

n         = 2:(d.L+1);
m         = (d.L+2):(2*d.L + 1);
etaM      = repmat(d.eta,length(d.eta));
sqrtP     = chol(d.p);
d.wA(:,1) = d.eta;
d.wA(:,n) = etaM + d.gamma*sqrtP;
d.wA(:,m) = etaM - d.gamma*sqrtP;
