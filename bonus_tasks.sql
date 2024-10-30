use SlopShop;

SELECT User, Host FROM mysql.user WHERE User IN ('customer_user', 'inventory_manager', 'sales_manager');

CREATE USER 'customer_user'@'localhost' IDENTIFIED BY 'customer_pass';
CREATE USER 'inventory_manager'@'localhost' IDENTIFIED BY 'inventory_pass';
CREATE USER 'sales_manager'@'localhost' IDENTIFIED BY 'sales_pass';

GRANT SELECT ON SlopShop.* TO 'customer_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON SlopShop.inventory TO 'inventory_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON SlopShop.orders TO 'sales_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON SlopShop.order_items TO 'sales_manager'@'localhost';

FLUSH PRIVILEGES;



CREATE VIEW order_summary AS
SELECT 
    o.order_id, 
    c.first_name, 
    c.last_name, 
    o.order_date, 
    o.total_amount
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id;
    
   
CREATE PROCEDURE AddNewOrder(
    IN customerId VARCHAR(50),
    IN orderDate DATE,
    IN totalAmount DECIMAL(10, 2),
    IN gameIds JSON,
    IN quantities JSON,
    IN pricesAtPurchase JSON
)
BEGIN
    DECLARE lastOrderId INT;

    INSERT INTO orders (customer_id, order_date, total_amount)
    VALUES (customerId, orderDate, totalAmount);

    SET lastOrderId = LAST_INSERT_ID();

    SET @i = 0;
    WHILE @i < JSON_LENGTH(gameIds) DO
        INSERT INTO order_items (order_id, game_id, quantity, price_at_purchase)
        VALUES (
            lastOrderId,
            JSON_UNQUOTE(JSON_EXTRACT(gameIds, CONCAT('$[', @i, ']'))),
            JSON_UNQUOTE(JSON_EXTRACT(quantities, CONCAT('$[', @i, ']'))),
            JSON_UNQUOTE(JSON_EXTRACT(pricesAtPurchase, CONCAT('$[', @i, ']')))
        );
        SET @i = @i + 1;
    END WHILE;
END

DELIMITER;


CREATE TRIGGER UpdateInventoryAfterOrderItem
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET quantity = quantity - NEW.quantity
    WHERE game_id = NEW.game_id;
END

DELIMITER;

