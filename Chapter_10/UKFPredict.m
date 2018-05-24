
%% UKFPREDICT Unscented Kalman Filter measurement update step
%% Form
%   d = UKFPredict( d )
%
%% Description
% Unscented Kalman Filter state prediction step.
%
% This uses RungeKutta to propagate the state.
%
% Use d = UKFWeight( d ) to get the weight matrices.
%
% The function f is of the form f(t,x,d) where d is a data structure
% contained in fData.
%
%% Inputs
%   d	(1,1)  UKF data structure
%              .m       (n,1)       Mean
%              .p       (n,n)       Covariance
%              .q       (n,n)       State noise
%              .wM      (1,2n+1)    Model weights
%              .w       (2n+1,2n+1)	Weight matrix
%              .f       (1,:)       Pointer for the right hand side
%                                   function
%              .fData   (1,1)       Data structure with data for f
%              .dT      (1,1)       Time step (s)
%              .t       (1,1)       Time (s)
%
%% Outputs
%   d	(1,1)  UKF data structure
%              .m       (:,1)       Mean
%              .p       (:,:)       Covariance

function d = UKFPredict( d )

pS      = chol(d.p)';
nS      = length(d.m);
nSig    = 2*nS + 1;
mM      = repmat(d.m,1,nSig);
x       = mM + d.c*[zeros(nS,1) pS -pS];

xH      = Propagate( x, d );
d.m     = xH*d.wM;
d.p     = xH*d.w*xH' + d.q;
d.p     = 0.5*(d.p + d.p'); % Force symmetry


%% Propagate each sigma point state vector
function x = Propagate( x, d )

for j = 1:size(x,2)
	x(:,j) = RungeKutta( d.f, d.t, x(:,j), d.dT, d.fData );
end
