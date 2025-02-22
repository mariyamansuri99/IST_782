# Anti-Money Laundering (AML) Data Warehouse

## Project Overview
The project was a group project done for the class IST 722 Data Warehouse, this project aims to implement an **Anti-Money Laundering (AML) Data Warehouse** to detect suspicious transactions and ensure **regulatory compliance**. The solution focuses on **business process identification, star schema design, ETL implementation, and data load**. 

### Key Features:
- **Suspicious Activity Reporting (SAR):** Detect and report transactions with potential fraud.
- **Transaction Flagging:** Identify high-value and abnormal transactions.
- **Regulatory Compliance:** Maintain transaction records for auditing and reporting.

## Repository Structure
This repository contains the following files:

### 1. Presentation (`IST 722 - Data Warehouse - AML PPT.pptx`)
- **Description:** PowerPoint presentation summarizing the project.
- **Key Components:**
  - Business process analysis and bus matrix
  - Dimensional modeling and schema design
  - BI and actionable insights for AML detection

### 2. Schema Design
- **Fact Table:** Transactions
- **Dimension Tables:** Customer, Account, SAR
- **Key Facts:** TransactionAmount, TransactionDate, TransactionID, CounterpartyCountry, SARStatus

### 3. Analytics Implemented
- **Flag High-Value Transactions:** Transactions exceeding **$50,000**.
- **Detect Multiple Large Transactions:** Customers with **more than two large transactions** in a day.
- **Identify High-Risk Countries:** Transactions originating from high-risk locations.
- **Unusual Behavior Detection:** Transactions that significantly deviate from a customer’s historical patterns.

## Required Software
To run and analyze the project, ensure you have the following:

### Software Requirements:
- **SQL Database (e.g., PostgreSQL, Snowflake, MySQL)** for data storage, we used Snowflake.
- **ETL Tools (e.g., Apache Nifi, Airflow)** for data pipeline automation
- **BI Tools (e.g., Tableau, Power BI, Google Data Studio)** for visualization, we used PowerBI

### Required Python Libraries:
Install dependencies using:
```bash
pip install pandas numpy matplotlib seaborn sqlalchemy psycopg2
```

## How to Review the Files
1. **Presentation:**
   - Open `IST 722 - Data Warehouse - AML PPT.pptx` in Microsoft PowerPoint or Google Slides.
   - Review the slides for a high-level understanding of the data warehouse architecture and AML strategy.

2. **Schema & Data Pipeline:**
   - Review the star schema design for transaction monitoring.
   - Understand the ETL workflow and reporting mechanisms.

3. **BI & Actionable Insights:**
   - Explore visualization dashboards for fraud detection and compliance monitoring.
   - Review alerts for suspicious transactions flagged in the SAR process.

## Business Intelligence & Future Enhancements
- **Automate AML transaction flagging** based on risk thresholds.
- **Enhance fraud detection models** using machine learning techniques.
- **Optimize reporting dashboards** for real-time AML insights.
