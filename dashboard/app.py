
import streamlit as st
import pandas as pd
import psycopg
import plotly.express as px

# ---------------- PAGE CONFIGURATION ----------------

st.set_page_config(
    page_title="Banking Analytics Dashboard",
    page_icon="🏦",
    layout="wide"
)

st.title("🏦 Banking Analytics & Risk Intelligence")
st.caption("PostgreSQL-powered Banking Analytics Platform")


# ---------------- DATABASE CONNECTION ----------------

def load_data(query):
    """
    Opens a fresh Neon PostgreSQL connection for each query.
    The connection is closed automatically after the query.
    """

    with psycopg.connect(
        st.secrets["DATABASE_URL"],
        connect_timeout=20,
        sslmode="require"
    ) as conn:

        with conn.cursor() as cur:
            cur.execute(query)
            rows = cur.fetchall()

            columns = [
                description.name
                for description in cur.description
            ]

    return pd.DataFrame(rows, columns=columns)


# ---------------- MAIN DASHBOARD ----------------

try:

    # ---------------- EXECUTIVE KPIs ----------------

    kpis = load_data("""
        SELECT *
        FROM executive_banking_kpis;
    """)

    if kpis.empty:
        st.warning("No executive KPI data found.")
        st.stop()

    kpi = kpis.iloc[0]

    st.subheader("📊 Executive Overview")

    c1, c2, c3, c4 = st.columns(4)

    c1.metric(
        "Total Customers",
        f"{int(kpi['total_customers']):,}"
    )

    c2.metric(
        "Total Accounts",
        f"{int(kpi['total_accounts']):,}"
    )

    c3.metric(
        "Transactions",
        f"{int(kpi['total_transactions']):,}"
    )

    c4.metric(
        "Transaction Volume",
        f"₹{float(kpi['total_transaction_volume']):,.0f}"
    )

    c5, c6, c7, c8 = st.columns(4)

    c5.metric(
        "Deposit Balance",
        f"₹{float(kpi['total_deposit_balance']):,.0f}"
    )

    c6.metric(
        "Loan Exposure",
        f"₹{float(kpi['total_loan_exposure']):,.0f}"
    )

    c7.metric(
        "NPA Loans",
        int(kpi["npa_loans"])
    )

    c8.metric(
        "NPA Percentage",
        f"{float(kpi['npa_percentage']):.2f}%"
    )

    st.divider()


    # ---------------- TRANSACTION ANALYTICS ----------------

    st.subheader("📈 Transaction Analytics")

    monthly = load_data("""
        SELECT
            DATE_TRUNC('month', txn_timestamp)::date AS month,
            SUM(amount) AS transaction_volume,
            COUNT(*) AS transaction_count
        FROM transactions
        GROUP BY 1
        ORDER BY 1;
    """)

    left, right = st.columns(2)

    with left:

        fig = px.bar(
            monthly,
            x="month",
            y="transaction_volume",
            title="Monthly Transaction Volume",
            labels={
                "month": "Month",
                "transaction_volume": "Amount (₹)"
            },
            text_auto=".2s"
        )

        st.plotly_chart(
            fig,
            use_container_width=True
        )

    with right:

        fig = px.line(
            monthly,
            x="month",
            y="transaction_count",
            markers=True,
            title="Monthly Transaction Count"
        )

        st.plotly_chart(
            fig,
            use_container_width=True
        )

    st.divider()


    # ---------------- CUSTOMER ANALYTICS ----------------

    st.subheader("👥 Customer Analytics")

    customers = load_data("""
        SELECT
            c.customer_id,
            c.full_name,
            c.city,
            c.risk_profile,
            COUNT(DISTINCT a.account_id) AS account_count,
            COALESCE(SUM(a.balance), 0) AS total_balance
        FROM customers c
        LEFT JOIN accounts a
            ON c.customer_id = a.customer_id
        GROUP BY
            c.customer_id,
            c.full_name,
            c.city,
            c.risk_profile
        ORDER BY total_balance DESC;
    """)

    # Customer risk filter

    risk_options = ["All"] + sorted(
        customers["risk_profile"].dropna().unique().tolist()
    )

    selected_risk = st.selectbox(
        "Filter customers by risk profile",
        risk_options
    )

    if selected_risk != "All":
        filtered_customers = customers[
            customers["risk_profile"] == selected_risk
        ]
    else:
        filtered_customers = customers

    st.dataframe(
        filtered_customers,
        use_container_width=True,
        hide_index=True
    )

    st.divider()


    # ---------------- LOAN ANALYTICS ----------------

    st.subheader("💳 Loan Analytics")

    loans = load_data("""
        SELECT
            loan_type,
            COUNT(*) AS loan_count,
            SUM(principal) AS total_principal
        FROM loans
        GROUP BY loan_type
        ORDER BY total_principal DESC;
    """)

    left, right = st.columns(2)

    with left:

        st.dataframe(
            loans,
            use_container_width=True,
            hide_index=True
        )

    with right:

        fig = px.pie(
            loans,
            names="loan_type",
            values="total_principal",
            title="Loan Exposure by Type",
            hole=0.35
        )

        st.plotly_chart(
            fig,
            use_container_width=True
        )

    st.divider()


    # ---------------- FRAUD ANALYTICS ----------------

    st.subheader("🚨 Fraud Risk Analysis")

    fraud = load_data("""
        SELECT
            fraud_risk_level,
            COUNT(*) AS transaction_count
        FROM fraud_transaction_analysis
        GROUP BY fraud_risk_level
        ORDER BY transaction_count DESC;
    """)

    left, right = st.columns(2)

    with left:

        st.dataframe(
            fraud,
            use_container_width=True,
            hide_index=True
        )

    with right:

        fig = px.pie(
            fraud,
            names="fraud_risk_level",
            values="transaction_count",
            title="Transactions by Fraud Risk Level",
            hole=0.35
        )

        st.plotly_chart(
            fig,
            use_container_width=True
        )

    st.caption(
        "Fraud classifications are based on project-defined "
        "rules, not machine-learning probabilities."
    )

    st.divider()


    # ---------------- FOOTER ----------------

    st.success(
        "Dashboard connected to Neon PostgreSQL successfully."
    )

    st.caption(
        "Banking Analytics & Risk Intelligence Platform "
        "| PostgreSQL + Python + Streamlit"
    )


# ---------------- ERROR HANDLING ----------------

except Exception as e:

    st.error(
        "Dashboard could not load the data. "
        "Please check the database connection and configuration."
    )

    # Detailed errors are kept out of the public dashboard.
    print(f"Dashboard error: {type(e).__name__}: {e}")
