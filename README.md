# Olist Snowflake + dbt Data Engineering Project

This repository demonstrates a simple end-to-end data engineering workflow using the **Brazilian Olist E-commerce Dataset**, **Python**, **Snowflake**, and **dbt**.

The project is organized into three main steps:

1. Upload the raw CSV files to a Snowflake stage using Python.
2. Create and populate the RAW tables in Snowflake using SQL.
3. Transform, test, and model the data using dbt.

---

## Project Structure

A typical project structure looks like this:

```text
project-root/
│
├── upload files onto the snowflake.py
├── olist_snowflake_raw_setup.sql
├── README.md
│
├── Raw Data/
│   ├── olist_customers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   └── product_category_name_translation.csv
│
└── olist_dbt_snowflake/
    ├── dbt_project.yml
    ├── README.md
    ├── models/
    ├── macros/
    ├── tests/
    ├── analyses/
    ├── seeds/
    └── snapshots/
```

The exact folder names may differ slightly depending on your local setup.

---

# 1. Prerequisites

Before running the project, install and configure the following:

- Python 3
- Git
- Snowflake account
- Snowflake warehouse
- dbt Core
- dbt Snowflake adapter

Install the required Python Snowflake package if it is not already installed:

```bash
pip install snowflake-snowpark-python
```

Install dbt for Snowflake:

```bash
pip install dbt-core dbt-snowflake
```

Check the installations:

```bash
python --version
dbt --version
```

---

# 2. Download the Olist Dataset

Download the Brazilian E-Commerce Public Dataset by Olist and place the CSV files inside the local raw-data folder used by the Python upload script.

The expected files are:

```text
olist_customers_dataset.csv
olist_geolocation_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
olist_order_reviews_dataset.csv
olist_orders_dataset.csv
olist_products_dataset.csv
olist_sellers_dataset.csv
product_category_name_translation.csv
```

Make sure the path configured inside:

```text
upload files onto the snowflake.py
```

points to the folder containing these CSV files.

---

# 3. Configure Snowflake Connection

The Python upload script connects to Snowflake.

Before running it, verify that the connection information is correct.

Typical Snowflake connection settings include:

```python
connection_parameters = {
    "account": "...",
    "user": "...",
    "password": "...",
    "role": "...",
    "warehouse": "COMPUTE_WH",
    "database": "DBT_PROJECT",
    "schema": "PUBLIC"
}
```

## Security

Do not commit real passwords, account credentials, private keys, or access tokens to GitHub.

For a real project, store credentials in environment variables or another secure secrets-management solution.

For example:

```python
import os

password = os.getenv("SNOWFLAKE_PASSWORD")
```

A local `.env` file should also be excluded from Git.

Example `.gitignore` entries:

```gitignore
.env
profiles.yml
target/
logs/
dbt_packages/
__pycache__/
```

---

# 4. Upload the CSV Files to Snowflake

Run:

```text
upload files onto the snowflake.py
```

from the project directory.

For example:

```bash
python "upload files onto the snowflake.py"
```

The purpose of this script is to:

- connect to Snowflake;
- create or use the Snowflake stage;
- upload the Olist CSV files to the stage.

The project uses the stage:

```text
DBT_PROJECT.PUBLIC.MY_STAGE
```

After the script finishes, verify the uploaded files in Snowflake:

```sql
LIST @DBT_PROJECT.PUBLIC.MY_STAGE;
```

You should see the Olist CSV files listed in the stage.

---

# 5. Create the Snowflake RAW Layer

After the files have been uploaded to the Snowflake stage, execute:

```text
olist_snowflake_raw_setup.sql
```

in a Snowflake worksheet.

The SQL file creates the main Snowflake objects used by the project.

It creates:

```text
DBT_PROJECT
│
├── RAW
├── STAGING
├── MARTS
└── PUBLIC
     └── MY_STAGE
```

It also creates the warehouse:

```text
COMPUTE_WH
```

The SQL script creates RAW tables for:

```text
CUSTOMERS
GEOLOCATION
ORDER_ITEMS
ORDER_PAYMENTS
ORDER_REVIEWS
ORDERS
PRODUCTS
SELLERS
PRODUCTS_CATEGORY_NAME
```

The script then loads the staged CSV files into these RAW tables using Snowflake `COPY INTO`.

---

# 6. Validate the RAW Data

After running the SQL file, verify that the tables exist:

```sql
SHOW TABLES IN SCHEMA DBT_PROJECT.RAW;
```

You can inspect individual tables:

```sql
SELECT *
FROM DBT_PROJECT.RAW.ORDERS
LIMIT 10;
```

You can also check row counts:

```sql
SELECT COUNT(*)
FROM DBT_PROJECT.RAW.ORDERS;
```

The setup SQL file already contains validation queries for the main RAW tables.

At this stage, the data pipeline looks like:

```text
Local CSV Files
      |
      v
Python Upload Script
      |
      v
Snowflake Internal Stage
DBT_PROJECT.PUBLIC.MY_STAGE
      |
      v
COPY INTO
      |
      v
DBT_PROJECT.RAW
```

---

# 7. Configure dbt

The dbt project is located inside the dbt project folder.

For example:

```text
olist_dbt_snowflake/
```

The folder contains its own `README.md` with dbt-specific details.

Before running dbt, configure your local Snowflake connection in:

```text
~/.dbt/profiles.yml
```

On Windows, this is normally located under:

```text
C:\Users\YOUR_USERNAME\.dbt\profiles.yml
```

A typical profile looks like:

```yaml
olist_dbt_snowflake:

  target: dev

  outputs:

    dev:
      type: snowflake
      account: YOUR_ACCOUNT
      user: YOUR_USERNAME
      password: YOUR_PASSWORD
      role: ACCOUNTADMIN
      database: DBT_PROJECT
      warehouse: COMPUTE_WH
      schema: RAW
      threads: 4
```

The profile name must match the profile configured in:

```text
dbt_project.yml
```

Do not commit `profiles.yml` when it contains credentials.

---

# 8. Test the dbt Connection

Open PowerShell or a terminal and navigate to the dbt project folder:

```bash
cd olist_dbt_snowflake
```

Then run:

```bash
dbt debug
```

A successful connection should end with a message similar to:

```text
All checks passed!
```

If the connection fails, verify:

- Snowflake account identifier;
- username;
- password or authentication method;
- role;
- warehouse;
- database;
- schema;
- `profiles.yml` location.

---

# 9. Run the dbt Models

The dbt project transforms the RAW data into cleaner analytical models.

The general architecture is:

```text
Snowflake RAW
     |
     v
dbt Staging Models
     |
     v
dbt Intermediate Models
     |
     v
dbt Marts
     |
     +--> Dimensions
     |
     +--> Facts
```

Run all models with:

```bash
dbt run
```

A more complete development command is:

```bash
dbt build
```

`dbt build` can run models and their associated tests in dependency order.

---

# 10. Run dbt Tests

Run all configured dbt tests:

```bash
dbt test
```

The project uses dbt tests to validate data quality, including checks such as:

- `not_null`
- `unique`
- `accepted_values`
- `relationships`
- custom SQL tests

For example, an order ID can be tested for uniqueness and null values:

```yaml
columns:
  - name: order_id
    tests:
      - not_null
      - unique
```

A passing dbt test returns no invalid records.

---

# 11. Run Individual dbt Models

You do not always need to rebuild the complete project.

Run one model:

```bash
dbt run --select fct_orders
```

Run the staging folder:

```bash
dbt run --select staging
```

Run the marts:

```bash
dbt run --select marts
```

Run a model together with its upstream dependencies:

```bash
dbt build --select +fct_orders
```

This is particularly useful while developing or debugging a specific model.

---

# 12. dbt Data Layers

## RAW

The RAW schema contains data loaded from the source CSV files with minimal transformation.

```text
DBT_PROJECT.RAW
```

The RAW layer should remain close to the original source data.

---

## STAGING

The staging layer cleans and standardizes RAW data.

Typical operations include:

- trimming strings;
- standardizing capitalization;
- correcting column names;
- casting data types;
- handling simple null values;
- creating basic derived columns.

Typical models include:

```text
stg_customers
stg_orders
stg_order_items
stg_order_payments
stg_order_reviews
stg_products
stg_sellers
stg_geolocation
```

---

## INTERMEDIATE

Intermediate models perform reusable transformations and aggregations.

Examples include:

```text
int_order_items_aggregated
int_order_payments_aggregated
int_order_reviews_aggregated
```

These models prepare data for analytical fact and dimension tables.

---

## MARTS

The marts layer contains analytics-ready tables.

Typical fact tables:

```text
fct_orders
fct_order_items
```

Typical dimension tables:

```text
dim_customers
dim_products
dim_sellers
```

The final structure follows a fact/dimension modeling approach suitable for reporting and analytics.

---

# 13. Generate dbt Documentation

dbt can generate interactive documentation for the project.

Run:

```bash
dbt docs generate
```

Then:

```bash
dbt docs serve
```

This opens local dbt documentation showing:

- models;
- columns;
- descriptions;
- tests;
- dependencies;
- lineage between models.

---

# 14. Recommended Execution Order

When running the project from the beginning, use this order:

```text
1. Download Olist CSV files
        |
        v
2. Configure Python Snowflake credentials
        |
        v
3. Run upload files onto the snowflake.py
        |
        v
4. Verify files in MY_STAGE
        |
        v
5. Run olist_snowflake_raw_setup.sql
        |
        v
6. Verify DBT_PROJECT.RAW tables
        |
        v
7. Configure ~/.dbt/profiles.yml
        |
        v
8. cd into the dbt project
        |
        v
9. dbt debug
        |
        v
10. dbt build
        |
        v
11. dbt test
        |
        v
12. dbt docs generate
        |
        v
13. dbt docs serve
```

---

# 15. Useful Commands

## Snowflake

List files in the stage:

```sql
LIST @DBT_PROJECT.PUBLIC.MY_STAGE;
```

Show RAW tables:

```sql
SHOW TABLES IN SCHEMA DBT_PROJECT.RAW;
```

Inspect data:

```sql
SELECT *
FROM DBT_PROJECT.RAW.ORDERS
LIMIT 10;
```

---

## dbt

Check connection:

```bash
dbt debug
```

Run models:

```bash
dbt run
```

Build models and tests:

```bash
dbt build
```

Run tests:

```bash
dbt test
```

Run one model:

```bash
dbt run --select fct_orders
```

Generate documentation:

```bash
dbt docs generate
```

Serve documentation:

```bash
dbt docs serve
```

---

# 16. Troubleshooting

## Python cannot connect to Snowflake

Check:

- account identifier;
- username;
- authentication credentials;
- warehouse;
- database;
- network connection.

---

## CSV files are not visible in the stage

Run:

```sql
LIST @DBT_PROJECT.PUBLIC.MY_STAGE;
```

If the expected files are missing, verify the local path used by the Python upload script.

---

## `COPY INTO` fails

Check:

- CSV file name;
- stage path;
- delimiter;
- header settings;
- timestamp format;
- destination column data types.

---

## dbt cannot find a source

Verify that the source is declared in the project's source YAML file.

For example:

```yaml
version: 2

sources:
  - name: raw
    database: DBT_PROJECT
    schema: RAW

    tables:
      - name: orders
      - name: customers
```

Then a dbt model can use:

```sql
SELECT *
FROM {{ source('raw', 'orders') }}
```

---

## dbt cannot connect to Snowflake

Run:

```bash
dbt debug
```

Then verify `profiles.yml`.

---

# 17. Technologies Used

- Python
- Snowflake
- Snowpark for Python
- SQL
- dbt Core
- dbt-snowflake
- Git
- GitHub

---

# Project Workflow Summary

```text
Olist CSV Dataset
       |
       v
Python / Snowpark
       |
       v
Snowflake Stage
       |
       v
Snowflake RAW Schema
       |
       v
dbt Staging
       |
       v
dbt Intermediate
       |
       v
dbt Marts
       |
       v
Analytics-Ready Fact & Dimension Tables
```

For additional details about individual dbt models, tests, sources, and project configuration, refer to the `README.md` inside the dbt project folder.
