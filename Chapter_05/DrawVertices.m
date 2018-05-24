%% DRAWVERTICES Draw vertices in a new figure.
%% Form
%  DrawVertices( v, f, name )
%  DrawVertices % Demo
%
%% Description
% The figure will be a uniform color.
%
% Type DrawVertices for a demo.
%
%% Inputs
%  v       (:,3) Vertices
%  f       (:,3) Faces
%  name    (1,:) Figure name
%
%% Outputs
%  None

function DrawVertices( v, f, name )

% Demo
if( nargin < 1 )
  Demo
  return
end

if( nargin < 3 )
  name = 'Vertices';
end

NewFigure(name)
patch('vertices',v,'faces',f,'facecolor',[0.8 0.1 0.2]);
axis image
xlabel('x')
ylabel('y')
zlabel('z')
view(3)
grid on
rotate3d on

function Demo
%% DrawVertices>Demo
% Draw a box

[v,f] = Box(2,3,4);
DrawVertices( v, f, 'Box' )

