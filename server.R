
# File:			server.R
#	Author:		Brett Amdur
#	Project:	Airline Recommender
# Notes:		This file contains virtually no comments.  Its purpose is to provide
#						the server side code for the Shiny app developed for this project.  
#						The only logic it contains is that associated with Shiny development.  
#						For business logic that was applied on this project, see the file titled 
#						helpers.R.

library(dplyr)
library(ggplot2)
library(reshape2)
library(shiny)
library(shinyjs)
library(shinyBS)
library(DT)
source('./helpers.R')
source('./verbiage.R')

load('.RData')

shinyServer(
	function(input, output, session) {
		
		observeEvent(input$originType, {
			if(input$originType == 'Airport Code'){
				show("originCodeToggler")
				hide("originMetroToggler")
				reset('originMetroToggler')
			} else{
				hide("originCodeToggler")
				show("originMetroToggler")
				reset('originCodeToggler')
			}
			
		})
		
		observeEvent(input$destinationType, {
			if(input$destinationType == 'Airport Code'){
				show("destinationCodeToggler")
				hide("destinationMetroToggler")
				reset('destinationMetroToggler')
				# hide('test')
			} else{
				hide("destinationCodeToggler")
				show("destinationMetroToggler")
				reset('destinationCodeToggler')
				# show('test')
			}
			
		})
		
		getFlightAnalysis <- eventReactive(input$goButton, {
			flightAnalysis <- getAnalysisComponents(input, allFlights)
		})

		# output$scoreTable <- renderDataTable({ # not using datatable bcse not
																						 # rendering properly when hosted
																						 # on shinyapps.io
		output$scoreTable <- renderTable({
			validate( # need to figure out how to put this into a function to avoid repeating
								# this validate block in each render section
				need(! input$destinationPrefs == "" | ! input$destinationMetroAreaPrefs == "",
						 "Please select an origin and destination")
			)
			flightAnalysis <- getFlightAnalysis()
			scores <- flightAnalysis$scoreSummary
			#DT::datatable(scores, options=list(paging = FALSE))
			#datatable(scores, options=list(paging = FALSE))
		})
		
		output$delayPlot <- renderPlot({
			validate(
				need(! input$destinationPrefs == "" | ! input$destinationMetroAreaPrefs == "",
						 "Please select an origin and destination")
			)				
			flightAnalysis <- getFlightAnalysis()
			return(flightAnalysis$delayPlot)
		})
		
		output$cancellationPlot <- renderPlot({
			validate(
				need(! input$destinationPrefs == "" | ! input$destinationMetroAreaPrefs == "",
						 "")
			)				
			flightAnalysis <- getFlightAnalysis()
			return(flightAnalysis$cancellationPlot)
		})
		
		output$destinationFlightsPlot <- renderPlot({
			validate(
				need(! input$destinationPrefs == "" | ! input$destinationMetroAreaPrefs == "",
						 "Please select an origin and destination")
			)				
			flightAnalysis <- getFlightAnalysis()
			return(flightAnalysis$destinationFlightsPlot)
		})
		
		# output$destinationCountTable <- renderDataTable({
		output$destinationCountTable <- renderTable({
			validate(
				need(! input$destinationPrefs == "" | ! input$destinationMetroAreaPrefs == "",
						 "Please select an origin and destination")
			)				
			flightAnalysis <- getFlightAnalysis()
			destCountTableData <- flightAnalysis$destinationCountTable
			#DT::datatable(destCountTableData, options=list(paging = FALSE))
			#datatable(destCountTableData, options=list(paging = FALSE))
		})
		
		output$pageHeader <- renderText({
			validate(
				need(! input$destinationPrefs == "" | ! input$destinationMetroAreaPrefs == "",
						 "Please select an origin and destination")
			)				
			flightAnalysis <- getFlightAnalysis()
			pageHeaderText <- paste('Origin:', flightAnalysis$originTitle,
																'<br>', 
															'Destination(s):', paste(flightAnalysis$destinationTitle,
																											 sep = '  ', collapse = '  ')
			)
		})
		
		output$backgroundMessage <- renderText({
			return(backgroundVerbiage)
		})
		
		output$pageTitle <- renderText({
			
		})
	}
)