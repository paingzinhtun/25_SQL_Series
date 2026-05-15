-- Day 6 - Simple Banking System
-- Sample data for PostgreSQL
--
-- This data is designed to support the analysis queries:
-- - Customers include individual and business customers.
-- - Accounts include savings, current, and business accounts.
-- - Account statuses include active, frozen, and closed.
-- - Transactions include success, failed, and pending records.
-- - Successful deposits and transfer_in increase balances.
-- - Successful withdrawals, transfer_out, and fees decrease balances.
-- - Failed and pending transactions are included but do not affect current_balance.

INSERT INTO customers (
    first_name,
    last_name,
    email,
    phone_number,
    city,
    customer_type
) VALUES
    ('Aung', 'Min', 'aung.min.bank@example.com', '09-460001001', 'Yangon', 'individual'),
    ('Su', 'Mon Trading', 'su.mon.trading@example.com', '09-460001002', 'Mandalay', 'business'),
    ('Thandar', 'Hlaing', 'thandar.hlaing.bank@example.com', '09-460001003', 'Naypyidaw', 'individual'),
    ('Kyaw', 'Zin', 'kyaw.zin.bank@example.com', '09-460001004', 'Yangon', 'individual'),
    ('May', 'Thu', 'may.thu.bank@example.com', '09-460001005', 'Bago', 'individual'),
    ('Htet Aung Services', 'Co', 'htet.aung.services@example.com', '09-460001006', 'Taunggyi', 'business'),
    ('Nilar', 'Win', 'nilar.win.bank@example.com', '09-460001007', 'Mawlamyine', 'individual'),
    ('Min', 'Khant', 'min.khant.bank@example.com', '09-460001008', 'Mandalay', 'individual'),
    ('Ei', 'Phyo', 'ei.phyo.bank@example.com', '09-460001009', 'Yangon', 'individual'),
    ('Ye Naing Logistics', 'Ltd', 'ye.naing.logistics@example.com', '09-460001010', 'Pathein', 'business'),
    ('Wai', 'Yan', 'wai.yan.bank@example.com', '09-460001011', 'Yangon', 'individual'),
    ('Khin', 'Sandi', 'khin.sandi.bank@example.com', '09-460001012', 'Naypyidaw', 'individual'),
    ('Myo', 'Thant', 'myo.thant.bank@example.com', '09-460001013', 'Mandalay', 'individual'),
    ('Hnin', 'Yu', 'hnin.yu.bank@example.com', '09-460001014', 'Yangon', 'individual'),
    ('Yamin Oo Retail', 'Group', 'yamin.oo.retail@example.com', '09-460001015', 'Taunggyi', 'business');

INSERT INTO branches (
    branch_name,
    city
) VALUES
    ('Yangon Central Branch', 'Yangon'),
    ('Mandalay Business Branch', 'Mandalay'),
    ('Naypyidaw Service Branch', 'Naypyidaw'),
    ('Taunggyi Digital Branch', 'Taunggyi');

INSERT INTO accounts (
    customer_id,
    branch_id,
    account_number,
    account_type,
    opening_date,
    current_balance,
    account_status
) VALUES
    (1, 1, 'MMK-100001', 'savings', '2024-01-10', 415000.00, 'active'),
    (1, 1, 'MMK-100002', 'current', '2024-03-15', 270000.00, 'active'),
    (2, 2, 'MMK-100003', 'business', '2023-08-20', 2675000.00, 'active'),
    (3, 3, 'MMK-100004', 'savings', '2024-02-01', 800000.00, 'active'),
    (4, 1, 'MMK-100005', 'current', '2023-11-05', 890000.00, 'active'),
    (5, 1, 'MMK-100006', 'savings', '2025-01-12', 100000.00, 'active'),
    (6, 4, 'MMK-100007', 'business', '2022-06-18', 3150000.00, 'active'),
    (7, 3, 'MMK-100008', 'savings', '2024-09-08', 550000.00, 'active'),
    (8, 2, 'MMK-100009', 'current', '2025-02-14', 395000.00, 'active'),
    (9, 1, 'MMK-100010', 'savings', '2025-03-01', 197000.00, 'active'),
    (10, 2, 'MMK-100011', 'business', '2023-04-25', 2160000.00, 'active'),
    (11, 1, 'MMK-100012', 'current', '2023-07-17', 73000.00, 'closed'),
    (12, 3, 'MMK-100013', 'savings', '2024-12-10', 650000.00, 'active'),
    (13, 2, 'MMK-100014', 'current', '2024-05-21', 640000.00, 'active'),
    (14, 1, 'MMK-100015', 'savings', '2025-04-04', 400000.00, 'frozen'),
    (15, 4, 'MMK-100016', 'business', '2022-10-11', 4040000.00, 'active'),
    (2, 2, 'MMK-100017', 'current', '2025-06-01', 550000.00, 'active'),
    (6, 4, 'MMK-100018', 'savings', '2024-08-19', 1290000.00, 'active');

INSERT INTO transactions (
    account_id,
    transaction_date,
    transaction_type,
    amount,
    transaction_status,
    description
) VALUES
    (1, '2026-01-02', 'deposit', 500000.00, 'success', 'Initial cash deposit'),
    (1, '2026-01-05', 'withdrawal', 80000.00, 'success', 'ATM withdrawal'),
    (1, '2026-01-10', 'fee', 5000.00, 'success', 'Monthly service fee'),
    (1, '2026-01-12', 'withdrawal', 100000.00, 'failed', 'Insufficient funds check'),
    (2, '2026-01-03', 'deposit', 300000.00, 'success', 'Salary deposit'),
    (2, '2026-01-09', 'transfer_out', 50000.00, 'success', 'Transfer to family'),
    (2, '2026-01-14', 'transfer_in', 20000.00, 'success', 'Wallet transfer in'),
    (3, '2026-01-04', 'deposit', 3000000.00, 'success', 'Business sales deposit'),
    (3, '2026-01-11', 'transfer_out', 700000.00, 'success', 'Supplier payment'),
    (3, '2026-01-17', 'fee', 25000.00, 'success', 'Business account fee'),
    (3, '2026-01-22', 'transfer_in', 400000.00, 'success', 'Partner settlement'),
    (4, '2026-01-06', 'deposit', 900000.00, 'success', 'Fixed income deposit'),
    (4, '2026-01-15', 'withdrawal', 100000.00, 'success', 'Cash withdrawal'),
    (4, '2026-01-20', 'transfer_out', 50000.00, 'pending', 'Pending mobile transfer'),
    (5, '2026-01-07', 'deposit', 1200000.00, 'success', 'Client payment'),
    (5, '2026-01-18', 'transfer_out', 300000.00, 'success', 'Household transfer'),
    (5, '2026-01-25', 'fee', 10000.00, 'success', 'Current account fee'),
    (6, '2026-02-01', 'deposit', 150000.00, 'success', 'Cash deposit'),
    (6, '2026-02-04', 'withdrawal', 50000.00, 'success', 'ATM withdrawal'),
    (6, '2026-02-08', 'withdrawal', 200000.00, 'failed', 'Failed withdrawal attempt'),
    (7, '2026-02-02', 'deposit', 5000000.00, 'success', 'Business revenue deposit'),
    (7, '2026-02-10', 'withdrawal', 800000.00, 'success', 'Cash operating expense'),
    (7, '2026-02-15', 'transfer_out', 1000000.00, 'success', 'Vendor transfer'),
    (7, '2026-02-20', 'fee', 50000.00, 'success', 'Business monthly fee'),
    (8, '2026-02-03', 'deposit', 700000.00, 'success', 'Salary deposit'),
    (8, '2026-02-12', 'transfer_in', 100000.00, 'success', 'Incoming transfer'),
    (8, '2026-02-18', 'withdrawal', 250000.00, 'success', 'Travel cash withdrawal'),
    (9, '2026-02-04', 'deposit', 400000.00, 'success', 'Cash deposit'),
    (9, '2026-02-11', 'fee', 5000.00, 'success', 'Account maintenance fee'),
    (9, '2026-02-16', 'withdrawal', 100000.00, 'pending', 'Pending ATM reversal check'),
    (10, '2026-02-05', 'deposit', 250000.00, 'success', 'Cash deposit'),
    (10, '2026-02-13', 'transfer_out', 50000.00, 'success', 'Digital transfer'),
    (10, '2026-02-22', 'fee', 3000.00, 'success', 'Monthly service fee'),
    (11, '2026-03-01', 'deposit', 2500000.00, 'success', 'Logistics payment deposit'),
    (11, '2026-03-05', 'transfer_in', 600000.00, 'success', 'Partner transfer in'),
    (11, '2026-03-12', 'transfer_out', 900000.00, 'success', 'Fuel supplier payment'),
    (11, '2026-03-18', 'fee', 40000.00, 'success', 'Business account fee'),
    (12, '2026-03-02', 'deposit', 100000.00, 'success', 'Final deposit before closure'),
    (12, '2026-03-06', 'withdrawal', 25000.00, 'success', 'Cash withdrawal'),
    (12, '2026-03-09', 'fee', 2000.00, 'success', 'Closure processing fee'),
    (13, '2026-03-03', 'deposit', 600000.00, 'success', 'Savings deposit'),
    (13, '2026-03-08', 'transfer_in', 150000.00, 'success', 'Incoming transfer'),
    (13, '2026-03-15', 'withdrawal', 100000.00, 'success', 'Cash withdrawal'),
    (14, '2026-03-04', 'deposit', 850000.00, 'success', 'Salary deposit'),
    (14, '2026-03-11', 'transfer_out', 200000.00, 'success', 'Transfer to supplier'),
    (14, '2026-03-19', 'fee', 10000.00, 'success', 'Current account fee'),
    (15, '2026-03-05', 'deposit', 450000.00, 'success', 'Cash deposit before account freeze'),
    (15, '2026-03-14', 'deposit', 200000.00, 'pending', 'Pending review deposit'),
    (15, '2026-03-22', 'withdrawal', 50000.00, 'success', 'Cash withdrawal before freeze'),
    (16, '2026-04-01', 'deposit', 4200000.00, 'success', 'Retail revenue deposit'),
    (16, '2026-04-06', 'transfer_in', 500000.00, 'success', 'Marketplace settlement'),
    (16, '2026-04-12', 'withdrawal', 600000.00, 'success', 'Business cash withdrawal'),
    (16, '2026-04-20', 'fee', 60000.00, 'success', 'Business service fee'),
    (17, '2026-04-02', 'deposit', 750000.00, 'success', 'Business current deposit'),
    (17, '2026-04-09', 'withdrawal', 120000.00, 'success', 'Cash withdrawal'),
    (17, '2026-04-16', 'transfer_out', 80000.00, 'success', 'Digital transfer'),
    (18, '2026-04-03', 'deposit', 1100000.00, 'success', 'Owner savings deposit'),
    (18, '2026-04-10', 'transfer_in', 200000.00, 'success', 'Incoming transfer'),
    (18, '2026-04-18', 'fee', 10000.00, 'success', 'Savings account fee');
