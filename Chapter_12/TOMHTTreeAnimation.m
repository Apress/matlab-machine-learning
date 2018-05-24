%% TOMHTTREEANIMATION Animates a TOMHT tree.
%% Form
%   TOMHTTreeAnimation( action, tracks )
%   TOMHTTreeAnimation( action, tree   )
%   TOMHTTreeAnimation( action, b      )
%% Description
%   Animates a TOMHT tree.
% 
%   Type TOMHTTreeAnimation for a demo. 
%
%% Inputs    
%   ------
%   action            'initialize' or 'update'
%   tracks    (.)     Track data structure array, OR:
%   tree      {.}     Tree data structure cell array, OR:
%   b         (:,:)   Track tree matrix with IDs in first column
%
%% Outputs
%   None
%
%% See Also
%   MHTTreeDiagram.

function TOMHTTreeAnimation( action, tracks )

% Demo
if( nargin < 1 )
  Demo
  return;
end

switch lower(action)
  case 'initialize'
    MHTTreeDiagram( tracks, [], 0 );
  case 'update'
    MHTTreeDiagram( tracks, [], 1 );
end

%% TOMHTTreeAnimation>>Demo
function Demo
% Animate a tree
m =  [  1      1     1     1     1;...
        13     2     2     2     2;...
        41     0     0     1     2;...
        43     0     0     0     1;...
        44     0     0     0     2];
TOMHTTreeAnimation( 'initialize', m );
pause(0.5)
    
m =  [  1      1     1     1     1;...
        13     2     2     2     2;...
        41     0     1     2     2;...
        43     0     0     0     1];
TOMHTTreeAnimation( 'update', m );
pause(0.5)
    
m =  [  1      1     1     1     1;...
        13     2     2     2     2;...
        41     1     2     0     0];
TOMHTTreeAnimation( 'update', m );
pause(0.5)
    
 m =  [  1      1     1     1     1;...
         13     2     2     2     2];
TOMHTTreeAnimation( 'update', m );


