
<H1 align="center" > <strong> Library_Project_DataBase </strong> </H1>

***

![image](https://github.com/BaselAbuHamed/Library_Project_DataBase/assets/107325485/c2f319dc-8dcf-4fb1-9182-e746ef9b50df)

***

<strong>The AlBayan Library</strong> is a successful book rental service with branches in Ramallah, Amman, and Dubai. It employs around 200 staff members and serves approximately 20,000 registered members. The library uses a comprehensive database system to manage member registration, staff records, book inventory, rentals, and feedback.

Members can rent up to five books from any branch, and late fines apply for overdue books. Members can also provide book feedback with ratings and optional comments. Encryption techniques using symmetric keys and certificates are applied to protect sensitive member data.

The project aims to streamline operations, enhance customer experiences, and efficiently manage resources across all branches, ensuring a convenient and enriching experience for members.

***
<body>
    <h1>Stored Procedures</h1>
  <table>
    <tr>
      <th>Procedure Name</th>
      <th>Description</th>
    </tr>
    <tr>
      <td>InsertBranchData</td>
      <td>This stored procedure is used to insert data into the "Branch" table, specifically the branch name and location.</td>
    </tr>
    <tr>
      <td>InsertStaffData</td>
      <td>The purpose of this stored procedure is to insert data into the "Staff" table, which includes information about the staff members working at each branch.</td>
    </tr>
    <tr>
      <td>InsertSupervisorData</td>
      <td>This stored procedure is responsible for inserting data into the "Supervisor" table. The "Supervisor" table links staff members with their corresponding supervisors.</td>
    </tr>
    <tr>
      <td>InsertBranchManagerData</td>
      <td>This stored procedure is used to add data to the "BranchManager" table, which stores information about the branch managers.</td>
    </tr>
    <tr>
      <td>InsertMemberData</td>
      <td>The purpose of this stored procedure is to insert data into the "Member" table. It is used during the member registration process, encrypting sensitive information like address, email, and phone using symmetric encryption techniques for data security.</td>
    </tr>
    <tr>
      <td>InsertBookData</td>
      <td>This stored procedure is employed to add data to the "Book" table, which contains information about each book in the library's inventory.</td>
    </tr>
    <tr>
      <td>InsertBookCopyData</td>
      <td>The purpose of this stored procedure is to insert data into the "BookCopy" table. It is essential for tracking the availability and number of copies for each book in the library's stock.</td>
    </tr>
    <tr>
      <td>InsertRentalData</td>
      <td>This stored procedure is used to insert rental data into the "Rental" table when a member borrows a book.</td>
    </tr>
    <tr>
      <td>UpdateReturnDate</td>
      <td>The purpose of this stored procedure is to update the return date in the "Rental" table when a member returns a book.</td>
    </tr>
    <tr>
      <td>InsertFeedbackData</td>
      <td>This stored procedure is used to insert feedback data into the "Feedback" table, allowing members to rate and comment on books they have read.</td>
    </tr>
    <tr>
      <td>DecryptMemberData</td>
      <td>This stored procedure is designed to decrypt sensitive member data from the "Member" table.</td>
    </tr>
  </table>
</body>

***
<body>
  <h1>SQL Triggers</h1>
  <ul>
    <li>
      <h2>UpdateRentCost</h2>
      <p>Description: After updating the 'return_date' column in the 'Rental' table, this trigger calculates and updates the 'rent_cost' based on the rental period. Rentals within 14 days have a cost of 10 units per day, and rentals after 14 days have an additional 15 units per day.</p>
      <code>CREATE TRIGGER UpdateRentCost
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
END;</code>
    </li>
    <li>
      <h2>FeedbackTrigger</h2>
      <p>Description: Instead of insert trigger on the 'Feedback' table to prevent duplicate feedback. If a member tries to provide feedback for the same book more than once, an error message will be displayed, and the insert operation will be blocked.</p>
      <code>CREATE TRIGGER FeedbackTrigger
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
END;</code>
    </li>
    <li>
      <h2>UpdateLimitBook</h2>
      <p>Description: Instead of insert trigger on the 'Rental' table to enforce the limit of 5 books per member. The trigger checks if the member has reached the maximum limit and if the book is available for rent. If any condition is not met, the rental transaction is rolled back and an error message is displayed.</p>
      <code>CREATE TRIGGER UpdateLimitBook
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
END;</code>
    </li>
    <li>
      <h2>returnBook</h2>
      <p>Description: After updating the 'return_date' column in the 'Rental' table, this trigger decrements the 'limit_book' for the respective member and increments the 'copy_number' for the returned book in the 'BookCopy' table.</p>
      <code>CREATE TRIGGER returnBook
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
END;</code>
    </li>
    <li>
      <h2>CheckCopyAvailability</h2>
      <p>Description: After inserting a new book copy into the 'BookCopy' table, this trigger checks if the 'copy_number' is 0. If so, it prints a message indicating that no copies are available for that book.</p>
      <code>CREATE TRIGGER CheckCopyAvailability
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
END;</code>
    </li>
  </ul>
</body>

***

<body>
  <h2>SQL Encryption Commands</h2>
  <p>In this section, we have a series of SQL commands for creating and managing encryption-related objects in a SQL Server database.</p>
  <pre>
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
  </pre>

  <h3>Explanation</h3>
  <p>The above SQL commands are used to set up encryption for sensitive data in a SQL Server database.</p>
  <ul>
    <li><b>CREATE MASTER KEY:</b> Creates a master key that protects other encryption keys in the database. It is encrypted using the specified password ('123456789' in this case).</li>
    <li><b>CREATE CERTIFICATE:</b> Creates a certificate named 'ProjectCertificate' with the specified subject. Certificates are used to encrypt symmetric keys and provide a mechanism for authentication and encryption.</li>
    <li><b>CREATE SYMMETRIC KEY:</b> Creates a symmetric key named 'ProjectSymmetricKey' with AES-256 encryption algorithm. The key is encrypted using the 'ProjectCertificate' certificate created earlier.</li>
    <li><b>CREATE ASYMMETRIC KEY:</b> Creates an asymmetric key named 'ProjectAsymmetricKey' with RSA-2048 algorithm. Asymmetric keys are typically used for digital signatures and encryption.</li>
    <li><b>OPEN SYMMETRIC KEY:</b> Opens the 'ProjectSymmetricKey' for decryption operations. It uses the 'ProjectCertificate' certificate to decrypt the key.</li>
    <li><b>CLOSE SYMMETRIC KEY:</b> Closes the 'ProjectSymmetricKey', making it unavailable for decryption operations.</li>
  </ul>

  <p>These encryption objects help protect sensitive data stored in the SQL Server database. They ensure that data is encrypted when stored and can only be decrypted with the appropriate keys and certificates.</p>
</body>

***


<body>
  <h2>SQL User and Role Permissions</h2>
  <table>
    <tr>
      <th>SQL Commands</th>
      <th>Explanation</th>
    </tr>
    <tr>
      <td>
        CREATE LOGIN basel WITH PASSWORD = 'basel123';<br>
        CREATE USER basel FOR LOGIN basel;<br>
        CREATE ROLE BranchManager;<br>
        ALTER ROLE BranchManager ADD MEMBER basel;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Branch TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Staff TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Supervisor TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON BranchManager TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Member TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Book TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON BookCopy TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Rental TO BranchManager WITH GRANT OPTION;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Feedback TO BranchManager WITH GRANT OPTION;<br>
        SELECT * FROM sys.database_principals WHERE name = 'BranchManager';
      </td>
      <td>
        <b>Explanation:</b><br>
        The above SQL commands create a login 'basel' with a password and create a user 'basel' associated with this login. Then, a role named 'BranchManager' is created and 'basel' is added as a member of this role.<br>
        Further, various permissions are granted to the 'BranchManager' role using the GRANT statement with the WITH GRANT OPTION. This allows the 'BranchManager' to grant the same permissions to other users and roles.<br>
        The last SELECT statement shows the details of the 'BranchManager' role using the sys.database_principals system view.
      </td>
    </tr>
    <tr>
      <td>
        CREATE LOGIN [fade] WITH PASSWORD = 'fade123';<br>
        CREATE USER [fade] FOR LOGIN [fade];<br>
        CREATE ROLE StaffSupervisor;<br>
        ALTER ROLE StaffSupervisor ADD MEMBER fade;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Branch TO StaffSupervisor;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Staff TO StaffSupervisor;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Supervisor TO StaffSupervisor;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Member TO StaffSupervisor;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Book TO StaffSupervisor;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON BookCopy TO StaffSupervisor;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Rental TO StaffSupervisor;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Feedback TO StaffSupervisor;<br>
        SELECT * FROM sys.database_principals WHERE name = 'StaffSupervisor';
      </td>
      <td>
        <b>Explanation:</b><br>
        These SQL commands create a login '[fade]' with a password and a user '[fade]' associated with this login. Then, a role named 'StaffSupervisor' is created and '[fade]' is added as a member of this role.<br>
        Subsequently, the GRANT statement is used to provide various permissions to the 'StaffSupervisor' role. These permissions allow the 'StaffSupervisor' to perform SELECT, INSERT, UPDATE, and DELETE operations on specific database objects.<br>
        Finally, the SELECT statement shows the details of the 'StaffSupervisor' role using the sys.database_principals system view.
      </td>
    </tr>
    <tr>
      <td>
        CREATE LOGIN [Alamleh] WITH PASSWORD = 'Alamlehl123';<br>
        CREATE USER [Alamleh] FOR LOGIN [Alamleh];<br>
        CREATE ROLE Librarian;<br>
        ALTER ROLE Librarian ADD MEMBER Alamleh;<br>
        GRANT SELECT, INSERT, UPDATE, DELETE ON Branch TO Librarian;<br>
        GRANT SELECT, INSERT, UPDATE ON Staff TO Librarian;<br>
        GRANT SELECT ON Supervisor TO Librarian;<br>
        GRANT SELECT ON BranchManager TO Librarian;<br>
        GRANT SELECT ON Member TO Librarian;<br>
        GRANT SELECT, INSERT, UPDATE ON Book TO Librarian;<br>
        GRANT SELECT, INSERT, UPDATE ON BookCopy TO Librarian;<br>
        GRANT SELECT, INSERT, UPDATE ON Rental TO Librarian;<br>
        GRANT SELECT ON Feedback TO Librarian;<br>
        SELECT * FROM sys.database_principals WHERE name = 'Librarian';
      </td>
      <td>
        <b>Explanation:</b><br>
        The SQL commands create a login '[Alamleh]' with a password and a user '[Alamleh]' associated with this login. Next, a role named 'Librarian' is created and '[Alamleh]' is added as a member of this role.<br>
        The GRANT statement is used to provide various permissions to the 'Librarian' role. The 'Librarian' role has SELECT, INSERT, UPDATE, and DELETE permissions on specific database objects, enabling them to manage books, members, and more.<br>
        Lastly, the SELECT statement shows the details of the 'Librarian' role using the sys.database_principals system view.
      </td>
    </tr>
    <tr>
      <td>
        CREATE LOGIN [ahmaed] WITH PASSWORD = 'ahmaedl123';<br>
        CREATE USER [ahmaed] FOR LOGIN [ahmaed];<br>
        CREATE ROLE Staff_Member;<br>
        ALTER ROLE Staff_Member ADD MEMBER ahmaed;<br>
        GRANT SELECT ON Branch TO [Staff_Member];<br>
        GRANT SELECT ON Staff TO [Staff_Member];<br>
        GRANT SELECT, INSERT ON Member TO [Staff_Member];<br>
        GRANT SELECT ON Book TO [Staff_Member];<br>
        GRANT SELECT ON BookCopy TO [Staff_Member];<br>
        GRANT SELECT ON Rental TO [Staff_Member];<br>
        SELECT * FROM sys.database_principals WHERE name = 'Staff_Member';
      </td>
      <td>
        <b>Explanation:</b><br>
        These SQL commands create a login '[ahmaed]' with a password and a user '[ahmaed]' associated with this login. Then, a role named 'Staff_Member' is created, and '[ahmaed]' is added as a member of this role.<br>
        The GRANT statement provides various permissions to the 'Staff_Member' role. This role has SELECT permissions on the 'Branch', 'Staff', 'Member', 'Book', 'BookCopy', and 'Rental' database objects, allowing them to view and access data.<br>
        Finally, the SELECT statement shows the details of the 'Staff_Member' role using the sys.database_principals system view.
      </td>
    </tr>
  </table>
</body>
