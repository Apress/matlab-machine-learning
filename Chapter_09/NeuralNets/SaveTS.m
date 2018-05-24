%% SAVETS Convenience function for saving a NN training set.
% Creates a training set *TS.mat file for use with the neural net trainer
%% Form:
%  SaveTS( inputs, outputs, trainSets, testSets )
%% Inputs
%   inputs    (:,n)   Sets of inputs to neural network. Each column is another set
%   outputs   (:,n)   Desired network outputs for each input set
%   trainSets (:)     Sets used for network training
%   testSets  (:)     Sets used for network testing
%
%% Outputs
% None

%% Copyright 
% Copyright (c) 1999, 2016 Princeton Satellite Systems, Inc.
% All rights reserved.

function SaveTS( inputs, outputs, trainSets, testSets )

% Input processing
if( nargin < 3 )
  trainSets = [];
end;
trainSets = trainSets(:)';

if( nargin < 4 )
  testSets = [];
end;
testSets = testSets(:)';

% Inputs and outputs must have same number of columns
cIn  = size(inputs,2);
cOut = size(outputs,2);

if( cIn ~= cOut )
  error('The input and output matrices must have the same number of columns');
end;

% Testing and training sets must be positive integers
if( ~isempty(trainSets) )
  j = find( abs( rem(trainSets,1) ) > eps, 1 );
  if( ~isempty(j) )
    error('The training set indices must all be integers');
  end;

  if( min(trainSets) < 1 )
    error('The training set indices must be greater than 0');
  end;

  if( max(trainSets) > cIn )
    error('The maximum training set index must be less than the number of input/output sets (columns)');
  end;
end;

if( ~isempty(testSets) )
  j = find( abs( rem(testSets, 1) ) > eps, 1 );
  if( ~isempty(j) )
    error('The testing set indices must all be integers');
  end;

  if( min(testSets) < 1 )
    error('The testing set indices must be greater than 0');
  end;

  if( max(testSets) > cIn )
    error('The maximum testing set index must be less than the number of input/output sets (columns)');
  end;
end;

% Save the training set
[filename, pathname] = uiputfile(['*TS.mat'],'Save As');
if ~ischar(filename) || ~ischar(pathname)
  error('Must enter filename');
end

[~,name,ext] = fileparts(filename);
name = [name 'TS'];
filename = [name ext];
eval([name '.inputs = inputs;'])
eval([name '.desOutputs = outputs;'])
eval([name '.trainSets = trainSets;'])
eval([name '.testSets = testSets;'])
fname = fullfile(pathname, filename);
eval(['save(''' fname ''',''' name ''');'])

