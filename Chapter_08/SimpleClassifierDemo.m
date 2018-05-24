%% Test the four class case with a manually created tree.
%
%% Description
% Demonstrates decision tree testing using the hand derived tree
% that is from the default data structure in DecisionTree.
%
%% See Also
% DecisionTree, ClassifierSets, DrawBinaryTree

% Create the decision tree
d      = DecisionTree;

% Vertices for the sets
v = [ 0 0; 0 4; 4 4; 4 0; 2 4; 2 2; 2 0; 0 2; 4 2];
   
% Faces for the sets
f = { [6 5 2 8] [6 7 4 9] [6 9 3 5] [1 7 6 8] };

% Generate the testing set
pTest  = ClassifierSets( 5, [0 4], [0 4], {'width', 'length'}, v, f, 'Testing Set' );

% Test the tree
[d, r] = DecisionTree( 'test',  d, pTest  );

q = DrawBinaryTree;
c = 'xy';
for k = 1:length(d.box)
  if( ~isempty(d.box(k).action) )
    q.box{k} = sprintf('%c %s %4.1f',c(d.box(k).param),d.box(k).action,d.box(k).value);
  else
    q.box{k} = sprintf('Class %d',d.box(k).class);
  end
end
DrawBinaryTree(q);

m = reshape(pTest.m,[],1);

for k = 1:length(r)
  fprintf(1,'Class %d\n',k);
  for j = 1:length(r{k})
    fprintf(1,'%d: %d\n',r{k}(j),m(r{k}(j)));
  end
end


