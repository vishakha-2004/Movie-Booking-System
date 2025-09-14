const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const cors = require('cors');
const WebSocket = require('ws'); 
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;
const wssPort = 8080; 

app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
});

db.connect(err => {
    if (err) {
        throw err;
    }
    console.log('MySQL connected...');
});


const wss = new WebSocket.Server({ port: wssPort });
const _blockedSeats = {}; 

wss.on('connection', ws => {
    console.log('Client connected to WebSocket.');

    ws.on('message', message => {
        try {
            const data = JSON.parse(message);
            console.log('Received message:', data);
            if (data.action === 'block') {
                const { showId, seat, userId } = data;
                // Block the seat if it's not already booked or blocked by someone else
                if (!_blockedSeats[showId] || !_blockedSeats[showId][seat]) {
                    if (!_blockedSeats[showId]) {
                        _blockedSeats[showId] = {};
                    }
                    _blockedSeats[showId][seat] = userId;
                    const broadcastMessage = JSON.stringify({
                        showId: showId,
                        seat: seat,
                        userId: userId,
                        status: 'blocked'
                    });
                    wss.clients.forEach(client => {
                        if (client.readyState === WebSocket.OPEN) {
                            client.send(broadcastMessage);
                        }
                    });
                }
            } else if (data.action === 'unblock') {
                const { showId, seat, userId } = data;
                if (_blockedSeats[showId] && _blockedSeats[showId][seat] === userId) {
                    delete _blockedSeats[showId][seat];
                    // Broadcast the unblocked status to all clients
                    const broadcastMessage = JSON.stringify({
                        showId: showId,
                        seat: seat,
                        userId: null,
                        status: 'available'
                    });
                    wss.clients.forEach(client => {
                        if (client.readyState === WebSocket.OPEN) {
                            client.send(broadcastMessage);
                        }
                    });
                }
            }
        } catch (e) {
            console.error('Failed to parse WebSocket message:', e);
        }
    });
});

// GET all cinemas
app.get('/cinemas', (req, res) => {
    const query = 'SELECT id, name, address FROM Cinemas';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching cinemas:', err);
            res.status(500).send('Error fetching cinemas');
        } else {
            res.status(200).json(results);
        }
    });
});

// GET all movies for a specific cinema
app.get('/cinemas/:cinema_id/movies', (req, res) => {
    const cinemaId = req.params.cinema_id;
    const query = `
        SELECT DISTINCT m.id, m.title, m.description, m.release_year
        FROM Movies m
        JOIN Shows s ON m.id = s.movie_id
        JOIN Screens sc ON s.screen_id = sc.id
        WHERE sc.cinema_id = ?;
    `;
    db.query(query, [cinemaId], (err, results) => {
        if (err) {
            console.error('Error fetching movies for cinema:', err);
            res.status(500).send('Error fetching movies');
        } else {
            res.status(200).json(results);
        }
    });
});

// GET all shows for a specific movie in a cinema
app.get('/cinemas/:cinema_id/movies/:movie_id/shows', (req, res) => {
    const { cinema_id, movie_id } = req.params;
    const query = `
        SELECT s.id, s.start_time, sc.name AS screen_name
        FROM Shows s
        JOIN Screens sc ON s.screen_id = sc.id
        WHERE sc.cinema_id = ? AND s.movie_id = ?;
    `;
    db.query(query, [cinema_id, movie_id], (err, results) => {
        if (err) {
            console.error('Error fetching shows:', err);
            res.status(500).send('Error fetching shows');
        } else {
            res.status(200).json(results);
        }
    });
});

// GET all seats for a specific show
app.get('/shows/:show_id/seats', (req, res) => {
    const showId = req.params.show_id;
    const query = 'SELECT seat_label FROM BookedSeats WHERE show_id = ?';
    db.query(query, [showId], (err, results) => {
        if (err) {
            console.error('Error fetching booked seats:', err);
            res.status(500).send('Error fetching seats');
        } else {
            const bookedSeats = results.map(row => row.seat_label);
            res.status(200).json({ booked_seats: bookedSeats });
        }
    });
});

// POST a new booking with a transaction
app.post('/bookings', (req, res) => {
    const { userId, showId, seats } = req.body;
    if (!userId || !showId || !seats || !Array.isArray(seats) || seats.length === 0) {
        return res.status(400).send('Missing or invalid booking data.');
    }

    db.beginTransaction(err => {
        if (err) {
            console.error('Error starting transaction:', err);
            return res.status(500).send('Error creating booking');
        }

        const bookingQuery = 'INSERT INTO Bookings (user_id, show_id) VALUES (?, ?)';
        db.query(bookingQuery, [userId, showId], (err, bookingResult) => {
            if (err) {
                return db.rollback(() => {
                    console.error('Error inserting booking:', err);
                    res.status(500).send('Error creating booking');
                });
            }
            const bookingId = bookingResult.insertId;
            const bookedSeatsValues = seats.map(seat => [bookingId, showId, seat]);

            const bookedSeatsQuery = 'INSERT INTO BookedSeats (booking_id, show_id, seat_label) VALUES ?';
            db.query(bookedSeatsQuery, [bookedSeatsValues], (err) => {
                if (err) {
                    return db.rollback(() => {
                        console.error('Error inserting booked seats:', err);
                        res.status(500).send('Error creating booking');
                    });
                }

                db.commit(err => {
                    if (err) {
                        return db.rollback(() => {
                            console.error('Error committing transaction:', err);
                            res.status(500).send('Error creating booking');
                        });
                    }
                    res.status(201).json({ message: 'Booking successful', booking_id: bookingId });
                });
            });
        });
    });
});

// GET all users
app.get('/users', (req, res) => {
    db.query('SELECT id, username FROM Users', (err, results) => {
        if (err) {
            console.error('Error fetching users:', err);
            res.status(500).send('Error fetching users');
        } else {
            res.status(200).json(results);
        }
    });
});

// GET a specific user's details
app.get('/users/:user_id', (req, res) => {
    const userId = req.params.user_id;
    db.query('SELECT id, username FROM Users WHERE id = ?', [userId], (err, results) => {
        if (err) {
            console.error('Error fetching user:', err);
            res.status(500).send('Error fetching user');
        } else if (results.length > 0) {
            res.status(200).json(results[0]);
        } else {
            res.status(404).send('User not found');
        }
    });
});

// GET a specific user's booking history, including the status
app.get('/users/:user_id/bookings', (req, res) => {
    const userId = req.params.user_id;
    const query = `
        SELECT
            b.id AS booking_id,
            GROUP_CONCAT(bs.seat_label SEPARATOR ', ') AS seats,
            b.status,
            m.title AS movie_title,
            c.name AS cinema_name,
            s.start_time
        FROM Bookings b
        JOIN Shows s ON b.show_id = s.id
        JOIN Movies m ON s.movie_id = m.id
        JOIN Screens sc ON s.screen_id = sc.id
        JOIN Cinemas c ON sc.cinema_id = c.id
        JOIN BookedSeats bs ON bs.booking_id = b.id
        WHERE b.user_id = ?
        GROUP BY b.id
        ORDER BY s.start_time DESC;
    `;
    db.query(query, [userId], (err, results) => {
        if (err) {
            console.error('Error fetching booking history:', err);
            res.status(500).send('Error fetching booking history');
        } else {
            res.status(200).json(results);
        }
    });
});

// PUT route to update booking status to 'cancelled'
app.put('/bookings/:booking_id/cancel', (req, res) => {
    const bookingId = req.params.booking_id;
    console.log(`[BACKEND] Received cancellation request for booking ID: ${bookingId}`);
    const updateBookingQuery = 'UPDATE Bookings SET status = ? WHERE id = ?';
    db.query(updateBookingQuery, ['cancelled', bookingId], (err, result) => {
        if (err) {
            console.error('Error updating booking status:', err);
            return res.status(500).send('Error cancelling booking');
        }
        if (result.affectedRows === 0) {
            console.warn(`[BACKEND] No booking found with ID: ${bookingId}`);
            return res.status(404).send('Booking not found');
        }
        console.log(`[BACKEND] Booking status updated to cancelled. Affected rows: ${result.affectedRows}`);
        
        const deleteSeatsQuery = 'DELETE FROM BookedSeats WHERE booking_id = ?';
        db.query(deleteSeatsQuery, [bookingId], (err, deleteResult) => {
            if (err) {
                console.error('Error deleting booked seats:', err);
                return res.status(500).send('Error cancelling booking');
            }
            
            console.log(`[BACKEND] Deleted ${deleteResult.affectedRows} seat(s) for booking ID: ${bookingId}`);
            res.status(200).json({ message: 'Booking cancelled and seats freed successfully' });
        });
    });
});

app.listen(port, () => {
    console.log(`Express server running on http://localhost:${port}`);
    console.log(`WebSocket server running on ws://localhost:${wssPort}`);
});
