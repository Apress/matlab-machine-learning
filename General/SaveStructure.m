%% SAVESTRUCTURE Save a data structure to a mat file
%% Form
%   SaveStructure( g, fileName )
%
%% Description
% Save a structure in a file. You will be able to read it in by typing
%
%   g = load('fileName');
%
%% Inputs
%   g        (.)   Data structure
%   fileName (1,:) .mat file name
%
%% Outputs
%   None

%% Copyright
%   Copyright (c) 2016 Princeton Satellite Systems, Inc.
%   All rights reserved.

function SaveStructure( g, fileName )

% Create the file name
if( nargin < 2 )
  if( isfield( g(1), 'name' ) )
    fileName = g(1).name;
  else
    t        = clock;
    fileName = ['Structure' num2str([t(5:6) 100*rand])];
  end
end

%  Must be a .mat file
k = strfind( fileName, '.mat' );
if( isempty(k) )
  fileName = [fileName '.mat'];
end

m = ['save  ''' fileName '''' ];

% Get the field names
sFNxx1 = fieldnames( g );

% Create a string with the field names
% and set an internal variable equal to each field
for k = 1:length(sFNxx1)
  m = [m ' ' sFNxx1{k}];
  eval( [sFNxx1{k} ' = g.' sFNxx1{k} ';'] ); 
end

% Save
eval( m );


