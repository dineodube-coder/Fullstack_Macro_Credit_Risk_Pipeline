--
-- PostgreSQL database dump
--

\restrict IZJ0BFM8rGTDkec0cqR32M7CT27GuWp0jHX4EV6g4zTx8gr8M1sIYGmzZukahCa

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

-- Started on 2026-08-22 23:10:20

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
-- TOC entry 6 (class 2615 OID 41041)
-- Name: Corporate_Credit_Risk_Database; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "Corporate_Credit_Risk_Database";


ALTER SCHEMA "Corporate_Credit_Risk_Database" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 32857)
-- Name: corporate_financial_ledgers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.corporate_financial_ledgers (
    company_id character varying(15) NOT NULL,
    fiscal_year integer NOT NULL,
    total_assets_zmw numeric(15,2) NOT NULL,
    working_capital_zmw numeric(15,2) NOT NULL,
    retained_earnings_zmw numeric(15,2) NOT NULL,
    ebit_zmw numeric(15,2) NOT NULL,
    total_debt_zmw numeric(15,2) NOT NULL,
    interest_expense_zmw numeric(15,2) NOT NULL,
    historical_default_event integer NOT NULL
);


ALTER TABLE public.corporate_financial_ledgers OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 32871)
-- Name: corporate_loan_book; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.corporate_loan_book (
    loan_contract_id character varying(20) NOT NULL,
    company_id character varying(15) NOT NULL,
    exposure_at_default_zmw numeric(15,2) NOT NULL,
    loss_given_default_pct numeric(4,2) NOT NULL,
    origination_year integer NOT NULL
);


ALTER TABLE public.corporate_loan_book OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 32849)
-- Name: macroeconomic_risk_factors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.macroeconomic_risk_factors (
    reporting_year integer NOT NULL,
    central_bank_policy_rate numeric(5,2) NOT NULL,
    currency_depreciation_pct numeric(5,2) NOT NULL
);


ALTER TABLE public.macroeconomic_risk_factors OWNER TO postgres;

--
-- TOC entry 4971 (class 0 OID 32857)
-- Dependencies: 221
-- Data for Name: corporate_financial_ledgers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.corporate_financial_ledgers (company_id, fiscal_year, total_assets_zmw, working_capital_zmw, retained_earnings_zmw, ebit_zmw, total_debt_zmw, interest_expense_zmw, historical_default_event) FROM stdin;
CORP-ZAME-01	2024	10000000.00	1500000.00	3000000.00	2100000.00	4000000.00	580000.00	0
CORP-RETL-02	2024	5000000.00	-200000.00	100000.00	300000.00	4800000.00	700000.00	1
CORP-AGRI-03	2024	25000000.00	4000000.00	8000000.00	4500000.00	8000000.00	1100000.00	0
CORP-MING-04	2024	80000000.00	12000000.00	22000000.00	14000000.00	35000000.00	5100000.00	0
CORP-TRAF-05	2024	3000000.00	-900000.00	-400000.00	150000.00	3900000.00	600000.00	1
\.


--
-- TOC entry 4972 (class 0 OID 32871)
-- Dependencies: 222
-- Data for Name: corporate_loan_book; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.corporate_loan_book (loan_contract_id, company_id, exposure_at_default_zmw, loss_given_default_pct, origination_year) FROM stdin;
LN-2024-9901	CORP-ZAME-01	3500000.00	0.45	2024
LN-2024-9902	CORP-RETL-02	4200000.00	0.60	2024
LN-2024-9903	CORP-AGRI-03	7000000.00	0.35	2024
LN-2024-9904	CORP-MING-04	28000000.00	0.50	2024
LN-2024-9905	CORP-TRAF-05	3100000.00	0.70	2024
\.


--
-- TOC entry 4970 (class 0 OID 32849)
-- Dependencies: 220
-- Data for Name: macroeconomic_risk_factors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.macroeconomic_risk_factors (reporting_year, central_bank_policy_rate, currency_depreciation_pct) FROM stdin;
2024	14.50	18.50
2025	13.75	-5.20
2026	13.00	-12.40
\.


--
-- TOC entry 4820 (class 2606 OID 32870)
-- Name: corporate_financial_ledgers corporate_financial_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.corporate_financial_ledgers
    ADD CONSTRAINT corporate_financial_ledgers_pkey PRIMARY KEY (company_id, fiscal_year);


--
-- TOC entry 4822 (class 2606 OID 32880)
-- Name: corporate_loan_book corporate_loan_book_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.corporate_loan_book
    ADD CONSTRAINT corporate_loan_book_pkey PRIMARY KEY (loan_contract_id);


--
-- TOC entry 4818 (class 2606 OID 32856)
-- Name: macroeconomic_risk_factors macroeconomic_risk_factors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.macroeconomic_risk_factors
    ADD CONSTRAINT macroeconomic_risk_factors_pkey PRIMARY KEY (reporting_year);


-- Completed on 2026-08-22 23:10:20

--
-- PostgreSQL database dump complete
--

\unrestrict IZJ0BFM8rGTDkec0cqR32M7CT27GuWp0jHX4EV6g4zTx8gr8M1sIYGmzZukahCa

