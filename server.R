#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#v2.2 wip


#--packages needed (either for server or for ui)
#install.packages("shiny")
#install.packages("tidyverse") #for sample data, and piping
#install.packages("leaflet") #for the leaflet map presentation
#install.packages("sf") #dealing w leaflet and spatial data, would need this somewhere 
#install.packages("tidytransit") #reads and writes with GTFS data
#install.packages("bslib")
#install.packages("bs4Dash") #allows for columns in rows on the ui
#install.packages("DT")
#install.packages("kableExtra")
#install.packages("htmlwidgets")
#install.packages("leafpm")
#install.packages("mapedit")
#install.packages("shinycssloaders")


#---libraries used

#interface libraries
library(shiny)
# library("gridlayout") #not usable with posit
library("bslib")
library("bs4Dash")  #this is what you're using to sort inputs into diff columns instead of being stacked onto another
library("htmlwidgets") #provides user control widgets too  
library("shinycssloaders") #for spinners while data/output loads  #haven't used it yet, but will later  #gets added using  withSpinner() function, or can check any other commands it offers


#sampling libraries
library("tidyverse")  #mostly brought in so that you have some sample data to work with for now
library("leaflet") #for the sample map, but also the proper map later

#map related libraries
#library("tidytransit")  #reads GTFS data, makes it usable sf data
library("sf")   #sf is needed, but for now it won't install for some reason and is interrupting
#library("leafpm") #this plugin lets the user interact with the map for input (basically your package for them to draw a polygon, although it does allow a few other things too) 
#library("mapedit") #this plugin lets the user interact with the map for input (basically your package for them to draw a polygon, although it does allow a few other things too)
#library("sp") #this is only until sf package can get installed, idk why the are errors are there
#library("rgeos") #pairs with sp, being used to make buffers atm  #can remove sp and rgeos once sf works again
#install.packages("sf") 


#libraries remotely sourced
#install.packages("remotes")  #lets you get packages directly from github
#library("remotes")
#install_github("r-spatial/sf")  #my source for sf while the general command isn't working     #this one sources it but doesn't store it either


library(shiny)



#------Server operations:

function(input, output, session) {
  
  
  ##initial leaflet (is first because adjustments throughout from the other actions)
  output$firstleaflet <- renderLeaflet(
    {leaflet::leaflet() %>% addProviderTiles(providers$Stamen.Toner) %>% leaflet::setView(0,0, zoom = 3)
    }) #curly brackets for expression to sort out your map
  
  ##initial values (before any action)
  #server operation initial defaults (eg basic buttons, textboxes, etc)
  output$prompt_click_map <- renderPrint( cat("Click map for.. ") ) #initial message when prompting user to click map for coordinates
  output$clickedLat <- renderPrint( cat("N/A") )   #set it up so that the ID can exist for the Shiny UI to generate the output box ahead of time, before getting updated with coordinate values
  output$clickedLong <- renderPrint( cat("N/A") )  #set it up so that the ID can exist for the Shiny UI to generate the output box ahead of time, before getting updated with coordinate values 
  output$messagemapclick1Long <- renderPrint( cat("Longitude:") )  #and then once the map is clicked you have it set in server to remove this message
  output$messagemapclick1Lat <- renderPrint( cat("Latitude:") )  #and then once the map is clicked you have it set in server to remove this message
  
  
  ##map click parts
  #--user location request values   #they got sourced from tags$script in the ui file
  output$userLat <- renderPrint({ cat(input$userLat) })
  output$userLong <- renderPrint({ cat(input$userLong) })
  output$geolocation <- renderPrint({ input$geolocation })
  
  
  ##origin button  (currently called 'save_origin' in the ui file)
  observeEvent(input$save_origin, {     #the code works on its own, but if you only want it to operate with the button's actions rather than live, then you need a diff reactive function
    origin_longitude <- input$NumericInput_OLong
    origin_latitude <- input$NumericInput_OLat
    origin_range <- input$NumericInput_OBuffer
    if (input$save_destination == 0 ) {
      leafletProxy(mapId = "firstleaflet") %>%  #leaflet marker making
        leaflet::addCircles(input$NumericInput_OLong, input$NumericInput_OLat, radius = input$NumericInput_OBuffer, color = 'green', opacity = 2, weight = 2) %>% #origin buffer, if you want it to stay live
        leaflet::fitBounds(input$NumericInput_OLong, input$NumericInput_OLat, 0, 0)
    } else {
      leafletProxy(mapId = "firstleaflet") %>%  #leaflet marker making
        #  leaflet::addCircles(origin_longitude, origin_longitude, radius = origin_range, color = 'green', opacity = 2, weight = 2)
        leaflet::addCircles(input$NumericInput_OLong, input$NumericInput_OLat, radius = input$NumericInput_OBuffer, color = 'green', opacity = 2, weight = 2) %>% #origin buffer, if you want it to stay live
        leaflet::fitBounds(input$NumericInput_OLong, input$NumericInput_OLat, input$NumericInput_DLong, input$NumericInput_DLat)
    }
    #  leaflet::addCircles(origin_longitude, origin_longitude, radius = origin_range, color = 'green', opacity = 2, weight = 2) 
      #would write here the action that gets coughed alive from the button (could generate a leaflet, but it isn't the same as an update submit button)    
  })
  
  
  ##destination button (button currently doesn't exist yet in the ui file)
  observeEvent(input$save_destination, {     #the code works on its own, but if you only want it to operate with the button's actions rather than live, then you need a diff reactive function
    dest_longitude <- input$NumericInput_DLong
    dest_latitude <- input$NumericInput_DLat
    dest_range <- input$NumericInput_DBuffer
    
    if (input$save_origin == 0 ) {
      leafletProxy(mapId = "firstleaflet") %>%  #leaflet marker making
        leaflet::addCircles(input$NumericInput_DLong, input$NumericInput_DLat, radius = input$NumericInput_DBuffer, color = 'red') %>% #destination buffer, if you want it to stay live
        leaflet::fitBounds(input$NumericInput_DLong, input$NumericInput_DLat, 0, 0)
    } else {
      leafletProxy(mapId = "firstleaflet") %>%  #leaflet marker making
        #  leaflet::addCircles(origin_longitude, origin_longitude, radius = origin_range, color = 'green', opacity = 2, weight = 2)
        leaflet::addCircles(input$NumericInput_DLong, input$NumericInput_DLat, radius = input$NumericInput_DBuffer, color = 'red') %>% #destination buffer, if you want it to stay live
        leaflet::fitBounds(input$NumericInput_OLong, input$NumericInput_OLat, input$NumericInput_DLong, input$NumericInput_DLat)
    }
     #would write here the action that gets coughed alive from the button (could generate a leaflet, but it isn't the same as an update submit button)    
  })   #you'll want to update it so that the map extent includes the buffer size (not just the point/line/polygon they use)
  
  
  ##map click outputs (if needed for re-display, don't need to re-calculate though)
  #--input taken from mouse interaction with leaflet map, turned into an output
  #this one gives nothing when no click, and then coordinates from the click
  observeEvent(input$firstleaflet_click, {    
    clickedcoords <- unlist(input$firstleaflet_click) %>%   #to sort the returned data into a usable selection later, means using unlist() function for the returned values to appear as a horizontal vector rather than vertical list
      data.frame() #then piped it into a dataframe so that you can select specific parts of it later where you want
    output$prompt_click_map <- renderPrint( cat("") )
    output$clickedLong <- renderPrint(cat(clickedcoords[2,1])) #returns the longitude of where user clicked on leaflet  #note that you made up the output name clickedLong here, doesn't exist otherwise  #used the cat() function to get record of the ID indicator that print creates
    output$clickedLat <- renderPrint(cat(clickedcoords[1,1])) #returns the latitude of where user clicked on leaflet   #note that you made up the output name clickedLat here, doesn't exist otherwise #used the cat() function to get record of the ID indicator that print creates
    output$messagemapclick1Long <- renderPrint( cat("Clicked Long:") )  #and then once the map is clicked you have it set in server to remove this message
    output$messagemapclick1Lat <- renderPrint( cat("Clicked Lat:") )  #and then once the map is clicked you have it set in server to remove this message
  })
  
  
  ##user location variables (three parts)
  #--user location request values   #they got sourced from tags$script in the ui file
  output$userLat <- renderPrint({ cat(input$userLat) })
  output$userLong <- renderPrint({ cat(input$userLong) })
  output$geolocation <- renderPrint({ input$geolocation })
  
  
}
