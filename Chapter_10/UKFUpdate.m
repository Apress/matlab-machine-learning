
%% UKFUPDATE Unscented Kalman Filter measurement update step.
%% Form
%  d = UKFUpdate( d )
%
%% Description
%  Unscented Kalman Filter measurement update step.
%
%% Inputs
%   d	(.)  UKF data structure
%              .m       (:,1)	Mean
%              .p       (:,:)	Covariance
%              .hFun    {}    Measurement function pointers
%              .hData   {}    Measurement function data
%              .r       {}    Measurement covariance matrices
%              .y       (1,1)	Measurements
%              .w       (:,:)	Weighting matrix
%              .wM      (:,1)	Weights
%
%% Outputs
%   d	(.)  UKF data structure
%              .m       (:,1)	Mean
%              .p       (:,:)	Covariance
%              .v       (m,1)	Residuals

function d = UKFUpdate( d )

% Get the sigma points
pS      = d.c*chol(d.p)';
nS      = length(d.m);
nSig    = 2*nS + 1;
mM      = repmat(d.m,1,nSig);
x       = mM + [zeros(nS,1) pS -pS];
[y, r]	= Measurement( x, d );
mu      = y*d.wM;
s       = y*d.w*y' + r;
c       = x*d.w*y';
k       = c/s;
d.v     = d.y - mu;
d.m     = d.m + k*d.v;
d.p     = d.p - k*s*k';


%%	Measurement estimates from the sigma points
function [y, r] = Measurement( x, d )

nSigma = size(x,2);

% Create the arrays
lR  = length(d.r);
y   = zeros(lR,nSigma);
r   = d.r;

for j = 1:nSigma
	f         = feval(d.hFun, x(:,j), d.hData );
	iR        = 1:lR;
	y(iR,j)   = f;
end

