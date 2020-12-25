CREATE TABLE categories (
		category_id serial PRIMARY KEY,
		category_name varchar(40) NOT NULL
);

CREATE TABLE suppliers (
		supplier_id serial PRIMARY KEY,
		company_name varchar(60) NOT NULL,
		contact_name varchar(30) NOT NULL,
		phone varchar(24) NOT NULL,
		email varchar(255) NOT NULL,
		address varchar(60) NOT NULL,
		website_url varchar(100),
		is_building_contractor boolean DEFAULT FALSE
);

CREATE TABLE products (
		product_id serial PRIMARY KEY,
		category_id int REFERENCES categories (category_id),
		supplier_id int REFERENCES suppliers  (supplier_id),
		product_name varchar(40) NOT NULL,
		sku varchar(20) UNIQUE NOT NULL,
		description text,
		unit_price numeric(15, 6) NOT NULL,
		discount real DEFAULT 0,
		units_in_stock int DEFAULT 0,
		rating real DEFAULT 0,
		pictures_directory varchar(255)
);

CREATE TABLE properties (
		property_id serial PRIMARY KEY,
		property_name varchar(40) NOT NULL
);

CREATE TABLE category_properties (
		category_id int REFERENCES categories (category_id),
		property_id int REFERENCES properties (property_id)
);

CREATE TABLE product_properties (
		product_id int REFERENCES products (product_id),
		property_id int REFERENCES properties (property_id),
		property_value varchar(40) 
);

CREATE TABLE customers (
		customer_id serial PRIMARY KEY,
		first_name varchar(60) NOT NULL,
		last_name varchar(60) NOT NULL,
		phone varchar(24)
);

CREATE TABLE users (
		user_id serial PRIMARY KEY,
		customer_id int REFERENCES customers (customer_id),
		email varchar(255) NOT NULL,
		password varchar(128) NOT NULL,
		birth_date date,
		entered_date date, -- TO DO: add trigger for default now()
		is_admin boolean DEFAULT FALSE
);

CREATE TABLE payments (
		payment_id serial PRIMARY KEY,
		by_cash boolean DEFAULT FALSE,
		credit_card varchar(20),
		is_paid boolean DEFAULT FALSE,
		paid_at timestamp
);

CREATE TABLE orders (
		order_id serial PRIMARY KEY,
		customer_id int REFERENCES customers (customer_id),
		payment_id int REFERENCES payments (payment_id),
		created_at timestamp
);

CREATE TABLE order_details (
		order_id int REFERENCES orders (order_id),
		product_id int REFERENCES products (product_id),
		quantity int NOT NULL,
		discount real DEFAULT 0
);

-- help functions
CREATE OR REPLACE PROCEDURE create_user(
    _email varchar(255),
    _phone varchar(24),
    _first_name varchar(60),
    _last_name varchar(60),
    _password varchar(255)
)
LANGUAGE plpgsql
AS $$
DECLARE _customer_id int;
    BEGIN 
        INSERT INTO customers (first_name, last_name, phone)
        VALUES (_first_name, _last_name, _phone)
        RETURNING customer_id INTO _customer_id;

        INSERT INTO users (customer_id, email, password)
        VAlUES (_customer_id, _email, _password);
    END;
$$;

CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (
    user_id int,
    first_name varchar(60),
    last_name varchar(60),
    email varchar(255),
    phone varchar(24),
    birth_date date,
    entered_date date,
    is_admin boolean
) AS $$
    SELECT user_id,
           first_name,
           last_name,
           email,
           phone,
           birth_date,
           entered_date,
           is_admin
    FROM users
      LEFT JOIN customers USING (customer_id);
$$ LANGUAGE SQL;

-- triggers
CREATE OR REPLACE FUNCTION set_entered_date()
RETURNS trigger AS $$
BEGIN
    NEW.entered_date := current_date;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_set_entered_date BEFORE INSERT
    ON users FOR EACH ROW EXECUTE PROCEDURE set_entered_date();

-- add admins
INSERT INTO users (email, password, is_admin)
VALUES ('admin@admin.admin', 'admin', TRUE),
       ('admin1@admin.admin', 'admin1', TRUE),
       ('admin2@admin.admin', 'admin2', TRUE);

-- add common users
CALL create_user('petropetrov@gmail.com', '+380000000000', 'Петро', 'Петров', 'petro123');
CALL create_user('vasilkravchina@gmail.com', '+380000000001', 'Василь', 'Кравчина', 'vasil123');
CALL create_user('ivangaydamaka@gmail.com', '+380000000002', 'Іван', 'Гайдамака', 'ivan123');
CALL create_user('dmytropolischuk@gmail.com', '+380000000003', 'Дмитро', 'Поліщук', 'dmytro123');
CALL create_user('denysshevchenko@gmail.com', '+380000000004', 'Денис', 'Шевченко', 'denys123');
CALL create_user('victorfranko@gmail.com', '+380000000005', 'Віктор', 'Франко', 'victor123');
CALL create_user('yevhentolochko@gmail.com', '+380000000006', 'Євген', 'Толочко', 'yevhen123');
CALL create_user('danylobezruchko@gmail.com', '+380000000007', 'Данило', 'Безручко', 'danylo123');
CALL create_user('anastasiabohdanets@gmail.com', '+380000000008', 'Анастасія', 'Богданець', 'anastasia123');
CALL create_user('yuliakushnir@gmail.com', '+380000000009', 'Юлія', 'Кушнір', 'yulia123');
CALL create_user('olenafedorovych@gmail.com', '+3800000000010', 'Олена', 'Федорович', 'olena123');
CALL create_user('darialeskovets@gmail.com', '+3800000000011', 'Дарія', 'Лесковець', 'petro123');
CALL create_user('angelinapakhniuk@gmail.com', '+3800000000012', 'Ангеліна', 'Пахнюк', 'angelina123');

-- Fill tables
INSERT INTO categories (category_name)
	VALUES ('A'), ('B'), ('C')
;

INSERT INTO suppliers (
	company_name, contact_name, phone,
	email, address, website_url, is_building_contractor
)
VALUES ('A', 'A', 'A', 'A', 'A', 'A', FALSE),
	   ('A', 'A', 'A', 'A', 'A', 'A', FALSE),
	   ('A', 'A', 'A', 'A', 'A', 'A', FALSE)
;

INSERT INTO products (
	category_id, supplier_id, product_name, sku,
	description, unit_price, discount,
	units_in_stock, rating, pictures_directory
)
VALUES (1, 1, 'A', 'A', '...', 100, 0, 0, 1, 'a'),
	   (1, 1, 'A', 'B', '...', 100, 0, 0, 1, 'a'),
	   (1, 1, 'A', 'C', '...', 100, 0, 0, 1, 'a')
;





--INSERT INTO categories (category_name)
--VALUES ('Гіпсокартон'),
--      ('Профіль для гіпсокартона'),
--      ('Будівельні суміші'),
--       ('Клеєві суміші'),
--       ('Утеплювач'),
--       ('Пиломатеріали'),
--       ('Будівельна хімія'),
--       ('Кладочні матеріали'),
--       ('Покрівельні матеріали'),
--       ('Лакофарбові матеріали'),
--       ('Фасадні матеріали'),
--       ('Кріплення'),
--       ('Металічні сітки'),
--       ('Двір і город'),
--       ('Електрика'),
--       ('Отоплення і водопровід'),
--       ('Вікна і двері'),
--       ('Лінолеум'),
--       ('Каналізація')
--;


