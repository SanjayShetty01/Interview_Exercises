library(shiny)
library(magrittr)
library(readxl)
library(DT)
library(skimr)
library(dplyr)
library(cluster)
library(bs4Dash)
library(shinycssloaders)
library(highcharter)
library(lubridate)
library(moments)


shinyApp(
  ui = dashboardPage(
    title = "Assignment",
    fullscreen = T,
    header = dashboardHeader(
      title = dashboardBrand('Dash!', color = 'lightblue')
    ),
    sidebar = dashboardSidebar(
      skin = "light",
      status = "primary",
      elevation = 3,
      sidebarUserPanel(
        name = "Welcome Onboard!"
      ),
      sidebarMenu(id = 'tabs',
        sidebarHeader("Let's Explore!"),
        menuItem(
          "Upload the Data",
          tabName = "item1",
          icon = icon("upload")
        ),
        menuItem(
          "Visualize!",
          tabName = "item2",
          icon = icon("line-chart")
        ),
        menuItem(
          "Clustering",
          tabName = "item3",
          icon = icon(name = 'bar-chart')
      ))
    ),
    
    body = dashboardBody(
      tabItems(
        tabItem(
          tabName = "item1",
          fluidRow(
              
              
              fileInput('uploadData', label = "Upload the File")),
              
              fluidRow(uiOutput('columnNames')),
              
              br(),
              
              uiOutput('summaryBox'), 
              
              br(),
              
              uiOutput('ourAction'),
            
              br(),
          fluidRow(
            div(dataTableOutput("topUploaded"), 
                              style = "font-size:80%")
              
            )
        ),
        
        tabItem(
          tabName = "item2", 
          br(),
          br(),
          
          
          fluidRow(
            align="center",
            radioButtons('graph', label = h4("Select the Type of Graph"),
                         choices = list("Line" = 'line',"Bar" = 'column'))
          ),
          
          fluidRow(shiny::column(4, 
                                 withSpinner(uiOutput("xaxis"))),
                   shiny::column(4,
                                 withSpinner(uiOutput('yaxis'))),
                   shiny::column(4,
                                 withSpinner(uiOutput('group')))),
          
          fluidRow( withSpinner(
            highchartOutput('plot')))
        ),
        tabItem(
          tabName = "item3",
          fluidRow(shiny::column(4,withSpinner(
                                 uiOutput('summarySelector')))),

          fluidRow(align="center",
                   bs4ValueBoxOutput('nCustomer', width = 4),
                   bs4ValueBoxOutput('TSales', width = 4),
                   bs4ValueBoxOutput('TOrder', width = 4)),
          fluidRow(align="center",
                   bs4ValueBoxOutput('TQuant', width = 4),
                   bs4ValueBoxOutput('SalePerCust', width = 4)),

          
          fluidRow(align = "center",
                   withSpinner(
            highchartOutput('kmeansPlot')))
        )
      )
    )
  ),
    
  server <- function(input, output, session) {
    
    
    data <- reactive(
      {
        req(input$uploadData)
        
        read_excel(input$uploadData$datapath) %>%
          mutate(Month = month(`Order Date`, label = T)) %>%
          mutate(Year = year(`Order Date`))
      })
    
    yaxisCol = reactive(c('Sales', 'Quantity', 'Discount', 'Profit'))
    
    xaxisCol = reactive(c('Year', 'Month'))
    
    groupCol = reactive(c('Ship Mode','Segment','City','State','Postal Code',
                          'Category','Sub-Category', 'Product Name'))
    
    dataCluster = reactive({
      req(input$uploadData)
      
      kMeans <- function(data){
        
        dataSub = subset(data, select = c('Sales', 'Profit'))
        
        error <- NULL 
        
        for(i in 2:floor(nrow(data)/500)){
          km = kmeans(dataSub,i, iter.max = 100)
          
          score = mean(data.frame(silhouette(km$cluster, dist(dataSub)))$sil_width)
          
          error = append(error, score)
        }
        
        finalKm = kmeans(dataSub,which.max(error)+1, iter.max = 50)
        
        dataSub$cluster <-  finalKm$cluster
        
        dataFinal = cbind(data,dataSub$cluster)
        
        colnames(dataFinal) <- c(colnames(data), 'Cluster')
        return(dataFinal)
      }
      
      
      kMeans(data())
      
    })
    
    #charColName <- reactive(names(data()[,
    #sapply(data(), class) %in% c('character', 'factor')]))
    
    #numColName <- reactive(names(data()[! names(data()) %in% charColName()]))
    
    
    output$topUploaded <- renderDataTable({ 
      
      req(input$uploadData)
      
      data() %>%
        head(10) %>%
        data.frame()
      
    })
    
    output$columnNames <- renderUI({
      
      req(input$uploadData)
      
      selectInput('columns', "Column Names",names(data()))
    })
    
    
    classCol <- reactive({
      req(input$columns)
      
      classIndentifier <- function(columnName){
        
        if(grepl("ID", columnName, ignore.case = F)) {
          return('idtype')
        }
        
        else if(grepl("Date", columnName, ignore.case = F)){
          return('DateTime')
        }
        
        else if(columnName %in% c("Sales", "Quantity", "Discount", "Profit")){
          return('numeric')
        }
        else{
          return('category')
        }
        
      }
      
      classIndentifier(input$columns)
    })
    
    
    output$summaryBox <- renderUI({
      
      req(input$columns)
      
      x <- data()[[input$columns]]
      
      get_mode <- function(x){
        return(names(sort(table(x), decreasing = T, na.last = T)[1]))
      }
    
      if(classCol() == 'category'){

          fluidRow(width= 12, align="center",
                   valueBox(h3(get_mode(x)), 'The Most Frequent value',
                            color = 'primary', width = 5),
                   valueBox(h3(length(unique(x))), 'Number of Unique Values',
                            color = 'primary', width = 5),
                   valueBox(h3(sum(is.na(x))), 'Number of NAs', 
                            color = 'primary', width = 5)
              )
          
      }
      
      else if(classCol() == 'numeric'){

          fluidRow(width = 12, align="center",
              valueBox(h3(round(mean(x), 2)), 'The mean', 
                       width = 3, color = 'primary'),
              valueBox(h3(round(median(x), 2)), 'The median', 
                       width = 3, color = 'primary'),
              valueBox(h3(paste(min(x), "-", max(x))), "The Range", 
                       width = 3, color = 'primary'),
              valueBox(h3(round(sd(x), 2)), 'The Std Dev', 
                       width = 3, color = 'primary'),
              valueBox(h3(round(skewness(x), 2)), "The Skewness",
                       width = 3, color = 'primary'),
              valueBox(h3(round(kurtosis(x),2)), "The Kurtosis",
                       width = 3, color = 'primary'),
              valueBox(h3(round(as.numeric(quantile(x, 0.25)),2)), 
                       'The 25th Quantile',
                       width = 3, color = 'primary'),
              valueBox(h3(round(as.numeric(quantile(x, 0.75)),2)), 
                       'The 75th Quantile',
                       width = 3, color = 'primary')
          )      
      
      }
      
      else if(classCol() == 'idtype'){

        fluidRow(width= 12,align="center",
                 valueBox(h3(length(unique(x))),
                          'Number of Unique Values',
                          color = 'primary'),
                 valueBox(h3(sum(is.na(x))), 
                          'Number of NAs', 
                          color = 'primary')
        )        
      }
      
      else if(classCol() == 'DateTime'){
        
        fluidRow(width= 12,align="center",
                 valueBox(h3(min(x)), 'Starting Date',
                          color = 'primary'),
                 valueBox(h3(max(x)), 'Last Date', 
                          color = 'primary')
        ) 
      }
      else{}
      
      
      
    })
    
    
    output$ourAction <- renderUI({
      req(input$uploadData)
      
      actionButton("switchTab", "Continue Analysis")
      
    })
    
    observeEvent(input$switchTab, {
      updateTabItems(session, "tabs",selected = 'item2')
    })
    
    
    
    output$xaxis <- renderUI({
      
      req(input$uploadData, input$graph)
      
      switch(input$graph,
             
             'line' = selectInput('xColumn', "Select X-Axis Variable", 
                                  xaxisCol()),
             
             'column' = selectInput('xColumn', "Select X-Axis Variable",
                                    append(xaxisCol(), groupCol()))
      )
      
    })
    
    output$yaxis <- renderUI({
      
      req(input$uploadData)
      
      selectInput('yColumn', "Select Y-Axis Variable", 
                  yaxisCol())
      
      
    })
    
    
    output$group <- renderUI({
      
      req(input$uploadData)
      
      selectInput('groupSelect', "Which Column do you want to GroupBy",
                  groupCol())
    })
    
    plotData <- reactive({
      req(input$xColumn, input$yColumn, input$graph, input$groupSelect)
      
      x = input$xColumn
      y = input$yColumn
      group = input$groupSelect
      
      data() %>%
        aggregate(as.formula(paste0('`', input$yColumn, '`', '~', 
                                    '`', input$xColumn, '`', '+',
                                    '`', input$groupSelect, '`')), ., sum
                  
        )
    })
    
    output$plot <-renderHighchart({
      req(input$xColumn, input$yColumn, input$graph, input$groupSelect)
      
      x = input$xColumn
      y = input$yColumn
      group = input$groupSelect
      
      plotData()   %>%     
        hchart(input$graph, hcaes(
          x = !!sym(x), 
          y = !!sym(y),
          group = !!sym(group),
        )) %>%
        hc_exporting(enabled = T, 
                     filename = "processedData")
    })
    
    output$summarySelector <- renderUI({
      req(input$uploadData)
      
      n = length(unique(dataCluster()$Cluster))
      
      selectInput('Ncluster', 'Select the Cluster', 1:n)
      
    })
    
    
  clusterData <- reactive({
    req(input$Ncluster)
    
    sumClusterData = dataCluster() %>%
      filter(Cluster == as.numeric(input$Ncluster))
  })
  

    
    output$nCustomer <- renderbs4ValueBox({
      bs4ValueBox(h3(length(unique(clusterData()$`Customer ID`))),
                  subtitle = "Number of Customer",
                  color = 'primary')
    })
  
    output$TSales <- renderbs4ValueBox({
      bs4ValueBox(h3(round(sum(clusterData()$Sales),2)),
                  subtitle = "Total Sales",
                  color = 'primary')
  })    
    
    output$TOrder <- renderbs4ValueBox({
      bs4ValueBox(h3(length(unique(clusterData()$`Order ID`))),
                  subtitle = "Total Order",
                  color = 'primary')
    })  

    output$TQuant <- renderbs4ValueBox({
      bs4ValueBox(h3(round(sum(clusterData()$Quantity), 2)),
                  subtitle = "Total Quantity",
                  color = 'primary')
    })
    
    output$SalePerCust <- renderbs4ValueBox({
      bs4ValueBox(h3(round(mean(clusterData()$Sales), 2)),
                  subtitle = "Total Sale per Customer",
                  color = 'primary')
    })  
    
    
    output$kmeansPlot <- renderHighchart({
      req(input$uploadData)
      
      dataCluster() %>%
        hchart('scatter', hcaes(
          x = 'Sales',
          y = 'Profit',
          group = 'Cluster'
        ))
    })
    
  }
  
)
  
