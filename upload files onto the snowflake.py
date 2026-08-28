from snowflake.snowpark import Session


connection_params = {
    "account":   "LGQPNSF-ZG08760",       # e.g. "abc12345.us-east-1"
    "user":      "SHAHRIARIZADEHFATIMA",
    "password":  "...",
    "role":      "ACCOUNTADMIN",
    "warehouse": "COMPUTE_WH",
    "database":  "DBT_PROJECT",
    "schema":    "PUBLIC"
}

session = Session.builder.configs(connection_params).create()

session.file.put(
    "D:/snowflake-dbt-github/Raw Data/*.csv",
    "@MY_STAGE",
    auto_compress=False
)

session.sql("LIST @MY_STAGE").show()