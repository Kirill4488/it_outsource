-- ==========================================
-- ФАЙЛ 1: init_db.sql
-- Инициализация БД: 6 таблиц, данные и 8 запросов
-- ==========================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS contract_details;
DROP TABLE IF EXISTS contracts;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS clients;

-- Создание таблиц
CREATE TABLE clients (
    client_id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_name TEXT NOT NULL,
    contact_person TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL
);

CREATE TABLE services (
    service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_name TEXT NOT NULL,
    price_per_hour REAL NOT NULL CHECK(price_per_hour > 0),
    category TEXT NOT NULL
);

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    position TEXT NOT NULL,
    salary REAL NOT NULL CHECK(salary > 0)
);

CREATE TABLE contracts (
    contract_id INTEGER PRIMARY KEY AUTOINCREMENT,
    contract_number TEXT NOT NULL UNIQUE,
    client_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    hours_allocated INTEGER NOT NULL CHECK(hours_allocated > 0),
    start_date TEXT NOT NULL,
    status TEXT NOT NULL CHECK(status IN ('Активен', 'Завершен', 'Приостановлен')),
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE
);

CREATE TABLE contract_details (
    detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
    contract_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    role_in_project TEXT NOT NULL,
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    contract_id INTEGER NOT NULL,
    payment_date TEXT NOT NULL,
    amount REAL NOT NULL CHECK(amount > 0),
    payment_status TEXT NOT NULL CHECK(payment_status IN ('Оплачено', 'Ожидается')),
    FOREIGN KEY (contract_id) REFERENCES contracts(contract_id) ON DELETE CASCADE
);

-- Наполнение данными (по 3 строки)
INSERT INTO clients (company_name, contact_person, email, phone) VALUES
('ООО ТехноПром', 'Иванов Иван', 'ivanov@technoprom.ru', '+79991112233'),
('АО АльфаБанк', 'Петров Петр', 'petrov@alfabank.ru', '+79992223344'),
('Магазин Клик', 'Алексеева Анна', 'anna@clickshop.ru', '+79994445566');

INSERT INTO services (service_name, price_per_hour, category) VALUES
('Разработка на Python', 2500.00, 'Разработка'),
('Администрирование Linux', 2000.00, 'Поддержка'),
('Тестирование ПО (QA)', 1800.00, 'Тестирование');

INSERT INTO employees (full_name, position, salary) VALUES
('Козлов Алексей', 'Senior Python Developer', 150000.00),
('Морозов Денис', 'Linux DevOps Engineer', 130000.00),
('Павлова Елена', 'QA Automation', 110000.00);

INSERT INTO contracts (contract_number, client_id, service_id, hours_allocated, start_date, status) VALUES
('ДОГ-2026-001', 1, 1, 120, '2026-01-15', 'Активен'),
('ДОГ-2026-002', 2, 2, 80, '2026-02-01', 'Активен'),
('ДОГ-2026-003', 3, 3, 50, '2026-02-10', 'Завершен');

INSERT INTO contract_details (contract_id, employee_id, role_in_project) VALUES
(1, 1, 'Тимлид разработки'),
(2, 2, 'Системный архитектор'),
(3, 3, 'Инженер по тестированию');

INSERT INTO payments (contract_id, payment_date, amount, payment_status) VALUES
(1, '2026-01-20', 300000.00, 'Оплачено'),
(2, '2026-02-05', 160000.00, 'Ожидается'),
(3, '2026-02-15', 90000.00, 'Оплачено');

-- Обязательные 8 SQL запросов для практики
-- 1. Фильтрация WHERE
SELECT * FROM clients WHERE company_name LIKE 'ООО%';
-- 2. Сортировка ORDER BY
SELECT * FROM services ORDER BY price_per_hour DESC;
-- 3. Группировка GROUP BY + COUNT
SELECT status, COUNT(*) FROM contracts GROUP BY status;
-- 4. JOIN 3 таблиц
SELECT c.contract_number, cl.company_name, s.service_name FROM contracts c INNER JOIN clients cl ON c.client_id = cl.client_id INNER JOIN services s ON c.service_id = s.service_id;
-- 5. Агрегация SUM с HAVING
SELECT contract_id, SUM(amount) FROM payments GROUP BY contract_id HAVING SUM(amount) > 100000;
-- 6. Подзапрос
SELECT contract_number FROM contracts WHERE hours_allocated > (SELECT AVG(hours_allocated) FROM contracts);
-- 7. UPDATE
UPDATE contracts SET status = 'Завершен' WHERE contract_number = 'ДОГ-2026-001';
-- 8. JOIN всех 6 таблиц
SELECT * FROM contracts c INNER JOIN clients cl ON c.client_id = cl.client_id INNER JOIN services s ON c.service_id = s.service_id INNER JOIN contract_details cd ON c.contract_id = cd.contract_id INNER JOIN employees e ON cd.employee_id = e.employee_id INNER JOIN payments p ON c.contract_id = p.contract_id;
