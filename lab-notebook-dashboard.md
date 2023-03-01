# SMALLERdash lab notebook
## MV Evans

## 2023-03-01

Working on making a nicer landing page. This will have little alert buttons + a map. I finished the buttons and cleaned up the rest of the app, but still need to make the map itself. It would be cool if when you clikced there was a little popup that showed the time series of something for that fokontany too. but that can come later.

**TO DO:**

- map on landing page
- download button for table data


## 2023-02-21

Got the community level thing up and running and refactored the plotly plot into a seperate function to hopefully make things easier to update all at once.

Now working on making the same thing for CSB level. I think I will put stockouts under this structure too. Got it working!!

**TO DO**

- make data downloadable
- maybe upload to better table format
- create landing page with map in the background
- move current home page to an about page


## 2023-02-20

For the landing page, I think I want some kind of overall map of the district, then a floating chart thing that shows overall incidence, % comared to last year, and prediction over next 3 months go up, stay same, go down.

I think I will just make new modules for this in case I break something from before. Okay, I made a  module for the community-level that shows a time series and data table for the fokontany. I may want to highlight the rows that are predictions, or maybe plot in descending order? Also, it would be nice to have some kind of title break between the plot and table but I can't super figure out how. Then I can just make the new community one from this template.

## 2023-02-01

Following getting some feedback from folks in Ranomafana, it is time to make some updates to the app. Here is a list of some to do (don't necessarily need all, some are just ideas):

- make landing page a map (like maybe predicted incidence over next 3 months), then could have htat floating chart that plots those values with historical ones if you click on a fokontany. Only thing is many people don't actually know where the fokontany are, so maybe a datatable and chart would be better?
- change the structure to be community vs CSB, then have incidence or cases within that
- make data downloadable
- make figures downloadable (ideally in a microsoft powerpoint editable format)
- need to set up automated workflow once the espace dev folks are done and new Pivot server has been bought. Probably moving over to gitlab too.
- some other important notes are in my notebook in Montpellier

## 2022-11-17

Got the table to work on the map of the incidence/case by fokontany. Also figured out why the time series was being annoyingly automatic.

I think I would like to add a table to the CSB map, maybe even color it by cases?

**TO DO**

- true prediction models that only use data from 2-3 months ahead of time [after Pivot presentation]
- models for each age group [after Pivot presentation]

## 2022-11-16

Met with PNLP to discuss dashboard. Generally, they were super into it. Their main want is how to scale it up to other districts, although that is mostly limited by the data.

Andres also had a good idea of structuring the site by level of the health system (fokontany, CSB/commune, district) rather by indicator, because this is more likely how people will use it. I think I agree, just deciding if I want to jump into that now like if I have time to do this before I present to Pivot. But honestly, yeah I think I do. Will just have to note where I am right now in case I mess it up.

Okay, I think the easiest is to just make brand-new modules, which hopefully won't take too long. Maybe I will see how long it takes to make one and then decide. Wait, okay for now instead of restructuring the whole thing. I will just change a button to where you can choose to plot cases or incidence of a fokontany/commune/etc. This isn't cases going to the CSB, but just rescaling the incidence by population of each spatial level. That's pretty easy to do.

First, I had to create the dataset of cases at these levels. I did this in the `save-data-to-repo.R` script. I then updated the module for the website. I feel like I have it working, but I wanted to make it only go when you click the "Allez" button, but am having some issues with it being overly reactive and changing each time. Gave up on having the button because I couldn't get it to work. [update. it is because I was feeding a reactive variable directly to a render function, if you define tha argument outside the function, this odesn't happen].

**TO DO**
- add table that goes next to map when a fokontany is selected (should I drop the click popup then?)
- add button to download data?

## 2022-11-14

Presented to the Teledetection team. Some feedback to take into account:

- recommend having the landing page be a map or something interactive so it is more engaging from the beginning
- add a table of data to the side of the map for people to interpret
- discussed how to automate it


**Model to do:**
- run true prediction models (i.e. only using data from 2-3 months prior) for dashboard
- run models on each age group individually for dashboard and combine
- may be worth looking into rainfall predictions from www.wmolc.org. they give probabilities of below/above normal for three months into the future for precipitation and temperature. very broad but could help for scenarios. [this is maybe a thing for future me like in a year for scenario planning]

## 2022-11-11

I did all the things! Set up a landing page and added information to each page in the form of markdown documents. 

Now want to explore some validation of the model to add. and to show to Pivot when I am there. done! honestly, I think this is all workign pretty well.

Pushed to github, but think this is a pretty good prototype for now.


## 2022-11-10

Some things I want to do to make the dashboard nicer:

1. landing page
2. information for each page on how it works
3. maybe update time series to dygraph or nicer timeseries plot. probably plotly would be better in the end for this, but it is almost too interactive and I'm worried will make people confused. but dygraphs was last updated in 2018.... okay better to use plotly 

got plotly up and running for the incience time series. will try to do the same for the cases just so it looks similar across pages. done!



## 2022-11-09

Okay, now that I have a workflow, things are going pretty quick. Made the cases time series module in about 90 minutes.

Took the rest of the morning to create the CSB case mapping module. It could be nice to change the shape of those circleMarkers (if possible) to match the different CSB types.

I think the next couple of days I want to write up some nice language for the landing page and more instructions. plus look into using boxes and other dashboard structures to make the page themselves look nicer.

**TO DO:**
- ~~stockout module~~
- add map of relative risk (this is an extra I can do after everything is done)

**Model to do:**
- run true prediction models (i.e. only using data from 2-3 months prior) for dashboard
- run models on each age group individually for dashboard and combine
- may be worth looking into rainfall predictions from www.wmolc.org. they give probabilities of below/above normal for three months into the future for precipitation and temperature. very broad but could help for scenarios. [this is maybe a thing for future me like in a year for scenario planning]

## 2022-11-08

Havng issues with the reactive zoom workign within a modele. I'm pretty sure it is possible, but the problem is I have like two reactive modules working with it. A helpful SO post:

https://stackoverflow.com/questions/67167626/is-it-possible-to-pass-leaflet-map-to-another-module

I got it to move, but then the problem is it isn't highlightable via the proxy. At least not in an easy way.

ahh okay I have it to zoom now based on a "go" button. And then I think I can pretty easily make it just remap each time (but it will be slow).

Got the map working. I also added a button to reset the zooming but it doesn't work yet. This is an extra feature we can work on later.

I got the map module working in the full app!

**Next steps:**
- cases time series module
- cases map module
- stockout module
- add map of relative risk (this is an extra I can do after everything is done)

## 2022-11-07

Okay I think I have a module that works. Currently, just selects the historical but am working on getting it to select the spatial scale too. I got this working too, was a bit of a pain to get the selection of the fokontany. Hope is that now it should be fairly simple to modify this for the next plot.

## 2022-11-04

Today, I want to start putting the skeleton of the app together. Here are some that look nice whose code I could use:

https://github.com/ceefluz/radar/blob/master/ui.R

https://github.com/eparker12/nCoV_tracker

Okay, I think I will make te sidebar select between 'Incidence', 'Cases', and 'Stockout Information'. Then within each one, I can use tabs or different moving boxes to plot the different stuff. (or just have it all on on page). this matches how the main Pivot dashboard works and also mauricianot's thing. Here is a nice example of that:

https://github.com/abenedetti/bioNPS/blob/master/code/ui.R

Basically just `shinydashboard`. there is also something called shinydashboardplus?


I've also set up `renv` to work within this project to help with reproducibility for when we (hopefully) get it running within a docker on the cloud or something. done.

Okay some goals to keep things moving are:

1. create a module for a function (this could really be for each visualization)
2. base dashboard structure (use shiny dashboad)


## 2022-11-03

### CSB stockout time series

Making the third time seris that tries to show the predicted cases at the level of the CSB while also showing CSB rates. One problem is that truly there were a ton of cases in 2021 that weren't really expected by the system so our predictions look super crazy. So one thing that may be good to do is show how this compares to what truly happened. That data is in the stockout data from 2021. Oh but for some reason we don't have any data on the number of positive tests from this stockout data :(, so it makes it look like all the cases were treated. I could calculate this from the raw data I got from Felana? or maybe just showing that truly there were a lot of cases in 2021 works. Also everyone knows that is actually the case.

**Note**: It may be worth it to just model the unadjusted data if what we want is who will actually arrive at the CSBs, unless we expect it to be changing a lot over time in a way that isn't fit by our temporal trends in the model. We get pretty strong agreement with our backscaling but we in general underpredict for within Pivot and over-predict outside. This is due to our zero imputation, which we can't really do *backwards*

### Proportion seen in PIVOT supported fokontany

The last time-series type figure I wanted to make was one that shows the proportion of children with malaria seen at CSBs vs. CHWs vs. not seen. The idea being this could help PIVOT teams figure out which programs are needed where. But I realized I hadn't made a model for under-5 kids yet. Perhaps a next step would then be to make a model for each age group and save those results? Oh, but wait, we wouldn't even have this data for hte future so it probably doesn't even make sense to make as a figure right now. okay dropping this figure for now

### Map of incidence by fokontany

I basically made two maps for this, one that is raw incidence and one that is like incidence relative to the year prior to help people understand and place it in context

### Map of cases by CSB (commune)

Then the idea is to make a map of cases by CSB. One problem is the CSB maps to a point and not a polygon. So I was thinking of using the commune. Or I could use the catchments of each CSB? Worried this will be a bit confusing though because actually I am estimating cases based on the CSB's that people go to. Maybe I will plot the raw cases by fokontany in like a very light alpha and then I can add the CSBs and a popup for each one. And also maybe make the size dependent on the number of cases? Yup this makes sense, may be a *bit* confusing, but we'll see. I can always drop the fokontany background

Have not done this yet

**TO DO:**
- create code for map of cases by CSB (commune)
- start putting figures into shiny dashboard [go one at a time, try a module]

**Model to do:**
- run true prediction models (i.e. only using data from 2-3 months prior) for dashboard
- run models on each age group individually for dashboard and combine
- may be worth looking into rainfall predictions from www.wmolc.org. they give probabilities of below/above normal for three months into the future for precipitation and temperature. very broad but could help for scenarios.

## 2022-11-02

Working on the visualization of time series of cases. For this, I need to back-calculate from incidence to cases. First, I want to pair fokontany with CSBS Rather than just assigning one to each, I am using the actual percentages based on consultations from 2018-2019.

Okay, I have a good back-calculation workflow going. I checked it with multiple other data sources, including the DHIS fever-seeking data and it seems to work well. This allows us to estimate the number of malaria cases each CSB should expect.

I've also got the plots working for this and it's kind of cool ( I think). I think people will be into being able to predict the cases at CSBs. One thing that may be helpful to convince people it is good is to compare it to the actual data to show how well it works. Obviously that wouldn't be possible all the time but could be another thing we make just for Pivot.

Next is taking this CSB level data and creating a plot of stockouts for ACTs. I am imagining something that has likea bar chart of the prior year showing the total malaria cases that were expected and the number who received ACTs, then next to it would be a bar for this year. If it showed all the CSBs then it could help compare how to reallocate the meds.

**TO DO**

- ~~create data for time series of cases (back-calculated using HCUI, this may be kind of complicated) at CSB~~
- ~~visualization of time seris of cases at CSB and district level~~
- time series of stockout data (cases at CSBS, proportion tested, proportion treated) [how to predict?]
- time series by fokontony to show the prop. cases being missed
- then all the map ones

## 2022-10-31

Getting things put together so I can show it to Pivot and MMoPH folks next month.

I have sketched everything out and started collecting all of the data.

One thing I realized is I had only run the model for the under-5 or maybe all ages so far? I will want to do this for each group seperately. For now, i'm not messing with it so I can focus on the visualization, but I will need to do it this week. One kind of interesting question is whether we should model each age class seperately and sum to get all ages or model all ages on its own.

Also, do we want to show the true data to give an idea of how well it is performing? Or will this be too confusing? For now, not doing this. Could add a button that makes that appear though.

We will want to have all the data downloadable like for each separate module.

**TO DO**

- create data for time series of cases (back-calculated using HCUI, this may be kind of complicated) at CSB
- visualization of time seris of cases at CSB and district level
- time series of stockout data (cases at CSBS, proportion tested, proportion treated) [how to predict?]
- time series by fokontony to show the prop. cases being missed
- then all the map ones