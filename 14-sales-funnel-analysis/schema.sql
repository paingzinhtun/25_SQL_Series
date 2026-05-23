-- Day 14 - Sales Funnel Analysis
-- PostgreSQL schema

DROP TABLE IF EXISTS deals;
DROP TABLE IF EXISTS opportunities;
DROP TABLE IF EXISTS lead_stage_history;
DROP TABLE IF EXISTS funnel_stages;
DROP TABLE IF EXISTS leads;
DROP TABLE IF EXISTS sales_reps;
DROP TABLE IF EXISTS lead_sources;

CREATE TABLE lead_sources (
    source_id SERIAL PRIMARY KEY,
    source_name VARCHAR(80) NOT NULL UNIQUE,
    source_type VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_lead_sources_type
        CHECK (source_type IN ('organic', 'paid', 'referral', 'outbound', 'event', 'partner'))
);

CREATE TABLE sales_reps (
    rep_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    region VARCHAR(80) NOT NULL,
    hire_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leads (
    lead_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    company_name VARCHAR(120) NOT NULL,
    city VARCHAR(80) NOT NULL,
    source_id INTEGER NOT NULL,
    assigned_rep_id INTEGER NOT NULL,
    lead_status VARCHAR(30) NOT NULL,
    created_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_leads_source
        FOREIGN KEY (source_id)
        REFERENCES lead_sources (source_id),

    CONSTRAINT fk_leads_sales_rep
        FOREIGN KEY (assigned_rep_id)
        REFERENCES sales_reps (rep_id),

    CONSTRAINT chk_leads_status
        CHECK (lead_status IN ('new', 'contacted', 'qualified', 'disqualified', 'converted'))
);

CREATE TABLE funnel_stages (
    stage_id SERIAL PRIMARY KEY,
    stage_name VARCHAR(50) NOT NULL UNIQUE,
    stage_order INTEGER NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_funnel_stages_order
        CHECK (stage_order > 0)
);

CREATE TABLE lead_stage_history (
    history_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL,
    stage_id INTEGER NOT NULL,
    entered_at DATE NOT NULL,
    exited_at DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_lead_stage_history_lead
        FOREIGN KEY (lead_id)
        REFERENCES leads (lead_id),

    CONSTRAINT fk_lead_stage_history_stage
        FOREIGN KEY (stage_id)
        REFERENCES funnel_stages (stage_id),

    CONSTRAINT chk_lead_stage_history_dates
        CHECK (exited_at IS NULL OR exited_at >= entered_at),

    CONSTRAINT uq_lead_stage_history
        UNIQUE (lead_id, stage_id)
);

CREATE TABLE opportunities (
    opportunity_id SERIAL PRIMARY KEY,
    lead_id INTEGER NOT NULL UNIQUE,
    rep_id INTEGER NOT NULL,
    opportunity_name VARCHAR(150) NOT NULL,
    estimated_value NUMERIC(12, 2) NOT NULL,
    probability NUMERIC(5, 2) NOT NULL,
    opportunity_status VARCHAR(20) NOT NULL,
    created_date DATE NOT NULL,
    expected_close_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_opportunities_lead
        FOREIGN KEY (lead_id)
        REFERENCES leads (lead_id),

    CONSTRAINT fk_opportunities_rep
        FOREIGN KEY (rep_id)
        REFERENCES sales_reps (rep_id),

    CONSTRAINT chk_opportunities_estimated_value
        CHECK (estimated_value >= 0),

    CONSTRAINT chk_opportunities_probability
        CHECK (probability BETWEEN 0 AND 100),

    CONSTRAINT chk_opportunities_status
        CHECK (opportunity_status IN ('open', 'won', 'lost')),

    CONSTRAINT chk_opportunities_dates
        CHECK (expected_close_date IS NULL OR expected_close_date >= created_date)
);

CREATE TABLE deals (
    deal_id SERIAL PRIMARY KEY,
    opportunity_id INTEGER NOT NULL UNIQUE,
    deal_value NUMERIC(12, 2) NOT NULL,
    deal_status VARCHAR(20) NOT NULL,
    closed_date DATE NOT NULL,
    loss_reason VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_deals_opportunity
        FOREIGN KEY (opportunity_id)
        REFERENCES opportunities (opportunity_id),

    CONSTRAINT chk_deals_value
        CHECK (deal_value >= 0),

    CONSTRAINT chk_deals_status
        CHECK (deal_status IN ('won', 'lost')),

    CONSTRAINT chk_deals_loss_reason
        CHECK (
            (deal_status = 'won' AND loss_reason IS NULL)
            OR
            (deal_status = 'lost' AND loss_reason IN ('price', 'no_budget', 'competitor', 'no_response', 'not_ready', 'poor_fit'))
        )
);
