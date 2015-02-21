#! /usr/bin/env python

# I didn't write this. It was borrowed from elsewhere. 
# http://gis.stackexchange.com/questions/55196/how-can-i-get-the-proj4-string-or-epsg-code-from-a-shapefile-prj-file
# Accessed on Feb 21 2015

import sys
from osgeo import osr

def esriprj2standards(shapeprj_path):
   prj_file = open(shapeprj_path, 'r')
   prj_txt = prj_file.read()
   srs = osr.SpatialReference()
   srs.ImportFromESRI([prj_txt])
   print 'Shape prj is: %s' % prj_txt
   print 'WKT is: %s' % srs.ExportToWkt()
   print 'Proj4 is: %s' % srs.ExportToProj4()
   srs.AutoIdentifyEPSG()
   print 'EPSG is: %s' % srs.GetAuthorityCode(None)

esriprj2standards(sys.argv[1])


