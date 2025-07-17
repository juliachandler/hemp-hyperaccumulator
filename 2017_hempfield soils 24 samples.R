getwd()
setwd("C:/R/2017/soils")
dir<-getwd()
list.files(dir)


# samples collected May 20th, 2017.
## soils sampled to 10 cm depth.
# Hempfield site (40.1863889 N, 79.7516389 W))
# samples collected by Julia Chandler and Matt Mallory

# balanced before-after-control-impact design
# with 12 samples in each the control and the treatment areas

date <- rep("2017_05-20", 24)
plot <- rep(1:4, 6)
tran <- rep(1:6, each = 4)
id <- 1:24

wet <- c(183.6, 268.3, 244.0, 264.7,
         159.4, 134.2, 165.9, 170.6,
         155.7, 152.3, 216.8, 220.5,
         142.6, 164.4, 146.6, 129.7,
         154.5, 111.4, 128.9, 132.1,
         170.7, 184.4, 208.3, 131.5)

dry <- c(151.6, 222.6, 202.2, 216.8,
         129.7, 109.1, 135.0, 136.1,
         127.0, 121.6, 176.9, 179.6,
         118.8, 134.6, 120.4, 100.1,
         125.9, 90.8, 103.4, 106.3,
         137.8, 150.5, 165.0, 104.8)

soils <- data.frame(date, tran, plot, id, wet, dry)

# Volumetric water content (vwc) is a measure of the amount of water held in a soil (expressed as a % of the total mixture)
# VWC = measured gravimetrically by:
# (1) collecting the sample in the field in an air tight container; (2) at the lab the sample is weighed;
# (3) the sample is air dried; and (4) sample is weighed again.
# VWC = 100 * (Weight Before Drying - Weight After Drying / Weight Before Drying)

soils$vwc <- ((soils$wet-soils$dry)/soils$dry)*100

require(DescTools)
Outlier(soils$mc, method = c("boxplot"), na.rm = FALSE)

soils$x <- soils$plot*10
soils$y <- soils$tran*10




# tray wieght = 91.5 g
#wet <- c(
#  183.6, (176.8 + 91.5), (125.0 + 91.5), (173.2 + 91.5),
#  159.4, 134.2, (74.4 + 91.5), (79.1 + 91.5),
#  155.7, 152.3, (125.3 + 91.5), (129.0 + 91.5),
#  142.6, (72.9+ 91.5), 146.6, 129.7,
#  154.5, 111.4, 128.9, 132.1,
#  (79.2 + 91.5), (92.9 + 91.5), (116.8 + 91.5), 131.5)

 
##wet <- c(
#  183.6, 176.8, 125.0, 173.2,
#  159.4, 134.2, 74.4, 79.1,
#  155.7, 152.3, 125.3, 129.0,
#  142.6, 72.9, 146.6, 129.7,
#  154.5, 111.4, 128.9, 132.1,
#  79.2, 92.9, 116.8, 131.5)


