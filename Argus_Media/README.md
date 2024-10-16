In this test you have a set of dummy deals data for a fictitious index.

The raw deals data is extracted from a database automatically for a range of days specified by the user.

You can assume that the extract process will always export Data.csv file with the same columns as the file attached.

Your task is to create R shiny application that allows user to select and import data set (attached), calculate a table containing the index price for each day that is included in the raw data, display it as a table and chart in the application and add a button to save the output as CSV file. 

The rules for creating an index price are:

- Only include a deal if the delivery period begins within 180 days of the deal date.

- Our indexes are calculated as a Volume Weighted Average Price (VWAP) of all the relevant deals.

- There are two indices:
    - Deals to include in the COAL2 index are delivered into Northwest Europe (delivery location in ARA, AMS, ROT, ANT)

    - Deals to include in the COAL4 index are delivered from South Africa  