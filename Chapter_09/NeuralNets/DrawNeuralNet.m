%% DRAWNEURALNET Draw a neural network.
% Create a new figure and draw the nodes of the neural network with connecting
% lines.
%% Form
% DrawNeuralNet( network )
%% Inputs
%  network   (.)   Network data structure
%                  .layer (:)  Struct array

%% Copyright 
% Copyright (c) 2016 Princeton Satellite Systems, Inc.
% All rights reserved.

function DrawNeuralNet( network )

plotWeights = true;
plotThresh = true;
plotNeurons = true;

figure('Name','DrawNeuralNet');

green = [0 0.7 0];
blue  = [0 0   1];
red   = [1 0   0];

% Find max number of nodes
[outputs,inputs] = size( network.layer(1,1).w );
maxNodes = inputs;
nLayers = length(network.layer);
for j = 1:nLayers
  outputsJ = size( network.layer(j,1).w );
  if( outputsJ > maxNodes )
    maxNodes = outputsJ;
  end;
end;

yLim = [0 maxNodes+1];
xLim = [-1 nLayers+1];

% Clear and prepare axes
axis ij;
hold on;

% Compute input locations
xPlot(1).x = zeros(inputs,1);

if( inputs == maxNodes )
  xPlot(1).y = 1:inputs;
else
  diff   = (maxNodes-1) / (inputs+1);
  xPlot(1).y = 1 + diff*(1:inputs);
end;

xPlot(1).y     = xPlot(1).y(:);
xPlot(1).color = ones(length(xPlot(1).y),1)*green;

% Compute node locations
for j = 1:nLayers
  [outputsJ,inputsJ] = size( network.layer(j,1).w );
  xPlot(j+1).x = j*ones(outputsJ,1);
  
  if( outputsJ == maxNodes )
    xPlot(j+1).y = 1:outputsJ;
  else
    diff       = (maxNodes-1) / (outputsJ+1);
    xPlot(j+1).y = 1 + diff*(1:outputsJ);
  end;
  
  xPlot(j+1).y     = xPlot(j+1).y(:);
  xPlot(j+1).color = ones(length(xPlot(j+1).y),1)*blue;
  
  if( plotThresh )
    k                     = find( network.layer(j,1).w0 < 0 );
    xPlot(j+1).color(k,:) = ones(length(k),1)*red;
  end;
  
end;

% Plot inputs
plot( xPlot(1).x, xPlot(1).y, 'o', 'Color', green );
plot( xPlot(1).x, xPlot(1).y, 'x', 'Color', green );

% Plot nodes
%-----------
for j = 2:nLayers+1
  for k = 1:length(xPlot(j).y)
    plot( xPlot(j).x(k,:), xPlot(j).y(k,:), 'o', 'Color', xPlot(j).color(k,:) );
  end;
end;

% Plot neurons
if( plotNeurons )
  
  xLim = [-0.5 xLim(2)];
  
  for j = 2:nLayers+1
    for k = 1:length(xPlot(j-1).y)
      for m = 1:length(xPlot(j).y)
        xNeuron  = [xPlot(j-1).x(k) xPlot(j).x(m)];
        yNeuron  = [xPlot(j-1).y(k) xPlot(j).y(m)];
        
        neuronColor = blue;
        if( plotWeights && ( network.layer(j-1,1).w(m,k) < 0 ) )
          neuronColor = red;
        end;
        
        plot( xNeuron, yNeuron, 'Color', neuronColor );
      end;
    end;
  end;
  
  % Plot outputs
  xPlot(nLayers+2).y = xPlot(nLayers+1).y;
  xPlot(nLayers+2).x = xPlot(nLayers+1).x + 0.5;
  plot( xPlot(nLayers+2).x, xPlot(nLayers+2).y, 'mx')
  
  xOut = [xPlot(nLayers+1).x xPlot(nLayers+2).x];
  yOut = [xPlot(nLayers+1).y xPlot(nLayers+2).y];
  plot( xOut',yOut','m')
  
  
end;

% Clean up plot
axis([xLim yLim]);
set(gca, 'XTick', 0:nLayers);
set(gca, 'YTick', 1:maxNodes);
