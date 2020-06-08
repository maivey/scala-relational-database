# Investigate a Relational Database

## Summary

This script uses SQL to explore a database related to movie rentals. The SQL queries are used to answer questions about the database and build visualizations to showcase the output of the queries. This project queries the **Sakila DVD Rental database**. The Sakila Database holds information about a company that rents movie DVDs. This project queries the database to gain an understanding of the customer base, such as what the patterns in movie watching are across different customer groups, how they compare on payment earnings, and how the stores compare in their performance.



Included in this repository is:

- A set of [slides](Investigate_Relational_Database_Presentation.pdf) with a question, visualization, and small summary on each slide.
- A [text file](queries.txt) with the queries needed to answer each of the four questions.
- A [jupyter notebook](Investigate_Relational_Database-AnalysisAndVisualizations.ipynb) that uses sqlalchemy to create visualizations
- A [ `.sql` file](queries.sql) with the queries needed to answer each of the four questions



## Prerequisites

#### Dependencies for the jupyter notebook:

```
import pandas as pd
from sqlalchemy import create_engine
import psycopg2
import matplotlib.pyplot as plt
import numpy as np
from databaseconfig import user_name, password, local_host
import seaborn as sns
import datetime
```

## ERD

The schema for the DVD Rental database is provided below:

![ERD](dvd-rental-erd.png)

## Questions

1. Out of all of the family movies, what are the categories of those movies and how many times has it been rented out?

2. How does the length of rental duration of these family-friendly movies compare to the duration that all movies are rented for?

3. How many movies are within each combination of film category for each corresponding rental duration category?

4. How do the two stores compare in their count of rental orders during every month for all the years we have data for?

5. Who were the top 10 paying customers, how many payments did they make on a monthly basis during 2007, and what was the amount of the monthly payments?

6. a. What is the difference across their monthly payments during 2007 for each of the top10 paying customers? 

   b. Who is the customer who paid the most difference in terms of payment?
