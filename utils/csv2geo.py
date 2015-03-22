# 
# Reformating csv file to .geo file.  
# Should contain list of points with 2 coords and an id.
# 
# Example:
# python csv2geo.py myBoundaryPoint.csv
# 
#

import sys


if (len(sys.argv) < 2):
   raise Exception("Insufficient arguments: need at least input (csv) file name")

elif (len(sys.argv) == 2):
   csvFile = sys.argv[1]
   baseName= csvFile.split('.')[0]
   geoFile = baseName+'.geo'

elif (len(sys.argv) == 3):
   csvFile = sys.argv[1]
   geoFile = sys.argv[2]

elif (len(sys.argv) > 3):
   raise Exception("Too many arguments: need at most input (csv) and output (geo) file names")


f = open(csvFile,'r')
points = f.readlines()   
f.close()
points = points[1:] # remove header

f_out = open(geoFile,'w')
f_out.write('lc=1000;\n')
SplineLine = 'Spline(1)={'

firstTime = True
for point in points:
   point = point.rstrip()
   [x,y,id] = point.split(',')
   if firstTime:
      firstId = id
   lineOut = 'Point('+id+') = {'+x+', '+y+', 0.0, lc};\n'
   f_out.write(lineOut)
   SplineLine = SplineLine+id+','
   firstTime = False

SplineLine = SplineLine+firstId+'};\n'
f_out.write(SplineLine)
f_out.write('Line Loop(2)={1}; \n')
f_out.write('Plane Surface(3) = {2}; \n')
f_out.write('Physical Line(4) = {1}; \n')
f_out.write('Physical Surface(5) = {3}; \n')

f_out.close()
