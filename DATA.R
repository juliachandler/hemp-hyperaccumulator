## DATA From: "2017_hempfield soils 48 samples.R"
## #####################################################################

date <- rep("2017_05-20", 24)
tran <- append(rep(1:6, each = 4), rep(11:18, each = 3))
plot<- append(rep(1:4, 6), rep(1:3, 8))
id <- 1:48

weight1 <- c(224, 178, 145, 235, 193, 224, 166, 256, 185, 140, 250, 184,
             206, 146, 153, 184, 200, 206, 220, 211, 216, 365, 196, 307,
             246, 194, 178, 181, 188, 217, 169, 134, 237, 161, 145, 204,
             203, 158, 202, 242, 179, 180, 204, 184, 170, 246, 168, 253)

bag <- c(13, 12, 12, 12, 12, 12, 13, 13, 12, 12, 12, 12,
         13, 15, 17, 13, 12, 12, 13, 13, 12, 12, 12, 13,
         11, 11, 11, 12, 11, 11, 11, 12, 11, 11, 11, 11,
         10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 10)

weight2 <- c(202, 165, 135, 210, 175, 197, 154, 224, 167, 128, 211, 170,
             176, 131, 137, 166, 162, 174, 193, 189, 195, 312, 173, 274,
             215, 171, 154, 161, 173, 184, 157, 125, 202, 144, 129, 180,
             184, 148, 183, 202, 158, 165, 177, 155, 150, 217, 148, 218)

plate <- rep(23, 48)
wet <- weight1 - bag
dry <- weight2 - plate
vwc <- ((wet-dry)/dry)*100
soils <- data.frame(date, tran, plot, id, wet, dry, vwc)
controlx <- rep(5:8, 3)
hemx <- append(controlx, rep(1:4, 3), after = length(controlx))
soycontx <- rep(1:8, each = 3)
soils$x <- append(hemx, soycontx, after = length(hemx)) 
controly <- rep(1:3, each = 4)
hemy <- append(controly, rep(1:3, each = 4), after = length(controly))
soyconty <- rep(4:6, 8)
soils$y <- append(hemy, soyconty, after = length(hemy)) 
soils <- soils[with(soils, order(x, y)), ]
soils$treat1 <- append(rep("hemp", 30), rep("control", 18), after = 30)

# END #########################################################################33