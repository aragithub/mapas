



#install.packages("rgdal")

library(rgdal)  #para leer archivos "shp"

entidad <- readOGR(dsn="./conjunto_de_datos",layer ="areas_geoestadisticas_estatales" )
municipio <- readOGR("./conjunto_de_datos","areas_geoestadisticas_municipales")
ageb <-readOGR(dsn="./conjunto_de_datos",layer="areas_geoestadisticas_basicas_rurales")

#### Obtengo información general del archivo shape
ogrInfo("./conjunto_de_datos","areas_geoestadisticas_estatales")

#summary(entidad)
#coordinates(entidad)
#names(entidad)
#plot(entidad)
#### 

str(entidad,max.level = 3)

#### es el número de polígonos independientes por estado (islas y parte continental),
#### es decir, un poligono corresponde a un estado, o si hay islas el numero de poligos
#### es mayor a uno 
sapply(entidad@polygons,function(x)length(x@Polygons))
sapply(ageb@polygons,function(x)length(x@Polygons))


#### Cambio el CRS (Coordinate Reference System)
## Library rgdal (spTransform)
entidad <- spTransform(entidad,CRS="+proj=longlat + datum=WGS84")
summary(entidad)
municipio <- spTransform(municipio,CRS="+proj=longlat + datum=WGS84")
summary(municipio)
ageb <- spTransform(ageb,CRS="+proj=longlat + datum=WGS84")

#### Obtengo el tamaño de cada archivo 
#### 
object.size(entidad)

####
object.size(municipio)


#### Reviso que se haya cambiado el CRS  
proj4string(entidad)
proj4string(municipio)
#plot(entidadMod)
#plot(munMod)
#plot(agebMod)

#coordinates(entidadMod)
# coordinates(gCentroid(entidadMod))
# coordinates(entidad)
# bbox(entidad)

#### library(ggplot2)
#### La funcion "fortify" convierte a dataframe para que cada vértice sea almacenado
#### en un renglón, y después contamos el numero de renglones para obtener el total 
#### de vertices
#entidadModDf <- fortify(entidad)
#nrow(entidadModDf)
#### a nivel entidad el número de vértices es de 686,300
# entidadDf <- fortify(entidad)
# nrow(entidadDf)
# 
# munModDf <- fortify(munMod)
# nrow(munModDf)
# 
# agebModDf <- fortify(agebMod)
# nrow(agebModDf)

entidad@data
#### por ageb el número de vértices es de 7,890,607

#### Con la función gSimplify reduzco el número de vértices 
#### mientras más alto es el nivel de tolerancia (tol), el numero de vertices disminuye 
library(rgeos)

# simplificación de polígonos -----------
entidadSimple <- gSimplify(entidad,tol = 0.005)
# incluyo los datos
entidadSimple <- SpatialPolygonsDataFrame(entidadSimple,
                                           data = entidad@data)



object.size(entidadSimple)
object.size(entidad)

#### Con la siguiente linea de codigo obtenemos cuanto representa el archivo simplificado
#### con respecto al original
(object.size(entidadSimple)/object.size(entidad))[1]

plot(entidadSimple)
#### Obtengo el número de vértices 
# entidadSimple <- fortify(entidadSimple)
# nrow(entidadSimple) #### Se redujo a 890
# plot(entidadSimple)

writeOGR(obj = entidadSimple,dsn = ".",layer = "entidadSimple",
         driver = "ESRI Shapefile")

saveRDS(entidadSimple,"./conjunto_de_datos/entidadDos.RDS")

# Por municipio  --------

municipioSimple <- gSimplify(municipio,tol = 0.005)
plot(municipioSimple)
municipioSimple <- SpatialPolygonsDataFrame(municipioSimple,
                                           data = municipio@data)

#### Obtengo el número de vértices 
#municipioSimple <- fortify(entidadSimplify)
# nrow(entidadSimplifyDf) #### Se redujo a 890
# plot(entidadSimplify)
writeOGR(obj = municipioSimple,dsn = "./conjunto_de_datos",layer = "municipioSimple",
         driver = "ESRI Shapefile")
saveRDS(municipioSimple,"./conjunto_de_datos/municipio.RDS")

# prueba de los mapas ------------------
library(dplyr)

# puntos a graficar ------
hospitales <- read.csv('./conjunto_de_datos/datosServSaludYAsistenciaSocialDenue.csv',sep='|')
hospitales <- hospitales[,names(hospitales)%in%c("nom_estab","latitud","longitud")]

hospitalesMini <- hospitales %>%
    filter(!is.na(longitud)) %>%
    filter(!is.na(latitud)) %>%
    mutate(
        lat = as.numeric(as.character(latitud)),
        lng = as.numeric(as.character(longitud))
    ) %>%
    filter(!is.na(lat)) %>%
    sample_n(500)

coordenadas <- hospitalesMini %>%
    select(lat,lng)

hospitalesPuntos <- SpatialPointsDataFrame(coords = coordenadas,
                                           data = hospitalesMini)

# guardamos
saveRDS(hospitalesPuntos,'./conjunto_de_datos/puntosSample.rds')

# poligonos
mapaEntidad <- readRDS('./conjunto_de_datos/entidad.RDS')


library(leaflet)

# Opcion 1 -----
# Mapa utilizando "popup" y "label"
leaflet(mapaEntidad) %>%
    addTiles() %>%
    setView(lng = -102.53, lat = 23.62, zoom = 4) %>%
    addPolygons(weight = 1) %>%
    addMarkers(data  = hospitalesPuntos,
               lng =~lng, lat=~lat,
               popup = ~as.character(nom_estab),
               label = ~as.character(nom_estab),
               clusterOptions = markerClusterOptions())

# Opcion 2 ----
# Mapa utilizando popup 
leaflet(mapaEntidad) %>%
    addTiles() %>%
    setView(lng = -102.53, lat = 23.62, zoom = 4) %>%
    addPolygons(weight = 1) %>%
    addMarkers(data  = hospitalesPuntos,
               lng =~lng, lat=~lat,
               popup = paste("Nombre",hospitalesPuntos$nom_estab,"<br>",
                             "Latitud",hospitalesPuntos$lat,"<br>",
                             "Longitud",hospitalesPuntos$lng),  # popup funciona al hacer clic sobre el marcador
               #label = ~as.character(nom_estab), # basta con pasar el mouse para que aparezca la etiqueta
               clusterOptions = markerClusterOptions())


# Opcion tres ----

# Mapa utilizando "labels"
library(htmltools)

# Construyo una variable con las etiquetas, 
# Elijo labels en lugar del popup porque con las etiquetas no es necesario
# dar clik en el marcador para que aparezca la informacion 
etiquetas<- lapply(seq(nrow(hospitalesPuntos@data)), function(i) {
    paste0( '<p>',"Nombre: ", hospitalesPuntos@data[i, "nom_estab"], '</p>', 
            '<p>',"latitud: ",hospitalesPuntos@data[i, "latitud"], '</p>', 
            '<p>',"longitud: ",hospitalesPuntos@data[i, "longitud"],'</p>'
            )
    }
    )

leaflet(mapaEntidad) %>%
    addTiles() %>%
    setView(lng = -102.53, lat = 23.62, zoom = 4) %>%
    addPolygons(weight = 1) %>%
    addMarkers(data  = hospitalesPuntos,
               lng =~lng, lat=~lat,
               #popup = paste("Nombre: ",hospitalesPuntos$nom_estab,"<br>",
                #             "Latitud: ",hospitalesPuntos$lat,"<br>",
                #             "Longitud: ",hospitalesPuntos$lng),  # popup funciona al hacer clic sobre el marcador
               label = lapply(etiquetas,HTML), # basta con pasar el cursor para que aparezca la informacion
               clusterOptions = markerClusterOptions())


