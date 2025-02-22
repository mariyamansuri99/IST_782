-- Create database and tables
create database aml;
DROP TABLE IF EXISTS SAR;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS Customer;

CREATE TABLE Customer (
    CustomerID VARCHAR(20) PRIMARY KEY,
    Name VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    PhoneNumber VARCHAR(75),
    EmailAddress VARCHAR(100),
    CountryRiskLevel VARCHAR(10),
    PEPFlag VARCHAR(5),
    RegulatorID VARCHAR(20)
);

CREATE TABLE Account (
    AccountID VARCHAR(20) PRIMARY KEY,
    CustomerID VARCHAR(20),
    AccountType VARCHAR(20),
    AccountOpeningDate DATE,
    KYCStatus VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Transactions (
    TransactionID VARCHAR(20) PRIMARY KEY,
    CustomerID VARCHAR(20),
    TransactionDate DATE,
    TransactionAmount DECIMAL(15, 2),
    TransactionType VARCHAR(20),
    Currency VARCHAR(10),
    CounterpartyID VARCHAR(20),
    CounterpartyCountry VARCHAR(150),
    TransactionChannel VARCHAR(20),
    TransactionPurpose VARCHAR(50),
    FlagStatus VARCHAR(5),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
select * from SAr;
CREATE TABLE SAR (
    SARID VARCHAR(100) PRIMARY KEY,
    CustomerID VARCHAR(20),
    Name VARCHAR(100),
    EmailAddress VARCHAR(100),
    TransactionID VARCHAR(20),
    ReasonForFlagging VARCHAR(255),
    SARStatus VARCHAR(20),
    SARSubmissionDate DATE,
    RegulatorID VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);

-- create format to copy data from stage
CREATE OR REPLACE FILE FORMAT csv_file_format_mmddyy
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
DATE_FORMAT = 'YYYY-MM-DD' -- Specify the date format for parsing dates
NULL_IF = ('NULL', ''); -- Treat 'NULL' and empty strings as NULL values


COPY INTO Transactions
FROM @AML_Stage/Updated_Fake_Transactions.csv
FILE_FORMAT = csv_file_format_mmddyy
ON_ERROR = 'CONTINUE'; -- Skip problematic rows and continue loading;
;

select * from transactions LIMIT 5;

COPY INTO Account
FROM @AML_Stage/Updated_Fake_Accounts.csv
FILE_FORMAT = csv_file_format_mmddyy
ON_ERROR = 'CONTINUE';-- Skip problematic rows and continue loading;

select * from account limit 5;


CREATE OR REPLACE FILE FORMAT csv_file_format
TYPE = 'CSV'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1 -- Skip the first row (header row)
NULL_IF = ('NULL', ''); -- Treat 'NULL' and empty strings as NULL values

COPY INTO Customer
FROM @AML_Stage/Updated_Fake_Customers.csv
FILE_FORMAT = csv_file_format
ON_ERROR = 'CONTINUE'; -- Skip problematic rows and continue loading

select * from customer;


-- etl process

-- business process: Flagged transactions as suspicious if they exceed $50,000
INSERT INTO SAR (
    SARID, CustomerID, Name, EmailAddress, TransactionID, ReasonForFlagging, SARStatus, SARSubmissionDate, RegulatorID
)
SELECT
    CONCAT('SAR-', UUID_STRING()) AS SARID, -- Generate a unique SAR ID using a UUID
    T.CustomerID,
    C.Name,
    C.EmailAddress,
    T.TransactionID,
    'Transaction exceeds $50,000' AS ReasonForFlagging,
    'Pending' AS SARStatus,
    CURRENT_DATE AS SARSubmissionDate,
    C.RegulatorID
FROM
    Transactions T
JOIN
    Customer C ON T.CustomerID = C.CustomerID
WHERE
    T.TransactionAmount > 50000; -- Removed the FlagStatus condition

-- business process : Flag multiple large transactions within a short period (A day)
INSERT INTO SAR (
    SARID, CustomerID, Name, EmailAddress, TransactionID, ReasonForFlagging, SARStatus, SARSubmissionDate, RegulatorID
)
SELECT DISTINCT
    CONCAT('SAR-', UUID_STRING()) AS SARID, -- Generate a unique SAR ID using a UUID
    T.CustomerID,
    C.Name,
    C.EmailAddress,
    T.TransactionID,
    'Multiple large transactions in short period' AS ReasonForFlagging,
    'Pending' AS SARStatus,
    CURRENT_DATE AS SARSubmissionDate,
    C.RegulatorID
FROM
    Transactions T
JOIN
    (
        SELECT CustomerID, COUNT(*) AS TransactionCount
        FROM Transactions
        WHERE TransactionAmount > 5000 -- Define "large transaction" threshold
        GROUP BY CustomerID, DATE(TransactionDate)
        HAVING COUNT(*) > 2 -- Define "short period" as the same day
    ) AS FlaggedCustomers
    ON T.CustomerID = FlaggedCustomers.CustomerID
JOIN
    Customer C ON T.CustomerID = C.CustomerID;

-- business process 3: Flag Transactions from High Risk Countries    
INSERT INTO SAR (
    SARID, CustomerID, Name, EmailAddress, TransactionID, ReasonForFlagging, SARStatus, SARSubmissionDate, RegulatorID
)
SELECT
    CONCAT('SAR-', UUID_STRING()) AS SARID, -- Generate a unique SAR ID using a UUID
    T.CustomerID,
    C.Name,
    C.EmailAddress,
    T.TransactionID,
    CONCAT('Transaction from high-risk country: ', T.CounterpartyCountry) AS ReasonForFlagging,
    'Pending' AS SARStatus,
    CURRENT_DATE AS SARSubmissionDate,
    C.RegulatorID
FROM
    Transactions T
JOIN
    Customer C ON T.CustomerID = C.CustomerID
WHERE
    T.CounterpartyCountry IN (SELECT Country FROM Customer WHERE CountryRiskLevel = 'High') -- High-risk countries
    AND T.TransactionAmount > 25000; -- Flag transactions greater than $50,000




SELECT
    SARID,
    CustomerID,
    Name,
    EmailAddress,
    ReasonForFlagging,
    SARStatus,
    SARSubmissionDate,
    RegulatorID
FROM
    SAR
WHERE
    SARStatus = 'Pending' and REASONFORFLAGGING <> 'Transaction exceeds $50,000';

-- business process: Generate Suspicious Activity Reports (SARs)
INSERT INTO SAR (
    SARID, CustomerID, Name, EmailAddress, TransactionID, ReasonForFlagging, SARStatus, SARSubmissionDate, RegulatorID
)
SELECT
    CONCAT('SAR-', UUID_STRING()) AS SARID, -- Generate a unique SAR ID using a 
    T.CustomerID,
    C.Name,
    C.EmailAddress,
    T.TransactionID,
    'Unusual transaction compared to customer’s usual behavior' AS ReasonForFlagging,
    'Pending' AS SARStatus,
    CURRENT_DATE AS SARSubmissionDate,
    C.RegulatorID
FROM
    Transactions T
JOIN
    (
        SELECT CustomerID, AVG(TransactionAmount) AS AvgAmount, STDDEV(TransactionAmount) AS StdDevAmount
        FROM Transactions
        GROUP BY CustomerID
    ) AS CustomerStats
    ON T.CustomerID = CustomerStats.CustomerID
JOIN
    Customer C ON T.CustomerID = C.CustomerID
WHERE
    ABS(T.TransactionAmount - CustomerStats.AvgAmount) > ( 2 * CustomerStats.StdDevAmount) -- 2-sigma rule
    ;


-- business process: Regulatory Compliance Reporting
UPDATE SAR
SET
    SARStatus = 'Submitted',
    SARSubmissionDate = CURRENT_DATE
WHERE
    SARStatus = 'Pending';
