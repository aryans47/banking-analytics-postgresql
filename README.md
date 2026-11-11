# Banking Analytics & Risk Intelligence Platform

A PostgreSQL-based banking analytics project designed to transform raw customer, account, transaction, and loan data into actionable business and risk insights.

## 📌 Project Overview

Banks generate large volumes of customer, account, transaction, and loan data. Raw transactional data alone does not provide actionable insights into customer behavior, transaction trends, loan performance, or suspicious activity.

This project addresses the gap between **data availability and actionable decision-making** by building a centralized PostgreSQL analytics platform.

The project uses SQL-based analytics, feature engineering, risk scoring, KPI generation, and PostgreSQL performance optimization techniques.

---

## 🎯 Business Objectives

The platform answers important banking business questions such as:

* Which customers are high-value or highly active?
* What is the total transaction volume?
* How are transactions changing month over month?
* Which customers contribute the most transaction value?
* What is the total loan exposure?
* Which loans are overdue?
* Which loans qualify as NPA under the project rule?
* Are there suspicious transaction patterns?
* Which transactions show rapid transaction behavior?
* How can banking KPIs be made reusable and easy to access?

---

## 🏗️ Project Architecture

```text
                    Banking Data
                         │
          ┌──────────────┼──────────────┐
          │              │              │
     Customers       Accounts        Loans
          │              │              │
          │         Transactions   Loan Payments
          │              │              │
          └──────────────┼──────────────┘
                         │
                  PostgreSQL
                         │
              SQL Data Transformation
                         │
        ┌────────────────┼────────────────┐
        │                │                │
 Customer Analytics  Transaction      Loan/Risk
                     Analytics        Analytics
        │                │                │
        └────────────────┼────────────────┘
                         │
               Risk & KPI Outputs
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   Fraud Risk       NPA Analysis     Executive KPIs
```

---

## 🗄️ Database Design

The project contains **5 core business tables**:

| Table           | Purpose                     |
| --------------- | --------------------------- |
| `customers`     | Customer master information |
| `accounts`      | Customer bank accounts      |
| `transactions`  | Account transaction history |
| `loans`         | Customer loan information   |
| `loan_payments` | Loan payment history        |

There is also a separate technical table:

| Table                      | Purpose                                                          |
| -------------------------- | ---------------------------------------------------------------- |
| `transactions_partitioned` | Demonstrates PostgreSQL range partitioning and partition pruning |

### Relationships

```text
customers
    │
    ├── 1:N ──> accounts
    │              │
    │              └── 1:N ──> transactions
    │
    └── 1:N ──> loans
                   │
                   └── 1:N ──> loan_payments
```

---

## 🔧 Technologies Used

* PostgreSQL 18
* SQL
* pgAdmin 4
* CTEs
* Window Functions
* CASE Expressions
* Aggregate Functions
* Views
* Materialized Views
* Indexes
* `EXPLAIN ANALYZE`
* Range Partitioning
* Partition Pruning
* Data Quality Checks
* Rule-based Risk Scoring

---

## 📊 Analytics Implemented

### 1. Customer Analytics

Calculated customer-level metrics including:

* Account balances
* Transaction count
* Transaction value
* Average transaction amount
* Customer contribution
* Customer activity
* Customer segmentation
* Simplified CLV proxy

---

### 2. Transaction Analytics

Analyzed:

* Total transaction volume
* Credit transactions
* Debit transactions
* Net transaction value
* Monthly transaction trends
* Month-over-month growth
* Customer transaction ranking
* Top customers
* Merchant activity
* Daily transaction activity
* Cumulative transaction value

---

### 3. Loan Analytics

Analyzed:

* Total loan count
* Total loan exposure
* Loan payment performance
* Paid payments
* Missed payments
* Payment success rate
* Overdue payments
* Loan risk categories
* NPA classification

---

### 4. NPA / Loan Risk Analysis

The project implements a simplified project-level rule for NPA classification based on overdue days.

A loan is classified as NPA when the payment is overdue by **90+ days** under the project's analytical rule.

Current project result:

```text
Total Loans       : 6
NPA Loans         : 1
NPA Percentage    : 16.67%
```

> Note: This is a simplified analytical rule for the project and should not be interpreted as a complete regulatory NPA implementation.

---

## 🚨 Fraud / Suspicious Transaction Analysis

The project implements **rule-based fraud risk scoring**, not a machine-learning fraud model.

Risk signals include:

### Transaction Amount

Transactions are compared with the customer's average transaction amount.

### Location Change

A transaction occurring from a different location than the previous transaction can contribute to the risk score.

### Rapid Transactions

Transactions occurring within **10 minutes** of another transaction on the same account are identified as rapid transaction activity.

### Risk Score

The project combines these signals into a fraud risk score.

```text
Amount Score
     +
Location Score
     +
Rapid Transaction Score
     =
Fraud Risk Score
```

Risk levels are then assigned using rule-based thresholds.

Current project summary:

```text
LOW RISK       : 76 transactions
MEDIUM RISK    : 1 transaction
HIGH RISK      : 0
```

---

## ⚡ Performance Optimization

Several PostgreSQL performance techniques were implemented.

### Indexing

Indexes were created for frequently queried columns such as:

* Customer IDs
* Account IDs
* Transaction timestamps
* Loan IDs
* Loan payment dates

### EXPLAIN ANALYZE

`EXPLAIN ANALYZE` was used to inspect query execution plans.

For the small project dataset, PostgreSQL may choose a sequential scan because scanning a small table can be cheaper than using an index.

This is expected behavior.

### Partitioning

A separate partitioned transaction table was created using:

```sql
PARTITION BY RANGE (txn_timestamp)
```

Monthly partitions were created for transaction data.

Example:

```text
transactions_partitioned
        │
        ├── January 2026
        ├── February 2026
        ├── March 2026
        ├── April 2026
        └── May 2026
```

Partition pruning was verified using `EXPLAIN ANALYZE`.

A May 2026 query accessed only the May partition instead of scanning all monthly partitions.

---

## 📈 Key Project KPIs

Current dataset results:

| KPI                      |        Value |
| ------------------------ | -----------: |
| Customers                |           10 |
| Accounts                 |           11 |
| Transactions             |           77 |
| Loans                    |            6 |
| Loan Payments            |           11 |
| Total Transaction Amount |   ₹31,36,800 |
| Total Credits            |   ₹26,94,000 |
| Total Debits             |    ₹4,42,800 |
| Net Transaction Value    |   ₹22,51,200 |
| Total Deposit Balance    |   ₹34,50,000 |
| Total Loan Exposure      | ₹1,56,00,000 |
| NPA Loans                |            1 |
| NPA Percentage           |       16.67% |

---

## 📁 Repository Structure

```text
banking-analytics-postgresql/
│
├── database/
│   ├── 01_create_tables.sql
│   ├── 02_insert_data.sql
│   ├── 03_analytics.sql
│   ├── 04_loan_risk_npa.sql
│   ├── 05_fraud_detection.sql
│   ├── 06_performance_partitioning.sql
│   └── README.md
│
└── README.md
```

### SQL Script Order

Run the scripts in this order:

```text
01 → Create database tables
02 → Insert banking data
03 → Run general analytics
04 → Run loan risk & NPA analysis
05 → Run fraud/risk analysis
06 → Run performance & partitioning analysis
```

---

## ▶️ How to Run the Project

### 1. Create the database

Create a PostgreSQL database named:

```sql
banking_analytics
```

### 2. Open pgAdmin

Connect to PostgreSQL and open the Query Tool for:

```text
banking_analytics
```

### 3. Execute SQL scripts

Run the files in this order:

```text
database/01_create_tables.sql
database/02_insert_data.sql
database/03_analytics.sql
database/04_loan_risk_npa.sql
database/05_fraud_detection.sql
database/06_performance_partitioning.sql
```

---

## 🧠 Data Science Perspective

Although the current project is primarily SQL and PostgreSQL based, it provides the foundation for a future machine-learning pipeline.

```text
Raw Banking Data
       ↓
Data Cleaning
       ↓
Feature Engineering
       ↓
Customer / Transaction Features
       ↓
Risk Signals
       ↓
Analytics & Rule-Based Scoring
       ↓
Future ML Model
```

Potential ML features include:

* Transaction frequency
* Average transaction amount
* Transaction velocity
* Monthly transaction volume
* Customer contribution
* Loan exposure
* Days overdue
* Rapid transaction count
* Location-change frequency
* Historical risk indicators

Future models could include:

* Logistic Regression
* Random Forest
* XGBoost / LightGBM

---

## ⚠️ Important Project Scope

This project should be described accurately during interviews.

### Fraud Detection

This implementation uses **rule-based risk scoring**, not machine learning.

### NPA

The NPA classification uses a **simplified 90+ day overdue project rule**, not a complete regulatory implementation.

### CLV

The project uses a **simplified CLV proxy** for analytical demonstration.

### Customer Segmentation

The current segmentation is **rule-based**, not ML clustering.

---

## 💼 Interview Explanation

### 30-Second Version

> I built a Banking Analytics and Risk Intelligence platform using PostgreSQL. The project integrates customer, account, transaction and loan data into a relational banking database. I used SQL joins, aggregations, CTEs, window functions and CASE expressions to generate customer, transaction and loan analytics. I also implemented rule-based fraud risk scoring and NPA analysis, and used PostgreSQL features such as indexes, materialized views, EXPLAIN ANALYZE and range partitioning for performance and reusable reporting.

### Main Technical Contribution

My work involved:

* Relational database design
* SQL analytics
* Feature engineering
* Customer segmentation
* Transaction analysis
* Loan risk analysis
* NPA classification
* Rule-based fraud scoring
* KPI development
* Query optimization
* Indexing
* Partitioning
* Data-quality validation

---

## 🚀 Future Enhancements

Possible next steps:

1. Connect the PostgreSQL database to Python.
2. Perform exploratory data analysis using Pandas.
3. Build a proper fraud ML model.
4. Train and evaluate classification models.
5. Build a Power BI dashboard.
6. Add automated data pipelines.
7. Add model monitoring and drift detection.
8. Deploy the analytics platform.

---

## 👨‍💻 Project Skills Demonstrated

```text
SQL
PostgreSQL
Data Modeling
Data Analytics
Feature Engineering
Risk Analytics
Fraud Analytics
Loan Analytics
NPA Analysis
Query Optimization
Indexing
Partitioning
Data Quality
Business KPI Analysis
```

---

## 📌 Project Status

**Status: Completed — SQL/PostgreSQL Analytics Phase**

The project currently includes:

* Relational database design
* Banking data loading
* SQL analytics
* Customer analytics
* Transaction analytics
* Loan analytics
* NPA analysis
* Rule-based fraud risk analysis
* KPI views
* Materialized views
* Indexing
* Query execution analysis
* Range partitioning
* Partition pruning
* Data-quality checks

The next phase can extend the project into **Python-based Data Science and Machine Learning**.
