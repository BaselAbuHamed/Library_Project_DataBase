# Library_Project_DataBase

***

![image](https://github.com/BaselAbuHamed/Library_Project_DataBase/assets/107325485/c2f319dc-8dcf-4fb1-9182-e746ef9b50df)

***

<strong>The AlBayan Library</strong> is a successful book rental service with branches in Ramallah, Amman, and Dubai. It employs around 200 staff members and serves approximately 20,000 registered members. The library uses a comprehensive database system to manage member registration, staff records, book inventory, rentals, and feedback.

Members can rent up to five books from any branch, and late fines apply for overdue books. Members can also provide book feedback with ratings and optional comments. Encryption techniques using symmetric keys and certificates are applied to protect sensitive member data.

The project aims to streamline operations, enhance customer experiences, and efficiently manage resources across all branches, ensuring a convenient and enriching experience for members.

***
<h2>Stored Procedure:</h2>
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
