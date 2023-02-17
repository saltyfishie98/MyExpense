/*markdown
 ### Create Tables
*/


CREATE TABLE Categories(category TEXT PRIMARY KEY);

CREATE TABLE Expenses(
    datetime TEXT PRIMARY KEY,
    amount INT,
    title TEXT,
    category TEXT NOT NULL,
    FOREIGN KEY (category) REFERENCES Categories(category)
);

/*markdown
### Insert Data
*/

INSERT INTO Categories (category)
VALUES
    ("Food"),
    ("Entertainment"),
    ("Sports"),
    ("Shopping");

-- @block
INSERT INTO Expenses(datetime, amount, title, category)
VALUES 
    ("dfd1", 30, "sdf", "Entertainment"),
    ("dfd2", 30, "sdf", "Sports"),
    ("dfd3", 30, "sdf", "Shopping");

/*markdown
### Read Tables
*/

SELECT *
FROM Categories;

SELECT *
FROM Categories
    INNER JOIN Expenses ON Expenses.category = Categories.category;

SELECT *
FROM Expenses;

/*markdown
### Delete Tables
*/

DROP TABLE Categories;

DROP TABLE Expenses;