-- Initialize database for Spring Boot K8s Demo
USE userdb;

-- Create users table (will be created by JPA, but this ensures it exists)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (name, email, phone, address) VALUES
('John Doe', 'john.doe@example.com', '+1234567890', '123 Main St, New York, NY'),
('Jane Smith', 'jane.smith@example.com', '+1987654321', '456 Oak Ave, Los Angeles, CA'),
('Bob Johnson', 'bob.johnson@example.com', '+1122334455', '789 Pine Rd, Chicago, IL'),
('Alice Brown', 'alice.brown@example.com', '+1555666777', '321 Elm St, Houston, TX'),
('Charlie Wilson', 'charlie.wilson@example.com', '+1888999000', '654 Maple Dr, Phoenix, AZ');

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_name ON users(name);
CREATE INDEX idx_users_phone ON users(phone);
