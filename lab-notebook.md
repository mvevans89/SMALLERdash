# SMALLERdash lab notebook
## MV Evans

## 2022-11-07

Okay I think I have a module that works. Currently, just selects the historical but am working on getting it to select the spatial scale too

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