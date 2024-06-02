# Template for dealing with the asg-student context file
# Goal : aggregating the data to country level --- Mean/ Median, group by sex/ overall
# Variable: countryID, sex, mean and median for maths score
# Need to use it for year from 2007 -- 2019 of TIMSS data 
# install.packages("purrr")
# Load the necessary library------------------------
library(httr)
library(haven)
library(grid)
library(Matrix)
library(survival)
library(survey)
library(mitools)
library(dplyr)
library(data.table)
library(purrr)
# Define  countries-------------------- 
countries <-  c("ALB", "ARM", "AUS","AUT", "AZE", "BHR", "BFL", "BIH", "BGR", "CAN", "CHL", "TWN", "HRV", "CYP", "CZE", "DNK", "EGY", "ENG", "FIN", "FRA", "GEO", "DEU", "HKG",
"HUN", "IRN", "IRL", "ISR", "ITA", "JPN", "JOR", "KAZ", "KOR", "XKX", "KWT", "LVA", "LBN", "LTU", "MYS", "MLT",
"MNE", "MAR", "NLD", "NZL", "NIR", "MKD", "NOR", "OMN", "PAK", "PHL", "POL", "PRT", "QAT", "ROM", "RUS", "SAU", 
"SRB", "SGP", "SVK", "ZAF", "ESP", "SWE", "TUR", "ARE", "USA")

country_code <- c(8,51,36,40,31,48,956,70,100,124,152,158,191,196,203,208,818,926,246,250, 268,276,344,348,364,
                372,376,380,392,400,398,410,411,414,428,422,440,458,470,499,504,528,554,928,807,578,512,586,608,
                616,620,634,642,643,682,688,702,703,710,724,752,792,784,840)

country_names <- setNames(countries, country_code)

# Download and unzip the 2019 fourth grade international database-------------------
# link 2019G4: "https://timss2019.org/international-database/downloads/T19_G4_SPSS%20Data.zip"
# link 2015G4 :"https://www.iea.nl/index.php/sites/default/files/data-repository/TIMSS/TIMSS2015/TIMSS2015_IDB_SPSS_G4.zip" 
# link 2011 G4: "https://www.iea.nl/index.php/sites/default/files/data-repository/TIMSS/TIMSS2011/TIMSS2011_IDB_SPSS_G4.zip"

this_url <- "https://timss2019.org/international-database/downloads/T19_G4_SPSS%20Data.zip"
tf <- tempfile()
GET( this_url , write_disk( tf ) , progress() )
unzipped_files <- unzip( tf , exdir = tempdir() )

# Import and stack each of the student context data files------------------------
# limit unzipped files to those starting with `asg` followed by three letters followed by `m7`
asg_fns <- unzipped_files[ grepl( '^asg[a-z][a-z][a-z]m7' , basename( unzipped_files ) ) ]
countries_lower <- tolower(countries)

fns_countries <- paste0( paste0( '^asg' , countries_lower , 'm7' ) , collapse = "|" )
asg_countries_fns <- asg_fns[ grepl( fns_countries , basename( asg_fns ) ) ]

timss_df <- NULL
for( spss_fn in asg_countries_fns ){
    this_tbl <- read_spss( spss_fn )
    this_tbl <- zap_labels( this_tbl )
    this_df <- data.frame( this_tbl )
    names( this_df ) <- tolower( names( this_df ) )
    timss_df <- rbind( timss_df , this_df )
}

# order the data.frame by unique student id
timss_df<- timss_df[ with( timss_df , order( idcntry , idstud ) ) , ]
head(timss_df)


# Save locally------------------------- 
# timss_fn <- file.path( path.expand( "/Users/zihualai/Documents" ) ,"timss_df.rds" )
# saveRDS( timss_df, file = timss_fn , compress = FALSE )


# Survey Design Definition-----------------------
# From among possibly plausible values, determine all columns that are multiply-imputed plausible values:
# identify all columns ending with `01` thru `05`
ppv <- grep( "(.*)0[1-5]$" , names( timss_df ) , value = TRUE )
# remove those ending digits
ppv_prefix <- gsub( "0[1-5]$" , "" , ppv )
# identify each of the possibilities with exactly five matches (five implicates)
pv <- names( table( ppv_prefix )[ table( ppv_prefix ) == 5 ] )

# identify each of the `01` thru `05` plausible value columns
pv_columns <-
  grep( 
    paste0( "^" , pv , "0[1-5]$" , collapse = "|" ) , 
    names( timss_df ) , 
    value = TRUE 
  )
# Extract those multiply-imputed columns into a separate data.frame, then remove them from the source
pv_wide_df <- timss_df[ c( 'idcntry' , 'idstud' , pv_columns ) ]
timss_df[ pv_columns ] <- NULL

# Reshape these columns from one record per student to one record per student per implicate:
pv_long_df <- 
  reshape( 
    pv_wide_df , 
    varying = lapply( paste0( pv , '0' ) , paste0 , 1:5 ) , 
    direction = 'long' , 
    timevar = 'implicate' , 
    idvar = c( 'idcntry' , 'idstud' ) 
  )

names( pv_long_df ) <- gsub( "01$" , "" , names( pv_long_df ) )

# Merge the columns from the source data.frame onto the one record per student per implicate data.frame:
timss_long_df <- merge( timss_df , pv_long_df )
timss_long_df <- timss_long_df[ with( timss_long_df , order( idcntry , idstud ) ) , ]
stopifnot( nrow( timss_long_df ) == nrow( pv_long_df ) )
stopifnot( nrow( timss_long_df ) / 5 == nrow( timss_df ) )

# Divide the five plausible value implicates into a list with five data.frames based on the implicate number
timss_list <- split( timss_long_df , timss_long_df[ , 'implicate' ] )

# Construct a replicate weights table following the estimation technique described in Methods Chapter 14:
weights_df <- timss_df[ c( 'jkrep' , 'jkzone' ) ]

for( j in 1:75 ){
  for( i in 0:1 ){
    weights_df[ weights_df[ , 'jkzone' ] != j , paste0( 'rw' , i , j ) ] <- 1
    
    weights_df[ weights_df[ , 'jkzone' ] == j , paste0( 'rw' , i , j ) ] <- 
      2 * ( weights_df[ weights_df[ , 'jkzone' ] == j , 'jkrep' ] == i )
  }
}

weights_df[ c( 'jkrep' , 'jkzone' ) ] <- NULL

# Define the design:
timss_design <- 
  svrepdesign(
    weights = ~totwgt ,
    repweights = weights_df , 
    data = imputationList( timss_list ) ,
    type = "other" ,
    scale = 0.5 ,
    rscales = rep( 1 , 150 ) ,
    combined.weights = FALSE ,
    mse = TRUE
  )

# Variable Recoding------------------
# Add new columns to the data set:
timss_design <- 
  update( 
    timss_design , 
    
    one = 1 ,
    
    countries = 
      
      factor( 
        
        as.numeric( idcntry ) ,
        
        levels = c(8L, 51L, 36L, 40L, 31L, 48L, 956L, 70L, 100L, 124L, 152L, 158L, 191L, 196L, 203L, 208L, 818L, 926L, 246L, 250L, 268L, 276L, 344L, 348L, 364L,
                   372L, 376L, 380L, 392L, 400L, 398L, 410L, 411L, 414L, 428L, 422L, 440L, 458L, 470L, 499L, 504L, 528L, 554L, 928L, 807L, 578L, 512L, 586L, 608L,
                   616L, 620L, 634L, 642L, 643L, 682L, 688L, 702L, 703L, 710L, 724L, 752L, 792L, 784L, 840L)
        ,
        
        labels = c("ALB", "ARM", "AUS","AUT", "AZE", "BHR", "BFL", "BIH", "BGR", "CAN", "CHL", "TWN", "HRV", "CYP", "CZE", "DNK", "EGY", "ENG", "FIN", "FRA", "GEO", "DEU", "HKG",
                   "HUN", "IRN", "IRL", "ISR", "ITA", "JPN", "JOR", "KAZ", "KOR", "XKX", "KWT", "LVA", "LBN", "LTU", "MYS", "MLT",
                   "MNE", "MAR", "NLD", "NZL", "NIR", "MKD", "NOR", "OMN", "PAK", "PHL", "POL", "PRT", "QAT", "ROM", "RUS", "SAU", 
                   "SRB", "SGP", "SVK", "ZAF", "ESP", "SWE", "TUR", "ARE", "USA")
          
        
      ) ,
    
    sex = factor( asbg01 , levels = 1:2 , labels = c( "female" , "male" ) ) ,
    
    born_in_country = ifelse( asbg07 %in% 1:2 , as.numeric( asbg07 == 1 ) , NA )
    
  )


# Define Functions for mean and variance------------------
# This survey uses a multiply-imputed variance estimation technique described in Methods Chapter 14.
timss_MIcombine <-
  function (results, variances, call = sys.call(), df.complete = Inf, ...) {
    m <- length(results)
    oldcall <- attr(results, "call")
    if (missing(variances)) {
      variances <- suppressWarnings(lapply(results, vcov))
      results <- lapply(results, coef)
    }
    vbar <- variances[[1]]
    cbar <- results[[1]]
    for (i in 2:m) {
      cbar <- cbar + results[[i]]
      vbar <- vbar + variances[[i]]
    }
    cbar <- cbar/m
    vbar <- vbar/m
    
    # MODIFICATION
    # evar <- var(do.call("rbind", results))
    evar <- sum( ( unlist( results ) - cbar )^2 / 4 )
    
    
    r <- (1 + 1/m) * evar/vbar
    df <- (m - 1) * (1 + 1/r)^2
    if (is.matrix(df)) df <- diag(df)
    if (is.finite(df.complete)) {
      dfobs <- ((df.complete + 1)/(df.complete + 3)) * df.complete *
        vbar/(vbar + evar)
      if (is.matrix(dfobs)) dfobs <- diag(dfobs)
      df <- 1/(1/dfobs + 1/df)
    }
    if (is.matrix(r)) r <- diag(r)
    rval <- list(coefficients = cbar, variance = vbar + evar *
                   (m + 1)/m, call = c(oldcall, call), nimp = m, df = df,
                 missinfo = (r + 2/(df + 3))/(r + 1))
    class(rval) <- "MIresult"
    rval
  }


# Analysis Examples with the survey library ---------------
# Unweighted Counts
# Count the unweighted number of records in the survey sample, overall and by groups:
# timss_MIcombine( with( timss_design , svyby( ~ one , ~ one , unwtd.count ) ) ) # total count unweighted
# timss_MIcombine( with( timss_design , svyby( ~ one , ~ sex , unwtd.count ) ) ) # count by sex unweighted

# Weighted Counts
# timss_MIcombine( with( timss_design , svytotal( ~ one ) ) ) # weighted count total
# timss_MIcombine( with( timss_design ,
                      #  svyby( ~ one , ~ sex , svytotal )   # weighted count by sex
# ) )

# Descriptive Statistics
##  Mean------------------- 
# Calculate the mean (average) of a linear variable, overall and by groups (maths score) for the global
# global_mean_maths <- timss_MIcombine( with( timss_design , svymean( ~ asmmat , na.rm = TRUE ) ) )
# global_mean_sex_maths <- timss_MIcombine( with( timss_design ,
#                       svyby( ~ asmmat , ~ sex , svymean , na.rm = TRUE ) ) )

# For each country
# for countries only without sex
country_mean_maths<- timss_MIcombine(with(timss_design, svyby(~asmmat, ~countries, svymean, na.rm = TRUE)))
country_mean_maths
# for each country grouped by sex
# country_mean_sex_maths <- timss_MIcombine(with(timss_design, svyby(~asmmat, ~countries_lower + sex, svymean, na.rm = TRUE)))






# Calculate the distribution of a categorical variable, overall and by groups
# timss_MIcombine( with( timss_design , svymean( ~ countries_lower ) ) )
# timss_MIcombine( with( timss_design ,
                      #  svyby( ~ countries_lower , ~ sex , svymean )
# ) )

# Calculate the sum of a linear variable, overall and by groups
# timss_MIcombine( with( timss_design , svytotal( ~ asmmat , na.rm = TRUE ) ) )
# timss_MIcombine( with( timss_design ,
                      #  svyby( ~ asmmat , ~ sex , svytotal , na.rm = TRUE )
# ) )

# Calculate the weighted sum of a categorical variable, overall and by groups of maths score for each country
# timss_MIcombine( with( timss_design , svytotal( ~ countries_lower ) ) )
# timss_MIcombine( with( timss_design ,
#                        svyby( ~ countries_lower , ~ sex , svytotal )
# ) )

# Estimate a ratio:
# timss_MIcombine( with( timss_design ,
                       # svyratio( numerator = ~ asssci , denominator = ~ asmmat )
# ) )

## Median ------------------------
# Calculate the median (50th percentile) of a linear variable, overall and by groups
# For global overall
# global_median_maths<- timss_MIcombine( with( timss_design ,
#                       svyquantile(
#                          ~ asmmat ,
#                          0.5 , se = TRUE , na.rm = TRUE 
#                         ) ) )

# For global grouped by gender
# global_median_sex_maths <- timss_MIcombine( with( timss_design ,
#                         svyby(
#                           ~ asmmat , ~ sex , svyquantile ,
#                           0.5 , se = TRUE ,
#                           ci = TRUE , na.rm = TRUE
#                         ) ) )

# For each country
country_median_maths<- timss_MIcombine( with( timss_design ,
                                              svyby(
                                                ~ asmmat , ~ countries , svyquantile ,
                                                0.5 , se = TRUE ,
                                                ci = TRUE , na.rm = TRUE
                                              ) ) )

str(country_median_maths)
# country_median_sex_maths <- timss_MIcombine( with( timss_design ,
#                        svyby(
#                          ~ asmmat , ~ sex + countries_lower , svyquantile ,
#                          0.5 , se = TRUE ,
#                          ci = TRUE , na.rm = TRUE
#                        ) ) )



##  Subsetting-----------------
# Restrict the survey design to Finland and not Finland
# Subset for Finland and calculate the mean
# finland_timss_design <- subset(timss_design, idcntry == 246)
# finland_result <- timss_MIcombine(with(finland_timss_design, svymean(~asmmat, na.rm = TRUE)))
# print(finland_result)
# Subset for countries that are not Finland
# not_finland_timss_design <- subset(timss_design, idcntry != 246)
# not_finland_result <- timss_MIcombine(with(not_finland_timss_design, svymean(~asmmat, na.rm = TRUE)))
# print(not_finland_result)
##  Measures of Uncertainty-----------------
# Extract the coefficient, standard error, confidence interval, and coefficient of variation from any descriptive statistics function result, overall and by groups:
# this_result <-
#   timss_MIcombine( with( timss_design ,
#                          svymean( ~ asmmat , na.rm = TRUE )
#   ) )

# coef( this_result )
# SE( this_result )
# confint( this_result )
# cv( this_result )

# grouped_result <-
#   timss_MIcombine( with( timss_design ,
#                         svyby( ~ asmmat , ~ sex , svymean , na.rm = TRUE )
#   ) )

# coef( grouped_result )
# SE( grouped_result )
# confint( grouped_result )
# cv( grouped_result )

# Calculate the degrees of freedom of any survey design object
# degf( timss_design$designs[[1]] )

# Calculate the complex sample survey-adjusted variance of any statistic
# timss_MIcombine( with( timss_design , svyvar( ~ asmmat , na.rm = TRUE ) ) )

# SRS without replacement
# timss_MIcombine( with( timss_design ,
#                        svymean( ~ asmmat , na.rm = TRUE , deff = TRUE )
# ) )

# SRS with replacement
# timss_MIcombine( with( timss_design ,
#                        svymean( ~ asmmat , na.rm = TRUE , deff = "replace" )
# ) )

# Compute confidence intervals for proportions using methods that may be more accurate near 0 and 1. See ?svyciprop for alternatives:
# MIsvyciprop( ~ born_in_country , timss_design ,  method = "likelihood" , na.rm = TRUE )


##  Regression Models and Tests of Association-----------------------------
# Perform a design-based t-test:
# MIsvyttest( asmmat ~ born_in_country , timss_design )
# Perform a chi-squared test of association for survey data:
# MIsvychisq( ~ born_in_country + countries_lower , timss_design )

# Perform a survey-weighted generalized linear model:
# glm_result <- 
#   timss_MIcombine( with( timss_design ,
#                         svyglm( asmmat ~ born_in_country + countries_lower )
#  ) )

# summary( glm_result )

# store the data with year 

# Prepare median and mean math scores
medians <- data.frame(country = names(country_median_maths$coefficients),
                      median_score = country_median_maths$coefficients)

means <- data.frame(country = names(country_mean_maths$coefficients),
                    mean_score = country_mean_maths$coefficients)

# Calculate mean and median for SES and interest
country_ses_interest <- timss_df %>%
  group_by(idcntry) %>%
  summarize(
    mean_ses = mean(asbghrl, na.rm = TRUE),
    median_ses = median(asbghrl, na.rm = TRUE),
    mean_interest = mean(asbgslm, na.rm = TRUE),
    median_interest = median(asbgslm, na.rm = TRUE)
  )
country_ses_interest





country_ses_interest$idcntry <- as.numeric(as.character(country_ses_interest$idcntry))

# Replace the country codes with country names
country_ses_interest <- country_ses_interest %>%
  mutate(country = country_names[as.character(idcntry)])

# Optionally, you can remove the old idcntry column if no longer needed
country_ses_interest <- country_ses_interest %>%
  select(-idcntry, everything())

country_ses_interest




# Merge all data together
all_data <- reduce(list(means, medians, country_ses_interest), full_join, by = "country")
all_data
# Add country names and year
all_data <- all_data %>%
  mutate(
    year = 2019
  ) %>%
  select(idcntry, country, year, mean_ses, median_ses, mean_interest, median_interest, mean_score, median_score)

# Print the head of the final data frame
print(head(all_data))

# Write the DataFrame to a CSV file
write.csv(merged_data, "merged_data_2019.csv", row.names = FALSE)

