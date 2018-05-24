%% JACOBIAN Computes the Jacobian matrix
%% Form
%   [a, fOP] = Jacobian( funFcn, xOP, tOP, varargin )
%
%% Description
% This function computes the Jacobian matrix for a right hand-side.
% The central difference approximation good to O(h^2) is used.
% For any function f(t,x) it will compute the f0 and a matrices.
%
%   f(x,t) ~= f(tOP,xOP) + a(xOP,tOP) x + ...
%
% funFcn is input as a character string 'xxxxx' and must be of the form
%
%   xdot = xxxxx ( t, x, {p1,p2,p3,p4,p5,p6,p7,p8,p9,p10})
%
% which is the same form used in RungeKutta. tOP is optional. 
% If not needed pass [].
%
%% Inputs
%   funFcn                'function name' or handle
%   xOP            (n,1)  State at the operating point
%   tOP                   Time
%   varargin              Optional arguments
%
%% Outputs
%   a              (n,n)  Jacobian matrix of first partials       
%   fOP            (n,1)  f(xOP,tOP) at the operating point
%

function [a, fOP] = Jacobian( funFcn, xOP, tOP, varargin )

% Compute the value of the function f at the set point

if( nargin < 3 )
   tOP = [];
end

if( isempty(tOP) )
   fOP = feval( funFcn, xOP, varargin{:} );
else
   fOP = feval( funFcn, tOP, xOP, varargin{:} );
end


n = size(fOP,1);
m = size(xOP,1);

% Start with an epsilon either 1/10,000 the size of the nominal
% Value or 10,000 x epsilon whichever is larger

h   = max(1.e-4*abs(xOP),1.e6*eps*ones(m,1));

a   = zeros(n,m);

% O(h^2) Central Difference Approximation

if( isempty(tOP) )
   for i = 1:m
      dx     = zeros(m,1);
      dx(i)  = h(i);
      a(:,i) = ( feval(funFcn, xOP+dx, varargin{:})-feval(funFcn, xOP-dx, varargin{:}) )/h(i);
   end
else
   for i = 1:m
      dx     = zeros(m,1);
      dx(i)  = h(i);
      a(:,i) = ( feval(funFcn, tOP, xOP+dx, varargin{:})-feval(funFcn, tOP, xOP-dx, varargin{:}) )/h(i);
   end
end

a = 0.5*a;
