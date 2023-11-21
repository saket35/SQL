use music_database;


-- 1. Who is the senior most employee based on job title?
select * from employee order by levels desc
limit 1;

-- 2. Which countries have the most Invoices?
select billing_country,count(billing_country) from invoice group by billing_country
order by billing_country desc ;

-- 3. What are top 3 values of total invoice?
select * from invoice order by total desc;

/* 4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals */
select billing_City,round(sum(total),2) as sum_city from invoice group by billing_city order by sum(total) desc ;

/* 5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money */

select c.customer_id,c.first_name,c.last_name,round(sum(i.total),2) as  invoice_total from customer c join invoice i  on i.customer_id = c.customer_id
 group by c.customer_id
 order by invoice_total desc
 limit 1;
 
 /* 6. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A */

select distinct first_name,last_name,email from customer c 
join invoice i on c.customer_id = i.customer_id
join invoice_line iv on i.invoice_id = iv.invoice_id
join track t on iv.track_id = t.track_id 
join genre g on g.genre_id = t.genre_id
where g.name =  "rock"
order by email;

/* 7. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands
*/
	select art.artist_id,art.name,count(art.artist_id) as number_of_song	   
	from track t 
	join album a on a.album_id = t.album_id
	join artist art on art.artist_id = a.artist_id
	join genre g on g.genre_id = t.genre_id
	where g.name = "rock"
	group by art.artist_id
	order by number_of_song desc
	limit 10;
    
/* 8. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */

select name,milliseconds from track
where milliseconds > ( 
select avg(milliseconds) as avg_len_track
from track) 
order by milliseconds desc
;


/* 9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

WITH best_selling_artist AS (
  SELECT
    artist.artist_id,
    artist.name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
  FROM invoice_line
  JOIN track ON track.track_id = invoice_line.track_id
  JOIN album ON album.album_id = track.album_id
  JOIN artist ON artist.artist_id = album.artist_id
  GROUP BY artist.artist_id
  ORDER BY total_sales DESC
  limit 1
)

SELECT
  customer.customer_id,
  customer.first_name,
  customer.last_name,
  best_selling_artist.name AS artist_name,
  SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist ON best_selling_artist.artist_id = album.artist_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.name
ORDER BY total_spent DESC;

/*
10. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres
*/
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS total_purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS row_num 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	group by customer.country,genre.name,genre.genre_id
order by genre.name, total_purchases desc ) 
SELECT * FROM popular_genre WHERE row_num <= 1;




/* . Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount
*/

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


