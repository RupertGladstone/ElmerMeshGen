
fileName = '/home/elmeruser/Work/AA_processing/bedmap2_bin/bedmap2_icemask_grounded_and_shelves.flt'
%fileName = '/home/elmeruser/Work/ElmerMeshGen/drawBoundary/bedmap2_bin/bedmap2_icemask_grounded_and_shelves.flt'
fid=fopen(fileName,'r','l');
IceMask=fread(fid,[6667,6667],'float32');
fclose(fid);

IceMask(IceMask==0)=1;
IceMask = rot90(IceMask); %IceMask = flip(IceMask);
boundaryFileOut = 'AABoundaryBM.geo';

Top    =  3333500;
Left   = -3333500;
Right  =  3333500;
Bottom = -3333500;
dx=1000.0;
nx=6667;ny=6667;

xmin=Left;ymin=Bottom;

i_l = 0 ; i_r = nx ;
j_b = 0 ; j_t = ny ;
nj = j_t-j_b+1 ; ni = i_r-i_l+1 ;

hold off; clf;

imagesc(IceMask); set(gca,'YDir','normal');
hold on

%xlim([i_l, i_r]);
%ylim([j_b, j_t]);

fprintf(['Calculating contour to use as ice-ocean boundary \n'])
[cc, hh] = contour(IceMask,[-5000.0,-5000.0]);
counter=1;
longest=1;
while (counter<length(cc))
    %    if (cc(2,counter)>5000)
    %    cc(2,counter),counter
    %end
    if  (cc(2,counter)>longest)
        longest=cc(2,counter)
        counter_keep=counter
    end
    counter=counter+cc(2,counter)+1;
end

stInd=counter_keep;
numPoints = cc(2,stInd);
mainContour = cc(:,1+stInd:numPoints+stInd);

clear cc, hh;
h = plot(mainContour(1,:), mainContour(2, :), 'k');
ob_x = mainContour(1,:);
ob_y = mainContour(2,:);

ob_x = xmin+ob_x*dx; ob_y = ymin+ob_y*dx;

ob_nx = length(ob_x);id=1;firstId = id;


fid=fopen(boundaryFileOut,'w');
fprintf(fid,['lc=100000;\n']);
SplineLineOB = 'Spline(1)={';

for ii=1:ob_nx(1);
    fprintf(fid,'Point(%i)={%12.5f,%12.5f,0.0,lc}; \n',id,ob_x(ii),ob_y(ii));
    SplineLineOB = [SplineLineOB int2str(id) ','];
    id_lastOB=id;
    id = id+1;
end
SplineLineOB = [SplineLineOB int2str(firstId) '};\n'];

fprintf(fid,SplineLineOB);
fprintf(fid,'Line Loop(2)={1}; \n');
fprintf(fid,'Plane Surface(3) = {2}; \n');
fprintf(fid,'Physical Line(4) = {1}; \n');
fprintf(fid,'Physical Surface(5) = {3}; \n');
fclose(fid);
