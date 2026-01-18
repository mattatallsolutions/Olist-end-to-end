# Olist End-to-End E-Commerce Analytics

An end-to-end analytics project that builds a reproducible SQL pipeline and analyzes
delivery performance, customer retention, and seller reliability using real e-commerce data.

## How to Run This Project (Reproducible)

1. Upload the Olist CSV files into the `/data` folder.
2. Open the repository in GitHub Codespaces.
3. Install dependencies:

       pip install duckdb pandas pyarrow matplotlib

4. Build the full pipeline:

       python - <<'EOF'
       import duckdb
       con = duckdb.connect("olist.duckdb")
       con.execute(open("sql/00_setup/00_build_all.sql").read())
       EOF

5. Generate charts:

       python docs/make_charts.py

All outputs are saved automatically to `/images/dashboard_screenshots`.


## Dashboard Preview (Auto-Generated)

Revenue Trend (Monthly)  
![Revenue Trend](images/dashboard_screenshots/01_revenue_trend_monthly.png)

Orders Trend (Monthly)  
![Orders Trend](images/dashboard_screenshots/02_orders_trend_monthly.png)

On-Time Delivery Rate (Monthly)  
![On-Time Rate](images/dashboard_screenshots/03_on_time_rate_monthly.png)

Average Review Score (Monthly)  
![Avg Review Score](images/dashboard_screenshots/04_avg_review_score_monthly.png)

On-time vs Late Delivery (Review Impact)  
![Review Impact](images/dashboard_screenshots/05_review_score_on_time_vs_late.png)

Customer Retention (Cohort Avg, Month 0–6)  
![Retention Curve](images/dashboard_screenshots/06_retention_curve_month0_6.png)

Worst Sellers by Late Delivery Rate  
![Worst Sellers](images/dashboard_screenshots/07_worst_sellers_late_rate.png)

## Skills Demonstrated

- End-to-end analytics pipeline design
- SQL data modeling (staging, fact tables, marts)
- Cohort-based customer retention analysis
- Operational KPI analysis (delivery performance)
- Translating data into business recommendations
- Reproducible, version-controlled analytics workflows


## Executive Summary
See `docs/executive_summary.md`.
