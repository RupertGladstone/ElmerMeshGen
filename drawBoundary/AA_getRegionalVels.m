
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

if and(and(exist('i_l'), exist('i_r')), and(exist('j_b'), exist('j_t')))
    fprintf('Found subregion definition from params file... \n')
else
    fprintf(['Drag mouse to select rectangle covering domain of ' ...
             'interest. \n'])
    rect = getrect();
    j_b  = floor(rect(2));
    j_t  = j_b + floor(rect(4));
    i_l  = floor(rect(1));
    i_r  = i_l + floor(rect(3));
end

nj = j_t-j_b+1 ; ni = i_r-i_l+1 ;

fprintf('Zooming to your domain of interest...\n')
xlim([i_l, i_r]);
ylim([j_b, j_t]);

if (exist('velFileOut'))
    fprintf(['Writing velocity data to ascii file for your region... \n'])
    vxr = vx(j_b:j_t,i_l:i_r) ; 
    vyr = vy(j_b:j_t,i_l:i_r) ;
    vnormr = vnorm(j_b:j_t,i_l:i_r) ;
    fid=fopen(velFileOut,'w');
    for jj=1:nj
        for ii=1:ni
            fprintf(fid,'%12.5f %12.5f %12.5f \n',vxr(jj,ii),vyr(jj,ii),vnormr(jj,ii));
        end
    end
    fclose(fid);
else
    fprintf(['velFileOut not set in params.m, not writing vels to ascii. \n'])
end


if WholeIceSheet
    fprintf(['Calculating contour to use as ice-ocean boundary \n'])
    [cc, hh] = contour(vnorm,[0.01,0.01]);
    numPoints = cc(2,1);
    mainContour = cc(:,2:numPoints+1);
    clear cc, hh;
    h = plot(mainContour(1,:), mainContour(2, :), 'k');
    ob_x = mainContour(1,:);
    ob_y = mainContour(2,:);
    ib_x = 0; ib_y = 0;
else
    fprintf(['Click points to define mesh ice-ocean boundary (double click ' ...
             'to end) \n'])
    [ob_x, ob_y] = getpts();
    fprintf(['Click points to define mesh interior ice boundary (start ' ...
             'near end of previous points, finish near start of previous ' ...
             'points, double click to end) \n'])
    [ib_x, ib_y] = getpts();
end

fprintf(['Writing boundaries to .geo file for gmsh. \n']);

ob_x = xmin+ob_x*dx; ob_y = ymin+ob_y*dx;
ib_x = xmin+ib_x*dx; ib_y = ymin+ib_y*dx;

ib_nx = length(ib_x);ob_nx = length(ob_x);id=1;firstId = id;

fid=fopen(boundaryFileOut,'w');
fprintf(fid,['lc=100000;\n']);
SplineLineOB = 'Spline(1)={';
SplineLineIB = 'Spline(2)={';
for ii=1:ob_nx(1);
    fprintf(fid,'Point(%i)={%12.5f,%12.5f,0.0,lc}; \n',id,ob_x(ii),ob_y(ii));
    if ( (ii<ob_nx(1)) | WholeIceSheet )
        SplineLineOB = [SplineLineOB int2str(id) ','];
    else
        SplineLineOB = [SplineLineOB int2str(id) '}; \n'];
    end
    id_lastOB=id;
    id = id+1;
end
if WholeIceSheet
    SplineLineOB = [SplineLineOB int2str(firstId) '};\n'];
else
    SplineLineIB = [SplineLineIB int2str(id_lastOB) ','];
    for ii=1:ib_nx(1);
        fprintf(fid,'Point(%i)={%12.5f,%12.5f,0.0,lc}; \n',id,ib_x(ii),ib_y(ii));
        SplineLineIB = [SplineLineIB int2str(id) ','];
        %    if (ii<ib_nx(1))
        %    SplineLineIB = [SplineLineIB int2str(id) ','];
        %else
        %    SplineLineIB = [SplineLineIB int2str(id) '}; \n'];
        %end
        id = id+1;
    end
    SplineLineIB = [SplineLineIB int2str(firstId) '};\n'];
end

fprintf(fid,SplineLineOB);
if WholeIceSheet
    fprintf(fid,'Line Loop(2)={1}; \n');
    fprintf(fid,'Plane Surface(3) = {2}; \n');
    fprintf(fid,'Physical Line(4) = {1}; \n');
    fprintf(fid,'Physical Surface(5) = {3}; \n');
else
    fprintf(fid,SplineLineIB);
    fprintf(fid,'Line Loop(3)={1,2}; \n');
    fprintf(fid,'Plane Surface(4) = {3}; \n');
    fprintf(fid,'Physical Line(5) = {1}; \n');
    fprintf(fid,'Physical Line(6) = {2}; \n');
    fprintf(fid,'Physical Surface(7) = {4}; \n');
end
fclose(fid);

fprintf(['Writing region parameters to text file for later use \n']);
fid=fopen(yamsInputFile,'w');
fprintf(fid,'DEM_nx=%i \n',ni);
fprintf(fid,'DEM_ny=%i \n',nj);
fprintf(fid,'DEM_xmin=%13.5f \n',xmin+i_l*dx);
fprintf(fid,'DEM_ymin=%13.5f \n',ymin+j_b*dx);
fprintf(fid,'DEM_dx=%10.3f \n',dx);
fprintf(fid,'DEM_dy=%10.3f \n',dx);
fprintf(fid,'DEM_noval=-9999999');
if (exist('velFileOut'))
    fprintf(fid,['VelDem=./' velFileOut]);
end
fclose(fid);

%% TODO: copy files to the refinement directory (or just read them
%% from here?)
