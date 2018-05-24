%% RHSSHIP Right hand side of a ship
%% Form
%  [xDot, a, b] = RHSShip( ~, x, a )
%
%% Description
% A ship steering model.
% This can be called by the MATLAB Recipes RungeKutta function or any MATLAB
% integrator. Time is not used. 
% The state vector is [lateral velocity;angular velocity;heading]
%
% If no inputs are specified it will return the default data structure.
%
%% Inputs
%  t       (1,1) Time (unused)
%  x       (3,1) State vector [v;r;psi]
%  d       (.)   Data structure
%                .a     (2,2) State data matrix
%                .b     (1,1) Rudder matrix
%                .alpha (3,1) Disturbances
%                .u     (1,1) Ship speed
%                .l     (1,1) Ship length
%                .delta (1,1) Rudder angle (rad)
%
%% Outputs
%  xDot     (3,1) State vector derivative d[v;r;psi]/dt
%  a        (3,3) State transition matrix
%  b        (3,1) Input matrix
%
%% References
% None.

function [xDot, a, b] = RHSShip( ~, x, d )

if( nargin < 1 )
  xDot = struct('l',100,'u',10,'a',[-0.86 -0.48;-5.2 -2.4],'b',[0.18;-1.4],'alpha',[0;0;0],'delta',0);
  return
end

uOL   = d.u/d.l;
uOLSq = d.u/d.l^2;
uSqOl = d.u^2/d.l;
a     = [  uOL*d.a(1,1) d.u*d.a(1,2) 0;...
         uOLSq*d.a(2,1) uOL*d.a(2,2) 0;...
                      0            1 0];
b     = [uSqOl*d.b(1);...
         uOL^2*d.b(2);...
         0];
       
xDot  = a*x + b*d.delta + d.alpha;


