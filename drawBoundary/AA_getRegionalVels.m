
clf; clear; 
params;

ncid = netcdf.open(ncfile,'NOWRITE');
varid = netcdf.inqVarID(ncid,xvelName);
vx = netcdf.getVar(ncid,varid);
varid = netcdf.inqVarID(ncid,yvelName);
vy = netcdf.getVar(ncid,varid);
clear varid;
netcdf.close(ncid);
vx = rot90(vx) ; vy = rot90(vy) ;
vnorm=sqrt(vx.^2+vy.^2);

figure(1)
imagesc(vnorm,[0,500]); set(gca,'YDir','normal');

if WholeIceSheet
i_l = 1 ; i_r = nx ; % left and right in x direction
j_b = 1 ; j_t = ny ; % bottom and top in y direction

end

if and(and(exist('i_l'), exist('i_r')), and(exist('j_b'), exist('j_t')))
    fprintf('Found subregion definition from params file... \n')
else
    fprintf(['Drag mouse to select rectangle covering domain of ' ...
             'interest. \n'])
    rect = getrect()
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

if DrawBothBoundaries
    fprintf(['Click points to define mesh ice-ocean boundary (double click ' ...
             'to end) \n'])
    [ob_x, ob_y] = getpts();
end
if (DrawBothBoundaries|DrawInlandBoundary)
    fprintf(['Click points to define mesh interior ice boundary (start ' ...
             'near end of previous points, finish near start of previous ' ...
             'points, double click to end) \n'])
    [ib_x, ib_y] = getpts();
end

clear vx;clear vy;clear vxr;clear vyr

if (WholeIceSheet|DrawInlandBoundary)
    if (UseBedmapContour)
        fid=fopen(BedMaskFile,'r','l');
        IceMask=fread(fid,[nx_bm,ny_bm],'float32');
        fclose(fid);
        IceMask(IceMask==0)=1;
        IceMask = rot90(IceMask); 
        figure(2)
        [cc, hh] = contour(IceMask,[-5000.0,-5000.0]);
        counter=1;
        longest=1;
        while (counter<length(cc))
            if  (cc(2,counter)>longest)
                longest=cc(2,counter);
                counter_keep=counter;
            end
            counter=counter+cc(2,counter)+1;
        end
        stInd=counter_keep;
        numPoints = cc(2,stInd);
        mainContour = cc(:,1+stInd:numPoints+stInd);       
    else
        fprintf(['Calculating contour to use as ice-ocean boundary \n'])
        [cc, hh] = contour(vnorm,[0.01,0.01]);
        fprintf(['done contour \n'])
        numPoints = cc(2,1);
        mainContour = cc(:,2:numPoints+1);
        clear cc, hh;
    end
    ob_x = mainContour(1,:);
    ob_y = mainContour(2,:);
    ob_x = ob_x';ob_y = ob_y';
end
if (WholeIceSheet)
    ib_x = 0; ib_y = 0;
end

fprintf(['Writing boundaries to .geo file for gmsh. \n']);

if (UseBedmapContour)
    ob_x = xmin_bm+ob_x*dx_bm; ob_y = ymin_bm+ob_y*dx_bm;
else
    ob_x = xmin+ob_x*dx; ob_y = ymin+ob_y*dx;
end
ib_x = xmin+ib_x*dx; ib_y = ymin+ib_y*dx;

if (DrawInlandBoundary)
    ib = [ib_x,ib_y];
    ob = [ob_x,ob_y];         
    % Find the closest points from the whole Antarctic ocean
    % boundary (ice front) to the start and end points of the
    % inland boundary.
    % We want the ocean boundary point closest to the end point of
    % the inland boundary to be the first one in the ocean boundary
    % array.  Therefore we flip along this dimension if needed. 
    ind_end = dsearchn(ob,ib(end,:));
    ind_st  = dsearchn(ob,ib(1,:));
    if (ind_end>ind_st)
        ob_use = ob(ind_st:ind_end,:);
        ob_use = flip(ob_use,1);
    else
        ob_use = ob(ind_end:ind_st,:);
    end
    ob_x = ob_use(:,1);
    ob_y = ob_use(:,2);
end

ib_nx = length(ib_x);ob_nx = length(ob_x);
id=1;firstId = id;

fid=fopen(boundaryFileOut,'w');
fprintf(fid,['lc=1000;\n']);
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
fprintf(fid,'DEM_noval=-9999999 \n');
if (exist('velFileOut'))
    fprintf(fid,['VelDem=./' velFileOut]);
end
fclose(fid);

%% TODO: copy files to the refinement directory (or just read them
%% from here?)
