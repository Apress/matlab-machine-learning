%% MHTDISTANCEUKF Finds the MHT distance
%% Form:
%   [k, del] = MHTDistanceUKF( d )
%
%% Description 
% Finds the MHT distance for use in gating computations using UKF.
%
% The measurement function is of the form h(x,d) where d is the UKF
% data structure. MHTDistanceUKF uses sigma points. The code is similar
% to UKFUpdate. Unlike MHTDistance this does not use the Jacobian of the
% measurement function.
%
% As the uncertainty gets smaller, the residual must be smaller to 
% remain within the gate. 
%
%
%% Inputs
%   d         (.)   UKF data structure
%
%% Outputs
%   k        (1,1)  MHT distance
%   del      (1,1)  MHT Residual
%
%% See Also
% MHTDistance for an alternative approach.

function [k, del] = MHTDistanceUKF( d )

% Get the sigma points
pS      = d.c*chol(d.p)';
nS      = length(d.m);
nSig    = 2*nS + 1;
mM      = repmat(d.m,1,nSig);
if( length(d.m) == 1 )
    mM = mM';
end

x       = mM + [zeros(nS,1) pS -pS];

[y, r]	= Measurement( x, d );
mu      = y*d.wM;
b       = y*d.w*y' + r;
del     = d.y - mu;
k       = del'*(b\del);

%% MHTDistanceUKF>>Measurement
function [y, r] = Measurement( x, d )
%	Measurement from the sigma points

nSigma  = size(x,2);
lR      = length(d.r);
y       = zeros(lR,nSigma);
r       = d.r;
iR      = 1:lR;

for j = 1:nSigma
	f           = feval( d.hFun, x(:,j), d.hData );
	y(iR,j)     = f;
	r(iR,iR)    = d.r;
end
