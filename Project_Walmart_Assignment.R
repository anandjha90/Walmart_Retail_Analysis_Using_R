## Dataset Description
# This is the historical data which covers sales from 2010-02-05 to 2012-11-01, in the file Walmart_Store_sales. 
# Within this file you will find the following fields:
  
# Store - the store number
# Date - the week of sales
# Weekly_Sales -  sales for the given store
# Holiday_Flag - whether the week is a special holiday week 1 – Holiday week 0 – Non-holiday week
# Temperature - Temperature on the day of sale
# Fuel_Price - Cost of fuel in the region
# CPI – Prevailing consumer price index
# Unemployment - Prevailing unemployment rate

walmart_data <- read.csv("Walmart_Store_sales.csv",header = T)
walmart_data
View(walmart_data)
str(walmart_data)

library(dplyr)
str(walmart_data)
class(walmart_data$Date)
walmart_data$Date <- as.Date(walmart_data$Date,format = "%d-%m-%Y")
# standard date format output %Y-%m-%d

## Analysis Tasks
# Basic Statistics tasks

# Which store has maximum sales
store_max_sales <- walmart_data %>% group_by(Store) %>% summarise(tot_sales = sum(Weekly_Sales)) %>% 
  filter(tot_sales == max(tot_sales))
store_max_sales

# Which store has maximum standard deviation i.e., the sales vary a lot. 
# Also, find out the coefficient of mean to standard deviation
max_std_dev <- walmart_data %>% group_by(Store) %>% summarise(stan_dev = sd(Weekly_Sales)) %>% 
  filter(stan_dev == max(stan_dev))
max_std_dev

coeff_vari <- walmart_data %>%  group_by(Store) %>% summarise(coeff_varia = sd(Weekly_Sales)/mean(Weekly_Sales)) %>% 
  filter(coeff_varia == max(coeff_varia))
coeff_vari

# Which store/s has good quarterly growth rate in Q3’2012
# Hint: Growth Rate = Weekly_Sales.Q3_2012-
# Weekly_Sales.Q2_2012)/Weekly_Sales.Q2_2012
# try mutate and if else to create a new column
# 1st April - 30th June - Q2
# 1st July - 30th Sep - Q3
# otherwise
# Use quarter(ymd(date), with_year = true ) this will give year and quarter value like 2010.1 , 2010.2 etc .
# You can use mutate and add this as a column to the df.

# fetching 2012 Q2 data
weekly_Sales_Q2_2012 <- walmart_data %>% group_by(Store) %>% 
  filter(Date >= as.Date("2012-04-01") & Date <= as.Date("2012-06-30")) %>% 
  summarise(sum(Weekly_Sales))
weekly_Sales_Q2_2012

# fetching 2012 Q3 data
weekly_Sales_Q3_2012 <- walmart_data %>% group_by(Store) %>% 
  filter(Date >= as.Date("2012-07-01") & Date <= as.Date("2012-09-30")) %>% 
  summarise(sum(Weekly_Sales))
weekly_Sales_Q3_2012

# Growth Rate = (Weekly_Sales.Q3_2012 - Weekly_Sales.Q2_2012) / Weekly_Sales.Q2_2012
growth_rate_q3_2012 <- mutate(weekly_Sales_Q3_2012,Performance = 
                      ((weekly_Sales_Q3_2012$`sum(Weekly_Sales)` - weekly_Sales_Q2_2012$`sum(Weekly_Sales)`) / 
                        weekly_Sales_Q2_2012$`sum(Weekly_Sales)`) * 100)

arrange(growth_rate_q3_2012,desc(Performance))

## Holiday Events
# Super Bowl: 12-Feb-10, 11-Feb-11, 10-Feb-12, 8-Feb-13
# Labour Day: 10-Sep-10, 9-Sep-11, 7-Sep-12, 6-Sep-13
# Thanksgiving: 26-Nov-10, 25-Nov-11, 23-Nov-12, 29-Nov-13
# Christmas: 31-Dec-10, 30-Dec-11, 28-Dec-12, 27-Dec-13

# Some holidays have a negative impact on sales. Find out holidays which have higher sales than the mean sales 
# in non-holiday season for all stores together
# Hint : You need to find dates where weekly_sales > avg_non_holiday_sales & holiday_flag == 1

mean_non_holiday_sales<- walmart_data %>% filter(Holiday_Flag == '0') %>% 
  summarise(total_non_holiday_sales = mean(Weekly_Sales)) 
mean_non_holiday_sales

holiday_sales <- walmart_data %>% group_by(Date)%>% filter(Holiday_Flag == '1') %>% 
  summarise(total_holiday_sales = sum(Weekly_Sales)) %>% 
  mutate(holiday_higher_sales_than_mean_non_holidays = total_holiday_sales > mean_non_holiday_sales)
holiday_sales

library(lubridate)
holiday_sales$Holiday <- ifelse(month(ymd(holiday_sales$Date)) == 2,"Super Bowl" ,
                                ifelse(month(ymd(holiday_sales$Date)) == 9,"Labour Day" ,
                                       ifelse(month(ymd(holiday_sales$Date)) == 11,"Thanksgiving" ,"Christmas")))
holiday_sales

# Provide a monthly and semester view of sales in units and give insights
# spliting of date
# Monthwise and Yearwise weekly sales. 
# For eg your output would look like this
#: -- DUMMY OUTPUT
# Hint :  Month Year Weekly_Sales
#           12  2015   60533

# monthly view of sales
month_year_view <- walmart_data %>% mutate(Month = month(Date) , Year = year(Date)) %>% 
  group_by(Month,Year) %>% summarise(Weekly_Sales = sum(Weekly_Sales)) %>% 
  arrange(Year)
month_sem_view

# semester view of sales
sem_view <- walmart_data %>% mutate(Semester = semester(Date,2010)) %>% group_by(Semester) %>% 
  summarise(Weekly_Sales_Fig = sum(Weekly_Sales))
sem_view

# Coorelation
# The corrplot package is a graphical display of a correlation matrix, 
# confidence interval. It also contains some algorithms to do matrix reordering. 
# In addition, corrplot is good at details, including choosing color, text labels, 
# color labels, layout, etc. The correlation matrix can be reordered according to the correlation coefficient.
# This is important to identify the hidden structure and pattern in the matrix.

subset2 <- subset(walmart_data, select = c('Weekly_Sales','Temperature','Fuel_Price','Unemployment','CPI'))
res <- cor(subset2)
head(res)

library(corrplot)
corrplot(res, type = 'upper', order = 'hclust', tl.col = 'black', tl.srt = 45)

# Statistical Model
# For Store 1 – Build  prediction models to forecast demand
# Hint : Linear Models

# H0 : There is no relation of Temperature,fuel_price,CPI,Unemployent on weekly sales of store1
# H1 : There is a relation and it affects the weekly sales of store 1 base on above indicators

store_1_data <- filter(walmart_data, Store == 1)
head(store_1_data)

model_store_1 <- lm(formula = Weekly_Sales ~ Temperature + Fuel_Price + CPI + Unemployment,data = store_1_data)
model_store_1


# Coefficients:
#  (Intercept)   Temperature     Fuel_Price        CPI      Unemployment  
#   -2727200         -2426        -31637          17872         90632  

# y = b0 + b1x1 + b2x2 + b3x3 + b4x4

# Weekly_Sales = (-2727200) +  Temp * (-2426 ) + Fuel_Price * (-31637) + CPI * 17872 + Unemployment * 90632
weekly_sales_1 <- 2727200 + 38.51 * (-2426 ) + 2.572 * (-31637) + 211.0964 * 17872 + 8.106 * 90632 # 72,22,523
weekly_sales_2 <- 2727200 + 39.51 * (-2426 ) + 2.572 * (-31637) + 211.0964 * 17872 + 8.106 * 90632 # 72,20,097

weekly_sales_1 - weekly_sales_2
# Inference : With 1 degree increase in temperature,weekly sales of store 1 got decreased by 2,426

weekly_sales_3 <- 2727200 + 38.51 * (-2426 ) + 2.572 * (-31637) + 211.0964 * 17872 + 8.106 * 90632 # 72,22,523
weekly_sales_4 <- 2727200 + 39.51 * (-2426 ) + 2.572 * (-31637) + 211.0964 * 17872 + 7.106 * 90632 # 71,29,465

weekly_sales_3 - weekly_sales_4 #93058
# Inference : With 1 unit fall in unemployment,weekly sales of store 1 got decreased by 93058

summary(model_store_1)
RSQD2 <- summary(model_store_1)$r.squared




# Call:
#  lm(formula = Weekly_Sales ~ Temperature + Fuel_Price + CPI + 
#     Unemployment, data = store_1_data)

# Residuals:
#   Min      1Q  Median      3Q     Max 
# -316968  -85750  -15239   51482  844800 

# Coefficients:
# Estimate Std. Error t value Pr(>|t|)   
# (Intercept)  -2727200.0  1759518.7  -1.550  0.12344   
# Temperature     -2426.5      917.8  -2.644  0.00915 **
# Fuel_Price     -31637.1    47551.8  -0.665  0.50696   
# CPI             17872.1     6807.0   2.626  0.00963 **
# Unemployment    90632.0    58925.1   1.538  0.12632   
--------------------------------------------------------------------------------------------------
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# Residual standard error: 147700 on 138 degrees of freedom
# Multiple R-squared:  0.1291,	Adjusted R-squared:  0.1039 
# F-statistic: 5.114 on 4 and 138 DF,  p-value: 0.0007142
---------------------------------------------------------------------------------------------------
# p-value_temp -> 0.00915 < alpha(0.05) -> Rej Ho, temp has effect on Sales
# p-value_fuel_price -> 0.50696 > alpha(0.05) -> Do not rej Ho, Fuel_Price has no effect on Sales
# p_value_cpi -> 0.00963 < alpha(0.05) -> Rej Ho, CPI has effect on Sales  
# p_value_unemployment -> 0.12632 > alpha(0.05)  -> Do not rej Ho, Fuel_Price has no effect on Sales
  
RSQD <- summary(model_store_1)$r.squared
RSQD # 2.90992

predicted_sales_model_store_1 <- predict(model_store_1, store_1_data) 
predicted_sales_model_store_1[1:10] # vector[first 10 values] 

rmse(model_store_1$coefficients)
rmse(model_store_1$residuals)
rmse(model_store_1$rank)
    



# Linear Regression – Utilize variables like date and restructure dates as 1 for 5 Feb 2010 
# (starting from the earliest date in order). 
# Hypothesize if CPI, unemployment, and fuel price have any impact on sales.
# Change dates into days by creating new variable.

# Hint: Convert Dates to days using - mutate and Days = yday(Date).
# Then subtract the number of days such that day 1 is 05-02-2010.
# Hint :Restructure dates as 1 for 5 Feb 2010

library(lubridate)

date_formatter <- as.Date("23/06/89", "%d/%m/%y")
weekdays(date_formatter)
quarters(date_formatter)
months(date_formatter)

x <- as.Date("2009-09-02")
yday(x)
mday(x)
wday(x)

# walmart_data$Date <- as.Date(walmart_data$Date,format = "%d-%m-%Y")

str(store_1_data)
store_1_data$Date <- as.Date(store_1_data$Date,format = "%d-%m-%Y")

mutate(store_1_data,date_to_days = yday(store_1_data$Date))
head(store_1_data)

library(caret)


# Select the model which gives best accuracy.
# accuracy of different model

# load the library
library(mlbench)
library(caret)
View(store_1_data)
str(store_1_data)
dim(store_1_data)

# load the dataset
data(walmart_data)

# prepare training scheme
control <- trainControl(method="repeatedcv", number=10, repeats=3)

# train the knn model
set.seed(7)
modelknn <- train(Weekly_Sales~ Temperature + Fuel_Price + CPI + Unemployment, data=store_1_data, method="knn", trControl=control)

# train the SVM model
set.seed(7)
modelSvm <- train(Weekly_Sales~ Temperature + Fuel_Price + CPI + Unemployment, data=store_1_data, method="svmRadial", trControl=control)


# collect resamples
results <- resamples(list(KNN=modelknn, SVM=modelSvm))

# summarize the distributions
summary(results)

# boxplots of results
bwplot(results)
# dot plots of results
dotplot(results)













