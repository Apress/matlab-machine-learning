%% CTODZOH Convert continuous time system to discrete time
%% Form
%  [f, g] = CToDZOH( a, b, T )
%
%% Description
% Continuous to discrete transformation using a zero order hold. Discretize
% using a matrix exponential.
%
% Given
%
%   .
%   x = ax + bu
%
% Find f and g where
%
%   x(k+1) = fx(k) + gu(k)
%
%% Inputs
%  a  (n,n)  Continuous plant  matrix
%  b  (n,m)  Input matrix
%  T  (1,1)  Time step
%
%% Outputs
%  f  (n,n)  Discrete plant
%  g  (n,m)  Discrete input
%
%% See also
% expm
%
%% References:  Van Loan, C.F., Computing Integrals Involving the Matrix
%               Exponential, IEEE Transactions on Automatic Control
%               Vol. AC-23, No. 3, June 1978, pp. 395-404.

%% Copyright
%   Copyright (c) 2016 Princeton Satellite Systems, Inc.
%   All rights reserved.

function [f, g] = CToDZOH( a, b, T )

if( nargin < 1 )
  Demo;
  return
end

[n,m] = size(b);
q     = expm([a*T b*T;zeros(m,n+m)]);
f     = q(1:n,1:n);
g     = q(1:n,n+1:n+m); 

%% Demo
function Demo

T       = 0.5;
fprintf(1,'Double integrator with a %4.1f second time step.\n',T);
a       = [0 1;0 0]
b       = [0;1]
[f, g]  = CToDZOH( a, b, T );
f
g



