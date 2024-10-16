box::use(./functions/calculate_index)

server <- function(input, output, session) {
  
  shiny::observeEvent(input$upload_proceed, {
    shinydashboard::updateTabItems(session = session,
                                   "tabs",
                                   "table_summary")
  }
)
  
  shiny::observeEvent(input$initialData, {
    tryCatch({
      extension <- tools::file_ext(input$initialData$datapath)
      
      stopifnot("Incorrect File Format" = identical(extension, "csv"))
    }, error = function(e) {
      shinyalert::shinyalert("Error", type = "error", 
                             text = e$message)
    })
    
  }
)
  
  coal4_index <- shiny::reactive({
    req(input$initialData)
    initial_data <- read.csv(input$initialData$datapath) 
    calculate_index$get_index_value(data = initial_data, index = "coal4")
  })
  
  coal2_index <- shiny::reactive({
    req(input$initialData)
    initial_data <- read.csv(input$initialData$datapath)
    calculate_index$get_index_value(data = initial_data, index = "coal2")
  })
  
  
  output$coal2_index <- DT::renderDataTable({
    req(input$initialData)
    coal2_index()
  })
  
  output$coal4_index <- DT::renderDataTable({
    req(input$initialData)
    coal4_index()
  })
  
  output$coal2_graph <- plotly::renderPlotly({
    req(input$initialData)
    
    data <- coal2_index()
    data <- data |>
      dplyr::select(c(DEAL.DATE, index_value)) |>       
      dplyr::group_by(DEAL.DATE) |>
      dplyr::summarise(index_value_average = mean(index_value))
    
    plotly::plot_ly(data, x = ~DEAL.DATE, y = ~index_value_average, type = 'scatter', 
                    mode = "lines")
  })
  
  
  output$coal4_graph <- plotly::renderPlotly({
    req(input$initialData)
    
    data <- coal4_index()
    data <- data |>
      dplyr::select(c(DEAL.DATE, index_value)) |>
      dplyr::group_by(DEAL.DATE) |>
      dplyr::summarise(index_value_average = mean(index_value))
    
    plotly::plot_ly(data, x = ~DEAL.DATE, y = ~index_value_average, type = 'scatter', 
                    mode = "lines")
  })
  
#Error handling code  
  shiny::observeEvent(input$tabs,{
    tryCatch({
      if ((identical(input$tabs, "table_summary") ||
           identical(input$tabs, "graphs")) && (is.null(input$initialData$datapath))) {
        shinyalert::shinyalert(title = "Warning",
                               type = "warning",
                               text = "Please Upload the data")
      }


    }, error = function(e) {
      shinyalert::shinyalert("Error", type = "error",
                             text = "An Error Occured, Please refresh the tool")
    })

})
}