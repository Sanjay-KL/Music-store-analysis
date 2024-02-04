
--Q1) Who is the senior most employee based on Job Title?

SELECT TOP 1 * 
FROM employee
ORDER BY levels desc;

--Q2) Top 10 countries which has most invoices?

SELECT TOP 10 COUNT(1) as invoices_count, billing_country 
FROM INVOICE
GROUP BY billing_country
ORDER BY invoices_count desc;


--Q3) What are top 3 values of total invoice round it to 2 decimals?

SELECT TOP 3 invoice_id, ROUND(total ,2) as invoice
FROM invoice
ORDER BY total desc;


--Q4) Which city has best customers? Write a query that returns city that has highest sum of
----- invoice totals. Return both the city name & sum of all invoice totals.

SELECT TOP 5 billing_city as city, ROUND(SUM(total),2) as invoice_total 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total desc;


--Q5) Who is the best customer? The customer who spent the most money will be declared the best customer.
----- Write a query that returns the person who has spent the most money.

SELECT TOP 1 c.customer_id, c.first_name, c.last_name
, ROUND(SUM(i.total),2) as invoice_total 
FROM customer c
JOIN invoice i on c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY invoice_total DESC;


--Q6) Write query to return the email, first name, last name & Genre of all Rock Music listeners. Return
----- your list ordered alphabetically by email starting with A.

SELECT DISTINCT c.email, c.first_name, c.last_name, g.name as genre
FROM customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on g.genre_id = t.genre_id
WHERE g.name = 'Rock';


--Q7) Let's invite the artists who have written the most rock music in dataset. Write a query that returns
---- the Artist name and total track count of the top 10 rock bands.


SELECT TOP 10 a.artist_id, a.name, count(a.artist_id) as no_of_songs 
FROM artist a
join album al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join genre g on g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY no_of_songs DESC;


--Q8) Return all the Track names that have a song length longer than the average song length.
----- Return the Name and milliseconds for each track. Order by the Song length with logest songs listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
					  SELECT AVG(milliseconds) as avg_track_length 
					  FROM track)
ORDER BY milliseconds DESC;


--Q9) Find how much amount spent by each customer on best selling artist? Write a Query to return customer name, artist name
---- and total spent.

WITH best_artist as(
		SELECT TOP 1 ar.artist_id as artist_id, ar.name as artist_name, sum(il.unit_price*il.quantity) as total_sales
		FROM invoice_line il 
		join track t on t.track_id = il.track_id
		join album a on t.album_id = a.album_id
		join artist ar on a.artist_id = ar.artist_id
		GROUP BY ar.artist_id , ar.name
		ORDER BY total_sales DESC)
SELECT c.customer_id, c.first_name, c.last_name, ba.artist_name, SUM(il.unit_price*il.quantity) as amount_spent
FROM customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album a on t.album_id = a.album_id
join best_artist ba on a.artist_id = ba.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, ba.artist_name
ORDER BY amount_spent DESC;


--Q10) We want to find out the most popular music genre for each country. We determine the most popular genre as the genre with
------ the highest amount of purchases. Write a query that returns each country along with the Top genre. For countries where the
------ maximum number of purchases is shared return all Genres.

WITH cte as(
SELECT i.billing_country as country, g.name as genre,g.genre_id as genre_id
, count(1) as no_of_copies_sold,
rank() over(partition by i.billing_country  order by count(1) desc) as rnk
FROM invoice i 
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on t.genre_id = g.genre_id
GROUP BY i.billing_country, g.name,g.genre_id)
SELECT country, genre_id, genre, no_of_copies_sold
FROM cte
WHERE rnk = 1;


--Q11) Write a query that determines the customer that has spent the most on music for each country.
--     Write a query that returns the country along with the Top customer and how much they spent.
--		For countries where the top amount is shared, provide all customers who spent same amount.

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

WITH cust_with_country as(
SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, sum(total) as total_spending,
ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY sum(total) DESC) as rn
FROM customer c
join invoice i on c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country)
SELECT customer_id, first_name, last_name, billing_country, total_spending
FROM cust_with_country
WHERE rn = 1;
