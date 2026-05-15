-- 1. SCHEMA REFRESH
CREATE SCHEMA IF NOT EXISTS market_data;

-- 2. ASSET REGISTRY
INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('MSFT', 'Microsoft Corp', 'NASDAQ'),
('ORCL', 'Oracle Corp', 'NYSE'),
('HSBC', 'HSBC Holdings', 'NYSE'),
('IBM', 'International Business Machines', 'NYSE'),
('CVX', 'Chevron Corporation', 'NYSE'),
('AMZN', 'Amazon.com Inc', 'NASDAQ'),
('JPM', 'JPMorgan Chase & Co', 'NYSE'),
('NU', 'Nu Holdings Ltd', 'NYSE'),
('ITUB', 'Itaú Unibanco', 'NYSE'),
('BSBR', 'Banco Santander Brasil', 'NYSE'),
('BDORY', 'Banco do Brasil', 'OTC'),
('TSLA', 'Tesla Inc', 'NASDAQ'),
('BP', 'BP p.l.c.', 'NYSE'),
('BK', 'BNY Mellon', 'NYSE'),
('BAC', 'Bank of America', 'NYSE'),
('MS', 'Morgan Stanley', 'NYSE'),
('MXAP', 'MSCI AC Asia Pacific', 'MSCI')
ON CONFLICT (ticker) DO NOTHING;

-- 3. ENERGY TARGETS
INSERT INTO market_data.energy_sector (ticker, one_year_target, last_close) VALUES 
('CVX', 217.00, 186.50)
ON CONFLICT (ticker) DO UPDATE SET last_close = EXCLUDED.last_close;

-- 4. RECENT TICKS (MAY 14, 2026)
INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('MSFT', 408.19, -0.63, '2026-05-14 19:15:00-03'),
('CVX', 186.50, 0.03, '2026-05-14 19:15:00-03'),
('AMZN', 188.20, 1.62, '2026-05-14 19:15:00-03'),
('TSLA', 175.40, 2.73, '2026-05-14 19:15:00-03'),
('BDORY', 0.00, -6.49, '2026-05-14 19:15:00-03'),
('BSBR', 0.00, -4.42, '2026-05-14 19:15:00-03'),
('MXAP', 272.60, 0.20, '2026-05-14 19:15:00-03')
ON CONFLICT DO NOTHING;

-- 5. TRADING SIGNALS VIEW (WITH RUNNING MAN ICON)
DROP VIEW IF EXISTS market_data.trading_signals;
CREATE VIEW market_data.trading_signals AS
SELECT 
    t.ticker,
    CASE 
        WHEN t.ticker IN ('TSLA', 'AMZN') AND t.pct_change > 1.0 THEN '🚀 STRONG BUY'
        WHEN e.one_year_target > t.price * 1.10 THEN '💎 BUY (VALUE)'
        WHEN t.pct_change < -4.0 THEN '🏃💨 RUN TO SELL'
        WHEN t.pct_change BETWEEN -0.5 AND 0.5 THEN '⚖️ HOLD'
        ELSE '🔎 MONITOR'
    END AS trend_signal
FROM (SELECT DISTINCT ON (ticker) * FROM market_data.ticks ORDER BY ticker, observed_at DESC) t
LEFT JOIN market_data.energy_sector e ON t.ticker = e.ticker;

-- 6. FINAL EXECUTIVE REPORT
SELECT 
    a.ticker AS "SYMBOL",
    LEFT(a.name, 18) AS "ENTITY",
    CASE WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change ELSE '▼ ' || t.pct_change END || '%' AS "MOVE",
    s.trend_signal AS "SIGNAL"
FROM market_data.assets a
JOIN (SELECT DISTINCT ON (ticker) ticker, pct_change FROM market_data.ticks ORDER BY ticker, observed_at DESC) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
ORDER BY t.pct_change DESC;
