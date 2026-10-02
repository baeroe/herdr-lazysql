-- Demo schema for the README screenshots (docs/screenshots.sh). Made-up data only.
CREATE TABLE customers (
  id serial PRIMARY KEY,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  city text NOT NULL,
  created_at date NOT NULL
);
CREATE TABLE products (
  id serial PRIMARY KEY,
  sku text NOT NULL UNIQUE,
  name text NOT NULL,
  price numeric(8,2) NOT NULL,
  stock int NOT NULL
);
CREATE TABLE orders (
  id serial PRIMARY KEY,
  customer_id int NOT NULL REFERENCES customers(id),
  status text NOT NULL,
  total numeric(10,2) NOT NULL,
  ordered_at timestamp NOT NULL
);
CREATE TABLE order_items (
  order_id int NOT NULL REFERENCES orders(id),
  product_id int NOT NULL REFERENCES products(id),
  quantity int NOT NULL,
  PRIMARY KEY (order_id, product_id)
);

INSERT INTO customers (name, email, city, created_at) VALUES
  ('Ada Fischer', 'ada@example.com', 'Hamburg', '2025-11-02'),
  ('Ben Okafor', 'ben@example.com', 'Leipzig', '2025-12-14'),
  ('Clara Novak', 'clara@example.net', 'Vienna', '2026-01-08'),
  ('David Moreau', 'david@example.org', 'Lyon', '2026-02-21'),
  ('Elif Yilmaz', 'elif@example.com', 'Cologne', '2026-03-03'),
  ('Finn Larsen', 'finn@example.net', 'Aarhus', '2026-04-17'),
  ('Greta Rossi', 'greta@example.org', 'Turin', '2026-05-29'),
  ('Hugo Brandt', 'hugo@example.com', 'Munich', '2026-06-11'),
  ('Ines Costa', 'ines@example.net', 'Porto', '2026-07-23'),
  ('Jonas Weber', 'jonas@example.com', 'Berlin', '2026-08-30');

INSERT INTO products (sku, name, price, stock) VALUES
  ('MUG-01', 'Enamel mug', 14.90, 120),
  ('TEE-02', 'Organic T-shirt', 29.00, 64),
  ('CAP-03', 'Canvas cap', 22.50, 37),
  ('BAG-04', 'Tote bag', 12.00, 210),
  ('NB-05', 'Dot grid notebook', 9.80, 155),
  ('PEN-06', 'Brass pen', 39.00, 18);

INSERT INTO orders (customer_id, status, total, ordered_at) VALUES
  (1, 'shipped',   44.70, '2026-09-01 09:14'),
  (2, 'shipped',   29.00, '2026-09-03 18:40'),
  (3, 'delivered', 61.50, '2026-09-07 11:02'),
  (1, 'delivered', 12.00, '2026-09-12 20:31'),
  (4, 'cancelled', 39.00, '2026-09-15 08:55'),
  (5, 'shipped',   78.80, '2026-09-19 14:12'),
  (6, 'paid',      22.50, '2026-09-24 16:47'),
  (7, 'paid',      58.00, '2026-09-28 10:05'),
  (8, 'pending',   24.70, '2026-10-01 21:19'),
  (9, 'pending',   48.80, '2026-10-02 07:33'),
  (10, 'pending',  14.90, '2026-10-02 19:58');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
  (1, 1, 3), (2, 2, 1), (3, 3, 1), (3, 6, 1), (4, 4, 1), (5, 6, 1), (6, 6, 2),
  (7, 3, 1), (8, 2, 2), (9, 1, 1), (9, 5, 1), (10, 5, 5), (11, 1, 1);
