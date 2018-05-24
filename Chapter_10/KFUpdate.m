%% KFUPDATE Linear Kalman Filter measurement update step.
%% Form
%   d = KFUpdate( d )
%
%% Description
% This assumes a discrete state-space model of the form:
%
% x[k] = a[k-1]x[k-1] + b[k-1]u[k-1]
% y[k] = h[k]x[k]
%
% All inputs are after the predict state (see KFPredict).
% The Kalman filter can be initialized using KFInitialize. 
%
%% Inputs
%   d   (.) Data structure
%           .m	(n,1)  Mean state vector
%           .p 	(n,n)  Covariance matrix
%           .y	(m,1)  Measurement vector
%           .h	(m,n)  Measurement matrix
%           .r	(m,m)  Measurement noise covariance matrix
%
%% Outputs
%   d   (.) Data structure
%
%% References
% None.

function d = KFUpdate( d )

s   = d.h*d.p*d.h' + d.r;	% Intermediate value
k   = d.p*d.h'/s;         % Kalman gain
v   = d.y - d.h*d.m;      % Residual
d.m = d.m + k*v;          % Mean update
d.p = d.p - k*s*k';       % Covariance update
