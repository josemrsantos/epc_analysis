# EPC data analysis

## Introduction
The dataset contains the Energy Performance Certificates (EPC) for buildings in the UK. The EPC is a certificate that 
provides information on the energy efficiency of a building. The dataset contains information on the energy efficiency
of buildings in the UK, such as the energy rating, the energy consumption, the carbon emissions, and the energy costs.
The dataset contains some PII data, that was not required for this analysis, so it was removed before uploading it to
this repository.  

## Data source
I fetched the dataset from: https://epc.opendatacommunities.org/login
That website sends a link to the dataset. Please note that on the website you need to register and login to be able to 
download the dataset. It also states: The data available contains personal information covered by the [Data Protection 
Act 2018 and the General Data Protection Regulation](https://epc.opendatacommunities.org/docs/protection), as well as 
data under a restrictive [licence](https://epc.opendatacommunities.org/docs/copyright). 
I have removed all PII (Personal Identifiable Information) from the dataset before uploading it to this repository as I
was only interested in aggregated data, around some (non-PII) attributes.
Note that the dataset is a large zip file (5.4GB) and once decompressed (into around 40GB) it contains one directory 
for each "local authority" in the UK. Each directory contains a CSV file with the EPC data for that local authority and 
a CSV file with recommendations for energy efficiency improvements.  

## Tools and process
 - DuckDB
 - DBeaver
 - https://public.tableau.com/

I used DuckDB to store the data and to run the queries. I also used DBeaver to connect to the DuckDB database and to
perform the import of the CSV files into the database and to run transformation queries. I also did some initial 
analysis using DBeaver and DuckDB. I finally created some SQL to export the aggregated data into CSV files.
I then used Tableau to create some visualizations.  

## Full process to fetch, clean and export the data for the visualizations

1. Download the dataset from https://epc.opendatacommunities.org/login
2. Unzip the dataset
3. Load the data into DuckDB
4. Run some queries to clean the data
5. Run some queries to aggregate the data
6. Export the aggregated data into CSV files

## Initial findings
### Data quality
I found that the dataset contains a lot of wrong data, in Years, floor areas, and other attributes. I also found that
the dataset contains a lot of missing data. I had to remove some of the data to be able to run the analysis. The wrong 
data mostly seems to be due to human error, as the data is entered by humans, but it could also be due to the design of
the system that collects the data. The missing data could be due to the same reasons, but it could also be due to the
fact that some buildings are not required to have an EPC.
### Interesting findings
All the initial analysis was done in SQL, using DuckDB and DBeaver.  
  
I am preparing a blog post with all the findings that I found "interesting" (TBD), but they are really all in the analysis.sql file of this repo.