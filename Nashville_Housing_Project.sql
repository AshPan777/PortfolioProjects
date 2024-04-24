SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM Nashville_Housing;

-- Standandize Date Format
SELECT sale_date_converted, CONVERT(sale_date, DATE)
FROM Nashville_Housing;

UPDATE Nashville_Housing
SET sale_date = CONVERT(sale_date, DATE);

ALTER TABLE Nashville_Housing
ADD sale_date_converted DATE;

UPDATE Nashville_Housing
SET sale_date_converted = CONVERT(sale_date, DATE);

-- Populate Property Address Data
-- Doesn't work bc mysql has different syntax than sql server
SELECT *
FROM Nashville_Housing
-- WHERE property_address = '';
ORDER BY parcel_id;

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, IFNULL(b.property_address, a.property_address)
FROM Nashville_Housing as a
JOIN Nashville_Housing as b
	ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
WHERE a.property_address = '';

UPDATE Nashville_Housing
SET property_address = IFNULL(b.property_address, a.property_address);

-- Breaking out Address into individual columns (Address, City, State)
-- Property Address
SELECT property_address
FROM Nashville_Housing;
 
SELECT SUBSTRING(property_address,1, LOCATE(',', property_address)-1) as Address, 
	SUBSTRING(property_address,LOCATE(',', property_address) + 1, LENGTH(property_address)) as City
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD property_split_address VARCHAR(255);

UPDATE Nashville_Housing
SET property_split_address = SUBSTRING(property_address,1, LOCATE(',', property_address)-1);

ALTER TABLE Nashville_Housing
ADD property_split_city VARCHAR(255);

UPDATE Nashville_Housing
SET property_split_city = SUBSTRING(property_address,LOCATE(',', property_address) + 1, LENGTH(property_address));

SELECT *
FROM Nashville_Housing;

-- Owner Address
SELECT owner_address
FROM Nashville_Housing;

SELECT SUBSTRING_INDEX(owner_address,',',1) AS Address,
	SUBSTRING(SUBSTRING_INDEX(owner_address,',', 2),LOCATE(',', owner_address) + 1, LENGTH(property_address)) AS City,
     SUBSTRING_INDEX(owner_address,',',-1) AS State
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD owner_split_address VARCHAR(255);

UPDATE Nashville_Housing
SET owner_split_address = SUBSTRING_INDEX(owner_address,',',1);

ALTER TABLE Nashville_Housing
ADD owner_split_city VARCHAR(255);

UPDATE Nashville_Housing
SET owner_split_city = SUBSTRING(SUBSTRING_INDEX(owner_address,',', 2),LOCATE(',', owner_address) + 1, LENGTH(property_address));

ALTER TABLE Nashville_Housing
ADD owner_split_state VARCHAR(255);

UPDATE Nashville_Housing
SET owner_split_state = SUBSTRING_INDEX(owner_address,',',-1);

SELECT *
FROM Nashville_Housing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant)
FROM Nashville_Housing
GROUP BY sold_as_vacant
ORDER BY 2;

SELECT sold_as_vacant, 
	CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		 WHEN sold_as_vacant = 'N' THEN 'No'
         ELSE sold_as_vacant
		 END
FROM Nashville_Housing;

UPDATE Nashville_Housing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		 WHEN sold_as_vacant = 'N' THEN 'No'
         ELSE sold_as_vacant
		 END;

-- Remove Duplicates
WITH row_num_cte AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY parcel_id, property_address,sale_price, sale_date, legal_reference ORDER BY unique_id) as row_num
FROM Nashville_Housing
-- ORDER BY parcel_id
)
DELETE nh
FROM Nashville_Housing as nh
INNER JOIN row_num_cte as r
ON nh.unique_id = r.unique_id
WHERE row_num > 1;
-- ORDER BY property_address;

SELECT *
FROM Nashville_Housing;

-- Delete Unused Columns
SELECT *
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
DROP COLUMN owner_address,
DROP COLUMN tax_district,
DROP COLUMN property_address;

ALTER TABLE Nashville_Housing
DROP COLUMN sale_date;


SET SQL_SAFE_UPDATES = 1;




