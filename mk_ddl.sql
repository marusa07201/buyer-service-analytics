DROP TABLE public.mk_orders;
DROP TABLE public.mk_customers;

CREATE TABLE public.mk_orders (
    order_date varchar(10),
    store varchar(100),
    order_id varchar(50),
    customer_name varchar(100),
    product_name varchar(500),
    quantity int,
    currency varchar(10),
    store_price real,
    discount varchar(10),
    charged_price real,
    exchange_rate real,
    charged_price_uah real
);

CREATE TABLE public.mk_customers (
    customer_name varchar(100),
    registration_date varchar(10),
    last_order_date varchar(10)
);
