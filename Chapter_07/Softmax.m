%% SOFTMAX Finds maximum using the logistic function
%% Form
% [p, pMax, kMax] = Softmax( q )
% Softmax % Demo
%
%% Description
% Finds the maximum value using the logistic function.
%
%% Inputs
%   q    (1,:)	Input array
%
%% Outputs
%   p    (1,:)	Output array
%   pMax (1,1)  Maximum value
%   kMax (1,1)  Index of the maximum value
%

function [p, pMax, kMax] = Softmax( q )

% Demo
if( nargin == 0 )
  Demo
  return
end

q = reshape(q,[],1);
n = length(q);
p = zeros(1,n);

den = sum(exp(q));

for k = 1:n
  p(k) = exp(q(k))/den;
end

[pMax,kMax] = max(p);

function Demo
%% Softmax>Demo
q = [1,2,3,4,1,2,3];
[p, pMax, kMax] = Softmax( q );
sum(p)
