server <- function(input, output) {
  
  # output$dat_out <- renderPrint({
  #   head(dat_long)
  # })
  
# outouts #####  
  
  
  output$epicurve_all <- renderPlot({
    dat_long_t <- dat_long
    ggplot(dat_long_t, aes(x = date, y = on_cases))  + 
      theme_cowplot() +
      geom_bar(stat = "identity") +
      facet_wrap(~ country_region, scales = "free_y") +
      scale_y_continuous("Count of new cases", breaks = integer_breaks(), 
                         labels = scales::comma) + 
      scale_x_date("Date")
  })
  
  single_country_reactive_deaths <- reactive({ 
    dat_death_long <- dat_death_long %>% 
      filter(country_region == input$country_selector_death_date)
  })  
  
  output$deathcurve <- renderPlotly({
    single_country_deaths <- single_country_reactive_deaths()

    ggplotly(
      ggplot(data = single_country_deaths, aes(x = date, y = on_deaths)) +
        geom_bar(stat = "identity") +
        theme_cowplot() +
        scale_y_continuous("Count of deaths in a day", breaks = integer_breaks(),
                           labels = scales::comma) +
        scale_x_date("Date") + 
        labs(title = as.character(input$country_selector_death_date))
    )

  })


  # single country ####
  # For single country tab, filter data to single country.

  single_country_reactive <- reactive({ 
    dat_long <- dat_long %>% 
      filter(country_region == input$country_selector)
    })
  
  output$epicurve_single <- renderPlotly({
    single_country <- single_country_reactive()
    
    ggplotly(
      ggplot(data = single_country, aes(x = date, y = on_cases)) + 
        geom_bar(stat = "identity") +
        scale_y_continuous("Count of new cases", breaks = integer_breaks(), 
                           labels = scales::comma) + 
        scale_x_date("Date") + 
        theme_cowplot() + 
      labs(title = as.character(input$country_selector))
        # labs(title = "Static title")
      ) 
  })
  
  # current count of cases ####
  single_country_reactive_curr <- reactive({ 
    dat_curre <- dat_curre %>% 
      filter(country_region == input$country_selector_curr)
  })
  
  output$currcases_single <- renderPlotly({
    single_country_curr <- single_country_reactive_curr()
    
    ggplotly(
      ggplot(data = single_country_curr, aes(x = date, y = current_cases)) + 
        # geom_bar(stat = "identity") +
        geom_line() + 
        scale_y_continuous("Count of current cases", breaks = integer_breaks(), 
                           labels = scales::comma) + 
        scale_x_date("Date") + 
        theme_cowplot() + 
        labs(title = as.character(input$country_selector_curr)) 
    ) 
  })

  # CFR ####
    output$cfr_plot <- renderPlotly({
       ggplotly(
        ggplot(data = all_summ, aes(x = cfr, y = reorder(all_summ$country_region, desc(all_summ$country_region)))) + 
          geom_point() + 
          scale_x_continuous("Case fatality rate") + 
          scale_y_discrete("Country") + 
          theme_cowplot()
       )
    })
 
}