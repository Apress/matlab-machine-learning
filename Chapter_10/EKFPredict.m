

%% EKFPREDICT Extended Kalman Filter prediction step.
%% Form
%  d = EKFPredict( d )
%
%% Description
% The state propagation step for an extended Kalman Filter
%
%% Inputs
%   d	(.)  EKF data structure
%              .m       (n,1)       Mean
%              .p       (n,n)       Covariance
%              .q       (n,n)       State noise
%              .f       (1,:)       Name of right hand side
%              .fX      (1,:)       Jacobian of right hand side
%              .fData   (1,1)       Data structure with data for f
%              .dT      (1,1)       Time step
%              .t       (1,1)       Time
%
%% Outputs
%   d	(.)  EKF data structure

function d = EKFPredict( d )

% Get the state transition matrix
a   = feval(d.fX, d.m, d.t, d.fData );

% Propagate the mean
d.m = RungeKutta( d.f, d.t, d.m, d.dT, d.fData );

% Propagate the covariance
d.p = a*d.p*a' + d.q;

