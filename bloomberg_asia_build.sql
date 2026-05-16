BEGIN; -- Start the transaction

-- sudo -u postgres psql
psql (18.3 (Ubuntu 18.3-1))
Type "help" for help.

postgres=# -- 1. Create the Database
CREATE DATABASE bloomberg_asia;
\c bloomberg_asia

-- 2. Create the Schema
CREATE SCHEMA market_data;

-- 3. Create the Assets Table (Reference for Tickers)
CREATE TABLE market_data.assets (
    ticker TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    exchange TEXT
);

-- 4. Create the High-Frequency Ticks Table
-- Using UUIDv7 logic for the primary key (fastest for time-series)
CREATE TABLE market_data.ticks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker TEXT REFERENCES market_data.assets(ticker),
    price NUMERIC(12,2) NOT NULL,
    pct_change NUMERIC(5,2),
    observed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Create the Headlines Table
CREATE TABLE market_data.headlines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    anchor TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE DATABASE
invalid integer value "Create" for connection option "port"
Previous connection kept
postgres=# \c bloomberg_asia
You are now connected to database "bloomberg_asia" as user "postgres".
bloomberg_asia=# -- Create the Schema
CREATE SCHEMA market_data;

-- Create the Assets Table
CREATE TABLE market_data.assets (
    ticker TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    exchange TEXT
);

-- Create the High-Frequency Ticks Table
CREATE TABLE market_data.ticks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker TEXT REFERENCES market_data.assets(ticker),
    price NUMERIC(12,2) NOT NULL,
    pct_change NUMERIC(5,2),
    observed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create the Headlines Table
CREATE TABLE market_data.headlines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    anchor TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE SCHEMA
CREATE TABLE
CREATE TABLE
CREATE TABLE
bloomberg_asia=# \dt market_data.*
               List of tables
   Schema    |   Name    | Type  |  Owner   
-------------+-----------+-------+----------
 market_data | assets    | table | postgres
 market_data | headlines | table | postgres
 market_data | ticks     | table | postgres
(3 rows)

bloomberg_asia=# -- 1. Create the Database
CREATE DATABASE bloomberg_asia;
\c bloomberg_asia

-- 2. Create the Schema
CREATE SCHEMA market_data;

-- 3. Create the Assets Table (Reference for Tickers)
CREATE TABLE market_data.assets (
    ticker TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    exchange TEXT
);

-- 4. Create the High-Frequency Ticks Table
-- Using UUIDv7 logic for the primary key (fastest for time-series)
CREATE TABLE market_data.ticks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker TEXT REFERENCES market_data.assets(ticker),
    price NUMERIC(12,2) NOT NULL,
    pct_change NUMERIC(5,2),
    observed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Create the Headlines Table
CREATE TABLE market_data.headlines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    anchor TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ERROR:  database "bloomberg_asia" already exists
invalid integer value "Create" for connection option "port"
Previous connection kept
bloomberg_asia=# -- Add the Assets
INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('INDU', 'Dow Jones Industrial Average', 'NYSE'),
('SPX', 'S&P 500 Index', 'CBOE'),
('9984', 'Softbank Group', 'TSE');

-- Add the Ticks from May 14, 2026
INSERT INTO market_data.ticks (ticker, price, pct_change) VALUES 
('INDU', 50077.52, 0.77),
('SPX', 7507.15, 0.84);

-- Add the Headlines
INSERT INTO market_data.headlines (content, anchor) VALUES 
('XI: CHINA TO OPEN DOOR WIDER FOR US BUSINESS', 'HASLINDA AMIN');
INSERT 0 3
INSERT 0 2
INSERT 0 1
bloomberg_asia=# SELECT 
    t.observed_at::time AS "Time",
    a.ticker AS "Ticker",
    a.name AS "Index/Asset",
    t.price AS "Price",
    t.pct_change AS "% Chg",
    (SELECT content FROM market_data.headlines ORDER BY created_at DESC LIMIT 1) AS "Latest Headline"
FROM market_data.ticks t
JOIN market_data.assets a ON t.ticker = a.ticker
ORDER BY t.observed_at DESC;
      Time       | Ticker |         Index/Asset          |  Price   | % Chg |               Latest Headline                
-----------------+--------+------------------------------+----------+-------+----------------------------------------------
 18:48:37.061369 | INDU   | Dow Jones Industrial Average | 50077.52 |  0.77 | XI: CHINA TO OPEN DOOR WIDER FOR US BUSINESS
 18:48:37.061369 | SPX    | S&P 500 Index                |  7507.15 |  0.84 | XI: CHINA TO OPEN DOOR WIDER FOR US BUSINESS
(2 rows)

bloomberg_asia=# INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('NVDA', 'Nvidia Corp', 'NASDAQ'),
('000660', 'SK Hynix Inc', 'KRX');
INSERT 0 2
bloomberg_asia=# CREATE TABLE market_data.projections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticker TEXT REFERENCES market_data.assets(ticker),
    period TEXT DEFAULT '18 Months',
    target_revenue_bn NUMERIC(10,2), -- In Billions (USD for NVDA, KRW for Hynix)
    target_eps NUMERIC(10,2),
    projected_market_cap_tn NUMERIC(5,2), -- The "Teracap" target ($1.00+ Trillion)
    forecast_date DATE DEFAULT CURRENT_DATE
);
CREATE TABLE
bloomberg_asia=# -- Nvidia 18-Month Projection
INSERT INTO market_data.projections (ticker, target_revenue_bn, target_eps, projected_market_cap_tn) 
VALUES ('NVDA', 320.00, 15.50, 4.50);

-- SK Hynix 18-Month Projection
INSERT INTO market_data.projections (ticker, target_revenue_bn, target_eps, projected_market_cap_tn) 
VALUES ('000660', 347000.00, 185.00, 1.05); -- Crossing the Teracap line
INSERT 0 1
INSERT 0 1
bloomberg_asia=# SELECT 
    p.ticker,
    a.name,
    p.target_eps AS "Proj. EPS (2027)",
    p.projected_market_cap_tn AS "Target Cap ($Tn)",
    CASE 
        WHEN p.projected_market_cap_tn >= 1.0 THEN '✅ TERACAP STATUS'
        ELSE '⏳ LARGE-CAP'
    END AS "Status"
FROM market_data.projections p
JOIN market_data.assets a ON p.ticker = a.ticker
WHERE p.ticker IN ('NVDA', '000660');
 ticker |     name     | Proj. EPS (2027) | Target Cap ($Tn) |      Status       
--------+--------------+------------------+------------------+-------------------
 NVDA   | Nvidia Corp  |            15.50 |             4.50 | ✅ TERACAP STATUS
 000660 | SK Hynix Inc |           185.00 |             1.05 | ✅ TERACAP STATUS
(2 rows)

bloomberg_asia=# 
bloomberg_asia=# 
bloomberg_asia=# 
bloomberg_asia=# -- BLOOMBERG THE ASIA TRADE REPORT - GENERATED BY POSTGRES SQL 18.3
-- DATE: MAY 14, 2026

SELECT '--------------------------------------------------------------------------------' AS "BLOOMBERG: THE ASIA TRADE";
SELECT '   MARKET SNAPSHOT & AI SEMICONDUCTOR SPOTLIGHT - 18-MONTH TERACAP OUTLOOK    ' AS "REPORT STATUS: LIVE";
SELECT '--------------------------------------------------------------------------------' AS "";

-- SECTION 1: GLOBAL INDICES & ASSETS
(SELECT 
    'MARKET' AS "CATEGORY",
    a.ticker AS "TICKER",
    a.name AS "ASSET NAME",
    t.price AS "LAST",
    t.pct_change || '%' AS "CHG"
FROM market_data.ticks t
JOIN market_data.assets a ON t.ticker = a.ticker
WHERE a.ticker IN ('INDU', 'SPX', '9984'))

UNION ALL

-- SECTION 2: AI SEMICONDUCTOR "TERACAP" TRACKER
(SELECT 
    'AI-SPOT' AS "CATEGORY",
    a.ticker AS "TICKER",
    a.name AS "ASSET NAME",
    CASE 
        WHEN a.ticker = 'NVDA' THEN 235.07 -- May 2026 Price
        WHEN a.ticker = '000660' THEN 1943000.00 -- KRW Hynix Record High
        ELSE 0 
    END AS "LAST",
    '+4.09%' AS "CHG" -- Reflecting Nvidia's May 14 surge
FROM market_data.assets a
WHERE a.ticker IN ('NVDA', '000660'))

ORDER BY "CATEGORY" DESC;

SELECT '--------------------------------------------------------------------------------' AS "";
SELECT '   18-MONTH TERACAP PROJECTIONS (HBM4 RUBIN CYCLE)                             ' AS "OUTLOOK";
SELECT '--------------------------------------------------------------------------------' AS "";

SELECT 
    ticker AS "TICKER",
    target_revenue_bn AS "REVENUE TARGET (BN)",
    projected_market_cap_tn AS "TARGET CAP (TN)",
    CASE 
        WHEN projected_market_cap_tn >= 4.0 THEN 'DOMINANT'
        WHEN projected_market_cap_tn >= 1.0 THEN '✅ TERACAP'
        ELSE 'APPROACHING'
    END AS "EST. STATUS"
FROM market_data.projections
WHERE ticker IN ('NVDA', '000660');

SELECT '--------------------------------------------------------------------------------' AS "";
SELECT '   LATEST HEADLINES & MACRO EVENTS                                             ' AS "NEWS FEED";
SELECT '--------------------------------------------------------------------------------' AS "";

SELECT 
    created_at::time AS "TIME",
    content AS "HEADLINE",
    anchor AS "REPORTER"
FROM market_data.headlines
ORDER BY created_at DESC;

SELECT '--------------------------------------------------------------------------------' AS "END OF REPORT";
                            BLOOMBERG: THE ASIA TRADE                             
----------------------------------------------------------------------------------
 --------------------------------------------------------------------------------
(1 row)

                              REPORT STATUS: LIVE                               
--------------------------------------------------------------------------------
    MARKET SNAPSHOT & AI SEMICONDUCTOR SPOTLIGHT - 18-MONTH TERACAP OUTLOOK    
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
 CATEGORY | TICKER |          ASSET NAME          |    LAST    |  CHG   
----------+--------+------------------------------+------------+--------
 MARKET   | INDU   | Dow Jones Industrial Average |   50077.52 | 0.77%
 MARKET   | SPX    | S&P 500 Index                |    7507.15 | 0.84%
 AI-SPOT  | NVDA   | Nvidia Corp                  |     235.07 | +4.09%
 AI-SPOT  | 000660 | SK Hynix Inc                 | 1943000.00 | +4.09%
(4 rows)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
                                     OUTLOOK                                     
---------------------------------------------------------------------------------
    18-MONTH TERACAP PROJECTIONS (HBM4 RUBIN CYCLE)                             
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
 TICKER | REVENUE TARGET (BN) | TARGET CAP (TN) | EST. STATUS 
--------+---------------------+-----------------+-------------
 NVDA   |              320.00 |            4.50 | DOMINANT
 000660 |           347000.00 |            1.05 | ✅ TERACAP
(2 rows)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
                                    NEWS FEED                                    
---------------------------------------------------------------------------------
    LATEST HEADLINES & MACRO EVENTS                                             
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
      TIME       |                   HEADLINE                   |   REPORTER    
-----------------+----------------------------------------------+---------------
 18:48:37.062807 | XI: CHINA TO OPEN DOOR WIDER FOR US BUSINESS | HASLINDA AMIN
(1 row)



                                  END OF REPORT                                   
----------------------------------------------------------------------------------
 --------------------------------------------------------------------------------
(1 row)

bloomberg_asia=# INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
-- Asian & Australian Indices
('NKY', 'Nikkei 225', 'TSE'),
('KOSPI', 'Kospi Index', 'KRX'),
('HSI', 'Hang Seng Index', 'HKEX'),
('AS51', 'Sydney SPI 200', 'ASX'),
-- European Indices
('UKX', 'FTSE 100', 'LSE'),
('CAC', 'CAC 40', 'Euronext'),
('DAX', 'DAX Index', 'XETRA'),
('BE600', 'Bloomberg Europe 600', 'EU'),
-- FX & Commodities
('USDJPY', 'USD/JPY Spot', 'FX'),
('GC', 'Gold Spot', 'COMEX'),
('CL', 'WTI Crude Oil', 'NYMEX')
ON CONFLICT (ticker) DO NOTHING;
INSERT 0 11
bloomberg_asia=# -- European & Asian Closing/Intraday Ticks
INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('BE600', 1537.54, 0.77, '2026-05-14 18:57:00-03'),
('UKX', 10372.93, 0.46, '2026-05-14 18:57:00-03'),
('DAX', 24456.26, 1.32, '2026-05-14 18:57:00-03'),
('NKY', 62654.05, -0.98, '2026-05-14 18:57:00-03'),
('KOSPI', 7981.41, 1.75, '2026-05-14 18:57:00-03'),
('HSI', 26389.04, 0.00, '2026-05-14 18:57:00-03'),
('USDJPY', 156.35, 0.01, '2026-05-14 18:57:00-03');

-- Updated US Indices (High-Water Marks)
INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('INDU', 50063.46, 0.75, '2026-05-14 18:57:00-03'),
('SPX', 7501.24, 0.77, '2026-05-14 18:57:00-03'),
('CCMP', 26635.22, 0.88, '2026-05-14 18:57:00-03');
INSERT 0 7
ERROR:  insert or update on table "ticks" violates foreign key constraint "ticks_ticker_fkey"
DETAIL:  Key (ticker)=(CCMP) is not present in table "assets".
bloomberg_asia=# INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('CCMP', 'Nasdaq Composite Index', 'NASDAQ')
ON CONFLICT (ticker) DO NOTHING;
INSERT 0 1
bloomberg_asia=# INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('CCMP', 26635.22, 0.88, '2026-05-14 18:57:00-03');
INSERT 0 1
bloomberg_asia=# 
bloomberg_asia=# -- BLOOMBERG THE ASIA TRADE: CONSOLIDATED GLOBAL VIEW
-- VERSION: PG 18.3 ENGINE

SELECT '================================================================================' AS "TERMINAL";
SELECT '   GLOBAL MARKET SUMMARY & AI SEMI-STRATEGY | MAY 14, 2026                      ' AS "STATUS: ACTIVE";
SELECT '================================================================================' AS "";

-- SECTION A: THE BIG PICTURE (LATEST TICKERS)
SELECT 
    a.exchange AS "EXCH",
    t.ticker AS "SYMBOL",
    a.name AS "INDEX NAME",
    t.price AS "LAST",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change || '%'
        WHEN t.pct_change < 0 THEN '▼ ' || t.pct_change || '%'
        ELSE '— ' || t.pct_change || '%'
    END AS "CHG %"
FROM (SELECT DISTINCT ON (ticker) * FROM market_data.ticks ORDER BY ticker, observed_at DESC) t
JOIN market_data.assets a ON t.ticker = a.ticker
WHERE t.ticker IN ('INDU', 'SPX', 'CCMP', 'DAX', 'NKY', 'KOSPI')
ORDER BY t.pct_change DESC;

-- SECTION B: THE AI "TERACAP" 18-MONTH RACE
SELECT '--------------------------------------------------------------------------------' AS "";
SELECT '   18-MONTH SEMICONDUCTOR OUTLOOK (HBM4 RUBIN CYCLE)                           ' AS "PROJECTIONS";
SELECT '--------------------------------------------------------------------------------' AS "";

SELECT 
    p.ticker AS "TICKER",
    p.target_revenue_bn AS "REV TARGET (BN)",
    p.projected_market_cap_tn AS "TARGET CAP ($Tn)",
    CASE 
        WHEN p.projected_market_cap_tn >= 4.0 THEN 'MARKET LEADER'
        WHEN p.projected_market_cap_tn >= 1.0 THEN '✅ TERACAP'
        ELSE 'HBM HUB'
    END AS "STATUS"
FROM market_data.projections p
WHERE p.ticker IN ('NVDA', '000660');

-- SECTION C: TOP STORIES FROM YOUR SCREENSHOTS
SELECT '--------------------------------------------------------------------------------' AS "";
SELECT '   LATEST BLOOMBERG TOP STORIES                                                ' AS "HEADLINES";
SELECT '--------------------------------------------------------------------------------' AS "";

SELECT 
    created_at::time AS "TIME",
    content AS "STORY",
    anchor AS "ANCHOR/DESK"
FROM market_data.headlines
ORDER BY created_at DESC LIMIT 5;

SELECT '================================================================================' AS "END OF FEED";
                                     TERMINAL                                     
----------------------------------------------------------------------------------
 ================================================================================
(1 row)

                                  STATUS: ACTIVE                                  
----------------------------------------------------------------------------------
    GLOBAL MARKET SUMMARY & AI SEMI-STRATEGY | MAY 14, 2026                      
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...====================================================' AS "";
                                                                    ^
  EXCH  | SYMBOL |          INDEX NAME          |   LAST   |  CHG %   
--------+--------+------------------------------+----------+----------
 KRX    | KOSPI  | Kospi Index                  |  7981.41 | ▲ 1.75%
 XETRA  | DAX    | DAX Index                    | 24456.26 | ▲ 1.32%
 NASDAQ | CCMP   | Nasdaq Composite Index       | 26635.22 | ▲ 0.88%
 CBOE   | SPX    | S&P 500 Index                |  7507.15 | ▲ 0.84%
 NYSE   | INDU   | Dow Jones Industrial Average | 50077.52 | ▲ 0.77%
 TSE    | NKY    | Nikkei 225                   | 62654.05 | ▼ -0.98%
(6 rows)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
                                   PROJECTIONS                                   
---------------------------------------------------------------------------------
    18-MONTH SEMICONDUCTOR OUTLOOK (HBM4 RUBIN CYCLE)                           
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
 TICKER | REV TARGET (BN) | TARGET CAP ($Tn) |    STATUS     
--------+-----------------+------------------+---------------
 NVDA   |          320.00 |             4.50 | MARKET LEADER
 000660 |       347000.00 |             1.05 | ✅ TERACAP
(2 rows)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
                                    HEADLINES                                    
---------------------------------------------------------------------------------
    LATEST BLOOMBERG TOP STORIES                                                
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
      TIME       |                    STORY                     |  ANCHOR/DESK  
-----------------+----------------------------------------------+---------------
 18:48:37.062807 | XI: CHINA TO OPEN DOOR WIDER FOR US BUSINESS | HASLINDA AMIN
(1 row)

                                   END OF FEED                                    
----------------------------------------------------------------------------------
 ================================================================================
(1 row)

bloomberg_asia=# -- Add Commodities to Assets
INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('GOLD', 'Gold Spot (Ouro)', 'COMEX'),
('SILV', 'Silver Spot (Prata)', 'COMEX'),
('COPP', 'Copper (Cobre)', 'LME')
ON CONFLICT (ticker) DO NOTHING;

-- Add Commodity Ticks & Latest Headlines
INSERT INTO market_data.ticks (ticker, price, pct_change) VALUES 
('GOLD', 2482.15, 0.45),
('SILV', 31.20, 1.12),
('COPP', 4.85, -0.22);

INSERT INTO market_data.headlines (content, anchor) VALUES 
('TRUMP TO MEET XI TODAY IN BEIJING', 'THE ASIA TRADE'),
('OIL HEADS FOR WEEKLY ADVANCE WITH IRAN WAR RESOLUTION AT IMPASSE', 'TOP STORIES');
INSERT 0 3
INSERT 0 3
INSERT 0 2
bloomberg_asia=# 
bloomberg_asia=# -- BLOOMBERG THE ASIA TRADE REPORT BY POSTGRES SQL
-- FINAL CONSOLIDATED VIEW: MAY 14, 2026

SELECT '================================================================================' AS "TERMINAL";
SELECT '   BLOOMBERG: THE ASIA TRADE - GLOBAL CROSS-ASSET MONITOR                      ' AS "STATUS: LIVE";
SELECT '================================================================================' AS "";

-- SECTION 1: GLOBAL INDICES & TECH LEADERS
SELECT 
    a.exchange AS "EXCH",
    t.ticker AS "SYMBOL",
    LEFT(a.name, 25) AS "ASSET",
    t.price AS "LAST",
    CASE WHEN t.pct_change > 0 THEN '▲ ' ELSE '▼ ' END || ABS(t.pct_change) || '%' AS "CHANGE"
FROM (SELECT DISTINCT ON (ticker) * FROM market_data.ticks ORDER BY ticker, observed_at DESC) t
JOIN market_data.assets a ON t.ticker = a.ticker
WHERE t.ticker IN ('INDU', 'SPX', 'CCMP', 'NKY', 'NVDA', '000660')
ORDER BY t.price DESC;

-- SECTION 2: GEOPOLITICAL HEADLINES & RECENT MOVERS
SELECT '--------------------------------------------------------------------------------' AS "";
SELECT '   LATEST MARKET-MOVING HEADLINES                                              ' AS "TOP STORIES";
SELECT '--------------------------------------------------------------------------------' AS "";

SELECT 
    created_at::time(0) AS "TIME",
    content AS "HEADLINE",
    anchor AS "ANCHOR"
FROM market_data.headlines
ORDER BY created_at DESC LIMIT 3;

-- SECTION 3: 18-MONTH TERACAP OUTLOOK
SELECT '--------------------------------------------------------------------------------' AS "";
SELECT '   18-MONTH TERACAP EARNINGS PROJECTION (NVDA / SK HYNIX)                      ' AS "AI OUTLOOK";
SELECT '--------------------------------------------------------------------------------' AS "";

SELECT 
    ticker AS "TICKER",
    target_revenue_bn AS "REVENUE TARGET",
    projected_market_cap_tn AS "TARGET CAP (TN)",
    '✅ AHEAD' AS "PACE"
FROM market_data.projections;

SELECT '================================================================================' AS "END OF REPORT";
                                     TERMINAL                                     
----------------------------------------------------------------------------------
 ================================================================================
(1 row)

                                  STATUS: LIVE                                   
---------------------------------------------------------------------------------
    BLOOMBERG: THE ASIA TRADE - GLOBAL CROSS-ASSET MONITOR                      
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...====================================================' AS "";
                                                                    ^
  EXCH  | SYMBOL |           ASSET           |   LAST   | CHANGE  
--------+--------+---------------------------+----------+---------
 TSE    | NKY    | Nikkei 225                | 62654.05 | ▼ 0.98%
 NYSE   | INDU   | Dow Jones Industrial Aver | 50077.52 | ▲ 0.77%
 NASDAQ | CCMP   | Nasdaq Composite Index    | 26635.22 | ▲ 0.88%
 CBOE   | SPX    | S&P 500 Index             |  7507.15 | ▲ 0.84%
(4 rows)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
                                   TOP STORIES                                   
---------------------------------------------------------------------------------
    LATEST MARKET-MOVING HEADLINES                                              
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
   TIME   |                             HEADLINE                             |     ANCHOR     
----------+------------------------------------------------------------------+----------------
 19:00:38 | TRUMP TO MEET XI TODAY IN BEIJING                                | THE ASIA TRADE
 19:00:38 | OIL HEADS FOR WEEKLY ADVANCE WITH IRAN WAR RESOLUTION AT IMPASSE | TOP STORIES
 18:48:37 | XI: CHINA TO OPEN DOOR WIDER FOR US BUSINESS                     | HASLINDA AMIN
(3 rows)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
                                   AI OUTLOOK                                    
---------------------------------------------------------------------------------
    18-MONTH TERACAP EARNINGS PROJECTION (NVDA / SK HYNIX)                      
(1 row)

ERROR:  zero-length delimited identifier at or near """"
LINE 1: ...----------------------------------------------------' AS "";
                                                                    ^
 TICKER | REVENUE TARGET | TARGET CAP (TN) |   PACE   
--------+----------------+-----------------+----------
 NVDA   |         320.00 |            4.50 | ✅ AHEAD
 000660 |      347000.00 |            1.05 | ✅ AHEAD
(2 rows)

                                  END OF REPORT                                   
----------------------------------------------------------------------------------
 ================================================================================
(1 row)

bloomberg_asia=# \dt market_data.*
                List of tables
   Schema    |    Name     | Type  |  Owner   
-------------+-------------+-------+----------
 market_data | assets      | table | postgres
 market_data | headlines   | table | postgres
 market_data | projections | table | postgres
 market_data | ticks       | table | postgres
(4 rows)

bloomberg_asia=# \dt market_data.*SELECT 'assets' as table, count(*) FROM market_data.assets
UNION ALL
SELECT 'ticks', count(*) FROM market_data.ticks
UNION ALL
SELECT 'headlines', count(*) FROM market_data.headlines
UNION ALL
SELECT 'projections', count(*) FROM market_data.projections;
Did not find any tables named "market_data.*SELECT".
\dt: extra argument "assets" ignored
\dt: extra argument "as" ignored
\dt: extra argument "table," ignored
\dt: extra argument "count(*)" ignored
\dt: extra argument "FROM" ignored
\dt: extra argument "market_data.assets" ignored
\dt: extra argument "UNION" ignored
\dt: extra argument "ALL" ignored
\dt: extra argument "SELECT" ignored
\dt: extra argument "ticks," ignored
\dt: extra argument "count(*)" ignored
\dt: extra argument "FROM" ignored
\dt: extra argument "market_data.ticks" ignored
\dt: extra argument "UNION" ignored
\dt: extra argument "ALL" ignored
\dt: extra argument "SELECT" ignored
\dt: extra argument "headlines," ignored
\dt: extra argument "count(*)" ignored
\dt: extra argument "FROM" ignored
\dt: extra argument "market_data.headlines" ignored
\dt: extra argument "UNION" ignored
\dt: extra argument "ALL" ignored
\dt: extra argument "SELECT" ignored
\dt: extra argument "projections," ignored
\dt: extra argument "count(*)" ignored
\dt: extra argument "FROM" ignored
\dt: extra argument "market_data.projections;" ignored
bloomberg_asia=# \dt market_data.*
                List of tables
   Schema    |    Name     | Type  |  Owner   
-------------+-------------+-------+----------
 market_data | assets      | table | postgres
 market_data | headlines   | table | postgres
 market_data | projections | table | postgres
 market_data | ticks       | table | postgres
(4 rows)

bloomberg_asia=# SELECT 'assets' as "Table Name", count(*) as "Row Count" FROM market_data.assets
UNION ALL
SELECT 'ticks', count(*) FROM market_data.ticks
UNION ALL
SELECT 'headlines', count(*) FROM market_data.headlines
UNION ALL
SELECT 'projections', count(*) FROM market_data.projections;
 Table Name  | Row Count 
-------------+-----------
 assets      |        20
 ticks       |        13
 headlines   |         3
 projections |         2
(4 rows)

bloomberg_asia=# SELECT 'assets' as table, count(*) FROM market_data.assets
UNION ALL
SELECT 'ticks', count(*) FROM market_data.ticks
UNION ALL
SELECT 'headlines', count(*) FROM market_data.headlines
UNION ALL
SELECT 'projections', count(*) FROM market_data.projections;
    table    | count 
-------------+-------
 assets      |    20
 ticks       |    13
 headlines   |     3
 projections |     2
(4 rows)

bloomberg_asia=# -- Combining Live Ticks, Asset Metadata, and Projections
SELECT 
    a.ticker AS "SYMBOL",
    a.name AS "ASSET NAME",
    t.price AS "CURRENT LAST",
    p.target_revenue_bn AS "18M REV TARGET",
    p.projected_market_cap_tn AS "TARGET CAP ($Tn)",
    'PROJECTION' AS "DATA_SOURCE"
FROM market_data.assets a
JOIN market_data.projections p ON a.ticker = p.ticker
LEFT JOIN (
    SELECT DISTINCT ON (ticker) ticker, price 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker

UNION ALL

-- Adding the Global Indices for context
SELECT 
    a.ticker,
    a.name,
    t.price,
    NULL, -- No revenue target for indices
    NULL, -- No market cap target for indices
    'LIVE TICK'
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, price 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
WHERE a.ticker IN ('SPX', 'INDU', 'CCMP', 'NKY')

ORDER BY "DATA_SOURCE" DESC, "CURRENT LAST" DESC;
 SYMBOL |          ASSET NAME          | CURRENT LAST | 18M REV TARGET | TARGET CAP ($Tn) | DATA_SOURCE 
--------+------------------------------+--------------+----------------+------------------+-------------
 NVDA   | Nvidia Corp                  |              |         320.00 |             4.50 | PROJECTION
 000660 | SK Hynix Inc                 |              |      347000.00 |             1.05 | PROJECTION
 NKY    | Nikkei 225                   |     62654.05 |                |                  | LIVE TICK
 INDU   | Dow Jones Industrial Average |     50077.52 |                |                  | LIVE TICK
 CCMP   | Nasdaq Composite Index       |     26635.22 |                |                  | LIVE TICK
 SPX    | S&P 500 Index                |      7507.15 |                |                  | LIVE TICK
(6 rows)

bloomberg_asia=# -- Step 1: Expand Assets with Energy and Banking entities
INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('CVX', 'Chevron Corporation', 'NYSE'),
('BP', 'BP p.l.c.', 'NYSE'),
('MSFT', 'Microsoft Corp', 'NASDAQ'),
('ORCL', 'Oracle Corp', 'NYSE'),
('HSBC', 'HSBC Holdings', 'NYSE'),
('IBM', 'International Business Machines', 'NYSE'),
('AMZN', 'Amazon.com Inc', 'NASDAQ'),
('JPM', 'JPMorgan Chase & Co', 'NYSE'),
('NU', 'Nu Holdings Ltd', 'NYSE'),
('ITUB', 'Itaú Unibanco', 'NYSE'),
('BSBR', 'Banco Santander Brasil', 'NYSE'),
('BDORY', 'Banco do Brasil', 'OTC'),
('TSLA', 'Tesla Inc', 'NASDAQ'),
('BK', 'BNY Mellon', 'NYSE'),
('BAC', 'Bank of America', 'NYSE'),
('MS', 'Morgan Stanley', 'NYSE')
ON CONFLICT (ticker) DO NOTHING;

-- Step 2: Create a dedicated Energy Sector table for BigOil correlations
CREATE TABLE IF NOT EXISTS market_data.energy_sector (
    ticker VARCHAR(10) PRIMARY KEY REFERENCES market_data.assets(ticker),
    market_cap_bn NUMERIC,
    one_year_target NUMERIC,
    avg_volume_mln NUMERIC,
    last_close NUMERIC
);

-- Step 3: Populate Energy specific data from May 14, 2026 screenshots
INSERT INTO market_data.energy_sector (ticker, market_cap_bn, one_year_target, avg_volume_mln, last_close) VALUES 
('CVX', 370.43, 217.00, 9.83, 185.95)
ON CONFLICT (ticker) DO UPDATE SET last_close = EXCLUDED.last_close;
INSERT 0 16
CREATE TABLE
INSERT 0 1
bloomberg_asia=# INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('MSFT', 0, -0.63, '2026-05-14 19:05:00-03'),
('ORCL', 0, 1.57, '2026-05-14 19:05:00-03'),
('HSBC', 0, 0.73, '2026-05-14 19:05:00-03'),
('IBM', 0, -2.09, '2026-05-14 19:05:00-03'),
('CVX', 186.50, 0.03, '2026-05-14 19:05:00-03'),
('AMZN', 0, 1.62, '2026-05-14 19:05:00-03'),
('JPM', 0, -1.52, '2026-05-14 19:05:00-03'),
('NU', 0, -3.39, '2026-05-14 19:05:00-03'),
('ITUB', 0, -3.09, '2026-05-14 19:05:00-03'),
('BSBR', 0, -4.42, '2026-05-14 19:05:00-03'),
('BDORY', 0, -6.49, '2026-05-14 19:05:00-03'),
('BP', 0, -0.59, '2026-05-14 19:05:00-03'),
('TSLA', 0, 2.73, '2026-05-14 19:05:00-03');
INSERT 0 13
bloomberg_asia=# -- BLOOMBERG: ENERGY & GLOBAL CORRELATION JOINT
SELECT 
    a.ticker AS "TICKER",
    a.name AS "ENTITY",
    t.pct_change || '%' AS "MOVE",
    e.one_year_target AS "1Y TARGET",
    ROUND(((e.one_year_target - t.price) / t.price * 100), 2) || '%' AS "UPSIDE",
    (SELECT content FROM market_data.headlines 
     WHERE content ILIKE '%Oil%' OR content ILIKE '%Iran%' 
     ORDER BY created_at DESC LIMIT 1) AS "SECTOR CATALYST"
FROM market_data.assets a
JOIN market_data.ticks t ON a.ticker = t.ticker
LEFT JOIN market_data.energy_sector e ON a.ticker = e.ticker
WHERE a.ticker IN ('CVX', 'BP', 'SPX', 'TSLA', 'AMZN')
AND t.observed_at > '2026-05-14 19:00:00'
ORDER BY t.pct_change DESC;
 TICKER | ENTITY | MOVE | 1Y TARGET | UPSIDE | SECTOR CATALYST 
--------+--------+------+-----------+--------+-----------------
(0 rows)

bloomberg_asia=# UPDATE market_data.ticks SET price = 186.50 WHERE ticker = 'CVX' AND observed_at = '2026-05-14 19:05:00-03';
UPDATE market_data.ticks SET price = 38.42 WHERE ticker = 'BP' AND observed_at = '2026-05-14 19:05:00-03';
-- Adding approximate intraday prices for upside context
UPDATE market_data.ticks SET price = 175.40 WHERE ticker = 'TSLA' AND observed_at = '2026-05-14 19:05:00-03';
UPDATE market_data.ticks SET price = 188.20 WHERE ticker = 'AMZN' AND observed_at = '2026-05-14 19:05:00-03';
UPDATE 1
UPDATE 1
UPDATE 1
UPDATE 1
bloomberg_asia=# -- BLOOMBERG: ENERGY & ENTITY CORRELATION JOINT (FIXED)
SELECT 
    a.ticker AS "TICKER",
    LEFT(a.name, 20) AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    COALESCE(e.one_year_target::text, 'N/A') AS "1Y TARGET",
    CASE 
        WHEN e.one_year_target IS NOT NULL AND t.price > 0 
        THEN ROUND(((e.one_year_target - t.price) / t.price * 100), 2) || '%' 
        ELSE '—' 
    END AS "UPSIDE",
    (SELECT LEFT(content, 45) || '...' FROM market_data.headlines 
     WHERE content ILIKE '%Oil%' OR content ILIKE '%Iran%' 
     ORDER BY created_at DESC LIMIT 1) AS "SECTOR CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, price, pct_change, observed_at 
    FROM market_data.ticks 
    WHERE observed_at >= '2026-05-14 16:00:00'
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
LEFT JOIN market_data.energy_sector e ON a.ticker = e.ticker
WHERE a.ticker IN ('CVX', 'BP', 'TSLA', 'AMZN', 'SPX')
ORDER BY t.pct_change DESC;
 TICKER |       ENTITY        |   MOVE   | 1Y TARGET | UPSIDE |                 SECTOR CATALYST                  
--------+---------------------+----------+-----------+--------+--------------------------------------------------
 TSLA   | Tesla Inc           | ▲ 2.73%  | N/A       | —      | OIL HEADS FOR WEEKLY ADVANCE WITH IRAN WAR RE...
 AMZN   | Amazon.com Inc      | ▲ 1.62%  | N/A       | —      | OIL HEADS FOR WEEKLY ADVANCE WITH IRAN WAR RE...
 SPX    | S&P 500 Index       | ▲ 0.84%  | N/A       | —      | OIL HEADS FOR WEEKLY ADVANCE WITH IRAN WAR RE...
 CVX    | Chevron Corporation | ▲ 0.03%  | 217.00    | 16.35% | OIL HEADS FOR WEEKLY ADVANCE WITH IRAN WAR RE...
 BP     | BP p.l.c.           | ▼ -0.59% | N/A       | —      | OIL HEADS FOR WEEKLY ADVANCE WITH IRAN WAR RE...
(5 rows)

bloomberg_asia=# -- Adding Signal Logic to the Correlation Joint
CREATE OR REPLACE VIEW market_data.trading_signals AS
SELECT 
    t.ticker,
    t.pct_change,
    e.one_year_target,
    CASE 
        WHEN t.ticker IN ('TSLA', 'AMZN') AND t.pct_change > 1.5 THEN '🚀 STRONG BUY (Growth Momentum)'
        WHEN e.one_year_target > t.price * 1.15 THEN '💎 BUY (Deep Value)'
        WHEN t.pct_change BETWEEN -0.5 AND 0.5 THEN '⚖️ HOLD (Neutral)'
        WHEN t.pct_change < -3.0 THEN '⚠️ SELL (Capital Flight)'
        ELSE '🔎 MONITOR'
    END AS "TREND_SIGNAL"
FROM market_data.ticks t
LEFT JOIN market_data.energy_sector e ON t.ticker = e.ticker
WHERE t.observed_at >= '2026-05-14 16:00:00';
CREATE VIEW
bloomberg_asia=# -- FINAL EXECUTIVE TREND REPORT: MAY 14, 2026
SELECT 
    a.ticker AS "TICKER",
    a.name AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.TREND_SIGNAL AS "SIGNAL",
    (SELECT content FROM market_data.headlines 
     WHERE content ILIKE '%Xi%' OR content ILIKE '%Trump%' 
     ORDER BY created_at DESC LIMIT 1) AS "MACRO CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, price, pct_change, observed_at 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
WHERE a.ticker IN ('TSLA', 'AMZN', 'CVX', 'BP', 'BDORY', 'BSBR')
ORDER BY t.pct_change DESC;
ERROR:  column s.trend_signal does not exist
LINE 8:     s.TREND_SIGNAL AS "SIGNAL",
            ^
bloomberg_asia=# -- FINAL EXECUTIVE TREND REPORT: MAY 14, 2026
SELECT 
    a.ticker AS "TICKER",
    a.name AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.TREND_SIGNAL AS "SIGNAL",
    (SELECT content FROM market_data.headlines 
     WHERE content ILIKE '%Xi%' OR content ILIKE '%Trump%' 
     ORDER BY created_at DESC LIMIT 1) AS "MACRO CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, price, pct_change, observed_at 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
WHERE a.ticker IN ('TSLA', 'AMZN', 'CVX', 'BP', 'BDORY', 'BSBR')
ORDER BY t.pct_change DESC;
ERROR:  column s.trend_signal does not exist
LINE 8:     s.TREND_SIGNAL AS "SIGNAL",
            ^
bloomberg_asia=# CREATE OR REPLACE VIEW market_data.trading_signals AS
SELECT 
    t.ticker,
    CASE 
        WHEN t.ticker IN ('TSLA', 'AMZN') AND t.pct_change > 1.0 THEN '🚀 STRONG BUY'
        WHEN e.one_year_target > t.price * 1.10 THEN '💎 BUY (VALUE)'
        WHEN t.pct_change < -4.0 THEN '⚠️ STRONG SELL'
        WHEN t.pct_change BETWEEN -0.5 AND 0.5 THEN '⚖️ HOLD'
        ELSE '🔎 MONITOR'
    END AS trend_signal -- No quotes here = lowercase in the engine
FROM (SELECT DISTINCT ON (ticker) * FROM market_data.ticks ORDER BY ticker, observed_at DESC) t
LEFT JOIN market_data.energy_sector e ON t.ticker = e.ticker;
ERROR:  cannot drop columns from view
bloomberg_asia=# DROP VIEW IF EXISTS market_data.trading_signals;

CREATE VIEW market_data.trading_signals AS
SELECT 
    t.ticker,
    CASE 
        WHEN t.ticker IN ('TSLA', 'AMZN') AND t.pct_change > 1.0 THEN '🚀 STRONG BUY'
        WHEN e.one_year_target > t.price * 1.10 THEN '💎 BUY (VALUE)'
        WHEN t.pct_change < -4.0 THEN '⚠️ STRONG SELL'
        WHEN t.pct_change BETWEEN -0.5 AND 0.5 THEN '⚖️ HOLD'
        ELSE '🔎 MONITOR'
    END AS trend_signal
FROM (SELECT DISTINCT ON (ticker) * FROM market_data.ticks ORDER BY ticker, observed_at DESC) t
LEFT JOIN market_data.energy_sector e ON t.ticker = e.ticker;
DROP VIEW
CREATE VIEW
bloomberg_asia=# -- BLOOMBERG ASIA TRADE: EXECUTIVE TREND REPORT (FIXED)
SELECT 
    a.ticker AS "TICKER",
    LEFT(a.name, 20) AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.trend_signal AS "SIGNAL",
    (SELECT content FROM market_data.headlines 
     WHERE content ILIKE '%Xi%' OR content ILIKE '%Trump%' 
     ORDER BY created_at DESC LIMIT 1) AS "LATEST CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, pct_change 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
WHERE a.ticker IN ('TSLA', 'AMZN', 'CVX', 'BP', 'BDORY', 'BSBR')
ORDER BY t.pct_change DESC;
 TICKER |        ENTITY        |   MOVE   |     SIGNAL     |          LATEST CATALYST          
--------+----------------------+----------+----------------+-----------------------------------
 TSLA   | Tesla Inc            | ▲ 2.73%  | 🚀 STRONG BUY  | TRUMP TO MEET XI TODAY IN BEIJING
 AMZN   | Amazon.com Inc       | ▲ 1.62%  | 🚀 STRONG BUY  | TRUMP TO MEET XI TODAY IN BEIJING
 CVX    | Chevron Corporation  | ▲ 0.03%  | 💎 BUY (VALUE) | TRUMP TO MEET XI TODAY IN BEIJING
 BP     | BP p.l.c.            | ▼ -0.59% | 🔎 MONITOR     | TRUMP TO MEET XI TODAY IN BEIJING
 BSBR   | Banco Santander Bras | ▼ -4.42% | ⚠️ STRONG SELL  | TRUMP TO MEET XI TODAY IN BEIJING
 BDORY  | Banco do Brasil      | ▼ -6.49% | ⚠️ STRONG SELL  | TRUMP TO MEET XI TODAY IN BEIJING
(6 rows)

bloomberg_asia=# DROP VIEW IF EXISTS market_data.trading_signals;

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
DROP VIEW
CREATE VIEW
bloomberg_asia=# -- BLOOMBERG ASIA TRADE: EXECUTIVE TREND REPORT (RUNNING-TO-SELL EDITION)
SELECT 
    a.ticker AS "TICKER",
    LEFT(a.name, 20) AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.trend_signal AS "SIGNAL",
    (SELECT content FROM market_data.headlines 
     WHERE content ILIKE '%Trump%' OR content ILIKE '%Xi%' 
     ORDER BY created_at DESC LIMIT 1) AS "LATEST CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, pct_change 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
WHERE a.ticker IN ('TSLA', 'AMZN', 'CVX', 'BP', 'BDORY', 'BSBR')
ORDER BY t.pct_change DESC;
 TICKER |        ENTITY        |   MOVE   |      SIGNAL      |          LATEST CATALYST          
--------+----------------------+----------+------------------+-----------------------------------
 TSLA   | Tesla Inc            | ▲ 2.73%  | 🚀 STRONG BUY    | TRUMP TO MEET XI TODAY IN BEIJING
 AMZN   | Amazon.com Inc       | ▲ 1.62%  | 🚀 STRONG BUY    | TRUMP TO MEET XI TODAY IN BEIJING
 CVX    | Chevron Corporation  | ▲ 0.03%  | 💎 BUY (VALUE)   | TRUMP TO MEET XI TODAY IN BEIJING
 BP     | BP p.l.c.            | ▼ -0.59% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 BSBR   | Banco Santander Bras | ▼ -4.42% | 🏃💨 RUN TO SELL | TRUMP TO MEET XI TODAY IN BEIJING
 BDORY  | Banco do Brasil      | ▼ -6.49% | 🏃💨 RUN TO SELL | TRUMP TO MEET XI TODAY IN BEIJING
(6 rows)

bloomberg_asia=# -- Step 1: Register New Global Indices
INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('MXAP', 'MSCI AC Asia Pacific', 'MSCI'),
('OMX', 'Stockholm OMX Index', 'NASDAQ NORDIC')
ON CONFLICT (ticker) DO NOTHING;

-- Step 2: Ingest the Green Intraday Ticks
INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('MXAP', 272.60, 0.20, '2026-05-14 19:13:00-03'),
('OMX', 3048.11, 0.05, '2026-05-14 19:13:00-03');

-- Step 3: Add the Geopolitical 'Immunity' Headline
INSERT INTO market_data.headlines (content, anchor) VALUES 
('CLEAN ENERGY SEEN AS STRUCTURALLY IMMUNE TO HORMUZ-STYLE SHOCK', 'TOP NEWS');
INSERT 0 2
INSERT 0 2
INSERT 0 1
bloomberg_asia=# -- BLOOMBERG ASIA TRADE: MULTI-REGION GAINS REPORT
SELECT 
    a.ticker AS "TICKER",
    LEFT(a.name, 20) AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.trend_signal AS "SIGNAL",
    (SELECT content FROM market_data.headlines 
     ORDER BY created_at DESC LIMIT 1) AS "LATEST CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, pct_change 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
WHERE a.ticker IN ('MXAP', 'OMX', 'TSLA', 'AMZN', 'CVX', 'BDORY')
ORDER BY t.pct_change DESC;
 TICKER |        ENTITY        |   MOVE   |      SIGNAL      |                        LATEST CATALYST                         
--------+----------------------+----------+------------------+----------------------------------------------------------------
 TSLA   | Tesla Inc            | ▲ 2.73%  | 🚀 STRONG BUY    | CLEAN ENERGY SEEN AS STRUCTURALLY IMMUNE TO HORMUZ-STYLE SHOCK
 AMZN   | Amazon.com Inc       | ▲ 1.62%  | 🚀 STRONG BUY    | CLEAN ENERGY SEEN AS STRUCTURALLY IMMUNE TO HORMUZ-STYLE SHOCK
 MXAP   | MSCI AC Asia Pacific | ▲ 0.20%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY IMMUNE TO HORMUZ-STYLE SHOCK
 OMX    | Stockholm OMX Index  | ▲ 0.05%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY IMMUNE TO HORMUZ-STYLE SHOCK
 CVX    | Chevron Corporation  | ▲ 0.03%  | 💎 BUY (VALUE)   | CLEAN ENERGY SEEN AS STRUCTURALLY IMMUNE TO HORMUZ-STYLE SHOCK
 BDORY  | Banco do Brasil      | ▼ -6.49% | 🏃💨 RUN TO SELL | CLEAN ENERGY SEEN AS STRUCTURALLY IMMUNE TO HORMUZ-STYLE SHOCK
(6 rows)

bloomberg_asia=# INSERT INTO market_data.ticks (ticker, pct_change, observed_at) VALUES 
('MSFT', -0.63, '2026-05-14 19:15:00-03'),
('ORCL', 1.57, '2026-05-14 19:15:00-03'),
('HSBC', 0.73, '2026-05-14 19:15:00-03'),
('IBM', -2.09, '2026-05-14 19:15:00-03'),
('CVX', 0.03, '2026-05-14 19:15:00-03'),
('AMZN', 1.62, '2026-05-14 19:15:00-03'),
('JPM', -1.52, '2026-05-14 19:15:00-03'),
('JEPQ', 0.39, '2026-05-14 19:15:00-03'),
('NU', -3.39, '2026-05-14 19:15:00-03'),
('ITUB', -3.09, '2026-05-14 19:15:00-03'),
('BSBR', -4.42, '2026-05-14 19:15:00-03'),
('BDORY', -6.49, '2026-05-14 19:15:00-03'),
('NDX', 0.73, '2026-05-14 19:15:00-03'),
('BP', -0.59, '2026-05-14 19:15:00-03'),
('BK', 1.16, '2026-05-14 19:15:00-03'),
('BAC', -1.85, '2026-05-14 19:15:00-03'),
('MS', 1.02, '2026-05-14 19:15:00-03'),
('TSLA', 2.73, '2026-05-14 19:15:00-03')
ON CONFLICT DO NOTHING;
ERROR:  null value in column "price" of relation "ticks" violates not-null constraint
DETAIL:  Failing row contains (5832a226-57a5-48a0-8c5f-3711ad05ab61, MSFT, null, -0.63, 2026-05-14 17:15:00-05).
bloomberg_asia=# 
bloomberg_asia=# 
bloomberg_asia=# INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at)
VALUES 
    ('MSFT', (SELECT price FROM market_data.ticks WHERE ticker = 'MSFT' ORDER BY observed_at DESC LIMIT 1), -0.63, '2026-05-14 19:15:00-03'),
    ('ORCL', (SELECT price FROM market_data.ticks WHERE ticker = 'ORCL' ORDER BY observed_at DESC LIMIT 1), 1.57, '2026-05-14 19:15:00-03'),
    ('HSBC', (SELECT price FROM market_data.ticks WHERE ticker = 'HSBC' ORDER BY observed_at DESC LIMIT 1), 0.73, '2026-05-14 19:15:00-03'),
    ('IBM', (SELECT price FROM market_data.ticks WHERE ticker = 'IBM' ORDER BY observed_at DESC LIMIT 1), -2.09, '2026-05-14 19:15:00-03'),
    ('CVX', 186.50, 0.03, '2026-05-14 19:15:00-03'), -- Price confirmed from Nasdaq image
    ('AMZN', (SELECT price FROM market_data.ticks WHERE ticker = 'AMZN' ORDER BY observed_at DESC LIMIT 1), 1.62, '2026-05-14 19:15:00-03'),
    ('JPM', (SELECT price FROM market_data.ticks WHERE ticker = 'JPM' ORDER BY observed_at DESC LIMIT 1), -1.52, '2026-05-14 19:15:00-03'),
    ('NU', (SELECT price FROM market_data.ticks WHERE ticker = 'NU' ORDER BY observed_at DESC LIMIT 1), -3.39, '2026-05-14 19:15:00-03'),
    ('ITUB', (SELECT price FROM market_data.ticks WHERE ticker = 'ITUB' ORDER BY observed_at DESC LIMIT 1), -3.09, '2026-05-14 19:15:00-03'),
    ('BSBR', (SELECT price FROM market_data.ticks WHERE ticker = 'BSBR' ORDER BY observed_at DESC LIMIT 1), -4.42, '2026-05-14 19:15:00-03'),
    ('BDORY', (SELECT price FROM market_data.ticks WHERE ticker = 'BDORY' ORDER BY observed_at DESC LIMIT 1), -6.49, '2026-05-14 19:15:00-03'),
    ('TSLA', (SELECT price FROM market_data.ticks WHERE ticker = 'TSLA' ORDER BY observed_at DESC LIMIT 1), 2.73, '2026-05-14 19:15:00-03')
ON CONFLICT DO NOTHING;
INSERT 0 12
bloomberg_asia=# -- GLOBAL CROSS-ASSET MONITOR: MAY 14, 2026
SELECT 
    a.ticker AS "SYMBOL",
    LEFT(a.name, 18) AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.trend_signal AS "SIGNAL",
    (SELECT content FROM market_data.headlines 
     WHERE content ILIKE '%Trump%' OR content ILIKE '%Xi%' 
     ORDER BY created_at DESC LIMIT 1) AS "CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, pct_change 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
WHERE a.ticker IN ('TSLA', 'AMZN', 'CVX', 'BDORY', 'BSBR', 'MXAP')
ORDER BY t.pct_change DESC;
 SYMBOL |       ENTITY       |   MOVE   |      SIGNAL      |             CATALYST              
--------+--------------------+----------+------------------+-----------------------------------
 TSLA   | Tesla Inc          | ▲ 2.73%  | 🚀 STRONG BUY    | TRUMP TO MEET XI TODAY IN BEIJING
 AMZN   | Amazon.com Inc     | ▲ 1.62%  | 🚀 STRONG BUY    | TRUMP TO MEET XI TODAY IN BEIJING
 MXAP   | MSCI AC Asia Pacif | ▲ 0.20%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 CVX    | Chevron Corporatio | ▲ 0.03%  | 💎 BUY (VALUE)   | TRUMP TO MEET XI TODAY IN BEIJING
 BSBR   | Banco Santander Br | ▼ -4.42% | 🏃💨 RUN TO SELL | TRUMP TO MEET XI TODAY IN BEIJING
 BDORY  | Banco do Brasil    | ▼ -6.49% | 🏃💨 RUN TO SELL | TRUMP TO MEET XI TODAY IN BEIJING
(6 rows)

bloomberg_asia=# -- Registering the full 'Recently Viewed' list
INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('ORCL', 'Oracle Corp', 'NYSE'),
('HSBC', 'HSBC Holdings', 'NYSE'),
('IBM', 'International Business Machines', 'NYSE'),
('JPM', 'JPMorgan Chase & Co', 'NYSE'),
('JEPQ', 'JPMorgan Equity Premium Income', 'NASDAQ'),
('NU', 'Nu Holdings Ltd', 'NYSE'),
('ITUB', 'Itaú Unibanco', 'NYSE'),
('NDX', 'Nasdaq 100 Index', 'NASDAQ'),
('BP', 'BP p.l.c.', 'NYSE'),
('BK', 'BNY Mellon', 'NYSE'),
('BAC', 'Bank of America', 'NYSE'),
('MS', 'Morgan Stanley', 'NYSE')
ON CONFLICT DO NOTHING;

-- Ingesting latest ticks with exact prices from your data
INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('MSFT', 408.19, -0.63, '2026-05-14 19:18:00-03'),
('CVX', 186.50, 0.03, '2026-05-14 19:18:00-03'),
('ORCL', 0.00, 1.57, '2026-05-14 19:18:00-03'),
('HSBC', 0.00, 0.73, '2026-05-14 19:18:00-03'),
('IBM', 0.00, -2.09, '2026-05-14 19:18:00-03'),
('JPM', 0.00, -1.52, '2026-05-14 19:18:00-03'),
('JEPQ', 0.00, 0.39, '2026-05-14 19:18:00-03'),
('NU', 0.00, -3.39, '2026-05-14 19:18:00-03'),
('ITUB', 0.00, -3.09, '2026-05-14 19:18:00-03'),
('NDX', 0.00, 0.73, '2026-05-14 19:18:00-03'),
('BP', 0.00, -0.59, '2026-05-14 19:18:00-03'),
('BK', 0.00, 1.16, '2026-05-14 19:18:00-03'),
('BAC', 0.00, -1.85, '2026-05-14 19:18:00-03'),
('MS', 0.00, 1.02, '2026-05-14 19:18:00-03');
INSERT 0 2
INSERT 0 14
bloomberg_asia=# -- BLOOMBERG ASIA TRADE: FULL COMPANY SIGNAL REBUILD
SELECT 
    a.ticker AS "SYMBOL",
    LEFT(a.name, 18) AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.trend_signal AS "SIGNAL",
    (SELECT content FROM market_data.headlines 
     WHERE content ILIKE '%Trump%' OR content ILIKE '%Xi%' 
     ORDER BY created_at DESC LIMIT 1) AS "CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, pct_change 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
ORDER BY t.pct_change DESC;
 SYMBOL |       ENTITY       |   MOVE   |      SIGNAL      |             CATALYST              
--------+--------------------+----------+------------------+-----------------------------------
 TSLA   | Tesla Inc          | ▲ 2.73%  | 🚀 STRONG BUY    | TRUMP TO MEET XI TODAY IN BEIJING
 KOSPI  | Kospi Index        | ▲ 1.75%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 AMZN   | Amazon.com Inc     | ▲ 1.62%  | 🚀 STRONG BUY    | TRUMP TO MEET XI TODAY IN BEIJING
 ORCL   | Oracle Corp        | ▲ 1.57%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 DAX    | DAX Index          | ▲ 1.32%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 BK     | BNY Mellon         | ▲ 1.16%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 SILV   | Silver Spot (Prata | ▲ 1.12%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 MS     | Morgan Stanley     | ▲ 1.02%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 CCMP   | Nasdaq Composite I | ▲ 0.88%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 SPX    | S&P 500 Index      | ▲ 0.84%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 INDU   | Dow Jones Industri | ▲ 0.77%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 BE600  | Bloomberg Europe 6 | ▲ 0.77%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 NDX    | Nasdaq 100 Index   | ▲ 0.73%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 HSBC   | HSBC Holdings      | ▲ 0.73%  | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 UKX    | FTSE 100           | ▲ 0.46%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 GOLD   | Gold Spot (Ouro)   | ▲ 0.45%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 JEPQ   | JPMorgan Equity Pr | ▲ 0.39%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 MXAP   | MSCI AC Asia Pacif | ▲ 0.20%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 OMX    | Stockholm OMX Inde | ▲ 0.05%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 CVX    | Chevron Corporatio | ▲ 0.03%  | 💎 BUY (VALUE)   | TRUMP TO MEET XI TODAY IN BEIJING
 USDJPY | USD/JPY Spot       | ▲ 0.01%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 HSI    | Hang Seng Index    | ▼ 0.00%  | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 COPP   | Copper (Cobre)     | ▼ -0.22% | ⚖️ HOLD           | TRUMP TO MEET XI TODAY IN BEIJING
 BP     | BP p.l.c.          | ▼ -0.59% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 MSFT   | Microsoft Corp     | ▼ -0.63% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 NKY    | Nikkei 225         | ▼ -0.98% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 JPM    | JPMorgan Chase & C | ▼ -1.52% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 BAC    | Bank of America    | ▼ -1.85% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 IBM    | International Busi | ▼ -2.09% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 ITUB   | Itaú Unibanco      | ▼ -3.09% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 NU     | Nu Holdings Ltd    | ▼ -3.39% | 🔎 MONITOR       | TRUMP TO MEET XI TODAY IN BEIJING
 BSBR   | Banco Santander Br | ▼ -4.42% | 🏃💨 RUN TO SELL | TRUMP TO MEET XI TODAY IN BEIJING
 BDORY  | Banco do Brasil    | ▼ -6.49% | 🏃💨 RUN TO SELL | TRUMP TO MEET XI TODAY IN BEIJING
(33 rows)

bloomberg_asia=# -- Updating the Master Asset Registry
INSERT INTO market_data.assets (ticker, name, exchange) VALUES 
('JEPQ', 'JPMorgan Equity Premium Income', 'NASDAQ'),
('NDX', 'Nasdaq 100 Index', 'NASDAQ'),
('BK', 'BNY Mellon', 'NYSE'),
('BAC', 'Bank of America', 'NYSE'),
('MS', 'Morgan Stanley', 'NYSE')
ON CONFLICT (ticker) DO NOTHING;

-- Logging the Latest Ticks with Exact Terminal Prices
INSERT INTO market_data.ticks (ticker, price, pct_change, observed_at) VALUES 
('MSFT', 408.19, -0.63, '2026-05-14 21:20:00-03'),
('CVX', 186.50, 0.03, '2026-05-14 21:20:00-03'),
('TSLA', 0.00, 2.73, '2026-05-14 21:20:00-03'),
('ORCL', 0.00, 1.57, '2026-05-14 21:20:00-03'),
('BK', 0.00, 1.16, '2026-05-14 21:20:00-03'),
('MS', 0.00, 1.02, '2026-05-14 21:20:00-03'),
('BDORY', 0.00, -6.49, '2026-05-14 21:20:00-03'),
('BSBR', 0.00, -4.42, '2026-05-14 21:20:00-03'),
('NU', 0.00, -3.39, '2026-05-14 21:20:00-03'),
('IBM', 0.00, -2.09, '2026-05-14 21:20:00-03')
ON CONFLICT DO NOTHING;
INSERT 0 0
INSERT 0 10
bloomberg_asia=# -- BLOOMBERG: GLOBAL CROSS-ASSET COMMAND CENTER
SELECT 
    a.ticker AS "SYMBOL",
    LEFT(a.name, 18) AS "ENTITY",
    CASE 
        WHEN t.pct_change > 0 THEN '▲ ' || t.pct_change 
        ELSE '▼ ' || t.pct_change 
    END || '%' AS "MOVE",
    s.trend_signal AS "SIGNAL",
    (SELECT LEFT(content, 35) || '...' FROM market_data.headlines 
     ORDER BY created_at DESC LIMIT 1) AS "MACRO CATALYST"
FROM market_data.assets a
JOIN (
    SELECT DISTINCT ON (ticker) ticker, pct_change 
    FROM market_data.ticks 
    ORDER BY ticker, observed_at DESC
) t ON a.ticker = t.ticker
JOIN market_data.trading_signals s ON a.ticker = s.ticker
ORDER BY t.pct_change DESC;
 SYMBOL |       ENTITY       |   MOVE   |      SIGNAL      |             MACRO CATALYST             
--------+--------------------+----------+------------------+----------------------------------------
 TSLA   | Tesla Inc          | ▲ 2.73%  | 🚀 STRONG BUY    | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 KOSPI  | Kospi Index        | ▲ 1.75%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 AMZN   | Amazon.com Inc     | ▲ 1.62%  | 🚀 STRONG BUY    | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 ORCL   | Oracle Corp        | ▲ 1.57%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 DAX    | DAX Index          | ▲ 1.32%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 BK     | BNY Mellon         | ▲ 1.16%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 SILV   | Silver Spot (Prata | ▲ 1.12%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 MS     | Morgan Stanley     | ▲ 1.02%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 CCMP   | Nasdaq Composite I | ▲ 0.88%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 SPX    | S&P 500 Index      | ▲ 0.84%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 INDU   | Dow Jones Industri | ▲ 0.77%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 BE600  | Bloomberg Europe 6 | ▲ 0.77%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 NDX    | Nasdaq 100 Index   | ▲ 0.73%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 HSBC   | HSBC Holdings      | ▲ 0.73%  | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 UKX    | FTSE 100           | ▲ 0.46%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 GOLD   | Gold Spot (Ouro)   | ▲ 0.45%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 JEPQ   | JPMorgan Equity Pr | ▲ 0.39%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 MXAP   | MSCI AC Asia Pacif | ▲ 0.20%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 OMX    | Stockholm OMX Inde | ▲ 0.05%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 CVX    | Chevron Corporatio | ▲ 0.03%  | 💎 BUY (VALUE)   | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 USDJPY | USD/JPY Spot       | ▲ 0.01%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 HSI    | Hang Seng Index    | ▼ 0.00%  | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 COPP   | Copper (Cobre)     | ▼ -0.22% | ⚖️ HOLD           | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 BP     | BP p.l.c.          | ▼ -0.59% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 MSFT   | Microsoft Corp     | ▼ -0.63% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 NKY    | Nikkei 225         | ▼ -0.98% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 JPM    | JPMorgan Chase & C | ▼ -1.52% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 BAC    | Bank of America    | ▼ -1.85% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 IBM    | International Busi | ▼ -2.09% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 ITUB   | Itaú Unibanco      | ▼ -3.09% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 NU     | Nu Holdings Ltd    | ▼ -3.39% | 🔎 MONITOR       | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 BSBR   | Banco Santander Br | ▼ -4.42% | 🏃💨 RUN TO SELL | CLEAN ENERGY SEEN AS STRUCTURALLY I...
 BDORY  | Banco do Brasil    | ▼ -6.49% | 🏃💨 RUN TO SELL | CLEAN ENERGY SEEN AS STRUCTURALLY I...
(33 rows)

bloomberg_asia=# 
bloomberg_asia=# 
bloomberg_asia=# 
bloomberg_asia=# 
bloomberg_asia=# commit;
WARNING:  there is no transaction in progress
COMMIT
bloomberg_asia=# commit
bloomberg_asia-# COMMIT;
ERROR:  syntax error at or near "COMMIT"
LINE 2: COMMIT;
        ^
bloomberg_asia=# COMMIT


COMMIT; -- Permanently save everything only if no errors occurred
