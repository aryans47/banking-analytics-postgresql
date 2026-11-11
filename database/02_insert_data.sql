--
-- PostgreSQL database dump
--

\restrict cWROmJA4GSo60tPMWfIYDT4oG35e6YbAhDiRuY3fpRoELRUoEqsTJosh3iJwB0b

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (customer_id, full_name, dob, gender, city, state, income, risk_profile, created_at) FROM stdin;
1	Rahul Sharma	1995-04-12	M	Bangalore	Karnataka	850000.00	LOW	2026-09-24 19:47:25.934181
2	Priya Singh	1992-08-20	F	Delhi	Delhi	1200000.00	LOW	2026-09-24 19:49:15.818958
3	Amit Kumar	1998-01-15	M	Patna	Bihar	550000.00	MEDIUM	2026-09-24 19:49:15.818958
4	Sneha Verma	1994-11-02	F	Mumbai	Maharashtra	950000.00	LOW	2026-09-24 19:49:15.818958
5	Rohit Gupta	1989-06-25	M	Pune	Maharashtra	1500000.00	LOW	2026-09-24 19:49:15.818958
6	Neha Patel	1997-03-18	F	Ahmedabad	Gujarat	700000.00	MEDIUM	2026-09-24 19:49:15.818958
7	Vikas Rao	1990-09-10	M	Hyderabad	Telangana	1100000.00	LOW	2026-09-24 19:49:15.818958
8	Anjali Mehta	1996-12-05	F	Jaipur	Rajasthan	600000.00	MEDIUM	2026-09-24 19:49:15.818958
9	Karan Malhotra	1987-07-30	M	Chennai	Tamil Nadu	1800000.00	LOW	2026-09-24 19:49:15.818958
10	Pooja Nair	1999-02-14	F	Kochi	Kerala	450000.00	HIGH	2026-09-24 19:49:15.818958
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accounts (account_id, customer_id, account_type, balance, opened_at, status) FROM stdin;
1	1	SAVINGS	125000.00	2021-05-10	ACTIVE
2	1	CURRENT	250000.00	2022-03-15	ACTIVE
3	2	SAVINGS	450000.00	2020-07-12	ACTIVE
4	3	SAVINGS	75000.00	2023-01-20	ACTIVE
5	4	SAVINGS	180000.00	2021-11-05	ACTIVE
6	5	CURRENT	850000.00	2019-08-18	ACTIVE
7	6	SAVINGS	95000.00	2022-06-25	ACTIVE
8	7	SAVINGS	320000.00	2020-02-11	ACTIVE
9	8	SAVINGS	110000.00	2023-04-16	ACTIVE
10	9	CURRENT	950000.00	2018-09-22	ACTIVE
11	10	SAVINGS	45000.00	2024-01-10	ACTIVE
\.


--
-- Data for Name: loans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.loans (loan_id, customer_id, loan_type, principal, interest_rate, tenure_months, emi, start_date, status) FROM stdin;
1	1	HOME	5000000.00	8.50	240	43391.00	2024-01-15	ACTIVE
2	2	PERSONAL	800000.00	11.50	60	17590.00	2023-06-10	ACTIVE
3	3	CAR	1200000.00	9.25	60	25050.00	2024-02-20	ACTIVE
4	4	EDUCATION	600000.00	8.00	84	9350.00	2022-07-01	ACTIVE
5	5	HOME	7500000.00	8.25	240	63900.00	2021-04-15	ACTIVE
6	6	PERSONAL	500000.00	12.00	48	13170.00	2024-05-05	ACTIVE
\.


--
-- Data for Name: loan_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.loan_payments (payment_id, loan_id, payment_date, amount_paid, status, due_date) FROM stdin;
1	1	2024-02-15	43391.00	PAID	2024-02-15
2	1	2024-03-15	43391.00	PAID	2024-03-15
3	1	2024-04-15	43391.00	PAID	2024-04-15
4	1	2024-05-15	43391.00	PAID	2024-05-15
5	2	2024-07-10	17590.00	PAID	2024-07-10
6	2	2024-08-10	17590.00	PAID	2024-08-10
7	2	2024-09-10	17590.00	PAID	2024-09-10
8	3	2024-03-20	25050.00	PAID	2024-03-20
9	3	2024-04-20	25050.00	PAID	2024-04-20
10	3	2024-05-25	20000.00	PARTIAL	2024-05-20
11	5	2024-05-20	63900.00	PAID	2024-01-15
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (txn_id, account_id, txn_type, amount, txn_timestamp, merchant, location) FROM stdin;
1	1	CREDIT	50000.00	2026-01-05 10:15:00	Salary	Bangalore
2	1	DEBIT	2500.00	2026-01-06 14:20:00	Amazon	Bangalore
3	1	DEBIT	1800.00	2026-01-08 18:10:00	Swiggy	Bangalore
4	1	DEBIT	5000.00	2026-01-10 11:30:00	Flipkart	Bangalore
5	2	CREDIT	100000.00	2026-01-05 09:10:00	Business Income	Bangalore
6	2	DEBIT	15000.00	2026-01-07 13:30:00	Office Supplies	Bangalore
7	2	DEBIT	8000.00	2026-01-12 16:45:00	Amazon	Mumbai
8	3	CREDIT	45000.00	2026-01-05 10:00:00	Salary	Delhi
9	3	DEBIT	3000.00	2026-01-07 19:00:00	Flipkart	Delhi
10	3	DEBIT	2200.00	2026-01-11 15:30:00	Swiggy	Delhi
11	4	CREDIT	70000.00	2026-01-05 09:30:00	Salary	Patna
12	4	DEBIT	5000.00	2026-01-06 15:00:00	Amazon	Patna
13	4	DEBIT	3500.00	2026-01-09 18:20:00	Flipkart	Patna
14	5	CREDIT	150000.00	2026-01-04 10:00:00	Business Income	Mumbai
15	5	DEBIT	25000.00	2026-01-05 12:00:00	Office Depot	Mumbai
16	5	DEBIT	7500.00	2026-01-09 17:30:00	Amazon	Mumbai
17	6	CREDIT	60000.00	2026-01-05 09:45:00	Salary	Pune
18	6	DEBIT	4500.00	2026-01-08 20:00:00	Amazon	Pune
19	6	DEBIT	3000.00	2026-01-12 14:00:00	Swiggy	Pune
20	7	CREDIT	90000.00	2026-01-05 10:20:00	Salary	Ahmedabad
21	7	DEBIT	10000.00	2026-01-08 12:00:00	Flipkart	Ahmedabad
22	7	DEBIT	2500.00	2026-01-13 16:00:00	Amazon	Ahmedabad
23	8	CREDIT	50000.00	2026-01-05 09:00:00	Salary	Hyderabad
24	8	DEBIT	3500.00	2026-01-10 18:00:00	Amazon	Hyderabad
25	8	DEBIT	4200.00	2026-01-14 13:00:00	Swiggy	Hyderabad
26	9	CREDIT	200000.00	2026-01-05 08:30:00	Business Income	Jaipur
27	9	DEBIT	50000.00	2026-01-06 11:00:00	Business Expense	Jaipur
28	9	DEBIT	12000.00	2026-01-10 15:30:00	Amazon	Jaipur
29	10	CREDIT	40000.00	2026-01-05 09:15:00	Salary	Chennai
30	10	DEBIT	2000.00	2026-01-07 17:00:00	Amazon	Chennai
31	10	DEBIT	4500.00	2026-01-12 19:00:00	Swiggy	Chennai
32	11	CREDIT	35000.00	2026-01-05 10:00:00	Salary	Kochi
33	11	DEBIT	2000.00	2026-01-07 17:00:00	Amazon	Kochi
34	11	DEBIT	1500.00	2026-01-11 18:00:00	Swiggy	Kochi
35	1	CREDIT	52000.00	2026-02-05 10:10:00	Salary	Bangalore
36	1	DEBIT	3200.00	2026-02-07 14:30:00	Amazon	Bangalore
37	2	CREDIT	105000.00	2026-02-05 09:15:00	Business Income	Bangalore
38	2	DEBIT	12000.00	2026-02-09 13:20:00	Office Supplies	Bangalore
39	3	CREDIT	46000.00	2026-02-05 10:00:00	Salary	Delhi
40	3	DEBIT	2800.00	2026-02-08 18:30:00	Flipkart	Delhi
41	4	CREDIT	72000.00	2026-02-05 09:30:00	Salary	Patna
42	4	DEBIT	4500.00	2026-02-10 15:10:00	Amazon	Patna
43	5	CREDIT	155000.00	2026-02-04 10:00:00	Business Income	Mumbai
44	5	DEBIT	22000.00	2026-02-06 12:30:00	Office Depot	Mumbai
45	1	CREDIT	53000.00	2026-03-05 10:05:00	Salary	Bangalore
46	1	DEBIT	3500.00	2026-03-08 15:20:00	Amazon	Bangalore
47	2	CREDIT	110000.00	2026-03-05 09:20:00	Business Income	Bangalore
48	2	DEBIT	14500.00	2026-03-10 13:45:00	Office Supplies	Bangalore
49	3	CREDIT	47000.00	2026-03-05 10:10:00	Salary	Delhi
50	3	DEBIT	3200.00	2026-03-09 18:00:00	Swiggy	Delhi
51	4	CREDIT	74000.00	2026-03-05 09:35:00	Salary	Patna
52	4	DEBIT	5200.00	2026-03-11 15:30:00	Flipkart	Patna
53	5	CREDIT	160000.00	2026-03-04 10:05:00	Business Income	Mumbai
54	5	DEBIT	24000.00	2026-03-07 12:45:00	Office Depot	Mumbai
55	1	CREDIT	54000.00	2026-04-05 10:10:00	Salary	Bangalore
56	1	DEBIT	3800.00	2026-04-08 16:00:00	Amazon	Bangalore
57	2	CREDIT	115000.00	2026-04-05 09:25:00	Business Income	Bangalore
58	2	DEBIT	16000.00	2026-04-10 14:00:00	Office Supplies	Bangalore
59	3	CREDIT	48000.00	2026-04-05 10:15:00	Salary	Delhi
60	3	DEBIT	3500.00	2026-04-09 18:15:00	Swiggy	Delhi
61	4	CREDIT	76000.00	2026-04-05 09:40:00	Salary	Patna
62	4	DEBIT	5500.00	2026-04-11 15:45:00	Flipkart	Patna
63	5	CREDIT	165000.00	2026-04-04 10:10:00	Business Income	Mumbai
64	5	DEBIT	26000.00	2026-04-07 13:00:00	Office Depot	Mumbai
65	1	CREDIT	55000.00	2026-05-05 10:15:00	Salary	Bangalore
66	1	DEBIT	4200.00	2026-05-08 16:20:00	Amazon	Bangalore
67	2	CREDIT	120000.00	2026-05-05 09:30:00	Business Income	Bangalore
68	2	DEBIT	18000.00	2026-05-10 14:15:00	Office Supplies	Bangalore
69	3	CREDIT	49000.00	2026-05-05 10:20:00	Salary	Delhi
70	3	DEBIT	3700.00	2026-05-09 18:30:00	Swiggy	Delhi
71	4	CREDIT	78000.00	2026-05-05 09:45:00	Salary	Patna
72	4	DEBIT	6000.00	2026-05-11 16:00:00	Flipkart	Patna
73	5	CREDIT	170000.00	2026-05-04 10:15:00	Business Income	Mumbai
74	5	DEBIT	28000.00	2026-05-07 13:30:00	Office Depot	Mumbai
75	10	DEBIT	18000.00	2026-05-10 14:00:00	Amazon	Chennai
76	10	DEBIT	22000.00	2026-05-10 14:04:00	Flipkart	Chennai
77	10	DEBIT	15000.00	2026-05-10 14:08:00	Swiggy	Chennai
\.


--
-- Name: accounts_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.accounts_account_id_seq', 11, true);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 10, true);


--
-- Name: loan_payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.loan_payments_payment_id_seq', 11, true);


--
-- Name: loans_loan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.loans_loan_id_seq', 6, true);


--
-- Name: transactions_txn_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transactions_txn_id_seq', 77, true);


--
-- PostgreSQL database dump complete
--

\unrestrict cWROmJA4GSo60tPMWfIYDT4oG35e6YbAhDiRuY3fpRoELRUoEqsTJosh3iJwB0b

