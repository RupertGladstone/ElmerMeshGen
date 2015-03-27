#!/bin/bash
#####################################################
## Convert from YAMS format (.mesh ; .sol files (and .vel)) to VTK format
######################################################
if [ -z "$1" ]
then
        echo 'Give the base name of the file'
	echo 'e.g.  mesh2D_1.d for mesh2D_1.d.mesh et mesh2D_1.d.sol'
	exit
fi


if [ ! -f "$1.mesh" ] 
then
	echo $1.mesh "doesn't exist"
	exit
fi
if [ ! -f "$1.sol" ] 
then
	echo $1.sol "doesn't exist"
	exit
fi

#supprime les lignes blanches (le premier sed supprime les espace en fin de ligne. Permet de supprimer les lignes avec uniquement des espaces)
sed  's/^[ \t]*//' $1.mesh | sed  "/^$/d" | grep -v "^ "   > tmp_work.mesh
sed  's/^[ \t]*//' $1.sol | sed  "/^$/d" | grep -v "^ "   > tmp_work.sol
if [  -f "$1.vel" ]
then
	sed  's/^[ \t]*//' $1.vel | sed  "/^$/d" | grep -v "^ "   > tmp_work.vel
fi



WriteVTKHeader()
{
echo '# vtk DataFile Version 3.0' > $1.vtk
echo 'vtk output from '$1'.(mesh/sol)' >> $1.vtk
echo 'ASCII' >> $1.vtk
echo >> $1.vtk
echo 'DATASET POLYDATA' >> $1.vtk
echo >> $1.vtk
}


WriteVTKPoints()
{
nn=$2
echo 'POINTS' $nn 'float' >> $1.vtk
grep -i -A $((nn+1)) vertices tmp_work.mesh | tail -n +3 | awk '{print $1,$2,0.0}' >> $1.vtk
}

WriteVTKPolygons()
{
echo >> $1.vtk
#nbre de traingles
nn=$(grep -i -A 1 triangles tmp_work.mesh | tail -1)
echo 'POLYGONS' $nn $((4*nn)) >> $1.vtk
#-1 au numero des noeuds car numerotation de type c (i.e. de 0 a NbreNoeuds-1)
grep -i -A $((nn+1)) triangles tmp_work.mesh | tail -n +3 | awk '{print 3,$1-1,$2-1,$3-1}' >> $1.vtk
}

WriteVTKSol()
{
nn=$2
echo 'SCALARS H11 double' >> $1.vtk
echo 'LOOKUP_TABLE default' >> $1.vtk
grep -i -A $((nn+2)) solatvertices tmp_work.sol | tail -n +4 | awk '{print $1}' >> $1.vtk
echo >> $1.vtk

echo 'SCALARS H22 double' >> $1.vtk
echo 'LOOKUP_TABLE default' >> $1.vtk
grep -i -A $((nn+2)) solatvertices tmp_work.sol | tail -n +4 | awk '{print $3}' >> $1.vtk
echo >> $1.vtk


echo 'SCALARS H12 double' >> $1.vtk
echo 'LOOKUP_TABLE default' >> $1.vtk
grep -i -A $((nn+2)) solatvertices tmp_work.sol | tail -n +4 | awk '{print $2}' >> $1.vtk
echo >> $1.vtk

if [ -f tmp_work.vel ]
then
	echo 'SCALARS Vel double' >> $1.vtk
	echo 'LOOKUP_TABLE default' >> $1.vtk
	grep -i -A $((nn+2)) solatvertices tmp_work.vel | tail -n +4 | awk '{print $1}' >> $1.vtk
	echo >> $1.vtk
fi
}

#nbre de points
np=$(grep -i -A 1 vertices tmp_work.mesh | tail -1)

# ecrit le header 
WriteVTKHeader $1
# ecrit les vertices
WriteVTKPoints $1 $np
# ecrit les elements triangle
WriteVTKPolygons $1
# ecrit les valeurs
echo >> $1.vtk
echo 'POINT_DATA ' $np >> $1.vtk
echo >> $1.vtk
WriteVTKSol $1 $np

rm -f tmp_work.*

