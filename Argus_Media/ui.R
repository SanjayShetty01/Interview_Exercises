box::use(shiny)
box::use(DT)
box::use(shinydashboard)
box::use(shinyalert)
box::use(lubridate)
box::use(dplyr)
box::use(plotly)

header <- shinydashboard::dashboardHeader(title = "Argus Media DS Test")
sidebar <- shinydashboard::dashboardSidebar(
  shinydashboard::sidebarMenu(id = "tabs",
    shinydashboard::menuItem(text = "Upload Dataset", 
                             tabName = "upload_data", 
                             icon = shiny::icon("upload")),
    shinydashboard::menuItem(text = "Table Summary",
                             tabName = "table_summary",
                             icon = shiny::icon("table")),
    shinydashboard::menuItem(text = "Graphs", tabName = "graphs", 
                             icon = shiny::icon("chart-simple"))
  )
)

body <- shinydashboard::dashboardBody(
  shinydashboard::tabItems(
    shinydashboard::tabItem(tabName = "upload_data",
                            shiny::fluidPage(
                                shiny::column(12, align = "center", 
                              shinydashboard::box(
                              shiny::fileInput(inputId = "initialData", 
                                               label = "Upload Data", 
                                               multiple = F,
                                               width = "100%")
                            )), 
                            column(4, 
                            shiny::actionButton(inputId = "upload_proceed",
                                                label = "Proceed",
                                                icon = shiny::icon("arrow-right"),
                                                width = "100px"), 
                            align = "center"
                            )
                            )),
    
    shinydashboard::tabItem(tabName = "table_summary",
                            shiny::fluidPage(
                              shiny::fluidRow(
                                shiny::h2("Coal 4 Index"),
                                DT::DTOutput(outputId = "coal4_index")
                                ),
                              shiny::fluidRow(
                                shiny::h2("Coal 2 Index"),
                                DT::DTOutput(outputId = "coal2_index")  
                              )
                              )),
    shinydashboard::tabItem(tabName = "graphs",
                            shiny::fluidPage(
                              shinydashboard::box(title = "Coal 4 Index Graph",
                                                  plotly::plotlyOutput(outputId = "coal4_graph")
                                                  ),
                              
                              shinydashboard::box(title = "Coal 2 Index Graph",
                                                  plotly::plotlyOutput(outputId = "coal2_graph")
                              )
                            ))
  )
)


shinydashboard::dashboardPage(
  header = header,
  sidebar = sidebar,
  body = body
)
