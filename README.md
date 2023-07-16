# Library_Project_DataBase

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

<head>
  <title>AlBayan SQL Triggers</title>
  <style>
    table {
      border-collapse: collapse;
      width: 100%;
    }
    th, td {
      border: 1px solid black;
      padding: 8px;
      text-align: left;
    }
    th {
      background-color: #f2f2f2;
    }
  </style>
</head>
<body>
  <h1>SQL Triggers</h1>
  <table>
    <tr>
      <th>Trigger Name</th>
      <th>Description</th>
      <th>SQL Code</th>
    </tr>
    <tr>
      <td>UpdateRentCost</td>
      <td>After updating the 'return_date' column in the 'Rental' table, this trigger calculates and updates the 'rent_cost' based on the rental period. Rentals within 14 days have a cost of 10 units per day, and rentals after 14 days have an additional 15 units per day.</td>
      <td>
        <code>
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
        </code>
      </td>
    </tr>
    <tr>
      <td>FeedbackTrigger</td>
      <td>Instead of insert trigger on the 'Feedback' table to prevent duplicate feedback. If a member tries to provide feedback for the same book more than once, an error message will be displayed, and the insert operation will be blocked.</td>
      <td>
        <code>
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
        </code>
      </td>
    </tr>
    <tr>
      <td>UpdateLimitBook</td>
      <td>Instead of insert trigger on the 'Rental' table to enforce the limit of 5 books per member. The trigger checks if the member has reached the maximum limit and if the book is available for rent. If any condition is not met, the rental transaction is rolled back, and an error message is displayed.</td>
      <td>
        <code>
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
        </code>
      </td>
    </tr>
    <tr>
      <td>returnBook</td>
      <td>After updating the 'return_date' column in the 'Rental' table, this trigger decrements the 'limit_book' for the respective member and increments the 'copy_number' for the returned book in the 'BookCopy' table.</td>
      <td>
        <code>
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
        </code>
      </td>
    </tr>
    <tr>
      <td>CheckCopyAvailability</td>
      <td>After inserting a new book copy into the 'BookCopy' table, this trigger checks if the 'copy_number' is 0. If so, it prints a message indicating that no copies are available for that book.</td>
      <td>
        <code>
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
        </code>
      </td>
    </tr>
  </table>
</body>

