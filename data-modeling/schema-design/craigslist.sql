--Schema Diagram for Craigslist--
--regions(region_id PK, name)--
--users(user_id PK, username, email, preferred_region FK)--
--post(post_id PK, title, content, user_id FK, location, region_id FK, created_at, updated_at)--
--categories(category_id PK, name)--
--post_categories(post_id FK, category_id FK)--

CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150),
    preferred_region INTEGER REFERENCES regions(region_id)
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    user_id INTEGER REFERENCES users(user_id),
    location VARCHAR(200),
    region_id INTEGER REFERENCES regions(region_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_categories (
    post_id INTEGER REFERENCES posts(post_id),
    category_id INTEGER REFERENCES categories(category_id),
    PRIMARY KEY (post_id, category_id)
);