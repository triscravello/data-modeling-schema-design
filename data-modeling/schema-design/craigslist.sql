--Schema Diagram for Craigslist--
--regions(region_id PK, name)--
--users(user_id PK, username, email, preferred_region FK)--
--post(post_id PK, title, content, user_id FK, location, region_id FK, created_at, updated_at, status)--
--categories(category_id PK, name)--
--post_categories(post_id FK, category_id FK)--
-- If post schema grows, separate authentication (passwords, login methods) into a user_auth table to keep PII and credentials modular --
--user_auth(user_id PK FK, auth_method, password)--

DROP DATABASE IF EXISTS craigslist;
CREATE DATABASE craigslist;
\c craigslist;

CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) UNIQUE,
    preferred_region INTEGER REFERENCES regions(region_id)
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL UNIQUE,
    content TEXT,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    location VARCHAR(200),
    region_id INTEGER REFERENCES regions(region_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'deleted'))
);

CREATE TABLE post_categories (
    post_id INTEGER REFERENCES posts(post_id),
    category_id INTEGER REFERENCES categories(category_id),
    PRIMARY KEY (post_id, category_id)
);

CREATE TABLE user_auth (
    auth_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    auth_method VARCHAR(50) NOT NULL CHECK (auth_method IN ('password', 'oauth', 'sso')),
    password VARCHAR(255) 
); -- Assuming password is nullable for non-password auth methods --

-- Indexes for performance optimization --
CREATE INDEX idx_users_region ON users(preferred_region);
CREATE INDEX idx_posts_user ON posts(user_id);
CREATE INDEX idx_posts_region ON posts(region_id);
CREATE INDEX idx_post_categories_post ON post_categories(post_id);
CREATE INDEX idx_post_categories_category ON post_categories(category_id);
CREATE INDEX idx_posts_created_at ON posts(created_at); -- For sorting by creation date --
CREATE INDEX idx_posts_updated_at ON posts(updated_at); -- For sorting by update date --
CREATE INDEX idx_posts_title ON posts(title); -- For searching by title --
CREATE INDEX idx_posts_location ON posts(location); -- For searching by location --
CREATE INDEX idx_users_username ON users(username); -- For searching by username --
CREATE INDEX idx_users_email ON users(email); -- For searching by email --
CREATE INDEX idx_regions_name ON regions(name); -- For searching by region name --
CREATE INDEX idx_categories_name ON categories(name); -- For searching by category name --

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; -- Trigger function to update updated_at column --

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; -- Trigger function to update updated_at column --
CREATE TRIGGER update_post_timestamp
BEFORE UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION update_timestamp(); -- Trigger to call the function before updating a post --

-- Sample Data Insertion --
INSERT INTO regions (name) VALUES
('New York'), ('Los Angeles'), ('Chicago'), ('Houston'), ('Phoenix');

INSERT INTO categories (name) VALUES
('For Sale'), ('Jobs'), ('Housing'), ('Services'), ('Community');

INSERT INTO users (username, email, preferred_region) VALUES
('john_doe', 'johndoe@gmail.com', 1),
('jane_smith', 'janesmith@msn.net', 2),
('alice_jones', 'jonesalice@comcast.com', 3),
('charlie_brown', 'browncharlie@aol.net', 4),
('eve_white', 'eveandadamwhite@gmail.com', 5);

INSERT INTO posts (title, content, user_id, location, region_id, status) VALUES
('Selling my bike', 'A barely used mountain bike for sale.', 1, 'Brooklyn, NY', 1, 'active'),
('Looking for a job', 'Experienced software developer seeking new opportunities.', 2, 'Los Angeles, CA', 2, 'active'),
('Apartment for rent', '2-bedroom apartment available in downtown Chicago.', 3, 'Chicago, IL', 3, 'active'),
('Dog walking services', 'Reliable dog walker available in Houston area.', 4, 'Houston, TX', 4, 'active'),
('Community event this weekend', 'Join us for a neighborhood cleanup event.', 5, 'Phoenix, AZ', 5, 'active');

INSERT INTO post_categories (post_id, category_id) VALUES
(1, 1), -- Selling my bike -> For Sale --
(2, 2), -- Looking for a job -> Jobs --
(3, 3), -- Apartment for rent -> Housing --
(4, 4), -- Dog walking services -> Services --
(5, 5); -- Community event this weekend -> Community --

INSERT INTO user_auth (user_id, auth_method, password) VALUES
(1, 'password', 'hashed_password_1'),
(2, 'oauth', NULL),
(3, 'password', 'hashed_password_3'),
(4, 'sso', NULL),
(5, 'password', 'hashed_password_5');
);
