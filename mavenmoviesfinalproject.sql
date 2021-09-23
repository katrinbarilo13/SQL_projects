USE mavenmovies; 

-- This is a mini project that focuses on the basics of SQL. 

-- 1/ manager name from each store, and street add, distr, city, country from each place

SELECT store.store_id, staff.first_name, address.address, 
address.district, city.city, country.country
FROM country
INNER JOIN city
	ON country.country_id = city.country_id
INNER JOIN address
	ON city.city_id = address.city_id 
INNER JOIN store
	ON address.address_id = store.address_id
INNER JOIN staff
	ON store.store_id = staff.store_id; 
    

-- 2/ list of each inventory item, store_id, inventory_id, name of film, 
-- film rating, rental rate + rep cost

SELECT inventory.inventory_id, inventory.store_id, film.title, film.rental_rate, 
film.rating, film.replacement_cost
FROM film 
LEFT JOIN inventory
ON film.film_id = inventory.film_id; 

-- 3/ how many inventory items we have, the rating at each store
SELECT inventory.store_id, COUNT(inventory.inventory_id) AS amnt_inv, film.rating
FROM inventory 
LEFT JOIN film
	ON film.film_id = inventory.film_id
GROUP BY film.rating, inventory.store_id; 

-- 4/ # of films, avg rep cost, total rep cost, sliced by store + film category
SELECT store_id, COUNT(inventory.inventory_id) as no_films, AVG(film.replacement_cost) AS avgrep, SUM(film.replacement_cost) AS 
tot_rep, category.name
FROM inventory
LEFT JOIN film
	ON film.film_id = inventory.film_id
LEFT JOIN film_category
	ON film.film_id = film_category.film_id
LEFT JOIN category
	ON category.category_id = film_category.category_id
GROUP BY store_id, category.name
ORDER BY SUM(film.replacement_cost) DESC; 

-- 5/ customer names, the store id they go to, whether store active, + streetadd, city, country
SELECT customer.first_name, store.store_id, customer.active, address.address, city.city, country.country
FROM country
INNER JOIN city
	ON country.country_id = city.country_id
INNER JOIN address
	ON city.city_id = address.city_id
INNER JOIN store
	ON address.address_id = store.address_id
INNER JOIN customer
	ON store.store_id = customer.store_id; 
    
-- 6/ customer names, their rentals, sum of payments, most valuable rentals at top of list
SELECT customer.first_name, COUNT(rental.rental_id), SUM(payment.amount) AS total_amnt
FROM customer
INNER JOIN rental
	ON customer.customer_id = rental.customer_id
INNER JOIN payment
	ON rental.rental_id = payment.rental_id 
GROUP BY customer.first_name
ORDER BY total_amnt DESC;

-- 7/ union with advisors + investors, who is who, and what company investors work at
SELECT 'advisor' AS type, advisor.first_name, advisor.last_name, NULL FROM advisor
UNION
SELECT 'investor' AS type, investor.first_name, investor.last_name, investor.company_name FROM investor; 

-- 8/ % carry films for 3 award actors, % for 2 award actors, % for 1 award actors
SELECT
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
		ELSE '1 award'
	END AS number_awards, 
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS percent_one_film
	
FROM actor_award
	

GROUP BY 
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
		ELSE '1 award'
	END



