# Downloading and extracting the data.
if (!file.exists ("Project1_Data")) {  
        dir.create ("Project1_Data")
        download.file ("http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip", 
                       destfile="Project1_Data/exdata-data-household_power_consumption.zip", 
                       method="auto")
        unzip ("Project1_Data/exdata-data-household_power_consumption.zip")  
        dateDownloaded <- date()   # Saves the date the download was done.
}

# Read only 1st and 2nd Feb, 2007 data points into R.
library (RSQLite)
con <- dbConnect ("SQLite", dbname="household_data")
dbWriteTable (con, name="data_table", value="household_power_consumption.txt", 
              row.names=F, header=T, sep=";")
finalData <- dbGetQuery (con, 
                         "SELECT * FROM data_table WHERE Date='1/2/2007' OR Date='2/2/2007'")
dbDisconnect(con)

# Convert character to date and time
finalData$Date <- strptime(paste(finalData$Date,finalData$Time), format="%d/%m/%Y %H:%M:%S")

# Delete the Time column (combined with Date now).
finalData <- finalData[,-2]
colnames(finalData)[1] <- "datetime"


## Plot 2

############################################################################
                                                                           #
png (filename="plot2.png")                                                 #
plot(finalData$datetime, finalData$Global_active_power, type="l", xlab="", #
     ylab="Global Active Power (kilowatts)")                               #
dev.off()                                                                  #
                                                                           #
############################################################################


# Deletes the temporary folder used to store the data.
unlink("Project1_Data", recursive=TRUE)
unlink(c("household_data.sql", "household_power_consumption.txt"))