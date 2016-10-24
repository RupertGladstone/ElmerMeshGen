
% If the netcdf file is to be read in by Elmer at run time using
% the gridDataReader, it will need to have coordinate
% variables. This code is to add them to an existing netcdf file.

params; dy=dx;

% create arrays for x and y coordinate variables
x_var = zeros(1,nx);
for ii = 1:nx;
    x_var(ii) = xmin + (ii-1)*dx;
end
y_var = zeros(1,ny);
for ii = 1:ny;
    y_var(ii) = ymin + (ii-1)*dy;
end

ncid = netcdf.open(ncfile, 'WRITE');
xdimid = netcdf.inqDimID(ncid,'nx');
ydimid = netcdf.inqDimID(ncid,'ny');
netcdf.reDef(ncid);
xvarid = netcdf.defVar(ncid,'x_coords','float',xdimid);
yvarid = netcdf.defVar(ncid,'y_coords','float',ydimid);
netcdf.endDef(ncid);
netcdf.putVar(ncid,xvarid,x_var);
netcdf.putVar(ncid,yvarid,y_var);
netcdf.close(ncid);

