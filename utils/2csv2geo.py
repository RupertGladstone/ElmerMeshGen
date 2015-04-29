# 
# Reformating csv file to .geo file.  
# Should contain list of points with 2 coords and an id.
# 
# Example:
# python csv2geo.py myBoundaryPoint.csv
# 
#

import sys


if (len(sys.argv) < 3):
   raise Exception("Insufficient arguments: need at least 2 input (csv) file names")

elif (len(sys.argv) == 3):
   csvFile1 = sys.argv[1]
   csvFile2 = sys.argv[2]
   baseName = csvFile1.split('.')[0]
   geoFile  = baseName+'.geo'

elif (len(sys.argv) == 4):
   csvFile1 = sys.argv[1]
   csvFile2 = sys.argv[2]
   geoFile  = sys.argv[3]

elif (len(sys.argv) > 4):
   raise Exception("Too many arguments: need at most input (csv) and output (geo) file names")


f = open(csvFile1,'r')
points1 = f.readlines()   
f.close()
points1 = points1[1:] # remove header

f = open(csvFile2,'r')
points2 = f.readlines()   
f.close()
points2 = points2[1:] # remove header

f_out = open(geoFile,'w')
f_out.write('lc=2000;\n')

new_id = 0

SplineLine1 = 'Spline(1)={'
firstTime = True
for point in points1:
   point = point.rstrip()
   [x,y,id] = point.split(',')
   new_id = new_id + 1
   id_str = str(new_id)
   if firstTime:
      firstId1 = id_str
   lineOut = 'Point('+id_str+') = {'+x+', '+y+', 0.0, lc};\n'
   f_out.write(lineOut)
   SplineLine1 = SplineLine1+id_str+','
   firstTime = False

SplineLine2 = 'Spline(2)={'
firstTime = True
for point in points2:
   point = point.rstrip()
   [x,y,id] = point.split(',')
   new_id = new_id + 1
   id_str = str(new_id)
   if firstTime:
      firstId2 = id_str
   lineOut = 'Point('+id_str+') = {'+x+', '+y+', 0.0, lc};\n'
   f_out.write(lineOut)
   SplineLine2 = SplineLine2+id_str+','
   firstTime = False

SplineLine1 = SplineLine1+firstId2+'};\n'
SplineLine2 = SplineLine2+firstId1+'};\n'

f_out.write(SplineLine1)
f_out.write(SplineLine2)

f_out.write('Line Loop(3)={1,2}; \n')
f_out.write('Plane Surface(4) = {3}; \n')
f_out.write('Physical Line(5) = {1}; \n')
f_out.write('Physical Line(6) = {2}; \n')
f_out.write('Physical Surface(7) = {4}; \n')

f_out.close()
