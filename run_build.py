import duckdb

con = duckdb.connect("olist.duckdb")

with open("sql/00_setup/00_build_all.sql", "r") as f:
    sql = f.read()

    con.execute(sql)
    con.close()

    print("Database build complete.")
    