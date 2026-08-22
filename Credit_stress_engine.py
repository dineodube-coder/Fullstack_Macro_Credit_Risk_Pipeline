import numpy as np
import pandas as pd
import xgboost as xgb
from sqlalchemy import create_engine


def run_credit_scoring_engine():
    # 1. Pipeline Connectivity
    engine = create_engine('postgresql://postgres@localhost:5432/Corporate_Credit_Risk_Database?password=')

    print("[Pipeline] Mining ledger accounts from PostgreSQL...")
    df_finance = pd.read_sql("SELECT * FROM corporate_financial_ledgers;", engine)
    df_loans = pd.read_sql("SELECT * FROM corporate_loan_book;", engine)

    # 2. Machine Learning Feature Engineering (Basel-style ratios & Altman Z-Score parts)
    print("[ML Engine] Engineering structural risk features...")
    df_finance['working_cap_to_assets'] = df_finance['working_capital_zmw'] / df_finance['total_assets_zmw']
    df_finance['retained_earnings_to_assets'] = df_finance['retained_earnings_zmw'] / df_finance['total_assets_zmw']
    df_finance['ebit_to_assets'] = df_finance['ebit_zmw'] / df_finance['total_assets_zmw']
    df_finance['debt_to_equity'] = df_finance['total_debt_zmw'] / (
                df_finance['total_assets_zmw'] - df_finance['total_debt_zmw'])
    df_finance['interest_coverage'] = df_finance['ebit_zmw'] / df_finance['interest_expense_zmw']

    # 3. Model Training (Supervised XGBoost Scoring)
    feature_columns = ['working_cap_to_assets', 'retained_earnings_to_assets', 'ebit_to_assets', 'debt_to_equity',
                       'interest_coverage']
    X = df_finance[feature_columns]
    y = df_finance['historical_default_event']

    print("[ML Engine] Running XGBoost binary classification model...")
    classifier = xgb.XGBClassifier(n_estimators=50, max_depth=3, learning_rate=0.1, objective='binary:logistic')
    classifier.fit(X, y)

    # Generate baseline structural Probability of Default (PD)
    df_finance['base_pd'] = classifier.predict_proba(X)[:, 1]

    # 4. Macroeconomic Shock Mapping (Logit Scaling)
    # Replicating an economic shock: 5.0% interest rate hike, 25% currency drop
    delta_interest_rate = 5.00
    delta_fx_shock = 25.00

    beta_interest = 0.08
    beta_fx = 0.03

    print("[Simulation] Processing Monte Carlo macro stress scenarios...")
    # Apply standard logit transform to scale probabilities safely up to 100%
    # 1. Define unique sensitivity profiles per industry sector
    sector_betas = {
        'CORP-MING-04': {'beta_interest': 0.04, 'beta_fx': -0.05},
        # Mining: FX drop actually HELPS because they sell copper in USD!
        'CORP-RETL-02': {'beta_interest': 0.12, 'beta_fx': 0.08},
        # Retail: High debt and import costs make them highly sensitive.
        'CORP-ZAME-01': {'beta_interest': 0.07, 'beta_fx': 0.04},  # Mfg: Moderate sensitivity.
        'CORP-AGRI-03': {'beta_interest': 0.06, 'beta_fx': 0.02},
        # Agri: High interest sensitivity due to machinery loans.
        'CORP-TRAF-05': {'beta_interest': 0.09, 'beta_fx': 0.05}
        # Telecom/Logistics: Vulnerable to high fuel/energy costs.
    }

    # 2. Apply the customized industry shocks inside a loop
    def calculate_stressed_pd(row):
        comp_id = row['company_id']
        betas = sector_betas.get(comp_id, {'beta_interest': 0.08, 'beta_fx': 0.03})  # fallback defaults

        # Calculate unbound log-odds using specialized coefficients
        base_logit = np.log(row['base_pd'] / (1 - row['base_pd']))
        stressed_logit = base_logit + (betas['beta_interest'] * 5.0) + (betas['beta_fx'] * 25.0)

        # Return probability mapped cleanly between 0 and 1
        return 1 / (1 + np.exp(-stressed_logit))

    #Map it back to the Dataframe before exporting to CSV
    df_finance['stressed_pd'] = df_finance.apply(calculate_stressed_pd, axis=1)

    # 5. Financial Risk Calculations
    df_production = pd.merge(df_loans, df_finance[['company_id', 'base_pd', 'stressed_pd']], on='company_id',
                             how='inner') 

    # Expected Credit Loss formula: ECL = PD * LGD * EAD
    df_production['base_ecl_zmw'] = df_production['base_pd'] * df_production['loss_given_default_pct'] * df_production[
        'exposure_at_default_zmw']
    df_production['stressed_ecl_zmw'] = df_production['stressed_pd'] * df_production['loss_given_default_pct'] * \
                                        df_production['exposure_at_default_zmw']
    df_production['capital_impairment_delta'] = df_production['stressed_ecl_zmw'] - df_production['base_ecl_zmw']

    # Export clean production table for Power BI BI ingestion
    df_production.to_csv("stressed_credit_portfolio.csv", index=False)
    print("[Pipeline] Data export complete. 'stressed_credit_portfolio.csv' is ready for deployment.")


if __name__ == "__main__":
    run_credit_scoring_engine()