%% ADDSCAN Add a scan to the scan data structure
%% Form
%  scan = AddScan( data, param, scan )
%
%% Description
%   Add a scan to the scan data structure array.
%
%% Inputs
%   data         (.)    Data
%   param        (.)    Parameter data structure
%                       .hFun   (1,:) Pointer to measurement function
%                       .hData   (.)  Data structure for the measurement
%                                     function
%   scan         (:)    Scan data structure
%
%% Outputs
%   scan         (:)    Data structure array with new scan appended
%                       .y          (:,1) Measurements
%                       .sensorType (1,1) Integer for data type
%                       .sensorID   (1,1) Integer for sensor ID
%                       .param      (1,1) Parameter data structure
%

function scan = AddScan( data, param, scan )

% Input processing
if( nargin < 2 )
	param = [];
end

% Create the data structure
s = struct( 'data', data, 'param', param );

% Append if necessary
if( nargin < 3 || isempty(scan) )
  scan        = s;
else
  scan(end+1)	= s;
end

