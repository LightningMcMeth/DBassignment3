import mysql.connector
import uuid
import random
from faker import Faker
from mysql.connector import Error
from datetime import datetime, timedelta

HOST = 'localhost'
USER = 'root'
PASSWORD = 'B1gGamingGamer123!'
DATABASE = 'SlopShop'

fake = Faker()

def create_connection():
    try:
        connection = mysql.connector.connect(
            host=HOST,
            user=USER,
            password=PASSWORD,
            database=DATABASE,
            autocommit=False
        )
        if connection.is_connected():
            return connection

    except Error as e:
        print(f"Error: {e}")
    return None

def insert_customers(connection, n=1000):
    cursor = connection.cursor()
    for _ in range(n):
        customer_id = str(uuid.uuid4())
        first_name = fake.first_name()
        last_name = fake.last_name()
        email = fake.email()
        phone = fake.phone_number()
        cursor.execute(
            "INSERT INTO customers (customer_id, first_name, last_name, email, phone) VALUES (%s, %s, %s, %s, %s)",
            (customer_id, first_name, last_name, email, phone)
        )
    connection.commit()
    cursor.close()

def insert_customer_details(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT customer_id FROM customers")
    customer_ids = cursor.fetchall()
    
    for customer_id in customer_ids:
        cursor.execute("SELECT 1 FROM customer_details WHERE customer_id = %s", (customer_id[0],))
        if cursor.fetchone() is None:
            address = fake.address()
            postcode = fake.postcode()
            cursor.execute(
                "INSERT INTO customer_details (customer_id, address, postcode) VALUES (%s, %s, %s)",
                (customer_id[0], address, postcode)
            )
    connection.commit()
    cursor.close()


def insert_slop(connection, n=1000):
    cursor = connection.cursor()
    for _ in range(n):
        game_id = str(uuid.uuid4())
        game_title = fake.catch_phrase()
        genres = fake.word() + ", " + fake.word()
        developer = fake.company()
        publisher = fake.company()
        price = round(random.uniform(10, 100), 2)
        is_discounted = random.choice([True, False])
        cursor.execute(
            "INSERT INTO slop (game_id, game_title, genres, developer, publisher, price, is_discounted) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (game_id, game_title, genres, developer, publisher, price, is_discounted)
        )
    connection.commit()
    cursor.close()

def insert_suppliers(connection, n=100):
    cursor = connection.cursor()
    for _ in range(n):
        name = fake.company()
        contact_info = fake.phone_number()
        address = fake.address()
        cursor.execute(
            "INSERT INTO suppliers (name, contact_info, address) VALUES (%s, %s, %s)",
            (name, contact_info, address)
        )
    connection.commit()
    cursor.close()

def insert_inventory(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT game_id FROM slop")
    game_ids = cursor.fetchall()
    cursor.execute("SELECT supplier_id FROM suppliers")
    supplier_ids = cursor.fetchall()

    for game_id in game_ids:
        quantity = random.randint(1, 100)
        reorder_threshold = random.randint(5, 20)
        location = fake.city()
        supplier_id = random.choice(supplier_ids)[0]
        cursor.execute(
            "INSERT INTO inventory (inventory_id, game_id, quantity, reorder_threshold, location, supplier_id) VALUES (%s, %s, %s, %s, %s, %s)",
            (str(uuid.uuid4()), game_id[0], quantity, reorder_threshold, location, supplier_id)
        )
    connection.commit()
    cursor.close()

def insert_orders(connection, n=50000):
    cursor = connection.cursor()
    cursor.execute("SELECT customer_id FROM customers")
    customer_ids = cursor.fetchall()
    
    for _ in range(n):
        customer_id = random.choice(customer_ids)[0]
        order_date = fake.date_between(start_date='-2y', end_date='today')
        total_amount = round(random.uniform(20, 500), 2)
        cursor.execute(
            "INSERT INTO orders (customer_id, order_date, total_amount) VALUES (%s, %s, %s)",
            (customer_id, order_date, total_amount)
        )
    connection.commit()
    cursor.close()


def insert_order_items(connection, n=500000):
    cursor = connection.cursor()
    cursor.execute("SELECT order_id FROM orders")
    order_ids = cursor.fetchall()
    cursor.execute("SELECT game_id, price FROM slop")
    slop_items = cursor.fetchall()

    for _ in range(n):
        order_id = random.choice(order_ids)[0]
        game_id, price = random.choice(slop_items)
        quantity = random.randint(1, 5)
        price_at_purchase = price * quantity
        cursor.execute(
            "INSERT INTO order_items (order_item_id, order_id, game_id, quantity, price_at_purchase) VALUES (%s, %s, %s, %s, %s)",
            (None, order_id, game_id, quantity, price_at_purchase)
        )
    connection.commit()
    cursor.close()

def insert_slop_suppliers(connection):
    cursor = connection.cursor()
    cursor.execute("SELECT game_id FROM slop")
    game_ids = cursor.fetchall()
    cursor.execute("SELECT supplier_id FROM suppliers")
    supplier_ids = cursor.fetchall()

    for game_id in game_ids:
        for _ in range(random.randint(1, 3)):
            supplier_id = random.choice(supplier_ids)[0]
            
            cursor.execute(
                "SELECT 1 FROM slop_suppliers WHERE slop_id = %s AND supplier_id = %s",
                (game_id[0], supplier_id)
            )
            if cursor.fetchone() is None:
                supply_price = round(random.uniform(5, 50), 2)
                cursor.execute(
                    "INSERT INTO slop_suppliers (slop_id, supplier_id, supply_price) VALUES (%s, %s, %s)",
                    (game_id[0], supplier_id, supply_price)
                )
    connection.commit()
    cursor.close()


def populate_database():
    connection = create_connection()
    if connection:
        print("Connection established. Populating database...")
        
        insert_customers(connection, n=1000)
        print("Inserted customers.")
        
        insert_customer_details(connection)
        print("Inserted customer details.")
        
        insert_slop(connection, n=1000)
        print("Inserted slop (products).")
        
        insert_suppliers(connection, n=100)
        print("Inserted suppliers.")
        
        insert_inventory(connection)
        print("Inserted inventory.")
        
        insert_orders(connection, n=50000)
        print("Inserted orders.")
        
        insert_order_items(connection, n=500000)
        print("Inserted order items.")
        
        insert_slop_suppliers(connection)
        print("Inserted slop-suppliers relationships.")
        
        connection.close()
        print("Data population complete and connection closed.")

populate_database()
