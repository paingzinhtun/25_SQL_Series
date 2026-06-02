# Business Questions - Data Warehouse Star Schema

| Business Question | Why It Matters | SQL / Warehouse Concept |
|---|---|---|
| How do sales facts connect to all dimensions? | Shows how a star schema supports reporting across many business angles. | Fact-to-dimension joins |
| What is total revenue? | Gives the main sales KPI for the business. | SUM measure |
| What is total profit? | Shows business value after cost. | SUM measure |
| What is total quantity sold? | Measures sales volume. | Aggregation |
| What is average order value? | Shows how much each order is worth on average. | COUNT DISTINCT, NULLIF |
| What are sales by year? | Supports yearly performance reporting. | dim_date, GROUP BY |
| What are sales by quarter? | Helps compare seasonal business periods. | Date dimension |
| What are sales by month? | Supports monthly BI dashboards. | Date dimension |
| What are sales by weekday? | Shows demand by day of week. | dim_date attributes |
| What are sales on weekends vs weekdays? | Helps with staffing and campaign planning. | CASE WHEN |
| Which regions generate the most revenue? | Helps prioritize regional strategy. | Dimension slicing |
| Which cities generate the most revenue? | Shows city-level performance. | GROUP BY |
| Which stores perform best? | Supports store performance management. | Store dimension |
| How do stores rank by revenue? | Creates leaderboard-style BI output. | RANK |
| Which store types perform best? | Compares mall, city, online, and wholesale formats. | GROUP BY |
| Which product categories drive revenue? | Helps decide product and inventory strategy. | Product dimension |
| Which subcategories drive revenue? | Adds deeper product-level insight. | Drill-down analysis |
| Which products rank highest by revenue? | Finds top-selling products. | DENSE_RANK |
| Which products rank highest by profit? | Finds products with the strongest business value. | RANK |
| Which products are low-performing? | Flags products for review. | CTE, LEFT JOIN |
| Which customer types generate sales? | Compares retail, wholesale, VIP, and corporate customers. | Customer dimension |
| Which customers spend the most? | Supports loyalty and CRM decisions. | RANK |
| How much revenue comes from repeat customers? | Measures customer retention value. | CTE, COUNT DISTINCT |
| Which sales channels perform best? | Compares website, app, store, and marketplace revenue. | Channel dimension |
| How do online and offline sales compare? | Helps channel strategy and budget decisions. | CASE WHEN |
| Which employees generate the most sales? | Supports sales performance reporting. | Employee dimension |
| How do employees rank by revenue? | Creates sales team leaderboard reporting. | RANK |
| What is average discount by category? | Shows promotion intensity by product group. | AVG |
| What is profit margin by category? | Measures profitability, not only revenue. | Profit margin formula |
| What is the monthly growth trend? | Shows business movement over time. | LAG, growth rate |
| What is year-over-year growth? | Compares performance across years. | LAG, year analysis |
| What is the top KPI summary? | Gives executives core business metrics quickly. | CTE |
| What should an executive sales dashboard show? | Combines revenue, profit, growth, top category, and top region. | CTE, ROW_NUMBER |
| What should a product performance dashboard show? | Combines product revenue, profit, discounts, and status. | CTE, CASE WHEN |
| What should a store performance dashboard show? | Combines store orders, revenue, profit, AOV, and rank. | RANK |
| What should a customer analytics dashboard show? | Combines spending, orders, AOV, and customer segment. | CTE, CASE WHEN |
| What should a sales trend dashboard show? | Shows revenue, profit, orders, growth, and trend status. | LAG, CASE WHEN |
| Which months show seasonal sales trends? | Helps identify peak seasons. | RANK, dim_date |
| What business actions should be recommended? | Converts analytics into decisions. | CASE WHEN |
| What BI summary view should reporting tools use? | Provides an analytics-ready view for dashboards. | CREATE VIEW |
| What is running revenue over time? | Shows cumulative business performance. | SUM OVER |
