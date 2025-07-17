#require(plotrix)
#require (stats)

require(psych)
describe(soils)
plot(soils$vwc)
hist(soils$vwc)

plot(soils$x, soils$y)
plot(soils$x, soils$vwc)
plot(soils$y, soils$vwc)

require(DescTools)
Outlier(soils$vwc, method = c("boxplot"), na.rm = FALSE)

require(rgl)
open3d()
x <- soils$x*10
y <- soils$y*10
z <- soils$vwc
plot3d(x, y, z)

require(geometry)
require(plotly)
mesh(x, y, vwc)

cor(soils$x, soils$y, soils$vwc)
cor(soils[2:9])
