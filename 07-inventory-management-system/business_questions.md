# Business Questions

| Business Question | Why It Matters | SQL Concept |
| --- | --- | --- |
| List all products with supplier information. | Helps the business know who supplies each product. | `JOIN` |
| Show current stock by product and warehouse. | Gives a clear view of stock by location. | `JOIN`, `ORDER BY` |
| Calculate total stock available per product. | Shows how much stock exists across all warehouses. | `LEFT JOIN`, `GROUP BY`, `SUM` |
| Calculate total inventory value using unit cost. | Helps estimate how much cash is tied up in inventory. | `SUM`, calculated columns |
| Calculate potential sales value using selling price. | Shows possible sales value if current stock is sold. | `SUM`, calculated columns |
| Find products below reorder point. | Helps avoid running out of stock. | `JOIN`, `WHERE` |
| Generate reorder recommendations. | Supports purchasing decisions with reorder quantity. | `CASE WHEN`, reorder logic |
| Find products at risk of stockout. | Helps prioritize urgent restocking. | `WHERE`, safety stock logic |
| Find overstocked products. | Helps reduce overbuying and storage cost. | `WHERE`, calculated threshold |
| Find products with zero stock. | Identifies actual stockouts. | `WHERE` |
| Show stock movement history by product. | Shows inventory activity over time. | `JOIN`, transaction data |
| Calculate total stock in by product. | Measures incoming stock volume. | `LEFT JOIN`, filtered aggregation |
| Calculate total stock out by product. | Measures outgoing stock volume. | `LEFT JOIN`, filtered aggregation |
| Find fast-moving products. | Identifies products with strong demand. | CTE, `RANK()` |
| Find slow-moving products. | Helps identify products that may be tying up cash. | CTE, date filtering |
| Rank warehouses by total inventory value. | Shows which locations hold the most inventory value. | CTE, `RANK()` |
| Count products by category. | Helps understand product mix. | `GROUP BY`, `COUNT` |
| Find suppliers with the most products. | Shows supplier contribution to the catalog. | `LEFT JOIN`, `GROUP BY` |
| Show products where selling price is lower than or equal to unit cost. | Identifies pricing or margin problems. | `WHERE`, calculated columns |
| Create an inventory health summary. | Gives a simple operational status for each product-location pair. | `CASE WHEN`, `LEFT JOIN` |
