# Executive Summary — Olist E-Commerce Analytics

## Goal
Build a reproducible analytics pipeline (raw → clean → warehouse → marts) and generate decision-ready insights on revenue, delivery performance, and customer retention.

## What I Built
- DuckDB analytics warehouse built from Kaggle’s Olist e-commerce dataset
- Layered modeling:
  - raw: direct CSV ingestion
  - stg: cleaned types and standardized fields
  - dw: fact tables for orders and order items
  - mart: business-ready KPI and insight tables
- Automated chart generation saved to `/images/dashboard_screenshots`

## Key Metrics Tracked
- Revenue and order trends (monthly)
- On-time delivery rate (monthly)
- Average review score (monthly)
- Review impact: on-time vs late deliveries
- Customer retention curve (cohort average, months 0–6)

## Key Findings (Data-Backed)
1. Late deliveries are associated with lower review scores.
   - Evidence: `mart.delivery_review_impact` and chart `05_review_score_on_time_vs_late.png`
2. Customer retention drops after the first purchase and continues declining across months 1–6.
   - Evidence: `mart.customer_cohort_retention` and chart `06_retention_curve_month0_6.png`

## Recommendations (What a business should do next)
1. Reduce late deliveries by targeting the biggest delay drivers first.
   - Prioritize: sellers, states, and categories with low on-time rates.
2. Improve post-purchase experience for at-risk orders.
   - Trigger proactive updates for orders likely to be late.
3. Increase retention with a “second purchase” program.
   - Offer incentives or reminders within 30–45 days after first purchase.

## Limitations
- This analysis focuses on order/review timing and does not include full cost data for true profitability.
- Some records may have missing timestamps or reviews, which can reduce sample sizes for certain metrics.

## Next Steps
- Add seller-level + category-level drilldowns for late delivery and review impact
- Build a “repeat purchase predictor” feature set (delivery delay, category, state, basket size)
- Expand marts for cancellation/refund proxies (if available)
