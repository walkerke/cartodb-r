## ---- fig = TRUE---------------------------------------------------------
library(rgdal)
library(maptools)
library(RCurl)
library(RJSONIO)
library(CartoDB)
library(RColorBrewer)
library(classInt)

# Setup our CartoDB Connection
cartodb_account_name = "viz2"; 
cartodb(cartodb_account_name)


crs <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# Get frisk density
boroughsUrl <- cartodb.collection(sql = "SELECT the_geom,num_stops,boroname,borocode,shape_area FROM nyct2000 WHERE the_geom IS NOT NULL AND boroname != 'Staten Island' AND 0<num_stops", method="GeoJSON", urlOnly=TRUE)
frisk.density<-readOGR(boroughsUrl,p4s=crs,layer = 'OGRGeoJSON')

plotvar <- as.numeric(frisk.density$num_stops)/as.numeric(frisk.density$shape_area)
# plotvar <- log(plotvar+1)
nclr <- 6
plotclr <- brewer.pal(nclr,"YlOrRd")
# plotclr <- plotclr[nclr:1] #reordering colors looks better
class <- classIntervals(plotvar, nclr, style="quantile")
colcode <- findColours(class, plotclr, digits=4)

frisk.hours <- cartodb.collection(sql = "SELECT count(*) as ct,city,city_code,floor(timestop/100) hr FROM stop_frisk Where frisked = 'Y' and city != 'STATEN IS' GROUP BY city,city_code,hr")

nclr <- 4
plotclr <- brewer.pal(nclr,"Set1")
class <- classIntervals(as.numeric(frisk.hours$city_code), nclr, style="quantile")
colcode2 <- findColours(class, plotclr, digits=4)

## ------------------------------------------------------------------------
op <- par(mfrow=c(1,2))
plot(frisk.hours$hr, frisk.hours$ct, col=colcode2, pch=15,
  	 xlab=NA, ylab="Frisks")
a<- legend(7,8000, legend=c("","","",""), fill=attr(colcode2, "palette"), bty="n",x.intersp = .5, y.intersp = .7)
text(a$text$x-1,a$text$y,c("Queens","Manhattan","Bronx","Brooklyn"),pos=2)
plot(frisk.density, col=colcode, border=NA,bg="#ced4db",axes=TRUE,ylab="",yaxt="n")
par(op)
title(main="NYC Frisks by Hour of Day and Neighborhood")

