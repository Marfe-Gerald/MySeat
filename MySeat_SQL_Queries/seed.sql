DROP DATABASE IF EXISTS MySeat_DB;
CREATE DATABASE MySeat_DB;
USE MySeat_DB;

CREATE TABLE tblGenre (
    genreID   INT         PRIMARY KEY AUTO_INCREMENT,
    genreName VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE tblMovie (
    movieID    INT          PRIMARY KEY AUTO_INCREMENT,
    title      VARCHAR(100) NOT NULL,
    duration   VARCHAR(20),
    rating     VARCHAR(10)
);

CREATE TABLE tblMovieGenre (
    movieGenreID INT PRIMARY KEY AUTO_INCREMENT,
    movieID      INT NOT NULL,
    genreID      INT NOT NULL,
    CONSTRAINT UC_MovieGenre UNIQUE (movieID, genreID),
    FOREIGN KEY (movieID) REFERENCES tblMovie(movieID) ON DELETE CASCADE,
    FOREIGN KEY (genreID) REFERENCES tblGenre(genreID) ON DELETE CASCADE
);

CREATE TABLE tblCinema (
    cinemaID   INT         PRIMARY KEY AUTO_INCREMENT,
    cinemaName VARCHAR(50) NOT NULL
);

CREATE TABLE tblSeat (
    seatID     INT         PRIMARY KEY AUTO_INCREMENT,
    cinemaID   INT         NOT NULL,
    seatRow    VARCHAR(2)  NOT NULL,
    seatNumber INT         NOT NULL,
    zoneName   VARCHAR(20) NOT NULL,
    FOREIGN KEY (cinemaID) REFERENCES tblCinema(cinemaID) ON DELETE CASCADE
);

CREATE TABLE tblShowtime (
    showtimeID INT      PRIMARY KEY AUTO_INCREMENT,
    movieID    INT      NOT NULL,
    cinemaID   INT      NOT NULL,
    showDate   DATE     NOT NULL,
    startTime  TIME     NOT NULL,
    FOREIGN KEY (movieID)  REFERENCES tblMovie(movieID),
    FOREIGN KEY (cinemaID) REFERENCES tblCinema(cinemaID)
);

CREATE TABLE tblCustomer (
    customerID INT         PRIMARY KEY AUTO_INCREMENT,
    lastName   VARCHAR(50) NOT NULL,
    firstName  VARCHAR(50) NOT NULL,
    middleName VARCHAR(50)
);

CREATE TABLE tblAdmin (
    adminID      INT          PRIMARY KEY AUTO_INCREMENT,
    lastName     VARCHAR(50)  NOT NULL,
    firstName    VARCHAR(50)  NOT NULL,
    middleName   VARCHAR(50),
    username     VARCHAR(50)  NOT NULL UNIQUE,
    passwordHash VARCHAR(255) NOT NULL,
    isActive     TINYINT(1)   DEFAULT 1
);

CREATE TABLE tblBooking (
    bookingID        INT       PRIMARY KEY AUTO_INCREMENT,
    customerID       INT       NOT NULL,
    showtimeID       INT       NOT NULL,
    bookingTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bookingStatus    ENUM(
                       'Confirmed',
                       'Cancelled',
                       'Pending'
                     )         NOT NULL DEFAULT 'Confirmed',
    FOREIGN KEY (customerID) REFERENCES tblCustomer(customerID) ON DELETE CASCADE,
    FOREIGN KEY (showtimeID) REFERENCES tblShowtime(showtimeID)
);

CREATE TABLE tblTicket (
    ticketID     INT         PRIMARY KEY AUTO_INCREMENT,
    bookingID    INT         NOT NULL,
    seatID       INT         NOT NULL,
    ticketCode   VARCHAR(20) NOT NULL UNIQUE,
    ticketStatus ENUM(
                   'Active',
                   'Used',
                   'Cancelled'
                 )           NOT NULL DEFAULT 'Active',
    CONSTRAINT UC_SeatPerBooking UNIQUE (seatID, bookingID),
    FOREIGN KEY (bookingID) REFERENCES tblBooking(bookingID) ON DELETE CASCADE,
    FOREIGN KEY (seatID)    REFERENCES tblSeat(seatID)
);

CREATE TABLE tblAdminLog (
    logID           INT          PRIMARY KEY AUTO_INCREMENT,
    adminID         INT          NOT NULL,
    actionType      ENUM(
                      'Login',
                      'Logout',
                      'MovieAdded',
                      'MovieEdited',
                      'MovieDeleted',
                      'GenreAdded',
                      'GenreEdited',
                      'GenreDeleted',
                      'ShowtimeAdded',
                      'ShowtimeEdited',
                      'ShowtimeDeleted',
                      'SeatAdded',
                      'SeatEdited',
                      'SeatDeleted'
                    )            NOT NULL,
    targetTable     VARCHAR(50),
    targetID        INT,
    actionTimestamp TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    remarks         VARCHAR(255),
    FOREIGN KEY (adminID) REFERENCES tblAdmin(adminID)
);
