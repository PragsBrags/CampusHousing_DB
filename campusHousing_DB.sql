-- Create 1NF Table
CREATE TABLE campusHousing (
    BuildingID int,
    BuildingName varchar(50),
    RoomNo int,
    StudentID int,
    StudentName varchar(60),
    Phone int,
    StartDate date,
    EndDate date,
    RentalCost int,
    RoomateID int
);

-- Insert data into 1NF table
INSERT INTO campusHousing (
    BuildingID,
    BuildingName,
    RoomNo,
    StudentID,
    StudentName,
    Phone,
    StartDate,
    EndDate,
    RentalCost,
    RoomateID
)
VALUES
    (001, 'Alpha', 101, 234, 'Clara Kent', 252452, '2024-12-01', '2024-12-30', 500, 237),
    (002, 'Delta', 103, 235, 'Lin Lei', 34144, '2024-12-01', '2024-12-30', 550, 238);

-- Create 2NF Tables
CREATE TABLE Building (
    BuildingID int,
    BuildingName varchar(50),
    PRIMARY KEY (BuildingID)
);

CREATE TABLE Student (
    StudentID int,
    StudentName varchar(60),
    Phone int,
    PRIMARY KEY (StudentID)
);

CREATE TABLE Room (
    BuildingID int,
    RoomID int,
    StudentID int,
    StartDate date,
    EndDate date,
    RentalCost int,
    RoommateID int,
    PRIMARY KEY (BuildingID, StudentID, RoomID),
    FOREIGN KEY (BuildingID) REFERENCES Building(BuildingID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

-- Insert data into 2NF tables
INSERT INTO Building(BuildingID, BuildingName)
VALUES
    (001, 'Alpha'),
    (002, 'Delta');

INSERT INTO Student(StudentID, StudentName, Phone)
VALUES
    (01, 'Clara', 452523),
    (02, 'Lin', 13241);

INSERT INTO Room(BuildingID, RoomID, StudentID, StartDate, EndDate, RentalCost, RoommateID)
VALUES
    (001, 1, 01, '2024-12-01', '2024-12-30', 500, 03),
    (002, 2, 02, '2024-12-01', '2024-12-30', 550, 04);

-- Convert to 3NF
ALTER TABLE Room DROP COLUMN RoommateID;

CREATE TABLE Roommate (
    StudentID int,
    RoommateID int,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

INSERT INTO Roommate (StudentID, RoommateID)
VALUES
    (1, 3),
    (2, 4);

-- Projection Operations
SELECT BuildingID, RoomID, StartDate, EndDate
FROM Room;

-- Cartesian Product and Union Operations
SELECT * FROM Building
UNION
SELECT * FROM Building;

-- Exception Operation (EXCEPT/NOT IN example from image)
SELECT *
FROM Building
WHERE BuildingID NOT IN (SELECT BuildingID FROM Room);

-- Join Operations
-- Inner Join
SELECT *
FROM Room r
INNER JOIN Building b ON r.BuildingID = b.BuildingID;

-- Left Join
SELECT *
FROM Room r
LEFT JOIN Building b ON r.BuildingID = b.BuildingID;

-- Right Join
SELECT *
FROM Room r
RIGHT JOIN Building b ON r.BuildingID = b.BuildingID;


-- Procedure 1: Transaction with error scenario
CREATE DEFINER='root'@'localhost' PROCEDURE `rentalUP_error`()
BEGIN
    START TRANSACTION;
    
    -- Increase Rental Cost
    UPDATE Room
    SET RentalCost = RentalCost + 100
    WHERE RoomID = 1;
    
    -- Attempt to add to non existent user
    UPDATE Room
    SET RentalCost = RentalCost + 100
    WHERE RoomID = 50;
    
    COMMIT;
END

-- Procedure 2: Transaction without rollback scenario
CREATE DEFINER='root'@'localhost' PROCEDURE `rentalNoROLL`()
BEGIN
    START TRANSACTION;
    
    -- Increase Rental Cost
    UPDATE Room
    SET RentalCost = RentalCost + 100
    WHERE RoomID = 1;
    
    UPDATE Room
    SET RentalCost = RentalCost + 100
    WHERE RoomID = 2;
    
    COMMIT;
END

-- Procedure 3: Transaction with error handling and rollback
CREATE DEFINER='root'@'localhost' PROCEDURE `rentalErrorROLLBACK`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed, rollback executed' as MESSAGE;
    END;
    
    START TRANSACTION;
    
    -- Increase Rental Cost
    UPDATE Room
    SET RentalCost = RentalCost + 100
    WHERE RoomID = 1;
    
    UPDATE Room
    SET RentalCost = RentalCost + 100
    WHERE RoomID = 2;
    
    COMMIT;
END