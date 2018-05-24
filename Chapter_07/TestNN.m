%% Test a neural net using random weights
%
%% Description
% Test the neural net software with a picture. Use the built in random
% weights

folderPath  = 'Cats1024/';
[s, name]   = ImageArray( folderPath, 4 );
d           = ConvolutionalNN;

% We use the last cat picture for the test
[d, r]      = ConvolutionalNN( 'random', d, s{end} );

fprintf(1,'Image %s has a %4.1f%% chance of being a cat\n',name{end},100*r);