CREATE DATABASE IF NOT EXISTS aquaping;
USE aquaping;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(200),
  address TEXT,
  contact_number VARCHAR(50),
  profile_pic VARCHAR(255),
  fcm_token TEXT,
  sms_opt_in BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE devices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  device_id VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(200),
  region VARCHAR(100),
  last_seen TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE readings (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  device_id VARCHAR(100),
  water_level INT,
  severity ENUM('yellow','orange','red'),
  latitude DECIMAL(9,6) NULL,
  longitude DECIMAL(9,6) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_device_created (device_id, created_at),
  FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE SET NULL
);

CREATE TABLE notifications (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  device_id VARCHAR(100),
  type ENUM('push','sms'),
  severity ENUM('yellow','orange','red'),
  message TEXT,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
