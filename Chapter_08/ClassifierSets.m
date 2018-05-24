%% CLASSIFIERSETS Puts data into sets
%% Form
%  p = ClassifierSets( n, xRange, yRange, name, v, f, setName )
%
%% Inputs
% n       (1,1) Number of points is n x n
% xRange  (1,2) Range of x coordinates
% yRange  (1,2) Range of y coordinates
% name    {:}   Names of sets
% v       (2,:) Vertices to be used in set membership
% f       {:}   Vertices defining set
%
%% Outputs
% p       (.) Data structure
%             .x (n,n) x coordinate
%             .y (n,n) y coordinate
%             .m (n,n) Set membership

function p = ClassifierSets( n, xRange, yRange, name, v, f, setName )


% Demo
if( nargin < 1 )
  Demo
  return
end

if( nargin < 7 )
  setName = 'Classifier Sets';
end

p.x    = (xRange(2) - xRange(1))*(rand(n,n)-0.5) + mean(xRange);
p.y    = (yRange(2) - yRange(1))*(rand(n,n)-0.5) + mean(yRange);
p.m    = Membership( p, v, f );


NewFigure(setName);
m = length(f);
c = rand(m,3);
for k = 1:n
  for j = 1:n 
    plot(p.x(k,j),p.y(k,j),'marker','o','MarkerEdgeColor','k')
    hold on
  end
end
for k = 1:m
  patch('vertices',v,'faces',f{k},'facecolor',c(k,:),'facealpha',0.1)
end

xlabel(name{1});
ylabel(name{2});
grid

%% ClassifierSets>>Membership
function z = Membership( p, v, f )

n = size(p.x,1);
m = size(p.x,2);
z = zeros(n,m);
for k = 1:n
  for j = 1:m
    for i = 1:length(f)
      vI = v(f{i},:)';
      q  = [p.x(k,j) p.y(k,j)];
      r  = PointInPolygon( q, vI );
      if( r == 1 )
        z(k,j) = i;
        break;
      end
    end
  end
end

%% ClassifierSets>>PointInPolygon
function r = PointInPolygon( p, v )

m = size(v,2);

% All outside
r = 0;

% Put the first point at the end to simplify the looping
v = [v v(:,1)];

for i = 1:m
	j   = i + 1;
	v2J	= v(2,j);
	v2I = v(2,i);
	if (((v2I > p(2)) ~= (v2J > p(2))) && ...
      (p(1) < (v(1,j) - v(1,i)) * (p(2) - v2I) / (v2J - v2I) + v(1,i)))
    r = ~r;
	end
end

%% ClassifierSets>>Demo
function Demo
v = [0 0;0 4; 4 4; 4 0; 0 2; 2 2; 2 0;2 1;4 1;2 1];
f = {[5 6 7 1] [5 2 3 9 10 6] [7 8 9 4]};
ClassifierSets( 5, [0 4], [0 4], {'width', 'length'}, v, f );



