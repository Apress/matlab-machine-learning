
%% EKFUPDATE Extended Kalman Filter measurement update step.
%% Form
%  d = EKFUpdate( d )
%
%% Description
%
% All inputs are after the predict state (see EKFPredict). The h
% data field may contain either a function name for computing
% the estimated measurements or an m by n matrix. If h is a function
% name you must include hX which is a function to compute the m by n
% matrix is a linearized version of the function h.
%% Inputs
%   d	(.)  EKF data structure
%              .m       (n,1)	Mean
%              .p       (n,n)	Covariance
%              .h       (m,n)	Either matrix or name of function
%              .hX      (1,:)	Name of Jacobian for h
%              .y       (m,1) 	Measurement vector
%              .r       (m,m)	Measurement covariance vector
%              .hData   (1,1)	Datastructure for the h and hX functions
%
%% Outputs
%   d	(.)  EKF data structure
%              .m       (n,1)	Mean
%              .p       (n,n)	Covariance
%              .v       (m,1)	Residuals

function d = EKFUpdate( d )

% Residual
if( ischar( d.h ) )
    yE  = feval( d.h,  d.m, d.hData );
    h   = feval( d.hX, d.m, d.hData );
else
    h   = d.h;
    yE  = h*d.m;
end

% Residual
d.v	= d.y - yE;

% Update step
s   = h*d.p*h' + d.r;

k	= d.p*h'/s;
d.m = d.m + k*d.v;
d.p	= d.p - k*s*k';

