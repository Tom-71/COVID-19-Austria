# COVID-19-Austria
COVID-19: Dataset for Austria. R Scripts for download, visualization, analysis and prediction
- 'number of days until times ten cases': This is the main unit for speed of spread of COVID-19 used here

## bmsgpk - Bundesministerium für Soziales, Gesundheit, Pflege und Konsumentenschutz
The official statisitcs are provided by the 'Sozial Ministerium (bmsgpk)'
- This dataset starts at 2020-02-25, the day the first COVID-19 case was confirmed in Austria. 
- Data on cases tested, confirmed, recovered and deaths are reported for Austria and the 'Bundeslaender' every day at 15h00. 
- From 2020-03-10 an additional report is issued at 08h00.
- Updated twice per day around 9h and 16h from 2020-03-21

### ./bmsgpk/data/COVID-19-austria.csv
Data up to 2020-03-20 have been manually compiled from
- https://www.kommunal.at/coronavirus-diese-daten-sind-die-grundlagen-fuer-massnahmen
- https://www.sn.at/panorama/oesterreich/coronavirus-in-oesterreich-und-salzburg-aktuelle-infektionszahlen-im-ueberblick-85045132
- and a few other sites

Starting from 2020-03-21 data have been manually extracted from 
- https://www.sozialministerium.at/Informationen-zum-Coronavirus/Neuartiges-Coronavirus-(2019-nCov).html
- Starting from 2020-03-21 these data are extracted from the above website by the ./bmsgpk/COVID-19-bmsgpk-extract.R script

## owid - OurWorldInData
Dataset provided by the OurWorldInData site
- https://covid.ourworldindata.org/data/full_data.csv
- Last data provided for 2020-03-17
- currently no updates here
- Plots with lots of data and calculations for 10+ regions worldwide

## ecdc - European Council for Decease Control
in progress


## jhucsse - John Hopkins University - Center for Systems Science and Engineering
in progress