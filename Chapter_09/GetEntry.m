%% GETENTRY Get an entry from a vector of graphics handles
%% Form
%  [x, valid, e] = GetEntry( h, d, errMsg )
%
%% Description
% Gets the input from a vector of graphics handles and determines
% if the input entries are valid.
%
%% Inputs
%
%   h        (n)    Vector of graphics handles
%   d        (1|n)  Data structure of valid parameters
%                   Must enter either 1 or n data structures
%                    
%           Field       Default     Description
%           -----       -------     -----------
%         .type         'scalar'    {'scalar','vector','matrix','string'}
%         .empty         'no'       'yes' = empty entry is valid
%         .integer       'no'       'yes' = only integers allowed
%         .max            inf        maximum allowable value 
%         .min           -inf        minimum allowable value 
%         .maxElements     1         maximum number of elements for scalar/vector
%         .minElements     1         minimum number of elements for scalar/vector
%         .maxColumns     inf        maximum number of columns for matrix
%         .minColumns      1         minimum number of columns for matrix
%         .maxRows        inf        maximum number of rows for matrix
%         .minRows         1         minimum number of rows for matrix
%         .complex       'no'       'yes' = complex values allowed
%         .maxImag        inf        maximum allowable imaginary value
%         .minImag       -inf        minimum allowable imaginary value
%         .maxComplexMag  inf        maximum allowable complex magnitude
%         .minComplexMag -inf        minimum allowable complex magnitude
%
%   errMsg   (1)    1 = show default error dialog boxes (default is 1)
%
%% Outputs
%   x        {n}    Cell array containing field input. If a numerical value
%                     is desired and the entry is valid, the numerical value
%                     is returned in the cell array. Otherwise, the entered 
%                     string is returned.
%                   If only one handle is entered and the entry is numeric,
%                     x is a scalar/vector/matrix, not a cell array.
%                   Vector output is a column vector.
%   valid    (n)    1 = valid
%   e        (n)    Data structure with same fields as d 
%                   indicating which error occured. 1 = error, [] = no error.


function [x, valid, e] = GetEntry( h, d, errMsg )

if( nargin < 2 )
  d = [];
end

if( isempty(d) )
  d = SetDefaults([]);
end

entries = length(h);
parms   = length(d);

% Set default parameters
if( parms ~= entries )
  if( parms == 1 )
    t            = SetDefaults(d);
    t(2:entries) = deal(t(1));
    d            = t;
  else
    errordlg('The length of the data structure must equal 1 or the number of handles')
    return    
  end;
else
  for k = 1:entries
    t(k) = SetDefaults(d(k));
  end;
  d = t;
end;

if( nargin < 3 )
  errMsg = [];
end;

if( isempty(errMsg) )
  errMsg = 1;
end;

% Set up output quantities
x      = cell(entries,1);
valid  = ones(entries,1);

fields = fieldnames(d);
errStr = 'fields{1}, x';

for k = 2:length(fields)
  errStr = [ errStr ', fields{',num2str(k),'},  x '];
end;

eval(['e = struct(', errStr, ');'])


% Get entries and check validity
for k = 1:entries
  
  s = get( h(k), 'String' );

  % Check for string input
  if( strcmp( d(k).type, 'string' ) )
    x{k}     = s;
  
  % Check for empty string
  elseif( isempty(s) )
    x{k}     = [];
    if( strcmp( d(k).empty, 'no' ) )
      valid(k)   = 0;
      e(k).empty = 1;
    end;

  % Convert string to number
  else
  
    x{k} = str2num( s );

    if( isempty(x{k}) )
      valid(k)  = 0;
      x{k}      = s;
      e(k).type = 1;

    else

      % Check number of elements
      [rows,cols] = size(x{k});

      if( strcmp(d(k).type,'scalar') ) 
        if( (rows ~= 1) | (cols ~= 1 ) ) 
          valid(k)  = 0;
          e(k).type = 1;
        end;
        
      elseif( strcmp(d(k).type,'vector') ) 
        if( (rows ~= 1) & (cols ~= 1 ) ) 
          valid(k)  = 0;
          e(k).type = 1;
    
        else
  
          elements = length(x{k});
          if( elements > d(k).maxElements )
            valid(k)         = 0;
            e(k).maxElements = 1;
    
          elseif( elements < d(k).minElements )
            valid(k)         = 0;
            e(k).minElements = 1;

          end;

          x{k} = x{k}(:);   % always return a column vector
        end;
        
      else
        if( rows > d(k).maxRows )
          valid(k)     = 0;
          e(k).maxRows = 1;
    
        elseif( rows < d(k).minRows )
          valid(k)     = 0;
          e(k).minRows = 1;

        end;
        
        if( cols > d(k).maxColumns )
          valid(k)        = 0;
          e(k).maxColumns = 1;

        elseif( cols < d(k).minColumns )
          valid(k)        = 0;
          e(k).minColumns = 1;
        end
      end;

      % Check for complex variables
      xReal = isreal(x{k});

      if( xReal )
        
        % Check variable range
        j = find( x{k} < d(k).min );
        if( ~isempty(j) )
          valid(k) = 0;
          e(k).min = 1;
        end;
    
        j = find( x{k} > d(k).max );
        if( ~isempty(j) )
          valid(k) = 0;
          e(k).max = 1;
        end;

        % Check for integers
        if( strcmp(d(k).integer,'yes') )

          j = find( abs( rem(x{k},1) ) > eps );

          if( ~isempty(j) )
            valid(k)     = 0;
            e(k).integer = 1;

          else
            x{k} = fix(x{k});
          end;
        end;

      else  % x is complex
        
        if( strcmp(d(k).complex,'no') )
          valid(k)     = 0;
          e(k).complex = 1;

        else
      
          % Check variable real range
          j = find( real(x{k}) < d(k).min );
          if( ~isempty(j) )
            valid(k) = 0;
            e(k).min = 1;
          end;
    
          j = find( real(x{k}) > d(k).max );
          if( ~isempty(j) )
            valid(k) = 0;
            e(k).max = 1;
          end;

          % Check variable imaginary range
          j = find( imag(x{k}) < d(k).minImag );
          if( ~isempty(j) )
            valid(k)     = 0;
            e(k).minImag = 1;
          end;
    
          j = find( imag(x{k}) > d(k).maxImag );
          if( ~isempty(j) )
            valid(k)     = 0;
            e(k).maxImag = 1;
          end;

          % Check complex magnitude
          j = find( abs(x{k}) < d(k).minComplexMag );
          if( ~isempty(j) )
            valid(k)           = 0;
            e(k).minComplexMag = 1;
          end;
    
          j = find( abs(x{k}) > d(k).maxComplexMag );
          if( ~isempty(j) )
            valid(k)           = 0;
            e(k).maxComplexMag = 1;
          end;

          % Check for integers
          if( strcmp(d(k).integer,'yes') )

            j = find( abs( rem( real(x{k}),1) ) > eps );
            m = find( abs( rem( imag(x{k}),1) ) > eps );
          
            if( ~isempty(j) | ~isempty(m) )
              valid(k)     = 0;
              e(k).integer = 1;

            else
              x{k} = fix(x{k});
            end;
          end;
        
        end; % end if(complex not good) else loop 

      end;  % end if(real) else(complex) loop
        
    end;  % end if(not valid number) else loop

  end; % end if(string) elseif(empty) else loop

  if( (errMsg == 1) & (valid(k) == 0) )
    DisplayErrorMessage( e(k), d(k) );
  end;
    
end;   % end for loop

% If only one entry is read and it is not a character string
%   return the numerical values, not the cell array

if( (entries == 1) & ~ischar(x{1}) )
  x = x{1};
end;


%--------------------------------------------------------------------------
%   Sets the defaults for the data structure
%--------------------------------------------------------------------------
function x = SetDefaults( d );

if ~IsValidField( d, 'type' )
  d.type = 'scalar';
end;

if ~IsValidField( d, 'empty' )
  d.empty = 'no';
end;

if ~IsValidField( d, 'integer' )
  d.integer = 'no';
end;

if ~IsValidField( d, 'max' )
  d.max = inf;
end;

if ~IsValidField( d, 'min' )
  d.min = -inf;
end;

if ~IsValidField( d, 'maxElements' )
  d.maxElements = 1;
end;

if ~IsValidField( d, 'minElements' )
  d.minElements = 1;
end;

if ~IsValidField( d, 'maxColumns' ) 
  d.maxColumns = inf;
end;

if ~IsValidField( d, 'minColumns' )
  d.minColumns = 1;
end;

if ~IsValidField( d, 'maxRows' )
  d.maxRows = inf;
end;

if ~IsValidField( d, 'minRows' )
  d.minRows = 1;
end;

if ~IsValidField( d, 'complex' )
  d.complex = 'no';
end;

if ~IsValidField( d, 'maxImag' )
  d.maxImag = inf;
end;

if ~IsValidField( d, 'minImag' )
  d.minImag = -inf;
end;

if ~IsValidField( d, 'maxComplexMag' )
  d.maxComplexMag = inf;
end;

if ~IsValidField( d, 'minComplexMag' )
  d.minComplexMag = -inf;
end;

x = d;

%--------------------------------------------------------------------------
%   Display the error dialog box
%--------------------------------------------------------------------------
function DisplayErrorMessage( e, d );

eString = [];
m       = 0;

if( e.empty )
  eString{1} = ['Empty strings are not allowed.'];

else
  
  if( e.type )
    m          = m + 1;
    eString{m} = ['Input must be a ' d.type '.'];
  end;

  if( e.maxElements )
    m          = m + 1;
    eString{m} = ['Maximum number of elements allowed in the vector is ' num2str(d.maxElements) '.'];
  end;

  if( e.minElements )
    m          = m + 1;
    eString{m} = ['Minimum number of elements allowed in the vector is ' num2str(d.minElements) '.'];
  end;
    
  if( e.maxColumns )
    m          = m + 1;
    eString{m} = ['Maximum number of columns allowed in the matrix is ' num2str(d.maxColumns) '.'];
  end;
  
  if( e.minColumns )
    m          = m + 1;
    eString{m} = ['Minimum number of columns allowed in the matrix is ' num2str(d.minColumns) '.'];
  end;
  
  if( e.maxRows )
    m          = m + 1;
    eString{m} = ['Maximum number of rows allowed in the matrix is ' num2str(d.maxRows) '.'];
  end;
  
  if( e.minRows )
    m          = m + 1;
    eString{m} = ['Minimum number of rows allowed in the matrix is ' num2str(d.minRows) '.'];
  end;
  
  if( e.complex )
    m          = m + 1;
    eString{m} = ['Each entry must be real.'];
  end;

  if( e.integer )
    m          = m + 1;
    eString{m} = ['Each entry must be an integer.'];
  end;

  if( e.min )
    m = m + 1;
    if( e.max )
      eString{m} = ['Each entry must be greater than or equal to ' num2str(d.min) ' and less than or equal to ' num2str(d.max) '.'];
    else
      eString{m} = ['Each entry must be greater than or equal to ' num2str(d.min) '.'];
    end;
  elseif( e.max )
    m          = m + 1;
    eString{m} = ['Each entry must be less than or equal to ' num2str(d.max) '.'];
  end;
  
  if( e.minImag )
    m = m + 1;
    if( e.maxImag )
      eString{m} = ['Each entry must have an imaginary part greater than or equal to ' num2str(d.minImag) 'i and less than or equal to ' num2str(d.maxImag) 'i.'];
    else
      eString{m} = ['Each entry must have an imaginary part greater than or equal to ' num2str(d.minImag) 'i.'];
    end;
  elseif( e.maxImag )
    m          = m + 1;
    eString{m} = ['Each entry must have an imaginary part less than or equal to ' num2str(d.maxImag) 'i.'];
  end;
  
  if( e.minComplexMag )
    m = m + 1;
    if( e.maxComplexMag )
      eString{m} = ['Each entry must have a magnitude greater than or equal to ' num2str(d.minComplexMag) ' and less than or equal to ' num2str(d.maxComplexMag) '.'];
    else
      eString{m} = ['Each entry must have a magnitude greater than or equal to ' num2str(d.minComplexMag) '.'];
    end;
  elseif( e.maxComplexMag )
    m          = m + 1;
    eString{m} = ['Each entry must have a magnitude less than or equal to ' num2str(d.maxComplexMag) '.'];
  end;


  
end;

errordlg(eString)
