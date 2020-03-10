# ui.r

ui <- fluidPage(


sidebarLayout(
  titlePanel("COVID-19 Epi Curves"),
  tabsetPanel(
    # back ground ####
    tabPanel("Background and notes", fluid = TRUE, 
             sidebarLayout(
               sidebarPanel(width = 2,
                 p("Created by Simon Thelwall"),
                 p("Code available at")
               ), 
               mainPanel(
                 h1("Introduction"),
                 p("On 31-12-2019 a novel cluster of pneumonia was reported in China. In the following weeks, this outbreak spread rapidly and has been transmitted worldwide."),
                 p("There are numerous dashboards available on the web, but none of them quite displayed the information in which I was interested. This webtool displays counts of cases and deaths occurring on a daily basis, rather than cumulative counts. This allows the reader to see how rapidly cases are spreading within each individual country."), 
                 p("In addition, the webapp shows the calculated current count of cases for each country, rather than the cumulative count and shows the case fatality rate calculated for each country."),
                 h1("Data source"),
                 p("The web app uses data from the", a(href="https://github.com/CSSEGISandData/COVID-19", "2019 Novel Coronavirus COVID-19 (2019-nCoV) Data Repository by Johns Hopkins CSSE")),
                 h1("Data caveats"), 
                 p("There are a number of caveats to be aware of."),
                 p("On 06-02-2020 Japan reported 45 cases. The following day, these cases were removed. These data have been manually altered to account for the reporting error"), 
                 p("Data are updated from the source every 12 hours, The source data is updated every 15 minutes. The date and time of the last update was"),
                 # , reactive_data()$time_last_update), 
                 p("It is not clear how movement of people is accounted for. For example, a person may be diagnosed in one country and repatriated to their country of residence. How this is reflected in the counts of cases in the source data is not described."),
                 h3("Counts of cases"),
                 p("Counts of cases are calculated by taking the daily cumulative count of cases, and subtracting the previous days count. The same approach has been used to create the count of deaths."),
                 p("The count of current cases is calculated by taking the current cumulative count of cases and subtracting the cumulative count of cases and the cumulative count of deaths."),
                 h3("National case fatality rates"),
                 p("The case fatality rate is simply calculated as the cumulative count of deaths divided by the cumulative count of cases."), 
                 p("In most countries this is likely to be an overestimate, people with mild cases may not seek medical attention, and of those who do, not all will be tested, depending on local testing criteria. For some countries, this over estimate may be quite severe, where only the the very sickest seek medical care and are tested."), 
                 p("In other ways, case-fatality rates may be underestimated. The final outcome of the case is not known for many patients, and there will be some patients infected who have yet to die. This should be less of a problem as time passes and the count of cases for which the outcome is known exceeds the count of cases for which it is not. However, this will change for each country as the count of cases progresses through time."),
                 h1("Acknowledgements"), 
                 p("As a final note, I want to acknowledge all the hard work put in by clinicians and public health officials across the world. Clinicians are at high risk of infection by the nature of their work, and the work of public health officials often goes unnoticed. The fact that Johns Hopkins CSSE make their data openly available is appreciated.")
                 
               )
             )
    ), 
    # all countries ####
    tabPanel("All countries", fluid = TRUE, 
             sidebarLayout(
               sidebarPanel(width = 1
                 
               ), 
               mainPanel(
                 plotOutput("epicurve_all", width = "100%", height = "800px")
               )
             )
             ), 
    tabPanel("Single country", fluid = TRUE, 
             sidebarLayout(
               sidebarPanel(width = 2, 
                 selectInput("country_selector", 
                   label = "Select country", 
                   choices = country_selector,
                   # choices = unique(as.character(dat_long$country_region)), 
                   selected = "Mainland China"
                   ) 
                            ), 
               mainPanel(
                 plotlyOutput("epicurve_single", width = "100%", height = "800px")
               )
             )
             ),
    # current cases ####
    tabPanel("Current cases", fluid = TRUE, 
             sidebarLayout(
               sidebarPanel(width = 2, 
                 selectInput("country_selector_curr", 
                             label = "Select country", 
                             choices = country_selector,
                             # choices = unique(as.character(dat_long$country_region)), 
                             selected = "Mainland China"
                 ) 
               ),
               mainPanel(
                  plotlyOutput("currcases_single", width = "100%", height = "800px")
               )
             )
    ),
    # deaths by date ####
    tabPanel("Deaths by date", fluid = TRUE, 
             sidebarLayout(
               sidebarPanel(width = 2, 
                 selectInput("country_selector_death_date", 
                             label = "Select country", 
                             choices = country_selector,
                             # choices = unique(as.character(dat_death_long$country_region)), 
                             selected = "Mainland China"
                 ) 
               ),
               mainPanel(
                  plotlyOutput("deathcurve", width = "100%", height = "800px")
               )
             )
    ),
    tabPanel("Case fatality rates", fluid = TRUE, 
             sidebarLayout(
               sidebarPanel(width = 1
                  ),
               mainPanel(
                 plotlyOutput("cfr_plot", width = "100%", height = "800px")
               )
             )
    )
  )
  
)
)
