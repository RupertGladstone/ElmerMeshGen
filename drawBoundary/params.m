
%% Projection information
xmin = -2800000.0  ;
ymin = -2800000.0  ;
ymax =  2800000.0  ;
Projection = 'Polar Stereographic South' ;
Ellipsoid = 'WGS-84' ;
Longitude_of_origin =   0 ;
Latidude_of_origin =  -90 ;
Secant_latitude =     -71 ;

%% TODO: remove nx and ny from here: need to get them from array
%% size in main script

%ncfile = 'antarctica_ice_velocity_900m.nc'; %% 900m resolution MEaSUREs data
ncfile = ['/mnt/hgfs/VMshare/drawBoundaryData/antarctica_ice_velocity_900m.nc'];
nx = 6223  ; ny = 6223  ; dx = 900.0 ;
%ncfile = 'antarctica_ice_velocity_450m.nc';
%nx = 12445 ; ny = 12445 ; dx = 450.0 ;

xvelName = 'vx'; yvelName = 'vy';

%% whole domain (valid for either resolution)
WholeIceSheet = false(1);
%WholeIceSheet = true(1);

%% if wholeIceSheet is false the user should choose to either 
%% draw both the ice front and inland boundaries...
DrawBothBoundaries = false(1);

%% ...or just draw the inland boundary and let a section of the
%% whole domain boundary be used for the ice front.
DrawInlandBoundary = true(1);


%% i_ and j_ are x and y coord indices at the left and right or top
%% and bottom of the domain of interest.  Comment these out to
%% enable interactive selection of domain of interest.

%% Totten/Law Dome ish region (900m)
%i_l = 5000 ; i_r = 6000 ; % left and right in x direction
%j_b = 1600 ; j_t = 3000 ; % bottom and top in y direction
%% Thwaites/PIG ish region
%i_l = 1000 ; i_r = 2000 ; % left and right in x direction
%j_b = 2400 ; j_t = 3350 ; % bottom and top in y direction
%% Thwaites near GL
%i_l = 1320 ; i_r = 1580 ; % left and right in x direction
%j_b = 2530 ; j_t = 2710 ; % bottom and top in y direction
%% Note, if all 4 corners (above) are defined then the script will
%% zoom straight in to the subregion.  Otherwise the script will ask
%% the user to interactively define the subregion.

%% name of ascii file to contain velocities for chosen subregion
%% (comment this out to suppress writing vels to ascii)
%velFileOut = 'AAvel900_Tottenish.asc';
%velFileOut = 'AAvel900.asc';
%velFileOut = 'AAvel900_ThwaitesPIG.asc';
%velFileOut = 'AAvel900_ThwaitesHR.asc';
velFileOut = 'AAvel900_AuroraWilkes.asc';

%% name of the ascii file to newritten in gmsh format (.geo)
%% containing the boundary points defined interactively by the
%% user. 
%boundaryFileOut = 'TottenBoundary.geo';
%boundaryFileOut = 'AABoundary.geo';
%boundaryFileOut = 'ThwaitesPIGBoundary.geo';
%boundaryFileOut = 'ThwaitesHRBoundary.geo';
boundaryFileOut = 'AurWilkesBoundary.geo';

%% name of the ascii file in which to write some yams input
%% information pertaining to the grid on which the velocity data
%% are stored.
yamsInputFile = 'yamsInput.asc';

%% TODO: lc 
%% lc is the 'characteristic length' which GMSH will use to
%% determine the element size.
%% lc=100000.0 ;


%% TODO: see if any of the following matlab files are helpful to
%% combine with this somehow:
%% http://www.mathworks.com/matlabcentral/fileexchange/47639-antarctic-drainage-basins
%% http://au.mathworks.com/matlabcentral/fileexchange/42353-bedmap2-toolbox-for-matlab
%% http://au.mathworks.com/matlabcentral/fileexchange/47638-antarctic-mapping-tools
%% http://au.mathworks.com/matlabcentral/fileexchange/47640-asaid-grounding-lines
%% http://au.mathworks.com/matlabcentral/fileexchange/47329-measures
%% http://au.mathworks.com/matlabcentral/fileexchange/46611-antarctic-grounding-zone-structure-from-icesat

%% TODO: extract bedrock and surface height regions from netcdf
%% file.  Not really essentail but would save space and having to
%% read in large files at run time for mesh extrusion.





