
%columns:               6223 pixel
%rows:               6223 pixel
%
%Projection:     Polar Stereographic South (PS)
%Ellipsoid:WGS-84
%PS_secant_latitude:     -71 degrees
%PS_longitude_origin:  0 degrees
%PS_latitude_origin:-90 degrees
%PS_spacing:  900 m
%PS_xmin:-2800000.0 m
%PS_ymax: 2800000.0 m


dx = 900.0 ; % measures grid spacing
nx = 6223 ; ny = 6223 ;
xmin = -2800350.0 ; xmax = 2800350.0 ; ymin = -2800350.0 ; ymax = 2800350.0 ;


%!cp /ds/projects/iomp/obs/measures/Antarctica_ice_velocity.nc .
nc_fname = 'antarctica_ice_velocity_900m.nc';
ncid = netcdf.open(nc_fname,'write');

x_dimid = netcdf.inqDimID(ncid,'nx');
y_dimid = netcdf.inqDimID(ncid,'ny');

netcdf.reDef(ncid);

x_varid = netcdf.defVar(ncid,'x_coords', 'double',(x_dimid));
y_varid = netcdf.defVar(ncid,'y_coords', 'double',(y_dimid));

netcdf.putAtt(ncid,x_varid,'standard_name','projection_x_coordinate');
netcdf.putAtt(ncid,y_varid,'standard_name','projection_y_coordinate');

vx_flip_varid = netcdf.defVar(ncid,'vx_flip', 'double',[x_dimid,y_dimid]);
vy_flip_varid = netcdf.defVar(ncid,'vy_flip', 'double',[x_dimid,y_dimid]);
vx_flip_ext_varid = netcdf.defVar(ncid,'vx_flip_ext', 'double',[x_dimid,y_dimid]);
vy_flip_ext_varid = netcdf.defVar(ncid,'vy_flip_ext', 'double',[x_dimid,y_dimid]);

netcdf.endDef(ncid);

x_var_data = linspace(xmin+dx/2.,xmax-dx/2.,nx);
y_var_data = linspace(ymin+dx/2.,ymax-dx/2.,ny);
netcdf.putVar(ncid,x_varid,x_var_data);
netcdf.putVar(ncid,y_varid,y_var_data);
clear x_var_data;
clear y_var_data;

vx_varid = netcdf.inqVarID(ncid,'vx');
vy_varid = netcdf.inqVarID(ncid,'vy');

vx_data = netcdf.getVar(ncid,vx_varid);
netcdf.putVar(ncid,vx_flip_varid,flipdim(vx_data,2));
vx_data_n = vx_data; vx_data_n(vx_data==0.00000) = NaN;
clear vx_data;
'extend vx'
%vx_ext = inpaint_nans(double(vx_data_n));
vx_ext=extendArray(vx_data_n);
clear vx_data_n;

vy_data = netcdf.getVar(ncid,vy_varid);
netcdf.putVar(ncid,vy_flip_varid,flipdim(vy_data,2));
vy_data_n = vy_data; vy_data_n(vy_data==0.00000) = NaN;
clear vy_data;
%'inpain nans again'
%vy_ext = inpaint_nans(double(vy_data_n));
%'inpain nans done'
'extend vy'
vy_ext=extendArray(vy_data_n);
clear vy_data_n;

netcdf.putVar(ncid,vx_flip_ext_varid,flipdim(vx_ext,2));
netcdf.putVar(ncid,vy_flip_ext_varid,flipdim(vy_ext,2));

'writing to netcdf'
netcdf.close(ncid);
%!mv Antarctica_ice_velocity.nc antarctica_ice_velocity.nc
'done'
