%% ISVALIDFIELD  Determine if a field exists and is not empty.
%% Form:
% x = IsValidField( m, s )
%
%% Description
%  Determine if a field exists and is not empty.
%
%% Inputs
%
%   m     (1,1) Structure
%   s     (1,:) Field
%
%% Outputs
%   x     (1,1) True or false
%

function x = IsValidField( m, s )

if( isfield( m, s ) && ~isempty( eval(['m.' s]) ) )
  x = true;
else
  x = false;
end
