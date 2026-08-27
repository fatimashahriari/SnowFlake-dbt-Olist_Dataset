Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices


### Install the following:
- git
- python
- dbt-core
- dbt-snowflake
- snowflake-cli
- pandas
- openpyxl
- snowflake-connector-python
- snowflake-snowpark-python

 ### The dataset:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

#### in PowerShell:
dbt init olist_dbt_snowflake
dbt will create something like:
olist_dbt/
│
├── dbt_project.yml
├── models/
├── macros/
├── seeds/
├── snapshots/
└── tests/

### in PowerShell:
cd olist_dbt
For local dbt Core, the connection is normally stored in:
C:\Users\<your-user>\.dbt\profiles.yml


### If your dbt project is named olist_dbt_snowflake, the first line in profiles.yml must match the profile: value in dbt_project.yml.


### test dbt connection:
in PowerShell:
dbt debug

OR if the directory of the profile.yml is not C:\Users\<your-user>\.dbt\ :
dbt debug --profiles-dir "NEW DIRECTORY"

