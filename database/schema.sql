-- Create the Cinemas table
CREATE TABLE Cinemas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL
);

-- Create the Movies table
CREATE TABLE Movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INT
);

-- Create the Screens table
CREATE TABLE Screens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cinema_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    `rows` INT NOT NULL,
    `columns` INT NOT NULL,
    FOREIGN KEY (cinema_id) REFERENCES Cinemas(id)
);

-- Create the Shows table
CREATE TABLE Shows (
    id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    screen_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES Movies(id),
    FOREIGN KEY (screen_id) REFERENCES Screens(id)
);

-- Create the Users table
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);

-- Create the Bookings table
CREATE TABLE Bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    show_id INT NOT NULL,
    status ENUM('booked', 'cancelled') DEFAULT 'booked',
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (show_id) REFERENCES Shows(id)
);

-- Create the BookedSeats table
CREATE TABLE BookedSeats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    show_id INT NOT NULL,
    seat_label VARCHAR(10) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES Bookings(id),
    FOREIGN KEY (show_id) REFERENCES Shows(id),
    UNIQUE (show_id, seat_label)
);
