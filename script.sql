USE SlopShop;

CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50) PRIMARY KEY COMMENT 'Unique identifier for each customer',
    first_name VARCHAR(100) NOT NULL COMMENT 'Customer\'s first name',
    last_name VARCHAR(100) NOT NULL COMMENT 'Customer\'s last name',
    email VARCHAR(100) NOT NULL COMMENT 'Customer\'s email address',
    phone VARCHAR(30) NOT NULL COMMENT 'Customer\'s phone number'
) COMMENT = 'Stores basic information about customers';

CREATE TABLE IF NOT EXISTS customer_details (
    customer_id VARCHAR(50) UNIQUE COMMENT 'Unique identifier, linked to the customer',
    address VARCHAR(200) NOT NULL COMMENT 'Customer\'s address',
    postcode VARCHAR(20) NOT NULL COMMENT 'Postal code for the customer\'s address',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) COMMENT = 'Stores additional details for each customer, linked one-to-one with customers';

CREATE TABLE IF NOT EXISTS slop (
    game_id VARCHAR(50) PRIMARY KEY COMMENT 'Unique identifier for each game or product',
    game_title VARCHAR(200) NOT NULL COMMENT 'Title of the game or product',
    genres VARCHAR(200) NOT NULL COMMENT 'Genres associated with the game',
    developer VARCHAR(100) NOT NULL COMMENT 'Developer of the game',
    publisher VARCHAR(100) NOT NULL COMMENT 'Publisher of the game',
    price DECIMAL(10, 2) NOT NULL COMMENT 'Price of the game or product',
    is_discounted BOOLEAN NOT NULL COMMENT 'Indicates if the game has a discount'
) COMMENT = 'Stores information about products (games and apparel) sold at SlopShop';

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each supplier',
    name VARCHAR(255) NOT NULL COMMENT 'Supplier\'s name',
    contact_info VARCHAR(255) COMMENT 'Contact information for the supplier',
    address VARCHAR(255) COMMENT 'Address of the supplier'
) COMMENT = 'Stores information about suppliers providing products to SlopShop';

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id VARCHAR(50) PRIMARY KEY COMMENT 'Unique identifier for each inventory record',
    game_id VARCHAR(50) COMMENT 'Foreign key linking to the product in slop',
    quantity INT NOT NULL CHECK (quantity >= 0) COMMENT 'Current quantity of the product in stock',
    reorder_threshold INT NOT NULL CHECK (reorder_threshold >= 0) COMMENT 'Minimum quantity to trigger reorder',
    location VARCHAR(40) NOT NULL COMMENT 'Location where the inventory is stored',
    supplier_id INT COMMENT 'Foreign key linking to the supplier',
    FOREIGN KEY (game_id) REFERENCES slop(game_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) COMMENT = 'Tracks inventory levels, locations, and reorder information for products';

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each order',
    customer_id VARCHAR(50) NOT NULL COMMENT 'Foreign key linking to the customer',
    order_date DATE NOT NULL COMMENT 'Date when the order was placed',
    total_amount DECIMAL(10, 2) NOT NULL COMMENT 'Total cost of the order',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) COMMENT = 'Stores customer orders with details such as date and total amount';

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each order item',
    order_id INT COMMENT 'Foreign key linking to the order',
    game_id VARCHAR(50) COMMENT 'Foreign key linking to the game or product',
    quantity INT NOT NULL CHECK (quantity >= 0) COMMENT 'Quantity of the product in this order',
    price_at_purchase DECIMAL(10, 2) NOT NULL COMMENT 'Price per item at the time of purchase',
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (game_id) REFERENCES slop(game_id)
) COMMENT = 'Stores details of individual items within each order';

CREATE TABLE IF NOT EXISTS slop_suppliers (
    slop_id VARCHAR(50) NOT NULL COMMENT 'Foreign key linking to the product in slop',
    supplier_id INT NOT NULL COMMENT 'Foreign key linking to the supplier',
    supply_price DECIMAL(10, 2) NOT NULL COMMENT 'Price at which the supplier provides the product',
    PRIMARY KEY (slop_id, supplier_id),
    FOREIGN KEY (slop_id) REFERENCES slop(game_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) COMMENT = 'Represents the many-to-many relationship between products and suppliers, including supply price';

CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_slop_game_title ON slop(game_title);
CREATE INDEX idx_inventory_supplier_id ON inventory(supplier_id);
CREATE INDEX idx_order_items_order_game ON order_items(order_id, game_id);
CREATE INDEX idx_slop_genres ON slop(genres);