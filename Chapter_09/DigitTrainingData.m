%% Generate the training data
% Use a for loop to create a set of noisy images for each desired digit (between
% 0 and 9). Save the data along with indices for data to use for training. To
% create our first data set for identifying a single digit, set the digits to be
% from 0 to 5, and only set the output to 1 for the first digit. Otherwise, the
% output is 1 for the current digit. 
%
% The pixel output of the images is scaled from 0 (black) to 1 (white) so it is
% suitable for neuron activation in the neural net.

% Control switches
oneDigitMode = true;
changeFonts = true;

% Number of training data sets
digits     = 0:5;
nImagesPer = 20;

% Prepare data
nDigits   = length(digits);
nImages   = nDigits*nImagesPer;
input     = zeros(256,nImages);
output    = zeros(1,nImages);
trainSets = [];
testSets  = [];
if (changeFonts)
  fonts = {'times','helvetica','courier'};
else
  fonts = 'times';
  kFont = 1;
end

% Loop
kImage = 1;
for j = 1:nDigits
  fprintf('Digit %d\n', digits(j));
  for k = 1:nImagesPer
    if (changeFonts)
      % choose a font randomly
      kFont = ceil(rand*3); 
    end
    pixels = CreateDigitImage( digits(j), fonts{kFont} );
    % scale the pixels to a range 0 to 1
    pixels = double(pixels);
    pixels = pixels/255; 
    input(:,kImage) = pixels(:);
    if (oneDigitMode)
      if (j == 1)
        output(j,kImage) = 1;
      end
    else
      output(j,kImage) = 1;
    end 
    kImage = kImage + 1;
  end
  sets = randperm(10);
  trainSets = [trainSets (j-1)*nImages+sets(1:5)]; %#ok<AGROW>
  testSets = [testSets (j-1)*nImages+sets(6:10)]; %#ok<AGROW>
end

% Use 75% of the images for training and save the rest for testing
trainSets = sort(randperm(nImages,floor(0.75*nImages)));
testSets = setdiff(1:nImages,trainSets);

% Save the training set to a MAT-file (dialog window will open)
SaveTS( input, output, trainSets, testSets );
