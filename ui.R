#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



#---libraries used

#interface libraries
library(shiny)
# library("gridlayout") #not usable with posit
library("bslib")
library("bs4Dash")  #this is what you're using to sort inputs into diff columns instead of being stacked onto another
library("htmlwidgets") #provides user control widgets too

#sampling libraries
library("tidyverse")  #mostly brought in so that you have some sample data to work with for now
library("leaflet") #for the sample map, but also the proper map later


library(shiny)



#tab organising
tab1 <- "Origin(s)"
tab2 <- "Destination"
tab3 <- "Other"

#input organising
origin_input_1 <- "NumericInput_OLong"
origin_input_2 <- "NumericInput_OLat"
origin_input_3 <- "NumericInput_OBuffer"

destination_input_1 <- "NumericInput_DLong"
destination_input_2 <- "NumericInput_DLat"
destination_input_3 <- "NumericInput_DBuffer"





#----VVV Shiny UI Building Below VVV ----





# Define UI for application that draws a histogram
shinyUI(       #note this initial shinyui() function was not default, I added it, though idk what it does
  fluidPage(
    
    #---initial variable definitions
    #(if any?)
    
    
    
    #---regular page-building below
    
    #navbarPage(title = "NavApp", tabPanel(tab1), tabPanel(tab2) )  #alternate option
    navlistPanel(widths = c(2,8),  #the two values in widths argument in navlistPanel are for the widths of the navigation list and tabset content areas respectively  
                 
                 tabPanel(title = tab1, #tab 1
                          #value = "sample_value1",
                          icon = icon("1"),
                          card(full_screen = FALSE,   #card-making begins
                               fluidRow(  #row1  made to contain columns
                                 
                                 column(width = 4,  #column 1  #coordinates default set at UTM as example
                                        numericInput(  #user text input, will use it to accept user origin coordinates  #still needs restrictions on the values are accepted to be considered coordinates (since coordinates are only values from -90 to +90)
                                          inputId = origin_input_1, label = "Origin longitude", value = -79.663733, step = .001, min = -180, max = 180, width = 150), 
                                        numericInput(  #user numeric input, will use it to accept user origin coordinates  #still needs restrictions on the values are accepted to be considered coordinates 
                                          inputId = origin_input_2, label = "Origin latitude", value = 43.547462, step = .001, min = -90, max = 90, width = 150),
                                        numericInput(  #user numeric input, will use to determine their origin buffer size 
                                          inputId = origin_input_3, label = "Radius (Metres)", value = 500, step = 100, min = 1, max = NA, width = 150),
                                        #will add a button which pops-up an option to draw the shape they want as their origin area
                                        actionButton(inputId = 'save_origin', label = "Save Origin Area")
                                 ) #concludes column 1 content
                                 #) #concludes column 2, holds the origin input map, drawing their optional origin(s) they've drawn 
                               ) #concludes fluidrow 1
                          ) #concludes card 1 in tab1
                 ),  #brackets here conclude first tabpanel, comma introduces next argument for second tabpanel
                 
                 tabPanel(title = tab2, #tab 2
                          icon = icon("2"), 
                          fluidRow(
                            column(width = 4,  #column 2 (middle)  #coordinates default set at Kipling as example
                                   numericInput(  #user text input, will use it to accept user destination coordinates  #still needs restrictions on the values are accepted to be considered coordinates
                                     inputId = destination_input_1, label = "Destination longitude", value = -79.537235, step = .01, min = -180, max = 180, width = 150),
                                   numericInput(  #user text input, will use it to accept user destination coordinates  #still needs restrictions on the values are accepted to be considered coordinates
                                     inputId = destination_input_2, label = "Destination latitude", value = 43.636796, step = .01, min = -90, max = 90, width = 150),
                                   numericInput(  #user numeric input, will use to determine their destination buffer size
                                     inputId = destination_input_3, label = "Radius (Metres)", value = 500, step = 100, min = 1, max = NA, width = 150),
                                   actionButton(inputId = 'save_destination', label = "Save Destination Area")
                            ) #concludes column 1 content
                          ) #concludes fluidrow
                 ), #concludes tabpanel 2
                 
                 tabPanel(title = tab3, #tab 3, for holding your geolocation request (temporarily)
                          icon = icon("3"), 
                          tags$script('
      $(document).ready(function () {
        navigator.geolocation.getCurrentPosition(onSuccess, onError);
        function onError (err) {
          Shiny.onInputChange("geolocation", false);
        }
        function onSuccess (position) {
          setTimeout(function () {
            var coords = position.coords;
            console.log(coords.latitude + ", " + coords.longitude);
            Shiny.onInputChange("geolocation", true);
            Shiny.onInputChange("userLat", coords.latitude);
            Shiny.onInputChange("userLong", coords.longitude);
          }, 1100)
        }
      });
              '),
                          #Show the values of coordinates if given (NULL if not), and geolocation variable is TRUE/FALSE whether given or not
                          fluidRow(
                            column(width = 6,   #column 1
                                   c("Device Longitude:"),verbatimTextOutput('userLong'),
                                   c("Device Latitude:"),verbatimTextOutput('userLat')),
                            column(width = 6,   #column 2
                                   c("Location Request Status:"),verbatimTextOutput('geolocation') )
                          ), #concludes fluid row 1 showing the geolocation values
                  
                          fluidRow(
                            column(width = 6,
                              textOutput(outputId = 'prompt_click_map'),  #will decide later whether this is placed inside or before the wellpanel
                            ),
                            #wellPanel(
                              column(width = 3,
                                     textOutput(outputId = 'messagemapclick1Long', inline = TRUE), verbatimTextOutput(outputId = 'clickedLong'),
                              ),
                              column(width = 3,
                                     textOutput(outputId = 'messagemapclick1Lat', inline =TRUE), verbatimTextOutput(outputId = 'clickedLat') 
                              )
                            #) #concludes wellpanel, can also get rid of this function opening and close as comments and leave the commands inside alone, they will still perform but without appearing inside a panel
                          ) #concludes fluid row with the user-clicking map lat/long values 
                 ) #concludes tabpanel 3
                 
    ),  #concludes the navlistpanel (but needs comma for future arguments)
    
    leafletOutput(outputId = 'firstleaflet')  #
    
    
  ))
