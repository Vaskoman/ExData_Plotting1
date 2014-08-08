## Downloading and extracting the data.
if (!file.exists ("Project1_Data")) {  
        dir.create ("Project1_Data")
        download.file ("http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip", 
                       destfile="Project1_Data/exdata-data-household_power_consumption.zip", 
                       method="auto")
        unzip ("Project1_Data/exdata-data-household_power_consumption.zip")  
        dateDownloaded <- date()   # Saves the date the download was done.
}


## Read only 1st and 2nd Feb, 2007 data points into R.
library (RSQLite)
con <- dbConnect ("SQLite", dbname="household_data")
dbWriteTable (con, name="data_table", value="household_power_consumption.txt", 
              row.names=F, header=T, sep=";")
finalData <- dbGetQuery (con, 
                         "SELECT * FROM data_table WHERE Date='1/2/2007' OR Date='2/2/2007'")
dbDisconnect(con)


## Convert character to date and time in $Date
finalData$Date <- strptime(paste(finalData$Date,finalData$Time), format="%d/%m/%Y %H:%M:%S")


## Delete the Time column (combined with Date now).
finalData <- finalData[,-2]
colnames(finalData)[1] <- "datetime"


## Plot 1
png (filename="plot1.png")
hist(finalData$Global_active_power, col="red", main="Global Active Power", xlab="Global Active 
     Power (kilowatts)")
dev.off()


## Plot 2
png (filename="plot2.png")
plot(finalData$datetime, finalData$Global_active_power, type="l", xlab="",
     ylab="Global Active Power (kilowatts)")
dev.off()


## Plot 3
png (filename="plot3.png")
with (finalData, {
        plot(datetime, Sub_metering_1, col="black", type="l", xlab="",ylab="Energy sub metering")
        lines (datetime, Sub_metering_2, col="red", type="l")
        lines (datetime, Sub_metering_3, col="blue", type="l")
}
        )
legend("topright", lty=1, col=c("black", "red", "blue"), legend=colnames(finalData)[6:8])
dev.off()


## Plot 4
png (filename="plot4.png")
par (mfrow=c(2,2))
with (finalData, {
        plot(datetime, Global_active_power, type="l", xlab="",
             ylab="Global Active Power")
        plot(datetime, Voltage, type="l", xlab=colnames(finalData)[1],
             ylab=colnames(finalData)[4])
        plot(datetime, Sub_metering_1, col="black", type="l", xlab="",ylab="Energy sub metering")
        lines (datetime, Sub_metering_2, col="red", type="l")
        lines (datetime, Sub_metering_3, col="blue", type="l")
        plot(datetime, Global_reactive_power, type="l", xlab=colnames(finalData)[1],
             ylab=colnames(finalData)[3])
        
})
dev.off()


## Deletes the temporary folder used to store the data.
unlink("Project1_Data", recursive=TRUE)
unlink(c("household_data.sql", "household_power_consumption.txt"))
