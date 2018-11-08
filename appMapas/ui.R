#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shinydashboard)

library(shinydashboard)

dashboardPage(
    dashboardHeader(),
    dashboardSidebar(
        sidebarMenu(
            menuItem(
                "Mapa", 
                tabName = "mapa", 
                icon = icon("dashboard")
            )
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(
                tabName = 'mapa',
                leafletOutput("mapa")
            )
        )
    )
)