CREATE MASTER KEY ENCRYPTION BY PASSWORD = '123456789';

CREATE CERTIFICATE ProjectCertificate
   WITH SUBJECT = 'Project Certificate';

CREATE SYMMETRIC KEY ProjectSymmetricKey
   WITH ALGORITHM = AES_256
   ENCRYPTION BY CERTIFICATE ProjectCertificate;

   CREATE ASYMMETRIC KEY ProjectAsymmetricKey
WITH ALGORITHM = RSA_2048;

OPEN SYMMETRIC KEY ProjectSymmetricKey DECRYPTION BY CERTIFICATE ProjectCertificate;

CLOSE SYMMETRIC KEY ProjectSymmetricKey;




--tables--
--**************************************************************************--

-- Table: Branch
CREATE TABLE Branch (
  branch_id INT IDENTITY(1,1) PRIMARY KEY ,
  branch_name VARCHAR(255),
  location VARCHAR(255),
);

-- Table: Staff
CREATE TABLE Staff (
  staff_id INT IDENTITY(1,1) PRIMARY KEY,
  branch_id INT,
  staff_name VARCHAR(255),
  staff_position VARCHAR(255),
  FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

-- Table: Supervisor
CREATE TABLE Supervisor (
  supervisor_id  INT IDENTITY(1,1) PRIMARY KEY,
  branch_id INT,
  staff_id INT,
  FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
  FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- Table: BranchManager
CREATE TABLE BranchManager (
  manager_id INT IDENTITY(1,1) PRIMARY KEY,
  branch_id INT,
  manager_name VARCHAR(255),
  manager_position VARCHAR(255),
  FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);


-- Table: Member
CREATE TABLE Member (
  member_id INT IDENTITY(1,1) PRIMARY KEY,
  member_name VARCHAR(255),
  member_address VARBINARY (MAX),
  member_email VARBINARY (MAX),
  limit_book INT,
  member_phone VARBINARY (MAX),
  passw VARBINARY (MAX)
);

-- Table: Book
CREATE TABLE Book (
  book_id INT IDENTITY(1,1) PRIMARY KEY,
  ISBN VARCHAR(20),
  book_title VARCHAR(255),
  author VARCHAR(255),
  publication_year INT,
  branch_id INT,
  FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);

-- Table: BookCopy
CREATE TABLE BookCopy (
  copy_id INT IDENTITY(1,1) PRIMARY KEY,
  book_id INT,
  copy_number INT,
  FOREIGN KEY (book_id) REFERENCES Book(book_id)
);

-- Table: Rental
CREATE TABLE Rental (
  rental_id INT IDENTITY(1,1) PRIMARY KEY,
  member_id INT,
  book_id INT,
  rent_cost INT,
  rental_date DATE,
  due_date DATE,
  return_date DATE,
  FOREIGN KEY (member_id) REFERENCES Member(member_id),
  FOREIGN KEY (book_id) REFERENCES Book(book_id)
);


-- Table: Feedback
CREATE TABLE Feedback (
  feedback_id INT IDENTITY(1,1) PRIMARY KEY,
  member_id INT,
  book_id INT,
  rating INT,
  comment VARCHAR(255),
  FOREIGN KEY (member_id) REFERENCES Member(member_id),
  FOREIGN KEY (book_id) REFERENCES Book(book_id)
);
--**************************************************************************--
--end tables--


-- Stored Procedure--
--**************************************************************************--

-- Stored Procedure: InsertBranchData
go
CREATE PROCEDURE InsertBranchData
  @branch_name VARCHAR(255),
  @location VARCHAR(255)
AS
BEGIN
  INSERT INTO Branch (branch_name, location)
  VALUES (@branch_name, @location);
END;


-- Stored Procedure: InsertStaffData
go
CREATE PROCEDURE InsertStaffData
  @branch_id INT,
  @staff_name VARCHAR(255),
  @staff_position VARCHAR(255)
AS
BEGIN
  -- Check if the branch ID exists
  IF EXISTS (SELECT 1 FROM Branch WHERE branch_id = @branch_id)
  BEGIN
    -- Insert data into Staff table
    INSERT INTO Staff (branch_id, staff_name, staff_position)
    VALUES (@branch_id, @staff_name, @staff_position);
    PRINT 'Data inserted successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Branch ID does not exist.';
  END
END;


-- Stored Procedure: InsertSupervisorData
go
CREATE PROCEDURE InsertSupervisorData
  @branch_id INT,
  @staff_id INT
AS
BEGIN
  -- Check if the branch ID and staff ID exist
  IF EXISTS (SELECT 1 FROM Branch WHERE branch_id = @branch_id) AND EXISTS (SELECT 1 FROM Staff WHERE staff_id = @staff_id)
  BEGIN
    -- Insert data into Supervisor table
    INSERT INTO Supervisor (branch_id, staff_id)
    VALUES (@branch_id, @staff_id);
    PRINT 'Data inserted successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Branch ID or Staff ID does not exist.';
  END
END;


go
CREATE PROCEDURE InsertBranchManagerData
  @branch_id INT,
  @manager_name VARCHAR(255),
  @manager_position VARCHAR(255)
AS
BEGIN
  -- Check if the branch ID exists
  IF EXISTS (SELECT 1 FROM Branch WHERE branch_id = @branch_id)
  BEGIN
    -- Insert data into BranchManager table
    INSERT INTO BranchManager (branch_id, manager_name, manager_position)
    VALUES (@branch_id, @manager_name, @manager_position);
    PRINT 'Data inserted successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Branch ID does not exist.';
  END
END;


go
CREATE PROCEDURE InsertMemberData
  @member_name VARCHAR(255),
  @member_address VARCHAR(255),
  @member_email VARCHAR(255),
  @member_phone VARCHAR(20),
  @pass VARCHAR(255)
AS
BEGIN
  -- Insert data into Member table
  INSERT INTO Member (member_name, member_address, member_email, member_phone, passw)
  VALUES (@member_name, @member_address, @member_email, @member_phone, @pass);

  PRINT 'Data inserted successfully.';
END;


go
CREATE PROCEDURE InsertBookData
  @ISBN VARCHAR(20),
  @book_title VARCHAR(255),
  @author VARCHAR(255),
  @publication_year INT,
  @branch_id INT
AS
BEGIN
  -- Check if the branch ID exists
  IF EXISTS (SELECT 1 FROM Branch WHERE branch_id = @branch_id)
  BEGIN
    -- Insert data into Book table
    INSERT INTO Book (ISBN, book_title, author, publication_year, branch_id)
    VALUES (@ISBN, @book_title, @author, @publication_year, @branch_id);
    PRINT 'Data inserted successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Branch ID does not exist.';
  END
END;


go
CREATE PROCEDURE InsertBookCopyData
  @book_id INT,
  @copy_number INT
AS
BEGIN
  -- Check if the book ID exists
  IF EXISTS (SELECT 1 FROM Book WHERE book_id = @book_id)
  BEGIN
    -- Insert data into BookCopy table
    INSERT INTO BookCopy (book_id, copy_number)
    VALUES (@book_id, @copy_number);
    PRINT 'Data inserted successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Book ID does not exist.';
  END
END;


go
CREATE PROCEDURE InsertRentalData
  @member_id INT,
  @book_id INT,
  @rental_date DATE,
  @due_date DATE
AS
BEGIN
  -- Check if the member ID and book ID exist
  IF EXISTS (SELECT 1 FROM Member WHERE member_id = @member_id) AND EXISTS (SELECT 1 FROM Book WHERE book_id = @book_id)
  BEGIN
    -- Insert data into Rental table
    INSERT INTO Rental (member_id, book_id, rental_date, due_date)
    VALUES (@member_id, @book_id, @rental_date, @due_date);

    -- Increment book count for the member
    UPDATE Member SET limit_book = limit_book + 1 WHERE member_id = @member_id;

    PRINT 'Data inserted successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Member ID or Book ID does not exist.';
  END
END;


go
CREATE PROCEDURE UpdateReturnDate
  @member_id INT,
  @book_id INT,
  @return_date DATE
AS
BEGIN
  -- Check if the rental exists for the specified member ID and book ID
  IF EXISTS (SELECT 1 FROM Rental WHERE member_id = @member_id AND book_id = @book_id)
  BEGIN
    -- Update the return date in Rental table
    UPDATE Rental SET return_date = @return_date WHERE member_id = @member_id AND book_id = @book_id;
    PRINT 'Return date updated successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Rental not found for the specified Member ID and Book ID.';
  END
END;


go
CREATE PROCEDURE InsertFeedbackData
  @member_id INT,
  @book_id INT,
  @rating INT,
  @comment VARCHAR(255)
AS
BEGIN
  -- Check if the member ID and book ID exist
  IF EXISTS (SELECT 1 FROM Member WHERE member_id = @member_id) AND EXISTS (SELECT 1 FROM Book WHERE book_id = @book_id)
  BEGIN
    -- Insert data into Feedback table
    INSERT INTO Feedback (member_id, book_id, rating, comment)
    VALUES (@member_id, @book_id, @rating, @comment);
    PRINT 'Data inserted successfully.';
  END
  ELSE
  BEGIN
    PRINT 'Member ID or Book ID does not exist.';
  END
END;

go
CREATE PROCEDURE DecryptMemberData
  @member_id INT
AS
BEGIN
  -- Variables to hold decrypted data
  DECLARE @member_name VARCHAR(255);
  DECLARE @limit_book INT;
  DECLARE @member_address VARCHAR(MAX);
  DECLARE @member_email VARCHAR(MAX);
  DECLARE @member_phone VARCHAR(MAX);
  DECLARE @passw VARCHAR(MAX);

  -- Get the encrypted data from the Member table
  SELECT @member_name = CONVERT(VARCHAR(255), DECRYPTBYKEYAUTOCERT(cert_id('ProjectCertificate'), NULL, member_name)),
         @limit_book = limit_book,
         @member_address = CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOCERT(cert_id('ProjectCertificate'), NULL, member_address)),
         @member_email = CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOCERT(cert_id('ProjectCertificate'), NULL, member_email)),
         @member_phone = CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOCERT(cert_id('ProjectCertificate'), NULL, member_phone)),
         @passw = CONVERT(VARCHAR(MAX), DECRYPTBYKEYAUTOCERT(cert_id('ProjectCertificate'), NULL, passw))
  FROM Member
  WHERE member_id = @member_id;

  -- Display the decrypted data
  SELECT 'Member ID: ' + CAST(@member_id AS VARCHAR(10)) AS [Decrypt Result],
         'Name: ' + @member_name AS [Member Name],
         'Limit Book: ' + CAST(@limit_book AS VARCHAR(10)) AS [Limit Book],
         'Address: ' + @member_address AS [Member Address],
         'Email: ' + @member_email AS [Member Email],
         'Phone: ' + @member_phone AS [Member Phone],
         'Password: ' + @passw AS [Password];
END;
go
-- Stored Procedure: InsertMemberData
-- Stored Procedure: InsertMemberData
CREATE PROCEDURE InsertMemberData
  @member_name VARCHAR(255),
  @limit_book INT,
  @member_address VARCHAR(MAX),
  @member_email VARCHAR(MAX),
  @member_phone VARCHAR(MAX),
  @passw VARCHAR(MAX)
AS
BEGIN
  -- Encrypt the sensitive data
  DECLARE @encrypted_address VARBINARY(MAX), @encrypted_email VARBINARY(MAX), @encrypted_phone VARBINARY(MAX), @encrypted_passw VARBINARY(MAX);

  -- Encrypt the address
  SET @encrypted_address = ENCRYPTBYKEY(KEY_GUID('ProjectSymmetricKey'), CAST(@member_address AS VARBINARY(MAX)));
  
  -- Encrypt the email
  SET @encrypted_email = ENCRYPTBYKEY(KEY_GUID('ProjectSymmetricKey'), CAST(@member_email AS VARBINARY(MAX)));
  
  -- Encrypt the phone
  SET @encrypted_phone = ENCRYPTBYKEY(KEY_GUID('ProjectSymmetricKey'), CAST(@member_phone AS VARBINARY(MAX)));
  
  -- Encrypt the password
  SET @encrypted_passw = ENCRYPTBYKEY(KEY_GUID('ProjectSymmetricKey'), CAST(@passw AS VARBINARY(MAX)));

  -- Insert data into Member table
  INSERT INTO Member (member_name, limit_book, member_address, member_email, member_phone, passw)
  VALUES (@member_name, @limit_book, @encrypted_address, @encrypted_email, @encrypted_phone, @encrypted_passw);

  PRINT 'Data inserted successfully.';
END;
--**************************************************************************--
--End Stored Procedure--


--TRIGGER--
--**************************************************************************--

go
CREATE TRIGGER UpdateRentCost
ON Rental
AFTER UPDATE
AS
BEGIN
  -- Check if the 'return_date' column is updated
  IF UPDATE(return_date)
  BEGIN
    -- Update the 'rent_cost' column based on the rental period
    UPDATE r
    SET r.rent_cost = CASE
      WHEN DATEDIFF(DAY, r.rental_date, r.return_date) <= 14 THEN DATEDIFF(DAY, r.rental_date, r.return_date) * 10
      ELSE (14 * 10) + ((DATEDIFF(DAY, r.rental_date, r.return_date) - 14) * 15)
    END
    FROM Rental AS r
    JOIN inserted AS i ON r.rental_id = i.rental_id;
  END
END;


go
CREATE TRIGGER FeedbackTrigger
ON Feedback
INSTEAD OF INSERT
AS
BEGIN
  DECLARE @memberId INT, @bookId INT;

  -- Get the member ID and book ID from the inserted rows
  SELECT @memberId = member_id, @bookId = book_id
  FROM inserted;

  -- Check if the member has already inserted feedback for the book
  IF EXISTS (
    SELECT 1
    FROM Feedback
    WHERE member_id = @memberId AND book_id = @bookId
  )
  BEGIN
    -- Display an error message
    PRINT 'You have already provided feedback for this book.';
  END;
  ELSE
  BEGIN
    -- Insert the feedback into the table
    INSERT INTO Feedback (member_id, book_id, rating, comment)
    SELECT member_id, book_id, rating, comment
    FROM inserted;
    PRINT 'Data inserted successfully.';
  END;
END;

go
CREATE TRIGGER UpdateLimitBook
ON Rental
INSTEAD OF INSERT
AS
BEGIN
  -- Variables
  DECLARE @member_id INT, @book_id INT, @rental_count INT;

  -- Get the inserted member_id and book_id
  SELECT @member_id = member_id, @book_id = book_id
  FROM inserted;

  -- Check if the member has reached the maximum limit of 5 books
  SELECT @rental_count = limit_book FROM Member WHERE member_id = @member_id;
  IF @rental_count >= 5
  BEGIN
    RAISERROR('Maximum limit of 5 books reached for this member. Rental transaction is not allowed.', 16, 1);
	    ROLLBACK;
    RETURN;
  END;

  -- Check if the member has already rented the same book
  IF EXISTS (SELECT 1 FROM Rental WHERE member_id = @member_id AND book_id = @book_id)
  BEGIN
    RAISERROR('This member has already rented this book. Rental transaction is not allowed.', 16, 1);
	    ROLLBACK;
    RETURN;
  END;

  -- Check if there are available copies of the book
  DECLARE @copy_count INT;
  SELECT @copy_count = COUNT(*) FROM BookCopy WHERE book_id = @book_id AND copy_number > 0;
  IF @copy_count = 0
  BEGIN
    RAISERROR('No copies available for this book. Rental transaction is not allowed.', 16, 1);
	    ROLLBACK;
    RETURN;
  END;

  -- Increment the limit_book column for the member
  UPDATE Member
  SET limit_book = limit_book + 1
  WHERE member_id = @member_id;
  print @book_id;
  -- Decrement the book_copy by one
  UPDATE BookCopy
  SET copy_number = copy_number - 1
  WHERE book_id = @book_id;

  PRINT 'Book rented successfully.';
END;


go
CREATE TRIGGER returnBook
ON Rental
AFTER UPDATE
AS
BEGIN
  -- Variables
  DECLARE @member_id INT, @book_id INT;

  -- Check if the return_date column has been updated
  IF UPDATE(return_date)
  BEGIN
    -- Get the member_id and book_id for the updated rental
    SELECT @member_id = member_id, @book_id = book_id
    FROM deleted;

    -- Decrement the limit_book column for the member
    UPDATE Member
    SET limit_book = limit_book - 1
    WHERE member_id = @member_id;

    -- Increment the book_copy by one
    UPDATE BookCopy
    SET copy_number = copy_number + 1
    WHERE book_id = @book_id;

    PRINT 'Book returned successfully.';
  END;
END;


go
CREATE TRIGGER CheckCopyAvailability
ON BookCopy
AFTER INSERT
AS
BEGIN
  -- Variables
  DECLARE @book_id INT;
  DECLARE @copy_number INT;

  -- Get the book_id and copy_number for the inserted book copy
  SELECT @book_id = book_id, @copy_number = copy_number
  FROM inserted;

  -- Check if the copy number is 0
  IF @copy_number = 0
  BEGIN
    -- Print a message indicating no copies are available
    PRINT 'No copies available for Book ID: ' + CAST(@book_id AS VARCHAR(10));
  END;
END;
--**************************************************************************--
--End TRIGGER--


--users--
--**************************************************************************--
CREATE LOGIN basel WITH PASSWORD = 'basel123';

GO

CREATE USER basel FOR LOGIN basel;
GO

CREATE ROLE BranchManager;

-- Assign user to the Branch Manager role
ALTER ROLE BranchManager ADD MEMBER basel;
-- Grant permissions for the Branch Manager role
GRANT SELECT, INSERT, UPDATE, DELETE ON Branch TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON Staff TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON Supervisor TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON BranchManager TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON Member TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON Book TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookCopy TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rental TO BranchManager WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON Feedback TO BranchManager WITH GRANT OPTION;

-- Revoke unnecessary permissions
SELECT * FROM sys.database_principals WHERE name = 'BranchManager';


CREATE LOGIN [fade] WITH PASSWORD = 'fade123';

GO

CREATE USER [fade] FOR LOGIN [fade];
GO


CREATE ROLE StaffSupervisor;

-- Assign user to the Branch Manager role
ALTER ROLE StaffSupervisor ADD MEMBER fade;

-- Grant permissions for the Staff Supervisor role
GRANT SELECT, INSERT, UPDATE, DELETE ON Branch TO StaffSupervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Staff TO StaffSupervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Supervisor TO StaffSupervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Member TO StaffSupervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Book TO StaffSupervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookCopy TO StaffSupervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rental TO StaffSupervisor;
GRANT SELECT, INSERT, UPDATE, DELETE ON Feedback TO StaffSupervisor;

SELECT * FROM sys.database_principals WHERE name = 'StaffSupervisor';


CREATE LOGIN [Alamleh] WITH PASSWORD = 'Alamlehl123';
GO

CREATE USER [Alamleh] FOR LOGIN [Alamleh];
GO
CREATE ROLE Librarian;
ALTER ROLE Librarian ADD MEMBER Alamleh;

-- Grant permissions for the Librarian role
GRANT SELECT, INSERT, UPDATE, DELETE ON Branch TO Librarian;
GRANT SELECT, INSERT, UPDATE ON Staff TO Librarian;
GRANT SELECT ON Supervisor TO Librarian;
GRANT SELECT ON BranchManager TO Librarian;
GRANT SELECT ON Member TO Librarian;
GRANT SELECT, INSERT, UPDATE ON Book TO Librarian;
GRANT SELECT, INSERT, UPDATE ON BookCopy TO Librarian;
GRANT SELECT, INSERT, UPDATE ON Rental TO Librarian;
GRANT SELECT ON Feedback TO Librarian;
SELECT * FROM sys.database_principals WHERE name = 'Librarian';


CREATE LOGIN [ahmaed] WITH PASSWORD = 'ahmaedl123';
GO

CREATE USER [ahmaed] FOR LOGIN [ahmaed];
GO


CREATE ROLE Staff_Member;

-- Assign user to the Branch Manager role
ALTER ROLE Staff_Member ADD MEMBER ahmaed;

-- Grant permissions for the Staff Member role
-- View Data
GRANT SELECT ON Branch TO [Staff_Member];
GRANT SELECT ON Staff TO [Staff_Member];
GRANT SELECT,INSERT ON Member TO [Staff_Member];
GRANT SELECT ON Book TO [Staff_Member];
GRANT SELECT ON BookCopy TO [Staff_Member];
GRANT SELECT ON Rental TO [Staff_Member];
SELECT * FROM sys.database_principals WHERE name = 'Staff_Member';
--**************************************************************************--
--End Users--

go
EXEC InsertBranchData 'Ramallah Branch', 'Ramallah';
EXEC InsertBranchData 'Amman Branch', 'Amman';
EXEC InsertBranchData 'Dubai Branch', 'Dubai';


EXEC InsertStaffData 1, 'John Smith', 'Librarian';
EXEC InsertStaffData 1, 'Emily Johnson', 'Assistant Librarian';
EXEC InsertStaffData 2, 'Michael Davis', 'Librarian';
EXEC InsertStaffData 2, 'Sarah Wilson', 'Assistant Librarian';
EXEC InsertStaffData 3, 'Robert Brown', 'Librarian';
EXEC InsertStaffData 3, 'Jessica Lee', 'Assistant Librarian';


EXEC InsertSupervisorData 1, 1;
EXEC InsertSupervisorData 1, 2;
EXEC InsertSupervisorData 2, 3;
EXEC InsertSupervisorData 2, 4;
EXEC InsertSupervisorData 3, 5;
EXEC InsertSupervisorData 3, 6;


EXEC InsertBranchManagerData 1, 'David Johnson', 'Branch Manager';
EXEC InsertBranchManagerData 2, 'Rachel Davis', 'Branch Manager';
EXEC InsertBranchManagerData 3, 'Andrew Smith', 'Branch Manager';


EXEC InsertMemberData 'Emma Wilson', '789 Oak St', 'emma.wilson@example.com',0, '555-9012', '123456789';
EXEC InsertMemberData 'Alice Brown', '123 Main St', 'alice.brown@example.com', '555-1234' ,'00123456';
EXEC InsertMemberData 'John Doe', '456 Elm St', 'john.doe@example.com', '555-5678' , '123456';
EXEC InsertMemberData 'Emma Tylor', '789 Oak St', 'emma.wilson@example.com', '555-9012', '123456';
EXEC InsertMemberData 'Emma Tylor', '789 Oak St', 'emma.wilson@example.com', '555-9012', '123456';

EXEC InsertMemberData 'fade', '12t', 'emma.wilson@example.com', '555-9012', '123456';

EXEC InsertMemberData 'John Doe', '123 Main St', 'john@example.com', 0, '555-1234', 'mypassword';




EXEC InsertBookData '1234567890', 'The Great Gatsby', 'F. Scott Fitzgerald', 1925, 1;
EXEC InsertBookData '9876543210', 'To Kill a Mockingbird', 'Harper Lee', 1960, 2;
EXEC InsertBookData '5432109876', 'Pride and Prejudice', 'Jane Austen', 1813, 3;


EXEC InsertBookCopyData 1, 1;
EXEC InsertBookCopyData 1, 2;
EXEC InsertBookCopyData 2, 1;
EXEC InsertBookCopyData 3, 1;
EXEC InsertBookCopyData 3, 2;
EXEC InsertBookCopyData 3, 3;


EXEC InsertRentalData 1, 1, '2023-07-01', '2023-07-15';
EXEC InsertRentalData 2, 2, '2023-07-05', '2023-07-19';
EXEC InsertRentalData 5, 3, '2023-07-10', '2023-07-24';


EXEC InsertFeedbackData 1, 1, 5, 'Great book!';
EXEC InsertFeedbackData 2, 2, 4, 'Enjoyed reading this book.';
EXEC InsertFeedbackData 3, 3, 3, 'Not my favorite.';

EXEC DecryptMemberData @member_id = 14;
