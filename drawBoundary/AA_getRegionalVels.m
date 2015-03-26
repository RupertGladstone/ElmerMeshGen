
clf; clear; params;

ncid = netcdf.open(ncfile,'NOWRITE');
varid = netcdf.inqVarID(ncid,xvelName);
vx = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,yvelName);
vy = netcdf.getVar(ncid,varid);
clear varid;
netcdf.close(ncid);

vx = rot90(vx) ; vy = rot90(vy) ;
vnorm=sqrt(vx.^2+vy.^2);

imagesc(vnorm); set(gca,'YDir','normal');
fprintf('Drag mouse to select rectangle covering domain of interest\n')
rect = getrect();
j_b  = floor(rect(2));
j_t  = j_b + floor(rect(4));
i_l  = floor(rect(1));
i_r  = i_l + floor(rect(3));
nj = j_t-j_b+1 ; ni = i_r-i_l+1 ;

fprintf('Zooming to your domain of interest...\n')
xlim([i_l, i_r]);
ylim([j_b, j_t]);

fprintf(['Click points to define mesh ice-ocean boundary (double click ' ...
      'to end) \n'])

[ob_x, ob_y] = getpts();

fprintf(['Click points to define mesh interior ice boundary (start ' ...
      'near end of previous points, finish near start of previous ' ...
      'points, double click to end) \n'])

[ib_x, ib_y] = getpts();

fprintf(['Writing velocity data to ascii file for your region \n'])
vxr = vx(j_b:j_t,i_l:i_r) ; 
vyr = vy(j_b:j_t,i_l:i_r) ;
vnormr = vnorm(j_b:j_t,i_l:i_r) ;
fid=fopen(fileOut,'w');
for jj=1:nj
    for ii=1:ni
        fprintf(fid,'%12.5f %12.5f %12.5f \n',vxr(jj,ii),vyr(jj,ii),vnormr(jj,ii));
    end
end
fclose(fid);

fprintf(['Writing region parameters to text file for later use ***' ...
         'NYI \n'])

fprintf(['Writing boundaries to .csv or .geo files***' ...
         'NYI \n'])


the value is given by:
 interp2(velocityField,x,y)

add the last bit of ocean boundary to the start of land boundary, ...
    and add first point of ocean boundary to last point of land boundary