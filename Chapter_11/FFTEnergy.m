
%% FFTENERGY FFT Energy signature
%% Form
%   [e, w, wP] = FFTEnergy( y, tSamp, aPeak )
%
%% Description
% FFT of the input signal converted to energy.
% The resolution in frequency will depend on the number of samples
% and the sampling period.
%
%% Inputs
%   y     (1,n) Sequence
%   tSamp	(1,1) Sampling period
%   aPeak (1,1) Peak fraction
%
%% Outputs
%   e     (1,n)  Energy
%   w     (1,n)  Frequencies (rad/sec)
%   wP    (1,:)  Frequencies of peaks  (rad/sec)
%

function [e, w, wP] = FFTEnergy( y, tSamp, aPeak )

if( nargin < 3 )
  aPeak  = 0.95;
end

n = size( y, 2 );

% If the input vector is odd drop one sample
if( 2*floor(n/2) ~= n )
  n = n - 1;
  y = y(1:n,:);
end

x  = fft(y);
e  = real(x.*conj(x))/n;

hN = n/2;
e  = e(1,1:hN);
r  = 2*pi/(n*tSamp);
w  = r*(0:(hN-1));

if( nargin > 1 )
  k   = find( e > aPeak*max(e) );
  wP  = w(k);
end

if( nargout == 0 )
  tL = sprintf('FFT Energy Plot: Resolution = %10.2e rad/sec',r);
	PlotSet(w,log10(e),'x label','Frequency (rad/sec)','y label','Log(Energy)','figure title',tL,'plot title',tL,'plot type','xlog');
end
