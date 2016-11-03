
% create a modified bedrock which i sset to the depth of the lower
% surface for lake vostock

!cp bedmap2.nc.bak bedmap2.nc

nc_fname = 'bedmap2.nc';
ncid = netcdf.open(nc_fname,'write');
x_dimid = netcdf.inqDimID(ncid,'x_dim');
y_dimid = netcdf.inqDimID(ncid,'y_dim');

bedvar_id  = netcdf.inqVarID(ncid,'bedrock_height');
bedvar     = netcdf.getVar(ncid,bedvar_id);
lowSurf_id = netcdf.inqVarID(ncid,'lower_surf_height');
lowSurf    = netcdf.getVar(ncid,lowSurf_id);

bed_VosFilled = bedvar;
bed_VosFilled(4450:4900,2850:3150) = lowSurf(4450:4900,2850:3150);

% could use nosink to fill bedrock hole, but simpler to set bedrock
% to equal lower ice surface

netcdf.reDef(ncid);
bedfilled_id = netcdf.defVar(ncid,'bed_vosfilled','double',[x_dimid,y_dimid]);
netcdf.endDef(ncid);
netcdf.putVar(ncid,bedfilled_id,bed_VosFilled);
netcdf.close(ncid);

