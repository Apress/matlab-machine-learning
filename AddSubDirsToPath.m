function AddSubDirsToPath

%------------------------------------------------------------------------
%   Add all sub-directories of the current directory to your MATLAB path.
%   Does not add SVN or CVS folders, or any folders that begin with "."
%------------------------------------------------------------------------
%   Form:
%   AddSubDirsToPath
%------------------------------------------------------------------------
%
%   ------
%   Inputs
%   ------
%   None
%
%   -------
%   Outputs
%   -------
%   None
%
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%   Copyright 2009 Princeton Satellite Systems, Inc. 
%   All rights reserved.
%------------------------------------------------------------------------

topDir = pwd;

cd( topDir )

p = cd;
path( fullfile(p,''), path );

s = dir;

np = {};
for k = 1:length(s)
   if( s(k).isdir & ~strcmp( '.', s(k).name(1) ) )
      z = fullfile( p, s(k).name, '' );
      np = AddDirectoryToPath( z, np );
   end
end

if( ~isempty(np) )
   addpath(np{:});
end

cd( topDir );

msgbox('Paths Set!')


function np = AddDirectoryToPath( p, np )

s = dir( p );

np{end+1} = p;
for k = 1:length(s)
   if( s(k).isdir & ~strcmp( '.', s(k).name(1) ) )
      z = fullfile( p, s(k).name, '' );
      if( isempty(findstr( '@', z )) )
         np = AddDirectoryToPath( z, np );
      end
   end
end
