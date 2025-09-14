# 🎬 Movie Screening System

Welcome to the **Movie Screening System**, a full-stack application for browsing movies, selecting seats in real-time, and booking tickets.

This project demonstrates a **multi-user, responsive system** with a **Flutter frontend** and a **Node.js backend** using **MySQL** for persistent data and **WebSockets** for real-time seat management.

---

## 🚀 Key Features

-   **Real-Time Seat Selection**: Users can view and select seats in real-time. When a user selects a seat, it is temporarily "blocked" for all other users to prevent double-booking.
-   **User and Cinema Management**: A backend API handles user details, cinema locations, and movie information.
-   **Booking History**: Users can view a history of their past bookings.
-   **Responsive UI**: The Flutter frontend provides a modern and responsive user interface that works seamlessly on different devices.

---

## 🛠️ Technologies Used

-   **Frontend**: Flutter (Dart)
-   **Backend**: Node.js, Express.js
-   **Database**: MySQL
-   **Real-time Communication**: WebSockets (`ws` library)

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

-   [Flutter SDK](https://flutter.dev/docs/get-started/install)
-   [Node.js & npm](https://nodejs.org/)
-   [MySQL](https://dev.mysql.com/downloads/)

---

## ⚙️ Project Setup

Follow these steps to set up the project locally.

### 1️⃣ Database Setup

1.  Start your MySQL server.
2.  Open your MySQL client (e.g., MySQL Command Line Client or MySQL Workbench).
3.  Create the database:
    ```sql
    CREATE DATABASE movie_booking;
    USE movie_booking;
    ```
4.  Run the SQL commands from the `schema.sql` file to create your tables.
5.  Run the SQL commands from the `initial_data.sql` file to populate the tables with initial data.

### 2️⃣ Backend Configuration and Startup

1.  Navigate to the `backend` directory:
    ```bash
    cd backend
    ```
2.  Create a `.env` file and add your database credentials:
    ```bash
    DB_HOST=localhost
    DB_USER=root
    DB_PASSWORD=your_mysql_password
    DB_DATABASE=movie_booking
    PORT=3000
    ```
3.  Install dependencies:
    ```bash
    npm install
    ```
4.  Start the backend server:
    ```bash
    node server.js
    ```

### 3️⃣ Frontend Startup

1.  Open a new terminal in the project's root directory.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the Flutter app:
    ```bash
    flutter run -d chrome
    ```

---

## 🧪 How to Test Real-Time Functionality

To test the real-time seat blocking, you'll need to simulate two users.

1.  Open the app in a regular browser window.
2.  Open the same URL in a separate Incognito or Private browser window.
3.  On the first window, select a seat. On the second window, you will see the same seat become "blocked," demonstrating the real-time synchronization.
