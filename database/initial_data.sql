-- Insert sample data into Cinemas table
INSERT INTO Cinemas (id, name, address) VALUES
(1, 'PVR Cinemas', '123 Main Street'),
(2, 'Cinepolis', '456 Oak Avenue'),
(3, 'INOX Forum', '29, 3rd Block, Koramangala, Bangalore'),
(4, 'Cinepolis Seasons Mall', 'Hadapsar, Pune, Maharashtra');

-- Insert sample data into Movies table
INSERT INTO Movies (id, title, description, release_year) VALUES
(1, 'Inception', 'A thief who steals corporate secrets through dream-sharing technology.', 2010),
(2, 'The Matrix', 'A computer hacker learns about the true nature of his reality.', 1999),
(3, 'Interstellar', 'A team of explorers travel through a wormhole in space to ensure humanity''s survival.', 2014),
(4, 'Inception', 'A thief who steals .', 2010),
(5, 'Oppenheimer', 'The story of J. Robert Oppenheimer, the "father of the atomic bomb."', 2023),
(6, 'Avatar: The Way of Water', 'Jake Sully and Neytiri have a new family and are trying to stay together.', 2022),
(7, 'Dune', 'A gifted young man must travel to the most dangerous planet in the universe.', 2021),
(8, 'Dune: Part Two', 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators.', 2024),
(9, 'Godzilla x Kong: The New Empire', 'The two ancient titans fight a colossal, undiscovered threat.', 2024),
(10, 'Oppenheimer', 'The story of J. Robert Oppenheimer, the "father of the atomic bomb."', 2023),
(11, 'Avatar: The Way of Water', 'Jake Sully and Neytiri have a new family and are trying to stay together.', 2022);

-- Insert sample data into Screens table
INSERT INTO Screens (id, cinema_id, name, `rows`, `columns`) VALUES
(1, 1, 'Screen 1', 10, 10),
(2, 1, 'Screen 2', 12, 15),
(3, 2, 'Screen 1', 8, 12),
(4, 1, 'Screen 3', 10, 15),
(5, 2, 'Screen 2', 12, 10),
(6, 3, 'IMAX Screen', 10, 15),
(7, 4, 'Main Screen', 12, 12);

-- Insert sample data into Shows table
INSERT INTO Shows (id, movie_id, screen_id, start_time) VALUES
(1, 1, 1, '2025-09-14 15:00:00'),
(2, 2, 1, '2025-09-14 18:00:00'),
(3, 3, 2, '2025-09-14 21:00:00'),
(4, 2, 3, '2025-09-14 16:30:00'),
(5, 3, 3, '2025-09-14 19:30:00'),
(6, 4, 3, '2025-09-14 13:00:00'),
(7, 5, 3, '2025-09-14 18:00:00'),
(8, 6, 4, '2025-09-14 15:30:00'),
(9, 4, 4, '2025-09-14 20:30:00'),
(19, 8, 6, '2025-09-14 17:30:00'),
(20, 8, 7, '2025-09-14 20:00:00'),
(21, 9, 6, '2025-09-14 22:00:00');

-- Insert sample users
INSERT INTO Users (id, username, password, email) VALUES
(1, 'alice', 'pass123', 'alice@example.com'),
(2, 'bob', 'pass456', 'bob@example.com');
