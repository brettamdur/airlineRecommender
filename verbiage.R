
backgroundVerbiage <- 
'
<h2>Introduction</h2>
This Shiny application represents my work on a data exercise that had once been used by an organization in connection with candidate screening. The employer no longer uses this exercise for candidate screening, and has released it for public use.  The assignment involved a data set consisting of flight information for selected US domestic flights (approximately 1.5M flights) that occurred during a three month period from 9/1/12 to 11/30/12.  The criteria for inclusion in this dataset was unstated, but it consists of flights from 14 major airlines. The organization, when using this as a data exercise, asked candidates for an analysis, based on this flight data, of which airline the organization should choose as its preferred carrier.

<h2> User Preferences and Filtering</h2>
It became apparent very early in my analysis that a recommendation for the organization would be most effective if it focused on the travel destinations that are important to the firm.  I would use those recommendations, of course, to filter the data to flights to and from the organization\'s preferred point of origin and preferred destinations.  Because I needed to filter the data anyway, it occurred to me that it would not be hard to write a small Shiny app that included interactive capabilities to allow the user to specify the filtering criteria.  Interactive capability would allow the organization to customize its preferences, for example, to the flying habits of individual members of the firm, or to reassess its preferred carrier as travel priorities change over time.<br><br>

The app allows users to specify one preferred point of origin and multiple preferred destinations.  For both origins and destinations, the user can choose to specify either a particular airport, or a metropolitan area.  I thought this seemed consistent with the way most people travel: we typically have one point of origin, with several destinations that we fly to most frequently.  Users can set the destination to "None", which means that no particular destination is preferred.<br><br>

Once the user enters preferences, the system filters the data to include only those flights from the origin to the destinations and from the destinations to the origin.  The system performs its analysis of the preferred carrier only on the filtered data, that is, only on flights to and from the user\'s preferred origin/destination.

<h2> Criteria for Assessing Carrier Performance </h2>
The assignment instructions make it clear that the analysis was for a lay audience, so I wanted to use a scoring methodology that was easy to understand.  Accordingly, I chose four criteria that are fairly straightforward.  The four criteria fall under two categories as follows:<br><br>
<ol>
	<li>
		On-Time Performance<br><br>
			<ul>
					<li>
						Carrier Delay Per Flight:<br>
						This is the sum of all delay attributable to the carrier, divided by the number of the carrier\'s flights.  To discern the delay attributable to the carrier, I added two numbers.  First, the data contained a field for delay attributable to the carrier, which obviously was part of the calculation.  Second, the data also included a field to indicate delays for a flight that were attributable to an earlier flight delay on the aircraft, causing a delayed departure for the flight in question.  How much of this "late arrival delay" was caused by the carrier, versus other delay factors that the data described (the other delay factors included in the data were weather, "national airspace delay" -- meaning things out of the carrier\'s control like air traffic control and general airport operations, and security.  See http://aspmhelp.faa.gov/index.php/Types_of_Delay for more info.).  To answer this question, I used the data set to calculate the percentage of all delay, other than late arrival delay, attributable to carrier delay.  I then assumed that the same percentage of "late arrival delay" was attributable to carrier delay.  The amount of late arrival delay I attributed to the carrier is shown on the On-Time Arrival Analysis plot as "LADCarrier". To arrive at total delay attributable to a carrier, I added the delay directly identified in the data as carrier delay and the derived "LADCarrier" number.  Other reasons for delay (weather, NAS, security) were not included in the analysis.<br><br>
					</li>
					<li>
						Cancellation Rate:<br>
						This is the percentage of a carrier\'s flights that were cancelled.  It is possible that many cancellations are outside of a carrier\'s control, but, without any criteria for allocating cancellation causes to carrier and non-carrier sources, I thought it best to include all cancellations as part of the analysis.  Additional research into cancellation causes may be helpful.<br><br>
					</li>
			</ul>
	</li>
	<li>
		Destination Options<br><br>
			<ul>
				<li>
					Total Flights:<br>
					This is the total number of flights from the point of origin to all the destinations, and from the destinations to the point of origin.  It is not controversial to suggest that more flight options to preferred locations is desirable for most travelers.<br><br>
				</li>intimitely 
				<li>
					Preferred Destinations Serviced by Carrier:<br>
					This is the number of the user\'s preferred destinations that the carrier services.  Of course, if the user chooses only one destination than this criteria has no impact on the score.
				</li>
			</ul>
	</li>
</ol>

<h2> Scoring Methodology </h2>
With the performance criteria established, the next question was how to use the criteria to rank the carriers.  While there are many different approaches that would accomplish this task, I elected to use a very simple one: z-scores.  Specifically, for each of the four criteria, I assigned each carrier a score representing the number of standard deviations the score was from the criteria\'s mean score for the filtered flights.  I then added the z-scores for each carrier across each of the four criteria, to arrive at a "Total Score".  I stack ranked the carriers according to their total score, so that the recommended carrier is the carrier with the highest total score. This accomplished several necessary objectives:<br><br>  
	<ul>
		<li> It transformed the scores on the four criteria so that they could be compared against each other on the same scale.<br><br></li>
		<li> It differentiated the carriers in meaningful ways.  With this approach, criteria for which all carriers had similar scores would have minimal impact on total score, since the distribution for that criteria would have low dispersion hence all z-scores would be low.   Conversely, criteria for which the carriers had more widely divergent scores would have a greater impact on total score, which of course is a desirable result.<br><br></li>
		<li>It is simple and straightforward.  While most lay people may not be intimately familiar with z-scores or standard deviations, they intuitively understand that criteria where there isn\'t much difference between the carriers should count less toward total score than criteria where the differences are large.</li>
	</ul>

<h2> Possible Enhancements </h2>
<ul>
	<li>Allow user to filter on time and day (day of week) of flights<br><br></li>
	<li>This analysis evaluates only direct flights.  Further analysis could include flights to destinations that include connections.<br><br></li>
	<li>The system could easily weight the performance criteria based on user preference.  This could be done by an addition to the interface that would ask the user to rate the importance of each criteria on a scale from "Completely Irrelevant" to "Extremely Important."<br><br></li>
	<li>The system could include in its analysis an assessment of non-preferred flights, giving them lower weight in the total score.  This would be based on the assumption that while users have preferred locations to which they fly, many users often fly to other locations.  Performance with respect to those other locations may not be irrelevant to someone\'s selection of a carrier.<br><br></li>
	<li>The scoring methodology used here does not incorporate tests for statistical significance. This was by design, to keep the approach simple for a lay person.  Nonetheless, more sophisticated significance assessment may be helpful to allow users to better understand differences in scores that are meaningful versus those that are more likely to be attributable to chance.<br><br></li>
</ul>

<h2> Other Notes </h2>
<ul>
	<li>This analysis is based on only three months of data that is more than three years old.  Obviously, a more robust assessment would be based on more data that is more recent.  Per the assignment instructions, however, I did not make any attempts to update the data.  Accordingly, this data may not be applicable to current conditions.  One fairly obvious example: USAir and American Airlines merged after the time period covered by this data.<br><br></li>
	<li>Evaluation of an airline could certainly include criteria not included in the dataset.  Factors commonly considered would include cleanliness, reservation processes, baggage handling, friendliness of staff, and many others.  Indeed, there is much literature on the subject.  See e.g. http://commons.erau.edu/cgi/viewcontent.cgi?article=1025&context=aqrr for the 2015 Airline Quality Rating published by a private organization.  Per assignment instructions, I did not expand my efforts to include criteria not included in the data set.<br><br></li>
	<li>This Shiny app is not production quality, in the sense that it is not of sufficient quality to present, for example, to clients.  I offer this small app not as an example of a product that I would build for clients (without some further enhancements), but rather as an example of an assessment tool.<br><br></li>  
	<li>I note also that in a "real world" environment, I certainly would have checked with the client before building a tool like this, to see if the tool comports with client expectations.  

</ul>
'
overallVerbiage <- 
	paste(
		'This table shows carrier scores for each of the',
		'four ranking criteria. The scores in each category', 
		'represent the standard deviation of a carrier&#39s',
		'performance from the average of all scores in that',
		'category.  The Total Score column shows the',
		'sum of all the standard deviations for a carrier',
		'across the four categories. The recommended',
		'carrier is the one with the highest total score.',
		'See the Instructions tab for more detail.'
	)

delayPlotVerbiage <- 
	paste(
		'This chart breaks down flight delays by',
		'their causes. Only two of these causes contribute to',
		'a carrier&#39s delay score: Carrier Delay and Late',
		'AircraftDelay, which added together make up Total Carrier',
		'Delay. The other delay causes shown in this chart are not',
		'attributable to the carrier, and are therefore not',
		'included in the carrier performance analysis.'
	)

cancellationVerbiage <- 
	paste(
		'This plot shows the percentage of each carrier&#39s flights that were cancelled', 
		'for flights from the specified origin to the specified destinations.'
	)

totalFlightsVerbiage <- 
	paste(
		'This plot shows the total number of flights that each carrier', 
		'offers for the specified preferred destinations, plus return flights',
		'from each destination to the origin.'
	)

destinationCountVerbiage <-
		paste(
			'This table shows the number of flights from the origin to each preferrred',
			'destination, and the number of return flights from each destination back',
			'to the origin.  Note that the fourth scoring category is simply the number',
			'of preferred destinations serviced by the carrier.  The third scoring category',
			'is the total number of flights to and from the origin.'
		)