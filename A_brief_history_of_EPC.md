# A brief history of EPC

This is a brief analysis that I did of the EPC landscape in the UK. Being a home renter myself and knowing beforehand that the UK has such a bad reputation for home insulation and home energy efficiency, I wanted to look at actual data to see if I could get a bit more informed.

## What EPC is (in the UK)

*Energy performance certificates (EPCs) are a rating scheme to summarise the energy efficiency of buildings. The building is given a **rating between A (Very efficient) \- G (Inefficient)**. The EPC will also include tips about the most cost-effective ways to improve the home energy rating. Energy performance certificates are used in many countries.*

I got the text above from [wikipedia](https://en.wikipedia.org/wiki/Energy\_Performance\_Certificate\_(United\_Kingdom)) where you can read all about its history and regulations, but let me make a quick bullet-point summary here:

* An “accredited energy assessor” visits the property and uses a software to input a series of data points. The software itself then generates the EPC rating and recommendations for possible improvements.  
* Some properties do not require a domestic EPC (e.g. offices, petrol stations, farms, churches and listed buildings).

We also have some facts in  wikipedia the [Energy efficiency in British housing](https://en.wikipedia.org/wiki/Energy\_efficiency\_in\_British\_housing) : 

* Housing accounted for around 30% of all the UK's carbon dioxide emissions in 2004\.  
* Despite many initiatives, energy efficiency in British housing is still much worse than in other (similarly “rich”) countries.

In terms of Energy policy of the United Kingdom (also from wikipedia) we can see that the primary energy sources in the UK in 2017 were oil and natural gas (as can be seen [here](https://ourworldindata.org/grapher/primary-energy-mix-uk))  
In the [UK gov website and in terms of private renting](https://www.gov.uk/guidance/domestic-private-rented-property-minimum-energy-efficiency-standard-landlord-guidance\#) we can see that:

* *From 1 April 2020, landlords can no longer let or continue to let properties covered by the MEES Regulations if they have an EPC rating below E, unless they have a valid exemption in place.*  
* *If you \[the landlord\] cannot improve your property to EPC E for £3,500 or less, you should make all the improvements which can be made up to that amount, then register an ‘all improvements made’ exemption.*  
* In short: **if you want to rent a property, it needs to have at least an EPC E or you need to have an exception in place**.

Also, from a different source, it appears that Landlords not following these rules can face **fines up to £5,000**.

## Data freely available

Now looking at the dataset that was made freely available by the Royal Mail (under certain conditions, since a postcode or a home address can be considered PII information), anyone can request access to that dataset in this website:   
[https://epc.opendatacommunities.org/domestic/search](https://epc.opendatacommunities.org/domestic/search)  
After filling in a form, you will get a link to a 5.4GB compressed file that contains 2 CSV files (the combined space of these is around 40GB): certificates.csv and recommendations.csv . These CSV files have a header with column names that are easy to understand (or at least google their meaning).

## Quality of the data available

I will start by saying that I can be completely wrong here and maybe I’ve missed something, but I have spent quite a few hours trying to understand the data and I can say that it could be better documented (e.g. I don’t really know if 6.5 in the column TOTAL\_FLOOR\_AREA is in m2, ft2 or any other unit type). **I have also found several data points that are bluntly wrong** and even if it is possible for the energy assessor to input some data manually, the software itself should have some guardrails to prevent obvious manual mistakes (e.g. many sq metres of floor area on a 2 bed apartment). If the software used lacks those guardrails, I would think that at least some basic data quality assurance would be made, before releasing this dataset to the general public.  
Some quite basic errors that I found whilst trying to extract any meaningful information:

* **33491 properties have either a huge floor area (over 500\) or very small (less than 6.5)**. I have assumed that the floor area is in m2.  
* **Some entries in the certificates have an invalid UPRN** (this value gives you the exact location of that property). I discovered this by accident, while looking at other errors like the one above to spot check if it made sense (it could be a really big house ?).  
*  Less than 50 **certificates have the exact\_construction\_year set in the future** (after the Year 2024, when the dataset analysed was from mid-2024).  
* The indicative cost is all over the place:  
  * It has single numbers (e.g. 16\)  
  * It has single values in £ (e.g. £16)  
  * It has numbers divided by “-” (e.g. 10 \- 56\)  
  * It has values in £ divided by “-” (e.g. £10 \- £56)  
  * It has negative numbers and £ values (e.g. \-16 or \-£16)  
* Many rented homes have an EPC rating below E. This should be illegal, unless there is an exception in place (the landlord has spent £3500, but was still not able to reach the EPC E)  
* Out of the **rented homes have an EPC rating below E**, many also have recommendations (with an indicative\_cost set) to go to a lower rating (only 6 to be honest) , to stay in the same rating (38,742) or to improve to a rating, bellow E. 

I didn’t need all the fields, so I have not done an extensive review of the entire dataset. 

## Some **assumptions** that can be made from the available data

Not everything is a blackhole on the available data though ;) so I was able to extract some **assumptions** (I am not able to call them facts, because of the data quality and because I have not cross-referenced this with other data sources).

There are **41,444** homes in England/Wales that are **being rented in the private sector**,   
where the **landlord would need to spend less than £3,500** to upgrade it to the minimum required by law.

Out of the 41,444 homes listed above, there are **159** homes that **would only need to make 1 recommended change** and out of those, **4 landlords would only need to spend £30** to make it to the required by law.

Getting **all privately rented homes to at least the E rating** would cost in total between **£751,483,481** and **£1,455,312,401**

On average, **the maximum that a home should need to improve (from F to A)**, would be **£3,609**

On average, **the maximum that** **85,354 homes should need to improve (from F to C**). would be  **£2161**

## Disclaimer

I may have made some mistakes, but all my process and SQL code is available in [https://github.com/josemrsantos/epc\_analysis](https://github.com/josemrsantos/epc\_analysis).

Some assumptions might be incorrect and have an actual justification (e.g. some rented properties might already have an exception).