# File:			helpers.R
#	Author:		Brett Amdur
#	Project:	Airline Recommender
# Notes:		This file contains the logic and processing rules associated with 
#						the airline flight recommendations that are the foundation 
#						of this project.

require(dplyr)
require(ggplot2)
require(reshape2)

# getAnalysisComponents takes as input the user preferences and the unfiltered
# flight data.  It filters the flight data based on the user preferences, and 
# then performs calculations associated with four criteria: flight delays, flight
# cancellations, flight volume, and number of user destinations serviced.  It
# returns a list of objects (tables and plots) related to these four criteria.

getAnalysisComponents <- function(input, allFlights){
	originAirport <- input$originPref
	destinationAirports <- input$destinationPrefs
	originMetroArea = input$originMetroAreaPrefs # scalar; either this or origin MUST be passed in
	destinationMetroAreas = input$destinationMetroAreaPrefs # vector; either this or destination MAY be passed in
	preferredDays = NULL        # vector; optional -- not yet implemented
	preferredTime = NULL        # vector; optional -- not yet implemented, 

	# return NULL if the function is called without at least one origin 
	if(
		(originAirport == 'None' & originMetroArea == 'None')
	){
		return(NULL)
	}
	
	##########################################################################
	#### FLIGHT FILTERING ####################################################
	##########################################################################
	
	
	# Subset to flight origin preferences -- includes flights from and flights to origin
	if(! originAirport == 'None'){
		subsettedFlights <- allFlights[allFlights$Origin == originAirport | 
																	 	allFlights$Dest == originAirport, ]
		originTitle <- originAirport 	# the __Title variables in this file 
																	# are used to create the pageTitle
																	# text at the top of the Results page.
	} else{
		subsettedFlights <- allFlights[allFlights$OriginCityMarket == originMetroArea | 
																	 	allFlights$Dest == originMetroArea, ]
		originTitle <- originMetroArea
	}
	
	# Subset to flight destination preferences
	# We've already subsetted to flights into and out of origin, so only need to 
	# futher subset to flights arriving at preferred destinations and outgoing flights 
	# from preferred destinations
	if(destinationAirports == 'None' &
		 destinationMetroAreas == 'None'){
				destinationTitle <- 'All Destinations' # Don't do any destination subsetting if 
																							 # user picked all destinations; just
																							 # set the destination title
	} else{
		if(! destinationAirports == 'None'){
			# If destination is airport(s), then subset to flights to that airport(s) from origin, and flights from that 
			# airport(s) to origin.  If destination is metro area(s), then subset to flights to that metro area(s) 
			# from origin, and from metro area(s) to origin.
			subsettedFlights <- subsettedFlights[subsettedFlights$Origin %in% destinationAirports |
																					 	subsettedFlights$Dest %in% destinationAirports, ]
			destinationTitle <- destinationAirports
		} else{
			subsettedFlights <- subsettedFlights[subsettedFlights$OriginCityMarket %in% destinationMetroAreas |
																					 	subsettedFlights$DestCityMarket %in% destinationMetroAreas, ]
			destinationTitle <- destinationMetroAreas			
		}	
		
	} # end of destination filtering
	
	# create title text to be used in plots:
	titleText <- paste('Origin:', originTitle, ' - Destination(s):', 
										 paste(destinationTitle, sep = ' ', collapse = ' '))
	
	##########################################################################
	#### FLIGHT DELAY ANALYSIS ###############################################
	##########################################################################
	delaySummary <- subsettedFlights %>% 
		group_by(Carrier) %>% 
		summarize(
			carrierDelayPerFlight = round(sum(CarrierDelay, na.rm = TRUE) / n(), 3),
			weatherDelayPerFlight = round(sum(WeatherDelay, na.rm = TRUE) / n(), 3),
			nasDelayPerFlight = round(sum(NASDelay, na.rm = TRUE) / n(), 3),
			securityDelayPerFlight = round(sum(SecurityDelay, na.rm = TRUE) / n(), 3),
			lateAircraftDelayPerFlight = round(sum(LateAircraftDelay, na.rm = TRUE) / n(), 3)
		) %>%
		arrange(Carrier)
	delaySummary$Carrier <- as.factor(delaySummary$Carrier)
	
	# Need a way to account for lateAircraftDelay attributable to carrier without double counting.
	# Approach here is to calculate carrierDelay as a percentage of all non-lateAircraftDelay, and 
	# assume that's the percentage of lateAircraftDelay attributateable to carrier.
	
	# calculate percentage of all non-lateAircraft delay attributable to carrier delay,
	# and add it to original carrier delay to get total carrier delay:
	allDelays <- allFlights[ , c("CarrierDelay", "WeatherDelay", "NASDelay", "SecurityDelay")]
	delaysByCause <- apply(allDelays, 2, function(x) sum(x, na.rm = TRUE))
	carrierDelayPercentage <- delaysByCause['CarrierDelay'] / sum(delaysByCause)
	delaySummary <- mutate(delaySummary, 
												 LADCarrier = lateAircraftDelayPerFlight * carrierDelayPercentage,
												 totalCarrierDelay = carrierDelayPerFlight + lateAircraftDelayPerFlight)
	
	
	# plot of delay categories by carrier
	delaySummaryMelted <- melt(delaySummary, id.vars = 'Carrier', variable.name = "Cause", value.name = 'Minutes')
	levels(delaySummaryMelted$Cause) <- c('Carrier Delay', 'Weather Delay', 
																				'NAS Delay', 'Security Delay', 
																				'Late Aircraft Delay', 'LAD-Carrier', 'Total Delay')
	delayPlot <- ggplot(delaySummaryMelted, 
									aes(Cause, Minutes, group = Carrier, 
											color = Carrier, shape = Carrier)) +
									geom_line(size=2) +
									geom_point(size=4) +
									theme_classic() +
									ggtitle(paste('Average Delay Per Flight by Carrier:\n', 
																	titleText)) +
									theme(axis.text.x = element_text(angle=45, hjust=1, size=12),
												axis.title = element_text(size=12, face="bold")
									)
	
	
	##########################################################################
	#### FLIGHT CANCELLATION ANALYSIS ########################################
	##########################################################################
	
	cancellationSummary <-  subsettedFlights %>% 
		group_by(Carrier) %>% 
		summarize(totalFlights = n(),
							carrierCancelled = sum(CancellationCode == 'Carrier'),
							cancellationRate = carrierCancelled / totalFlights
		)
	
	cancellationPlot <-  ggplot(cancellationSummary, aes(Carrier, cancellationRate * 100)) +
		geom_bar(stat = 'identity', fill = 'lightblue') +
		theme_classic() +
		ggtitle(paste('Percentage of Flights Cancelled:\n', 
									titleText)) +
		theme(axis.text.x = element_text(angle=45, hjust=1, size=12),
					axis.title = element_text(size=12, face="bold")
		)
	
	##########################################################################
	#### DESTINATION ANALYSIS ################################################
	##########################################################################
	destinationSummary <- subsettedFlights %>% 
		group_by(Carrier) %>% 
		summarize(totalFlights = n(),
							destinationCount = n_distinct(Dest) - 1) 	# subtracting 1 because origin
																												# would otherwise be included
	
	destinationFlightsPlot <-  ggplot(destinationSummary, aes(Carrier, totalFlights)) +
		geom_bar(stat = 'identity', fill = 'lightblue') +
		theme_classic() +
		ggtitle(paste('Total Flights:\n', titleText)) +
		theme(axis.text.x = element_text(angle=45, hjust=1, size=12),
					axis.title = element_text(size=12, face="bold")
		)			

	destinationCountTable <-  subsettedFlights %>%
														group_by(Carrier, Dest) %>%
														select(Carrier, Dest) %>%
														summarise(Flights = n()) %>%
														arrange(desc(Carrier)) # %>%
														#filter(! Dest == originAirport)

	##########################################################################
	#### TOTAL SCORE CALCULATION #############################################
	##########################################################################
	
	# Take scores from four criteria (delay, cancellation, total flights, and total destinations),
	# standardize them on z scores, and rank carriers on sum of z scores.
	
	scoreSummary <- data.frame(
		carrier = destinationSummary$Carrier,
		delayScore = - scale(delaySummary$totalCarrierDelay), 
		cancellationScore = - scale(cancellationSummary$cancellationRate),
		destinationFlightScore = scale(destinationSummary$totalFlights),
		destinationCountScore = scale(destinationSummary$destinationCount)
	)
	scoreSummary$destinationCountScore[is.nan(scoreSummary$destinationCountScore)] = 0
	scoreSummary$totalScore <- apply(scoreSummary[, 2:ncol(scoreSummary)], 
																	 MARGIN = 1, sum, na.rm	= TRUE)
	scoreSummary <- arrange(scoreSummary, desc(totalScore))	
	names(scoreSummary) <- c('Carrier', 'Delays', 
													 'Cancellations', 'Flight Volume', 
													 'Destinations Served', 'Total Score')
	
	##########################################################################
	#### BUILD RETURN OBJECT  ################################################
	##########################################################################

	return(list(scoreSummary = scoreSummary, 
							delayPlot = delayPlot,
				 			cancellationPlot = cancellationPlot,
							destinationFlightsPlot = destinationFlightsPlot,
							destinationCountTable = destinationCountTable,
							originTitle = originTitle,
							destinationTitle = destinationTitle
							)
					)
}