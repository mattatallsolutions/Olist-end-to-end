import os
import duckdb
import matplotlib.pyplot as plt

DB = "olist.duckdb"
OUT_DIR = "images/dashboard_screenshots"
os.makedirs(OUT_DIR, exist_ok=True)

con = duckdb.connect(DB)

def save_line_chart(query, x_col, y_col, title, filename, y_label):
    rows = con.execute(query).fetchall()
    if not rows:
        raise RuntimeError(f"No data returned for chart: {title}")

    x = [r[0] for r in rows]
    y = [r[1] for r in rows]

    plt.figure()
    plt.plot(x, y)
    plt.title(title)
    plt.xlabel(x_col)
    plt.ylabel(y_label)
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, filename), dpi=160)
    plt.close()

def save_bar_chart(query, x_col, y_col, title, filename, y_label, top_n=10):

    rows = con.execute(query).fetchall()
    if not rows:
        raise RuntimeError(f"No data returned for chart: {title}")

    x = [r[0] for r in rows][:top_n]
    y = [r[1] for r in rows][:top_n]

    plt.figure()
    plt.bar(x, y)
    plt.title(title)
    plt.xlabel(x_col)
    plt.ylabel(y_label)
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, filename), dpi=160)
    plt.close()
    
def save_two_bar_chart(query, title, filename, y_label):
    rows = con.execute(query).fetchall()
    if not rows:
        raise RuntimeError("No data returned")

    labels = [r[0] for r in rows]
    values = [r[2] for r in rows]  # avg_review_score

    plt.figure()
    plt.bar(labels, values)
    plt.title(title)
    plt.xlabel("delivery_status")
    plt.ylabel(y_label)
    plt.tight_layout()
    plt.savefig(os.path.join(OUT_DIR, filename), dpi=160)
    plt.close()
# 1) Revenue trend (monthly)
save_line_chart(
    """
    SELECT
      strftime(date, '%Y-%m') AS month,
      SUM(revenue) AS revenue
    FROM mart.kpi_daily
    GROUP BY 1
    ORDER BY 1
    """,
    x_col="month",
    y_col="revenue",
    title="Revenue Trend (Monthly)",
    filename="01_revenue_trend_monthly.png",
    y_label="revenue"
)

# 2) Orders trend (monthly)
save_line_chart(
    """
    SELECT
      strftime(date, '%Y-%m') AS month,
      SUM(orders) AS orders
    FROM mart.kpi_daily
    GROUP BY 1
    ORDER BY 1
    """,
    x_col="month",
    y_col="orders",
    title="Orders Trend (Monthly)",
    filename="02_orders_trend_monthly.png",
    y_label="orders"
)

# 3) On-time delivery rate (monthly)
save_line_chart(
    """
    SELECT
      strftime(date, '%Y-%m') AS month,
      AVG(on_time_rate) AS on_time_rate
    FROM mart.kpi_daily
    GROUP BY 1
    ORDER BY 1
    """,
    x_col="month",
    y_col="on_time_rate",
    title="On-Time Delivery Rate (Monthly)",
    filename="03_on_time_rate_monthly.png",
    y_label="on_time_rate"
)

# 4) Avg review score (monthly)
save_line_chart(
    """
    SELECT
      strftime(date, '%Y-%m') AS month,
      AVG(avg_review_score) AS avg_review_score
    FROM mart.kpi_daily
    GROUP BY 1
    ORDER BY 1
    """,
    x_col="month",
    y_col="avg_review_score",
    title="Average Review Score (Monthly)",
    filename="04_avg_review_score_monthly.png",
    y_label="avg_review_score"

)# 5) Late vs On-time review score
save_two_bar_chart(
    "SELECT * FROM mart.delivery_review_impact ORDER BY delivery_status",
    title="Average Review Score: On-time vs Late Deliveries",
    filename="05_review_score_on_time_vs_late.png",
    y_label="avg_review_score"
)


print(f"Saved charts into: {OUT_DIR}")
