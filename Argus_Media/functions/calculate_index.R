box::use(lubridate)

#  The rules for creating an index price are:                               
#
#a)Only include a deal if the delivery period begins within 180 days of the deal 
#date                 
#b) Our indexes are calculated as a Volume Weighted Average Price (VWAP) of all 
#the relevant deals                
#
#c)There are two indices:                   
#  
# Deals to include in the COAL2 index are delivered into Northwest Europe 
#(delivery location in ARA, AMS, ROT, ANT)
#
# Deals to include in the COAL4 index are delivered from South Africa

get_delivery_date <- function(month, year) {
  return(lubridate::ym(paste(year, month)))
}

vwap_calculator <- function(price, volume) {
  return(cumsum(price * volume) / cumsum(volume))
}

index_data_preper <- function(data) {
  # assuming delivery date to be 01th of the month
  data$delivery_date <- get_delivery_date(month = data$DELIVERY.MONTH,
                                          year = data$DELIVERY.YEAR)
  
  data$DEAL.DATE_date <- lubridate::dmy(data$DEAL.DATE)
  
  data_delivery_interval <- lubridate::interval(start = data$DEAL.DATE_date,
                                                end = data$delivery_date)
  
  data$data_delivery_interval <- data_delivery_interval %/% lubridate::days(1)
  
  subsetted_data <- data |> 
    dplyr::filter(data_delivery_interval < 180)
  
  
  subsetted_data$index_value <- vwap_calculator(price = subsetted_data$PRICE,
                                                volume = subsetted_data$VOLUME)
  
  subsetted_data <- subsetted_data |>
    dplyr::select(-c(data_delivery_interval, delivery_date, DEAL.DATE_date))
  
  return(subsetted_data)
}

#'@export
get_index_value <- function(data, index) {
  data_with_index <- index_data_preper(data = data)
  
  if (identical(index, "coal4")) {
    coal4_index <- data_with_index |> 
      dplyr::filter(DELIVERY.LOCATION == "SOT")
    
    return(coal4_index)
  } else {
    coal2_index <- data_with_index |>
      dplyr::filter(DELIVERY.LOCATION %in% c("ARA", "AMS", "ROT", "ANT"))
    return(coal2_index)
  } 
}