#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
# shinyServer(function(input, output, session) {
#     
#     output$mapa <- renderLeaflet({
#         leaflet(mapaEntidad) %>%
#             addTiles() %>%
#             setView(lng = -102.53, lat = 23.62, zoom = 4) %>%
#             addPolygons(weight = 1) %>%
#             addMarkers(data  = hospitalesPuntos,lng =~lng, lat=~lat,
#                        popup = ~as.character(nom_estab),
#                        clusterOptions = markerClusterOptions())
#         
#     })
  


shinyServer(function(input, output, session) {
    
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
    
    
    output$mapa <- renderLeaflet({
        leaflet(mapaEntidad) %>%
            addTiles() %>%
            setView(lng = -102.53, lat = 23.62, zoom = 4) %>%
            addPolygons(weight = 1) %>%
            addMarkers(data  = hospitalesPuntos,lng =~lng, lat=~lat,
                       #popup = ~as.character(nom_estab),
                       label = lapply(etiquetas,HTML),
                       clusterOptions = markerClusterOptions())

    })
})
