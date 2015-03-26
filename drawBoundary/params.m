
%% Projection information
xmin = -2800000.0  ;
ymax =  2800000.0  ;
Projection = 'Polar Stereographic South' ;
Ellipsoid = 'WGS-84' ;
Longitude_of_origin =   0 ;
Latidude_of_origin =  -90 ;
Secant_latitude =     -71 ;


%% Some params depend on which resolution velocity data we are using

%***remove nx and ny from here: need to get them in script

ncfile = 'antarctica_ice_velocity.nc';
nx = 6223  ; ny = 6223  ; spacing = 900.0 ;
%ncfile = 'antarctica_ice_velocity_450m.nc';
%nx = 12445 ; ny = 12445 ; spacing = 450.0 ;

xvelName = 'vx'; yvelName = 'vy';

%% i_ and j_ are x and y coord indices at the left and right or top
%% and bottom of the domain of interest

%% Totten/Law Dome ish region (900m)
i_l = 5000 ; i_r = 6000 ;
j_b = 1600 ; j_t = 3000 ;
fileOut = 'AAvel900_Tottenish.asc';

%% whole domain (valid for either resolution)
%i_l = 0 ; i_r = nx ;
%j_b = 0 ; j_t = ny ;
%fileOut = 'AAvel900.asc';
%fileOut = 'AAvel450.asc';




