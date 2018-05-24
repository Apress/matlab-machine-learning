%% KFPREDICT Linear Kalman Filter prediction step.
%% Form
%   d = KFPredict( d )
%
%% Description
% Linear Kalman Filter prediction step.
% This assumes a discrete model of the form:
%
% x[k] = a[k-1]x[k-1] + b[k-1]u[k-1] + q
% y[k] = h[k]x[k] + r
%
% b and u are optional. 
%
%% Inputs
%   d   (.) Data structure
%           .m	(n,1)  Mean state vector
%           .p 	(n,n)  Covariance matrix
%           .u	(m,1)  Input vector
%           .b	(m,n)  Input matrix
%           .a	(n,n)  State transition matrix
%
%% Outputs
%   d   (.) Data structure
%
%% References
% None.

function d = KFPredict( d )
  
% The first path is if there is no input matrix b
if( isempty(d.b) )
  d.m = d.a*d.m;
else
  d.m = d.a*d.m + d.b*d.u;
end

d.p = d.a*d.p*d.a' + d.q;

