## US counties - data regarding second waive of pandemic
# Goals:
# 1. Retrieve data on the number of COVID cases and the number of deaths    
#    in each of the ~3000 counties for which we have demographic data during    
#    the period of the second wave of the pandemic in the corresponding federal state 
# 2. Combine these data with demographic information
# 3. Determine the Case Fatality Rate (CFR) and Mortality Rate (m/r) based on the data on deaths and cases


rm(list = ls()) # Removing all variables from Environment

cat("\014") # clear console (same as Ctrl + L) 


library(tidyverse) # Loading tidyverse package

setwd("C:/Users/Milica Jokovic/OneDrive/Radna površina/Milica Jokovic/Master rad sa Markovog laptopa/Milica Jokovic/Maturski/covid") # Set the working directory (It should contain all the files that we will call in the script)

########### Table with the cumulative number of cases by dates ################

# Loading a table with CUMULATIVE data on the number of cases/deaths per day: 
all_dates_cases_deaths <- read.csv('covid_final.csv')

# Check the loaded data (their type, how the data frame looks):
str(all_dates_cases_deaths)
head(all_dates_cases_deaths)

# Sorting the data by the names of federal states and counties (if they are not already sorted):
all_dates_cases_deaths_ordered <- all_dates_cases_deaths %>% arrange(Province_State, Admin2,Last_Update)

# Formatting the column with dates so that R recognizes them as dates. 
all_dates_cases_deaths_ordered$Last_Update <- as.Date(all_dates_cases_deaths_ordered$Last_Update) 
head(all_dates_cases_deaths_ordered)


# Check how many dates we have in the table: 
a <- unique(all_dates_cases_deaths_ordered$Last_Update) # We have 471 unique dates. (from 01.11.2020 till 14.02.2022)
rm(a) 

# How many different counties are there:
county_state_combinations <- unique(all_dates_cases_deaths_ordered[c("Province_State","Admin2")]) # Imamo 3196 okruga. 
rm(county_state_combinations)
# How many different states are left: 
state_names <- as.data.frame(unique(all_dates_cases_deaths_ordered$Province_State)) # 52 state-a
colnames(state_names) <- c("State")
rm(state_names)

### Displaying data for an individual county: 
# (Confirmation that it is the CUMULATIVE NUMBER OF CASES/DEATHS)
one_state_data = all_dates_cases_deaths_ordered[all_dates_cases_deaths_ordered$Province_State == "Alabama",]
one_county_data = one_state_data[one_state_data$Admin2 == 'Autauga',]
plot(one_county_data$Deaths)
plot(one_county_data$Confirmed) # it is the cumilative number. 
rm(one_county_data, one_state_data)

# Defining a function that checks if a number is an empty integer. 
is.integer0 <- function(x)
{
  is.integer(x) && length(x) == 0L
} 
# Are there any empty fields in the data? 
sum(length(all_dates_cases_deaths_ordered)==0) # So, among the confirmed cases,
#  there are NO empty fields.


############################# TABLE WITH DATES ###############################

library(readxl)

second_peak_dates <- read_excel('COVID19_US_counties_second_peak_dates.xlsx', sheet = 'COVID19_US_counties_second_peak') 
second_peak_dates$start_date <- as.Date(second_peak_dates$start_date)
second_peak_dates$end_date <- as.Date(second_peak_dates$end_date)
head(second_peak_dates)

# Excluding Guam from table dates: 
second_peak_dates <- second_peak_dates[second_peak_dates$state != "Guam",]

county_names <- as.data.frame(unique(all_dates_cases_deaths_ordered[c("Province_State","Admin2")]))

####  Determining the cumulative number of cases from the start date to the end date

library(tidyverse)
second_peak_counts <- read_excel('PROBA.xlsx') # Loading the auxiliary data.frame
second_peak_counts$Start <- as.Date(second_peak_counts$Start) 
second_peak_counts$End <- as.Date(second_peak_counts$End) 

## Extending the table to 3318 rows: 
added_row <- second_peak_counts 
for (i in 1:(nrow(county_names)-1)){
  second_peak_counts <- rbind(second_peak_counts, added_row)
}

# Checking if the variables are of the appropriate type: 
str(second_peak_counts) # they are.


  
## ADDING TO THE TABLE THE CUMULATIVE NUMBER OF THE CASES/DEATHS BY COUNTIES: 
  
  
county_nr = 0
printf <- function(...) cat(sprintf(...))
  
for (i in 1:nrow(second_peak_dates)) {
    state <- second_peak_dates$state[i]
    start_date <- second_peak_dates$start_date[i]
    end_date <- second_peak_dates$end_date[i]
    temp_state_df <- all_dates_cases_deaths_ordered[all_dates_cases_deaths_ordered$Province_State == state,]
    counties_in_state <- as.data.frame(unique(temp_state_df$Admin2))
    colnames(counties_in_state) <- "County_name"
    for (j in 1:nrow(counties_in_state)){
      county <- counties_in_state$County_name[j]
      start_date <- second_peak_dates$start_date[i]
      end_date <- second_peak_dates$end_date[i]
      temp_county_df <- temp_state_df[temp_state_df$Admin2 == county,]
      first_date <- temp_county_df$Last_Update[1]
      last_date <- temp_county_df$Last_Update[nrow(temp_county_df)]
      # Setting conditions for dates: 
      if (start_date < last_date){
        county_nr = county_nr + 1
        printf("county %d\n",county_nr)
          if (first_date > start_date) {
            start_date <- first_date
          }
          
          if (last_date < end_date){
            end_date <- last_date
          }
      
          while (sum(temp_county_df$Last_Update == start_date)==0) {
            start_date <- start_date + 1
          }
          
          while (sum(temp_county_df$Last_Update == end_date)==0) {
            end_date <- end_date - 1
          }    
      
        cases <- (temp_county_df$Confirmed[temp_county_df$Last_Update == end_date] - temp_county_df$Confirmed[temp_county_df$Last_Update == start_date])
        deaths <- (temp_county_df$Deaths[temp_county_df$Last_Update == end_date] - temp_county_df$Deaths[temp_county_df$Last_Update == start_date])
        
      }
      # Rearranging table order:      
      second_peak_counts$State[county_nr] <- state
      second_peak_counts$County[county_nr] <- county
      second_peak_counts$Start[county_nr] <- start_date
      second_peak_counts$End[county_nr] <- end_date
      second_peak_counts$Cases[county_nr] <- cases
      second_peak_counts$Deaths[county_nr] <- deaths
    }
    
  }

rm(temp_county_df, temp_state_df, cases, county,deaths, end_date, first_date,i, j, last_date, start_date, state, counties_in_state, added_row) 
second_peak_counts <- second_peak_counts[1:county_nr,]
  
View(second_peak_counts) # Checking if everything is as it should be
  
# Saving the tabele

library("writexl")
write_xlsx(second_peak_counts,"Second_peak_cumulative_cases_deaths_US_counties.xlsx")


######## Calculating CFR (Case Fatality Rate) and m/r (mortality rate) based on cases and deaths ##########################

# Adding them as two columns at the end of the second peak counts
# Calculate the mean and standard deviation for CFR and m/r and graphically represent these data

library(stringr)
state_county_names_column <- as.data.frame(str_c(second_peak_counts$State,',',second_peak_counts$County)) # Add when the table is finished!
colnames(state_county_names_column) <- "County"
second_peak_counts <- second_peak_counts[3:6]
CFR <- as.data.frame(second_peak_counts$Deaths/second_peak_counts$Cases)
colnames(CFR) <- "CFR"
mr <- as.data.frame(CFR/(1-CFR))
colnames(mr) <- "mr"
second_peak_counts <- cbind(state_county_names_column,second_peak_counts,CFR,mr)

########### Integrating these data with demographic predictors ############

## PREDICTOR data set :

PREDICTORS_df <-  read_excel("predictors_US_counties.xlsx")
colnames(PREDICTORS_df)[1] <- "County"
head(PREDICTORS_df)

PREDICTORS_df_ordered <- PREDICTORS_df %>% arrange(County) # Arrange them by county

## Organizing our table so that the county name is in the same format as in the predictors table:

comparison_df_new <- as.data.frame(matrix(0,nrow(second_peak_counts),2))
colnames(comparison_df_new) <- c("County","Correct")
comparison_df_new$County <- as.character(comparison_df_new$County)
str(comparison_df_new)

for (i in 1:nrow(second_peak_counts)){
  correct = 0
  for (j in 1:nrow(PREDICTORS_df_ordered)){
    if (second_peak_counts$County[i]==PREDICTORS_df_ordered$County[j]){
      correct = 1 + correct
    }
  }
  comparison_df_new$County[i] <- second_peak_counts$County[i]
  comparison_df_new$Correct[i] <- correct
}


comparison_df_new$Correct <- as.integer(comparison_df_new$Correct)
Missing_Counties_new <- comparison_df_new$County[comparison_df_new$Correct==0]

# Double counties: 
Double_c <- comparison_df_new$County[comparison_df_new$Correct >1] # none 
# Number of counties that overlap:
remaining_counties <-sum(comparison_df_new$Correct) #2997
# Number of counties for which we do not have demographic data but have the number of cases: 
diff1 <- nrow(second_peak_counts) - sum(comparison_df_new$Correct) #199
diff1
# Number of counties for which we have demographic data but not the number of cases: 
diff2 <- nrow(PREDICTORS_df_ordered) - sum(comparison_df_new$Correct) #0 
diff2

# Removing counties from second_peak_counts that are not present in PREDICTORS_df_ordered


Counts_Predictors_df <- read_excel('PROBA.xlsx') 
Counts_Predictors_df$Start <- as.Date(Counts_Predictors_df$Start) 
Counts_Predictors_df$End <- as.Date(Counts_Predictors_df$End) 


Counts_Predictors_df <- cbind(Counts_Predictors_df, PREDICTORS_df_ordered[1,])
Counts_Predictors_df <- Counts_Predictors_df[,2:ncol(Counts_Predictors_df)]
added_row <- Counts_Predictors_df 
for (i in 1:(remaining_counties-1)){
  Counts_Predictors_df <- rbind(Counts_Predictors_df, added_row)
}

n = 0
for (i in 1:nrow(second_peak_counts)){
  for (j in 1:nrow(PREDICTORS_df_ordered)){
    if (second_peak_counts$County[i]==PREDICTORS_df_ordered$County[j]){
      n = n+1
      Counts_Predictors_df[n,] <- cbind(second_peak_counts[i,],PREDICTORS_df_ordered[j,])
    }
  }
}




# Check if the order in NEW_Counts_df is the same as in PREDICTORS_df_ordered. 
n = 0
for (i in 1:nrow(Counts_Predictors_df)){
  if (Counts_Predictors_df$County[i]==Counts_Predictors_df$County.1[i]){
    n = n+1
  }
}
sum(n) # 2997 - order is good. 

# Removing the excess column:
US_county_counts_predistors <- Counts_Predictors_df[,c(1:5,7:ncol(Counts_Predictors_df))] # Ovde izmeniti broj kolona koje ostaju, tako da zadrzimo i CFR i m/r

# Saving the results as *.xlsx and *.csv files 
write_xlsx(US_county_counts_predistors,"Second_Peak_US_county_counts_predistors.xlsx")
write.csv(US_county_counts_predistors,"Second_Peak_US_county_counts_predistors.csv")
