%% CATREDUCER Use mapreduce with an ImageDatastore
%% Form
% data = catReducer
%
%% Description
% The are a number of pictures of cats in the Cats/ folder, for use in the image
% recognition chapter. We use mapreduce to perform a simple analysis on the
% colors of the images, which could be extended to any computation.
%
%% Inputs
% None
%
%% Outputs
% data   (:)   A table of outputs, one for each key: Red, Green, Blue

function data = catReducer

imds = imageDatastore('../Cats');
maxRGB = mapreduce(imds, @catColorMapper, @catColorReducer);
data = readall(maxRGB);
disp(data)

function catColorMapper(data, info, intermediateStore)
% info includes filename and filesize

add(intermediateStore, 'Avg Red', struct('Filename',info.Filename,'Val',mean(mean(data(:,:,1)))) );
add(intermediateStore, 'Avg Blue', struct('Filename',info.Filename,'Val',mean(mean(data(:,:,2)))) );
add(intermediateStore, 'Avg Green', struct('Filename',info.Filename,'Val',mean(mean(data(:,:,3)))) );

function catColorReducer(key, intermediateIter, outputStore)

% Iterate over values for each key
minVal = 255;
minImageFilename = '';
while hasnext(intermediateIter)
  value = getnext(intermediateIter);

  % Compare values to find the minimum
  if value.Val < minVal
      minVal = value.Val;
      minImageFilename = value.Filename;
  end
end

% Add final key-value pair
add(outputStore, ['Maximum ' key], minImageFilename);
