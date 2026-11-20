# Cart Abandonment Analysis
**SQL Server · Python · Power BI**

📊 [View Dashboard Screenshots](https://github.com/rohnitbhardwaj/cart-abandonment-analysis/blob/main/dashboard)

## Business Problem
Where do shoppers leave before buying, and which fixes would recover the most revenue? The goal is to help an online store find where its checkout loses customers and prioritise improvements.

## Dataset
Maven Fuzzy Factory e-commerce data (March 2012 to March 2015): 472,871 website sessions, of which 94,953 reached the cart, with 32,313 completed orders.

[Dataset source -- Maven Analytics](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database)

## Methodology

1. **Data preparation (SQL Server):** Created the database and tables with scripts, loaded the CSVs with `BULK INSERT`, and validated row counts and joins.
2. **Transformation (SQL):** Built one row per session with funnel flags, landing page and last product viewed before the cart, using CTEs, `ROW_NUMBER()` and `OUTER APPLY`. Cart session = viewed `/cart`; abandoned = never reached the order confirmation page.
3. **Analysis (Python):** Compared abandonment rates by device, checkout step, hour, weekday, visitor type, traffic source, product and landing page, checking segments within device where traffic mix could mislead, and sized three recovery scenarios.
4. **Visualization (Power BI):** One-page dashboard with DAX measures and device and date slicers: who abandons, where, and what recovery is worth.

## Key Findings

* **Overall:** 65.97% of carts are abandoned (62,640 of 94,953), about $3.76M at stake at the $59.99 average order value.
* **Device:** Mobile abandons at 77.2% versus 63.0% on desktop, and trails at every checkout step. The widest gap is shipping to billing (70.7% vs 83.0% conversion).
* **Where carts are lost:** Cart page 49%, billing 32%, shipping 20% of abandoned carts.
* **Landing page:** `/lander-3` looks worst (76.7%) but receives only mobile traffic. `/lander-1` is the only page weaker than the homepage on both devices.
* **No meaningful difference:** Hour, weekday, new vs returning visitors, traffic source and product all sit within about 64% to 68%.
* **Recovery potential:** Bringing mobile to the desktop rate is worth about 2,800 carts (about $169K), and recovering 10% of billing-stage abandoners about 2,000 carts (about $118K).

## Recommendations

* Review the mobile checkout, especially the shipping and billing steps.
* Retarget billing-stage abandoners, who are closest to buying.
* Review the `/lander-1` page.
* Deprioritise timing, visitor type, traffic source and product, where the data shows no difference.

## Limitations

* Revenue at stake is an estimate: abandoned carts have no recorded value, and not every abandoned cart would convert.
* Cart contents are not recorded, so product is the last product page viewed before the cart.
* The data shows where shoppers leave, not why.
* Recovery scenarios rest on assumptions (mobile reaching the desktop rate, a 10% recovery rate) and overlap, so they should not be added together.
* Landing pages ran in different periods, so part of a page's gap may reflect timing.

## Project Files

* `sql/` -- Table creation and loading, validation checks, session funnel build
* `notebook/cart_abandonment_analysis.ipynb` -- Python analysis
* `dashboard/cart_abandonment.pbix` -- Power BI dashboard
* `dashboard/` -- Dashboard screenshots

Rohnit Bhardwaj
