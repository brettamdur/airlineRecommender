
# File:			ui.R
#	Author:		Brett Amdur
#	Project:	Airline Recommender
# Notes:		This file contains virtually no comments.  Its purpose is to provide
#						the UI for the Shiny app developed for this project.  The only logic 
#						it contains is that associated with Shiny development.  For business
#						logic that was applied on this project, see the file titled 
#						helpers.R.


require(shinythemes)
require(dplyr)
require(ggplot2)
require(reshape2)
library(shinyjs)
library(shinyBS)
library(shiny)
source('./helpers.R')
source('./verbiage.R')


# allFlights <- read.csv('../data/AirlineDataSepOctNov2012v3.csv', stringsAsFactors = FALSE)
load('.RData')

airports <- c('None', 
							unique(allFlights$Origin)[order(unique(allFlights$Origin))])
metroAreas <- c('None', 
								unique(allFlights$OriginCityMarket)[order(unique(allFlights$OriginCityMarket))])

shinyUI(
	fluidPage(
		tags$head(
			tags$style(HTML("
												hr{
													border-width: 5px;
													border-color: darkgrey;
												}
												#pageHeader {
														color: blue;
														font-size: 1.5em;
												}
										")
									)
		),
		useShinyjs(),
		titlePanel("Airline Recommendation System"),
		theme = shinytheme('flatly'),
		
		fluidRow(
			column(
				3, 
				h2("Preferences"),
				wellPanel(
					"Select Preferred Origin",
					br(),
					'(select one origin:):',
					radioButtons("originType", label = NULL, choices = c('Airport Code', 'Metro Area'), 
											 selected = 'Airport Code', inline = FALSE, width = NULL),
					div(id = "originCodeToggler",
							selectInput("originPref", label = NULL, choices = airports,
													multiple = FALSE, selected = 'None'
							)
					),
					div(id = 'originMetroToggler',
							selectInput("originMetroAreaPrefs", label = NULL, choices = metroAreas,
													multiple = FALSE, selected = 'None'
							)
					)
				),
				wellPanel(			
					'Select Preferred Destinations',
					br(),
					'(multiple selections permitted):',					
					radioButtons("destinationType", label = NULL, choices = c('Airport Code', 'Metro Area'), 
											 selected = 'Airport Code', inline = FALSE, width = NULL),
					div(id = "destinationCodeToggler",
							selectInput("destinationPrefs", label = NULL, choices = airports,
													multiple = TRUE, selected = 'None'
							)
					),
					div(id = 'destinationMetroToggler',
							selectInput("destinationMetroAreaPrefs", label = NULL, choices = metroAreas,
													multiple = TRUE, selected = 'None'
							)
					)
				),
				actionButton("goButton", "Get Recommendation")
			), # end column 1.1
			
			column(
				8, 
# 				conditionalPanel("input.goButton == 0",
# 					br(),br(),br(),br(),
# 					h3('Welcome'),
# 					'
# 					Welcome to the Airline Recommendation System. This system will recommend an 
# 					airline carrier based on your preferred point of origin and preferred 
# 					destinations.  Please make your selections in the Preferences section 
# 					on the left.
# 					'
# 				),
# 				conditionalPanel("! input.goButton == 0",
					tabsetPanel(type = "tabs", 
						tabPanel(h4("Results"),
										 
										 conditionalPanel("input.goButton == 0",
										 								 br(),br(),br(),br(),
										 								 h3('Welcome'),
										 								 '
										 								 Welcome to the Airline Recommendation System. This system will recommend an 
										 								 airline carrier based on your preferred point of origin and preferred 
										 								 destinations.  Please make your selections in the Preferences section 
										 								 on the left.
										 								 '
										 ),
										 conditionalPanel("! input.goButton == 0",
										 
										 
										 htmlOutput('pageHeader'),
										 h3('Overall Carrier Rankings'),
										 'Hover over table for explanation.',
										 tableOutput('scoreTable'),
										 bsPopover("scoreTable","Overall Carrier Rankings", 
										 					content = overallVerbiage,
										 					placement = 'left'
										 ),														 
										 br(),
										 hr(),
										 
										 h3('On-Time Arrival Analysis'),
										 'Click on charts for explanations.',
										 br(), br(),
										 plotOutput('delayPlot'),
										 bsPopover("delayPlot","Scoring Category #1: Delay Per Flight",
										 					content = delayPlotVerbiage,				
															placement = 'left',
															trigger = 'click'
										 ),
										 					
										 br(),
										 br(),
										 plotOutput('cancellationPlot'),
										 bsPopover('cancellationPlot', 'Scoring Category #2: Percentage of Flights Cancelled',
										 		content = cancellationVerbiage,
										 		placement = 'left',
										 		trigger = 'click'
										 ),
										 br(),
										 hr(),
										 
										 h3('Destination Analysis'),
										 'For explanations, click on chart and hover over table.',
										 plotOutput('destinationFlightsPlot'),
										 bsPopover('destinationFlightsPlot', 
										 					'Scoring Category #3: Total Flights',
										 					content = totalFlightsVerbiage,
										 					placement = 'left',
										 					trigger = 'click'
										 ),														 
										 br(),
										 br(),
										 h4('Flight Counts for Destinations and Return Flights:'),
										 tableOutput('destinationCountTable'),
										 bsPopover('destinationCountTable', 
										 					'Scoring Category #4: Destination and Return Flights',
										 					content = destinationCountVerbiage,
										 					placement = 'left',
										 					trigger = 'hover'
										 )
									) # end conditionalPanel
						), 
						tabPanel(h4("Instructions"),
										 br(),br(),
										 '
										 For a production quality product, instructions for use, along
										 with an explanation of how to interpret the results, would be
										 included here.  These topics, along with more detail describing
										 approach to this project, are included in the "Background"
										 tab.
										 
										 '
						), 
						tabPanel(h4("Background"),
										 htmlOutput('backgroundMessage')
						)
					)# end tabSetPanel
				#)# end conditionalPanel
			) # end column 1.2
		) # end row 1
	) # end page
) # end shinyUI