library(shiny)
library(readr)
library(shinydashboard)
library(shinyWidgets)
library(shinythemes)
library(leaflet)
library(lubridate)
library(tidyverse)

# LOAD DATA

mass_shootings <- read_csv("mass_shootings.csv", 
                           col_types = cols(date = col_date(format = "%d/%m/%Y")))

text_about <- "It's a paragraph text."

ui <- bootstrapPage(
    
    #set theme
    theme = shinythemes::shinytheme('simplex'),
    
    # only one output
    leaflet::leafletOutput('map', width = '100%', height = '100%'),
    
    # panel on top of output
    absolutePanel(top = 10, right = 10, id = 'controls',
                  sliderInput('nb_fatalities', 'Minimum Fatalities', 1, 40, 10),
                  dateRangeInput(
                      'date_range', 'Select Date', "2010-01-01", "2019-12-01"
                  ),
                  actionButton('show_about', 'About')
    ),
    
    tags$style(type = "text/css", "
    html, body {width:100%;height:100%}     
    #controls{background-color:white;padding:20px;}
  ")
)
server <- function(input, output, session) {

    observeEvent(input$show_about, {
        showModal(modalDialog(text_about, title = 'About'))
    })
    output$map <- leaflet::renderLeaflet({
        mass_shootings %>% 
            filter(
                date >= input$date_range[1],
                date <= input$date_range[2],
                fatalities >= input$nb_fatalities
            ) %>% 
            leaflet() %>% 
            setView( -98.58, 39.82, zoom = 5) %>% 
            addTiles() %>% 
            addCircleMarkers(
                popup = ~ summary, radius = ~ sqrt(fatalities)*3,
                fillColor = 'red', color = 'red', weight = 1
            )
    })
}

shinyApp(ui, server)
