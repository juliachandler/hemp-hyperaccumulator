getwd()
setwd("C:/R/hemp")
dir<-getwd()
list.files(dir)

source("DATA.R")
str(soils)
require(ggplot2)
df <- soils[7:9]
df<- data.frame(df)

#Plot the points
p <- ggplot(df, aes(x, y)) + geom_point(aes(size=vwc), color="blue", alpha=1.5/4) +
  ggtitle("Gravimetric Water Content\n(range = 17-35%)") + coord_equal() + theme_bw() +
  scale_x_discrete(name = "Distance (m)", limits=c("10", "20", "30", "40", "50", "60", "70", "80")) +
  scale_y_discrete(name = "Distance (m)", limits=c("10", "20", "30", "40", "50", "60")) +
  theme(legend.position="none")
  
p
  
#theme(legend.title = element_text(colour="orange", size = 12, face = "bold")) +
#scale_fill_discrete(name = "GWC (%)")) +
#labs(fill = "GWC (%)")


### TRY TO KRIG - NOT WORKING!!!!!!!!!!!!!!!!!!!
#install.packages("kriging")
library(kriging) 
x <- df$x
y <- df$y
vwc <- df$vwc
kriging(x, y, vwc, model = "spherical", lags = 10, pixels = 100, polygons = NULL)

## Change to a spatial data file
class(df)
df.sp <- df
install.packages("gstat")
library(gstat)
data(df)
coordinates(df.sp) <- ~ x + y
class(df.sp)
bbox(df.sp)
coordinates(df.sp)

## EXAMPLE ## 
# Krige random data for a specified area using a list of polygons
library(maps)
usa <- map("usa", "main", plot = FALSE)
p <- list(data.frame(usa$x, usa$y))
# Create some random data
x <- runif(50, min(p[[1]][,1]), max(p[[1]][,1]))
y <- runif(50, min(p[[1]][,2]), max(p[[1]][,2]))
z <- rnorm(50)
# Krige and create the map
kriged <- kriging(x, y, z, polygons=p, pixels=300)
image(kriged, xlim = extendrange(x), ylim = extendrange(y))





library(sp)

# convert simple data frame into a spatial data frame object
coordinates(soils)= ~ x+y

# create a bubble plot with the random values
bubble(soils, zcol='vwc', fill=FALSE, do.sqrt=FALSE, maxsize=5, col = "orchid")

# plot the semivariogram
variogram1=variogram(vwc~1, data=soils)
plot(variogram1)
variogram1
summary(variogram1)
TheVariogramModel <- vgm(psill=15, model="Gau", nugget=0.0001, range=0.75)
plot(variogram1, model=TheVariogramModel)

#make a prediction at an unkown location

library(geoR)
soilsgeo <- as.geodata(soils[7:9])

prediction <- ksline(soilsgeo, cov.model="exp", cov.pars=c(15,0.75), nugget=0.0001, locations=c(6.5,7))

prediction$predict
prediction$krige.var

FittedModel <- fit.variogram(variogram1, model=TheVariogramModel)

plot(variogram1, model=FittedModel)

x.range <- as.integer(range(soils[,8]))
y.range <- as.integer(range(soils[,9]))
grd <- expand.grid(x=seq(from=x.range[1], to=x.range[2], by=1), y=seq(from=y.range[1], to=y.range[2], by=1))
q <- ksline(soilsgeo, cov.model="exp",cov.pars=c(10,3.33), nugget=0, locations=grd)






















library(sp)
library(gstat)

suppressPackageStartupMessages({
  library(dplyr) # for "glimpse"
  library(ggplot2)
  library(scales) # for "comma"
  library(magrittr)
})

# Plot a grid
soils %>% as.data.frame %>% 
  ggplot(aes(x, y)) + geom_point(aes(size=vwc), color="blue", alpha=3/4) + 
  ggtitle("Volumetric Water Content (%)") + coord_equal() + theme_bw()

# (1) Convert the dataframe to a spatial points dataframe (SPDF)
class(soils)
str(soils)

coordinates(soils) <- ~ x + y
class(soils)
str(soils)

grid <- makegrid(soils[8:9], cellsize = 1)
grid <- SpatialPoints(grid, proj4string = CRS(proj4string(colorado)))
plot(colorado)
plot(grid, pch = ".", add = T)

#For SPDF objects there are five different slots:
# The 'data' slot contains all the variables associated with different spatial locations.
# Those locations, though, are stored in the 'coordinates' slot, which is a matrix of all spatial locations with corresponding values in the dataframe.
# 'coords.nrs' contains the column numbers of the spatial coordinates in the dataframe, like if you coerce the SPDF to a dataframe first.
# 'bbox' is the bounding box, that is, four points (or "corners") which denote the spatial extent of the data.
# 'proj4string' is the slot which contains the projection information.

bbox(soils)
coordinates(soils) %>% glimpse
proj4string(soils) # we haven't specified the projection yet; currently set to NA

# manually coerce the data back to a dataframe to retain the coordinate information, as opposed to just accessing the data slot:
soils@data %>% glimpse
soils %>% as.data.frame %>% glimpse
soils


# (2) Fitting a variogram
lzn.vgm <- variogram(log(vwc)~1, soils) # calculates sample variogram values 
#lzn.vgm <- variogram(vwc, soils) # calculates sample variogram values
lzn.fit <- fit.variogram(lzn.vgm, model=vgm(10, "Sph", 900, 10)) # fit model
plot(lzn.vgm, lzn.fit) # plot the sample values, along with the fit model

data(soils.grid)

# to compare, recall the bubble plot above; those points were what there were values for. this is much more sparse
plot1 <- soils %>% as.data.frame %>%
  ggplot(aes(x, y)) + geom_point(size=1) + coord_equal() + 
  ggtitle("Points with measurements")

# this is clearly gridded over the region of interest
plot2 <- soils.grid %>% as.data.frame %>%
  ggplot(aes(x, y)) + geom_point(size=1) + coord_equal() + 
  ggtitle("Points at which to estimate")

library(gridExtra)
grid.arrange(plot1, plot2, ncol = 2)
coordinates(soils.grid) <- ~ x + y # step 3 above
lzn.kriged <- krige(log(zinc) ~ 1, soils, soils.grid, model=lzn.fit)

lzn.kriged %>% as.data.frame %>%
  ggplot(aes(x=x, y=y)) + geom_tile(aes(fill=var1.pred)) + coord_equal() +
  scale_fill_gradient(low = "yellow", high="red") +
  scale_x_continuous(labels=comma) + scale_y_continuous(labels=comma) +
  theme_bw()





### Example ###############
data(meuse)
#glimpse(meuse)
#?meuse

meuse %>% as.data.frame %>% 
  ggplot(aes(x, y)) + geom_point(aes(size=zinc), color="blue", alpha=3/4) + 
  ggtitle("Zinc Concentration (ppm)") + coord_equal() + theme_bw()

class(meuse)
str(meuse)

coordinates(meuse) <- ~ x + y
class(meuse)
str(meuse)
bbox(meuse)
coordinates(meuse) %>% glimpse
proj4string(meuse)
identical( bbox(meuse), meuse@bbox )
identical( coordinates(meuse), meuse@coords )
meuse@data %>% glimpse
meuse %>% as.data.frame %>% glimpse
lzn.vgm <- variogram(log(zinc)~1, meuse) # calculates sample variogram values 
lzn.fit <- fit.variogram(lzn.vgm, model=vgm(1, "Sph", 900, 1)) # fit model
plot(lzn.vgm, lzn.fit) # plot the sample values, along with the fit model

# load spatial domain to interpolate over
data(meuse.grid)

# to compare, recall the bubble plot above; those points were what there were values for. this is much more sparse
plot1 <- meuse %>% as.data.frame %>%
  ggplot(aes(x, y)) + geom_point(size=1) + coord_equal() + 
  ggtitle("Points with measurements")

# this is clearly gridded over the region of interest
plot2 <- meuse.grid %>% as.data.frame %>%
  ggplot(aes(x, y)) + geom_point(size=1) + coord_equal() + 
  ggtitle("Points at which to estimate")

library(gridExtra)
grid.arrange(plot1, plot2, ncol = 2)
coordinates(meuse.grid) <- ~ x + y # step 3 above
lzn.kriged <- krige(log(zinc) ~ 1, meuse, meuse.grid, model=lzn.fit)

lzn.kriged %>% as.data.frame %>%
  ggplot(aes(x=x, y=y)) + geom_tile(aes(fill=var1.pred)) + coord_equal() +
  scale_fill_gradient(low = "yellow", high="red") +
  scale_x_continuous(labels=comma) + scale_y_continuous(labels=comma) +
  theme_bw()


