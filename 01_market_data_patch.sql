-- ====================================================================
-- STARGATE CLUSTER: EXTRACTION & DATA INTEGRITY PATCH (REVISED)
-- TARGET ENGINE: PostgreSQL 18.3
-- COMPONENT: Sequential Ingestion Framework
-- ====================================================================

BEGIN;

-- 1. REGISTER THE MISSING INDEX TYPE ASSET
INSERT INTO market_data.assets (ticker, name) 
VALUES ('B500', 'Bloomberg 500 Index') 
ON CONFLICT (ticker) DO NOTHING;

-- 2. INGEST FRIDAY CLOSE TELEMETRY (MAY 15, 2026)
-- Clean append strategy for time-series logging
INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('B500', 2672.45, -1.25, '2026-05-15 16:00:00-04'),
('IBM', 219.30, 0.44, '2026-05-15 16:00:00-04'),
('SPX', 7408.50, -1.24, '2026-05-15 16:00:00-04'),
('CCMP', 26225.14, -1.54, '2026-05-15 16:00:00-04');

COMMIT;
