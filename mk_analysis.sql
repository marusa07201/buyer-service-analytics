-- ============================================
-- Concierge Shopping Service Analytics
-- Author: Marina Kolisnichenko
-- Data: 2020-2026
-- ============================================

--5 карток KPI одним запитом: total_turnover, total_orders, total_customers, aov, avg_frequency
SELECT 
	round(SUM(charged_price_uah)::numeric, 2) AS total_turnover --загальний обіг
	, count(DISTINCT order_id) AS total_orders --кількість замовлень
	, count(DISTINCT customer_name) AS total_customers --кількість покупців
	, round((sum(charged_price_uah) / count(DISTINCT order_id))::NUMERIC, 2) AS aov --середній чек
	, round((count(DISTINCT order_id)::NUMERIC / count(DISTINCT customer_name)::NUMERIC), 1) AS avg_frequency --середня кількість замовлень на клієнта
FROM mk_orders;
--avg_frequency 14.2 замовлення на клієнта означає що клієнти дуже лояльні і постійно повертаються

--обіг по місяцям
SELECT 
	to_char(DATE_TRUNC('month', order_date::date), 'Mon.YYYY') AS order_month
	,round(SUM(charged_price_uah)::NUMERIC, 2) AS total_turnover
FROM mk_orders
GROUP BY DATE_TRUNC('month', order_date::date)
ORDER BY DATE_TRUNC('month', order_date::date);

--топ-10 магазинів
SELECT 
	store
	, round(SUM(charged_price_uah)::numeric, 2) AS total_turnover
	, count(DISTINCT order_id) AS total_orders
FROM mk_orders
WHERE store != 'Other (USD)'
		AND store != 'Other (EUR)'
GROUP BY store 
ORDER BY total_turnover DESC 
LIMIT 10;

--топ-10 клієнтів за LTV
SELECT 
	customer_name 
	, round(SUM(charged_price_uah)::NUMERIC, 2) AS ltv
	, count(DISTINCT order_id) AS total_orders
FROM mk_orders
WHERE customer_name != 'Alisa Koles'
	AND customer_name != 'Марина MarUSA'
GROUP BY customer_name 
ORDER BY ltv DESC 
LIMIT 10;

-- Purchase Frequency розподіл, показує скільки клієнтів зробили 1, 2, 3 замовлень
-- метрика для мене, інсайт вловила, але на дашборд не виводити
SELECT 
	order_count
	, count(customer_name) AS customers_cnt
FROM 
(
	SELECT 
		customer_name 
		, count(DISTINCT order_id) AS order_count
	FROM mk_orders
	WHERE customer_name != 'Alisa Koles'
		AND customer_name != 'Марина MarUSA'
	GROUP BY customer_name
) AS subquery
GROUP BY order_count
ORDER BY order_count;

--список і кількість активних і відвалившихся клієнтів
WITH customer_status AS (
    SELECT 
        customer_name
        , registration_date
        , last_order_date
        , CASE 
            WHEN last_order_date::DATE < CURRENT_DATE - INTERVAL '6 months'
            THEN 'Churned'
            ELSE 'Active'
        END AS status
    FROM mk_customers
    WHERE customer_name NOT IN ('Alisa Koles', 'Марина MarUSA')
        AND last_order_date IS NOT NULL
        AND last_order_date != ''
)
/*-- для себе (детально)
SELECT *
FROM customer_status
ORDER BY last_order_date::DATE DESC;*/
-- для дашборду
SELECT 
    status,
    COUNT(*) AS customers_cnt
FROM customer_status
GROUP BY status;


--currency_source, розбивка по валютах, яка частка кожної валюти від загального обігу
SELECT
    currency
    , ROUND(SUM(charged_price_uah)::NUMERIC, 2) AS total_uah
    , ROUND((SUM(charged_price_uah) * 100.0 / SUM(SUM(charged_price_uah)) OVER())::NUMERIC, 1) AS pct
FROM mk_orders
GROUP BY currency
ORDER BY total_uah DESC;

