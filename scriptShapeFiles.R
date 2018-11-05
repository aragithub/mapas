

#### Esto es para las 32 carpetas de INEGI
#### Funciona pero se tarda demasiado 
#### Descargo los archivos ----
#url <- "http://internet.contenidos.inegi.org.mx/contenidos/Productos/prod_serv/contenidos/espanol/bvinegi/productos/geografia/marcogeo/889463526636_s.zip"

#if (!file.exists("shpMexico.zip")){
#    download.file(url,"shpMexico.zip")
#}

#### Extraigo los archivos ----
#if(!file.exists("conjunto de datos/areas_geoestadisticas_basicas_rurales.dbf")){
#    unzip("shpMexico.zip")
#}

### Extraigo los archivos zip ----
fileNames <- list.files(pattern = "*.zip")
archivos <- lapply(fileNames,unzip)


#### Lectura archivos shape


#library(foreign)
# x <- read.dbf("~/Documents/Arena/2018_07_infoExterna/2018_10_capasInegi/889463592587_s/01_aguascalientes/conjunto de datos/01a.dbf")

########################################################################
#install.packages("rgdal")

library(rgdal)

######## NUEVO INTENTO 

#setwd("~/Documents/Arena/2018_07_infoExterna/2018_10_capasInegi/889463142683_s/conjunto_de_datos")
entidad <- readOGR(dsn=".",layer ="areas_geoestadisticas_estatales" )
mun <- readOGR(".","areas_geoestadisticas_municipales")
ageb <-readOGR(dsn=".",layer="areas_geoestadisticas_basicas_rurales")

#### Obtengo información general del archivo shape
ogrInfo(".","areas_geoestadisticas_estatales")

#summary(entidad)
#coordinates(entidad)
#names(entidad)
#plot(entidad)
#### 

str(entidad,max.level = 3)

#### No tengo claro qué estoy obteniendo :(
#### Aparentemente es el número de polígonos 
sapply(entidad@polygons,function(x)length(x@Polygons))
sapply(ageb@polygons,function(x)length(x@Polygons))


#### Cambio el CRS
## Library rgdal (spTransform)
entidadMod <- spTransform(entidad,CRS="+proj=longlat + datum=WGS84")
summary(entidadMod)
munMod <- spTransform(mun,CRS="+proj=longlat + datum=WGS84")
summary(munMod)
agebMod <- spTransform(ageb,CRS="+proj=longlat + datum=WGS84")

#### Obtengo el tamaño de cada archivo 
#### 
object.size(entidadMod)

####
object.size(agebMod)


#### Reviso que se haya cambiado el CRS  
proj4string(munMod)
proj4string(agebMod)
#plot(entidadMod)
#plot(munMod)
#plot(agebMod)

#coordinates(entidadMod)
# coordinates(gCentroid(entidadMod))
# coordinates(entidad)
# bbox(entidad)

#### La funcion "fortify" "aplana" el archivo para que cada vértice sea almacenado
#### en un renglón, y después se cuenta el resultado.
entidadModDf <- fortify(entidadMod)
nrow(entidadModDf)
#### a nivel entidad el número de vértices es de 686,300
entidadDf <- fortify(entidad)
nrow(entidadDf)

munModDf <- fortify(munMod)
nrow(munModDf)

agebModDf <- fortify(agebMod)
nrow(agebModDf)
#### por ageb el número de vértices es de 7,890,607

#### Con la función gSimplify reduzco el número de vértices 
#### mientras más alto es el nivel de tolerancia 
library(rgeos)

#### Entidad 
entidadSimplify <- gSimplify(entidadMod,tol = 0.1)
entSimplifyDos <- SpatialPolygonsDataFrame(entidadSimplify,
                                           data = entidadMod@data)

#### Obtengo el número de vértices 
entidadSimplifyDf <- fortify(entidadSimplify)
nrow(entidadSimplifyDf) #### Se redujo a 890
plot(entidadSimplify)

writeOGR(obj = entSimplifyDos,dsn = ".",layer = "entSimplifyDos",
         driver = "ESRI Shapefile")



############################REVISAR --------
#### Por municipio 
munSimplify <- gSimplify(munMod,tol = 0.1)
plot(munSimplify)
munSimplifyDos <- SpatialPolygonsDataFrame(munSimplify,
                                           data = munMod@data)

#### Obtengo el número de vértices 
entidadSimplifyDf <- fortify(entidadSimplify)
nrow(entidadSimplifyDf) #### Se redujo a 890
plot(entidadSimplify)

writeOGR(obj = entSimplifyDos,dsn = ".",layer = "entSimplifyDos",
         driver = "ESRI Shapefile")

