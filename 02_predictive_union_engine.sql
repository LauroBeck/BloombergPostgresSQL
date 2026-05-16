-- ====================================================================
-- STARGATE CLUSTER: PREDICTIVE HORIZON ENGINE (36-MONTH HORIZON)
-- TARGET ENGINE: PostgreSQL 18.3
-- COMPONENT: Multi-Layer Analytical UNION Joint
-- ====================================================================

-- Route the output cleanly to a dedicated report file for GitHub versioning
\o predictive_36m_gains.txt

SELECT '=== MASTER PREDICTIVE TELEMETRY LOG ===' AS "SYSTEM_STATUS";

(
    -- LAYER A: Absolute Live Position Tracking
    SELECT 
        a.ticker AS "SYMBOL",
        LEFT(a.name, 18) AS "ENTITY",
        'LIVE CLOSE' AS "TIMEFRAME",
        t.price AS "VALUE_METRIC",
        CASE WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change ELSE '▼ ' || t.pct_change END || '%' AS "DELTA_MOVE",
        s.trend_signal AS "SIGNAL_STATUS"
    FROM market_data.assets a
    JOIN (
        SELECT DISTINCT ON (ticker) ticker, price, pct_change 
        FROM market_data.ticks 
        ORDER BY ticker, observed_at DESC
    ) t ON a.ticker = t.ticker
    JOIN market_data.trading_signals s ON a.ticker = s.ticker
    WHERE a.ticker IN ('IBM', 'SPX', 'CCMP', 'B500')
)
UNION ALL
(
    -- LAYER B: 36-Month Compounded Predictive Modeling
    -- Formula applied: Current_Value * (1 + Annual_Rate)^3
    SELECT 
        a.ticker AS "SYMBOL",
        LEFT(a.name, 18) AS "ENTITY",
        '36-M PROJECTED' AS "TIMEFRAME",
        ROUND(t.price * (POWER(1 + (CASE 
            WHEN a.ticker = 'IBM' THEN 0.12     -- Cloud/Defensive Alpha allocation
            WHEN a.ticker = 'CCMP' THEN 0.15    -- AI Structural Transformation baseline
            WHEN a.ticker = 'SPX' THEN 0.09     -- Normalized core enterprise market recovery
            ELSE 0.10                           -- Standardized multi-asset benchmark index
        END), 3))::numeric, 2) AS "VALUE_METRIC",
        '▲ ' || ROUND(((POWER(1 + (CASE 
            WHEN a.ticker = 'IBM' THEN 0.12 
            WHEN a.ticker = 'CCMP' THEN 0.15 
            WHEN a.ticker = 'SPX' THEN 0.09 
            ELSE 0.10 
        END), 3) - 1) * 100)::numeric, 1) || '%' AS "DELTA_MOVE",
        CASE 
            WHEN a.ticker = 'IBM' THEN '👑 CORE OUTPERFORM'
            WHEN a.ticker = 'CCMP' THEN '🚀 TECH ALPHA'
            ELSE '⚖️ STRATEGIC ASSET'
        END AS "SIGNAL_STATUS"
    FROM market_data.assets a
    JOIN (
        SELECT DISTINCT ON (ticker) ticker, price 
        FROM market_data.ticks 
        ORDER BY ticker, observed_at DESC
    ) t ON a.ticker = t.ticker
    WHERE a.ticker IN ('IBM', 'SPX', 'CCMP', 'B500')
)
ORDER BY "SYMBOL" ASC, "TIMEFRAME" DESC;

-- Reset output routing back to normal stdout screen display
\o
SELECT '=== SNAPSHOT RECORDED IN DISK ===' AS "SYSTEM_STATUS";
