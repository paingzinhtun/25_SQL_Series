# Historical Analytics & SCD Questions

| Historical Analytics Question | Why It Matters | SQL / SCD Concept |
| :--- | :--- | :--- |
| **What is the current state of a customer?** | Needed for operational systems and current reporting. | `is_current = TRUE` filter |
| **What did a customer look like last year?** | Needed for auditing and historically accurate reporting. | "As of date" `BETWEEN start AND end` |
| **How many customers changed their city?** | Helps identify mobility and geographic shifts. | Self-Joins / Window Functions |
| **Are we attributing sales to the right region?** | If a customer moves, old sales shouldn't move to the new region. | Fact to SCD2 Surrogate Key Join |
| **Which employees change departments most often?** | Highlights internal mobility or instability. | `COUNT()` and `GROUP BY` |
| **How long does a product stay in a category?** | Measures product lifecycle stability. | Date math: `end_date - start_date` |
| **How do Type 1 vs Type 2 metrics differ?** | Demonstrates the analytical risk of overwriting history. | `UNION ALL` comparison |
| **What is our total database size growth?** | Type 2 adds rows rapidly; needs monitoring. | CTE KPI Summary |