import os
from flask import Flask, render_template, request, redirect, url_for
import sqlite3

app = Flask(__name__)
DB_PATH = os.path.join(os.path.dirname(__file__), "database.db")


def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


@app.route("/")
def index():
    conn = get_db_connection()

    # Сборный запрос договоров с деталями и суммами оплат
    contracts_query = """
        SELECT 
            c.id AS contract_id,
            c.contract_number,
            c.start_date,
            cl.name AS client_name,
            s.name AS service_name,
            m.name AS manager_name,
            st.name AS status_name,
            COALESCE(SUM(p.amount), 0) AS total_paid
        FROM contracts c
        JOIN clients cl ON c.client_id = cl.id
        JOIN services s ON c.service_id = s.id
        JOIN managers m ON c.manager_id = m.id
        JOIN statuses st ON c.status_id = st.id
        LEFT JOIN payments p ON c.id = p.contract_id
        GROUP BY c.id
    """
    contracts = conn.execute(contracts_query).fetchall()

    # Общая сумма абсолютно всех оплат в базе данных
    total_payments_query = "SELECT COALESCE(SUM(amount), 0) AS total FROM payments"
    total_payments_sum = conn.execute(total_payments_query).fetchone()["total"]

    conn.close()

    return render_template(
        "index.html", contracts=contracts, total_payments_sum=total_payments_sum
    )


@app.route("/add_client", methods=["POST"])
def add_client():
    name = request.form.get("name")
    phone = request.form.get("phone")
    email = request.form.get("email")

    if name:
        conn = get_db_connection()
        conn.execute(
            "INSERT INTO clients (name, phone, email) VALUES (?, ?, ?)",
            (name, phone, email),
        )
        conn.commit()
        conn.close()

    return redirect(url_for("index"))


if __name__ == "__main__":
    app.run(debug=True)

