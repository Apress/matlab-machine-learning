%% Train a neural net
% Trains the net from the images in the folder. 

folderPath = './Cats1024/';
[s, name]   = ImageArray( folderPath, 4 );
d           = ConvolutionalNN;

% Use all but the last for train
s           = s(1:end-1);

% This may take awhile
d           =	ConvolutionalNN( 'train', d, s );

% Test the net using the last image that was not used in training
[d, r]      = ConvolutionalNN( 'test', d, s{end} );

fprintf(1,'Image %s has a %4.1f%% chance of being a cat\n',name{end},100*r);

% Test the net using the first image
[d, r]      = ConvolutionalNN( 'test', d, s{1} );

fprintf(1,'Image %s has a %4.1f%% chance of being a cat\n',name{1},100*r);
