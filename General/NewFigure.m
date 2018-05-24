%% NEWFIGURE Create a new named figure window
%% Form:
%   h = NewFigure( x, varargin )
%
%% Description
% Creates a new figure window and assigns it a name.
%
%% Inputs
%   x          (:)    Name for the figure
%   varargin   {}     Parameter pairs to pass to figure()
%
%% Outputs
%   h                 Handle to the figure

%% Copyright
%   Copyright (c) 2016 Princeton Satellite Systems, Inc. 
%   All rights reserved.

function h = NewFigure( x, varargin )

h = figure(varargin{:});
set(h,'Name',x);

