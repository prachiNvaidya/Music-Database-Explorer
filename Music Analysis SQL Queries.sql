--Q1. Who is the senior most employee based on job title? 

SELECT * FROM employee
ORDER BY levels desc
LIMIT 3


--Q2. Which countries have the most Invoices? 

SELECT billing_country, COUNT(invoice_id) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices desc
LIMIT 5


--Q3. What are top 3 values of total invoice?


SELECT total AS total_invoice
FROM invoice
ORDER BY total desc
LIMIT 3


--Q4. Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--totals 

SELECT billing_city, SUM(total) AS invoice_total 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 5


--Q5. Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money 


SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total
FROM customer AS c
INNER JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 5


--Q6. Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A 

SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer AS c
JOIN invoice AS i
ON c.customer_id = i.customer_id
JOIN invoice_line AS l
ON i.invoice_id = l.invoice_id
WHERE track_id IN
(
SELECT track_id
FROM track AS t
JOIN genre AS g
ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
) 
ORDER BY email;


--Q7. Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands 

SELECT ar.artist_id, ar.name, COUNT(ar.artist_id) AS number_of_songs
FROM track AS t
JOIN album AS a
ON a.album_id = t.album_id
JOIN artist AS ar
ON ar.artist_id = a.artist_id
JOIN genre AS g
ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY ar.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;



--Q8. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first

SELECT name, milliseconds
FROM track 
WHERE milliseconds > 
(
SELECT AVG(milliseconds) AS avg_song_length
FROM track
)
ORDER BY milliseconds DESC;




--Q9. Find how much amount spent by each customer on artists? Write a query to return 
--customer name, artist name and total spent

WITH money_spent_on_artists AS
(SELECT ar.artist_id, ar.name, SUM(il.unit_price * il.quantity) AS total_spent
FROM invoice_line AS il
JOIN track AS t
ON t.track_id = il.track_id
JOIN album AS al
ON al.album_id = t.album_id
JOIN artist AS ar
ON ar.artist_id = al.artist_id
GROUP BY ar.artist_id
ORDER BY total_spent DESC)

SELECT c.customer_id, c.first_name, c.last_name, msoa.name AS artist_name,
SUM(il.unit_price * il.quantity) AS total_spent
FROM invoice_line AS il
JOIN invoice AS i
ON i.invoice_id = il.invoice_id
JOIN customer AS c
ON c.customer_id = i.customer_id
JOIN track AS t
ON t.track_id = il.track_id
JOIN album AS al
ON al.album_id = t.album_id
JOIN money_spent_on_artists AS msoa
ON msoa.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY total_spent DESC





--Q10. We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres. 

WITH popular_genre AS
(
SELECT COUNT(il.quantity) AS purchases,i.billing_country AS country, 
g.name AS genre_name, g.genre_id AS genreid,
ROW_NUMBER() OVER (PARTITION BY i.billing_country
                   ORDER BY COUNT(il.quantity) DESC) AS rownumber
FROM invoice_line AS il
JOIN invoice AS i 
ON i.invoice_id = il.invoice_id
JOIN track AS t
ON t.track_id = il.track_id
JOIN genre AS g
ON g.genre_id = t.genre_id
GROUP BY country, genre_name, genreid
ORDER BY country ASC, purchases DESC
)
SELECT * FROM popular_genre 
WHERE rownumber = 1






--Q11. Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how 
--much they spent.

WITH highest_spending_customer AS 
(
SELECT c.customer_id, c.first_name, c.last_name, i.billing_country AS country,
SUM(i.total) AS total_spent,
ROW_NUMBER() OVER (PARTITION BY i.billing_country 
            ORDER BY SUM(i.total) DESC) AS rownum
FROM customer AS c
JOIN invoice AS i
ON i.customer_id = c.customer_id
GROUP BY 1,2,3,4
ORDER BY country ASC, total_spent DESC
)
SELECT customer_id, first_name, last_name, country, total_spent
FROM highest_spending_customer
WHERE rownum = 1





 