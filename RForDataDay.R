# R script for Open Data Day
# Jesse Hamner
# 

# What directory are you in?
getwd()

# Go to a more useful directory:
setwd("~/Downloads")

# If you haven't installed the required libraries, uncomment this block:
#chooseCRANmirror(graphics=F, ind=92)
 
# Some indications that the dependencies for -sp- end up with a bad gGDAL basic set that is broken:
#install.packages(pkgs="sp", dependencies=NULL)

# The majority of the libraries to be installed:
#install.packages(pkgs=c("boot","nlme","coda","spdep","maptools","rvest","ggplot2"),dependencies=c("Depends","Imports","LinkingTo" ) )

# MASS and rgeos are source only, it appears
#install.packages(pkgs=c("MASS"), dependencies=c("Depends","Imports","LinkingTo"), type="source" )

# Good. OK, next:

# load the required libraries:
library(boot)
library(MASS)
library(nlme)
library(coda)
library(sp)
library(spdep)
library(maptools)
library(rgeos)
library(ggplot2)
library(plyr)

# if you really don't want to work with the Excel sheet (and you don't have to),
# you'll need to run fixfrackvotesheet.plx first. Otherwise, save the worksheet
# to a tab-separated text file called "frackvotetabsep.txt"

# Read in the fracking precinct data:
frackvote <- read.table(file="frackvotetabsep.txt", sep="\t", header=T, skip=0)

# It starts life as a list. This is not a big deal:
f<-as.data.frame(frackvote)

# The variable names are unhelpfully named, especially because the "FOR" and "AGAINST"
# columns are poorly marked, even in the Excel spreadsheet. We really need to fix that.
# variable.names(frackvote)

# Hey, which one of these would you rather do?
#names(f)[names(f)=="Absentee.1"] <- "AbsenteeAGAINST"
#colnames(f)[3] <- "AbsenteeFOR"

# Right. So:
columnnames <- c("Precinct", "Registered.Voters","AbsenteeFOR","EarlyFOR","ElectionDayFOR",
                 "ChoiceFOR.Total","AbsenteeAGAINST","EarlyAGAINST","ElectionDayAGAINST",
                 "ChoiceAGAINST.Total","TotalVoteCount")

# Now rename them all at once:
colnames(f) <- columnnames

# Of course, you could figure up the "Total vote count" on your own.

# These are projected in a standard projection rather than Geographic
# (only latitude & longitude). This is common: it's more spatially
# accurate than Long-Lat, but it's less universal and interchangeable.
#
# Lots of state-level data is kept in a variety of formats, and that means you have 
# to handle each of them. That's annoying but true.
# 
# These voting districts are kept in the following projection:
#
# PROJCS[
# "NAD_1983_StatePlane_Texas_North_Central_FIPS_4202_Feet",
# GEOGCS["GCS_North_American_1983",
# DATUM["D_North_American_1983",
# SPHEROID["GRS_1980",6378137.0,298.257222101]],
# PRIMEM["Greenwich",0.0],
# UNIT["Degree",0.0174532925199433]],
# PROJECTION["Lambert_Conformal_Conic"],
# PARAMETER["False_Easting",1968500.0],
# PARAMETER["False_Northing",6561666.666666666],
# PARAMETER["Central_Meridian",-98.5],
# PARAMETER["Standard_Parallel_1",32.13333333333333],
# PARAMETER["Standard_Parallel_2",33.96666666666667],
# PARAMETER["Latitude_Of_Origin",31.66666666666667],
# UNIT["Foot_US",0.3048006096012192]
# ]
#
# But there's a python script to fix this problem. It converts 
# the PRJ file into a PROJ4 string that makes R happy.
#
# The "pretty formatting" is not necessary, but keeps the line 
# from running off the page and being unreadable.

Proj4Type1 <- "+proj=lcc 
    +lat_1=32.13333333333333 
    +lat_2=33.96666666666667 
    +lat_0=31.66666666666667 
    +lon_0=-98.5 
    +x_0=600000 
    +y_0=2000000 
    +datum=NAD83 
    +units=us-ft 
    +no_defs "

# "CRS" is "Coordinate Reference System", a way of representing
# data that exist on a bumpy, not-quite-a-sphere Earth, on 
# a two-dimensional surface like a screen or paper.

CityPrecincts <- readShapePoly(
  "VoterDistricts/VoterDistricts.shp", 
  proj4string=CRS(Proj4Type1)
  )

# A simple plot:
plot(CityPrecincts, lty=1, col="grey", lwd=1)
title(main="Denton City Voting Districts")

# Now for the county voting precincts. 
# Note that the PROJ4 string is the same as above.

CountyPrecincts <- readShapePoly(
  "VoteDIst/VoteDist.shp",
  proj4string=CRS(Proj4Type1)
)


# Get city boundary:
CityLimits <- readShapePoly(system.file("/Users/jhh0085/Dropbox/nils/Citylimits/Citylimits.shp", 
                            package="maptools"),
                            proj4string=CRS(Proj4Type1)
                            )

Wells <- readShapePoints("SurfaceWells/SurfaceWells.shp", proj4string=CRS(Proj4Type1))

# summary(Wells)

plot(CountyPrecincts, lty=1, col="#a9ffff", lwd=1, main="Denton County 2014")
plot(CityPrecincts, lty=1, col="grey", lwd=1, add=T)
plot(Wells,  pch=21, cex=0.2, col="black", bg="orange", add=TRUE)

# Now create some new, computed columns:

# Percent within a voting precinct who voted FOR the ban: 
f$PCTFOR      <- (f$ChoiceFOR.Total/f$TotalVoteCount)

# And then AGAINST the ban (yeah yeah this could be (1-f$PCTFOR):
f$PCTAGAINST  <- (f$ChoiceAGAINST.Total/f$TotalVoteCount)

# Export the table to something that QGIS can easily import:
write.table(f, "frackvotepct.txt", sep="\t", quote=F, row.names = FALSE, na="")



