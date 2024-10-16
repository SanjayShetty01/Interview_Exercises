**R shiny Assignment**

- Utilize the superstore data that was enclosed in the mail to create a R shiny dashboard. Refer to the Definition document for information on each column in the Superstore data, which is at the Customer ID X Order ID X Order date level.
- **Tab 1: Importing Dataset** 
1) Give the user the chance to browse for and choose the necessary file.
1) Once the file has been imported, display the top 10 records in a table. For more control over the table view, utilise the data.table method. Investigate at least 7-8 parameters.
1) The button under the name "continue analysis" should be displayed at the end of the Tab1 and on clicking, it must switch to Tab 2.	
- **Tab 2: Data Set Review**
  - Show line and bar charts for the required attributed. Use radio buttons in order to toggle between the two types of plots. For eg: Sales trend line across month for each category (category in dropdown)  
  - Include a download option for the data set used to create the charts along the plot.
- **Tab 3: Tab 3: K- means Clustering analysis (2018-2019)** 
  - Customer segmentation into clusters with a summary at each cluster based on Sales and Profit (based on user input) [# customers, Sales, # Orders, # quantity, # Sales per customer]

**Note:**

1. Dashboard Package to be used: library(bs4Dash)
1. Plots package to be used: library(highcharter) (Use various parameters in order to make your plots visually informative and appealing) 
1. Use page loader packages like library(shinycssloaders) when calculations happen in backend. 
1. Use fluidpage, fluidrow and column appropriately.

**Reference:**

<https://www.rdocumentation.org/packages/highcharter/versions/0.9.4>

<https://cran.r-project.org/web/packages/bs4Dash/bs4Dash.pdf>

<https://www.rdocumentation.org/packages/DT/versions/0.24/topics/datatable>



