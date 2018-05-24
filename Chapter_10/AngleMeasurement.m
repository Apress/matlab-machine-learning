%% ANGLEMEASUREMENT Function for an angle measurement
%% Form
%  y = AngleMeasurement( x, d )
%
%% Description
% An angle measurement
%
%% Inputs
%  x       (2,1) State [r;v]
%  d       (.)   Data structure
%                .baseline (1,1) Baseline
%
%% Outputs
%  y       (1,1) Angle
%
%% References
% None.

function y = AngleMeasurement( x, d )

if( nargin < 1 )
  y = struct('baseline',10);
  return
end

y = atan(x(1)/d.baseline);
