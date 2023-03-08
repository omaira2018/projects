
-- POPULATING PROPERTY ADDRESSES THAT ARE NULL

select * from data_1 
where PropertyAddress = '';


select nullif (PropertyAddress, '') as PropertyAddress from data_1;

update data_1 set PropertyAddress = NULL where PropertyAddress = '';

select * from data_1
where PropertyAddress is NULL;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
from data_1 a join data_1 b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID -- ensuring both are not the same row 
where a.PropertyAddress is null

-- updating the table 

UPDATE data_1 a 
JOIN data_1 b 
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

select * from data_1 where PropertyAddress is null;

-- Explanation:

/* UPDATE data_1 a specifies the table data_1 to be updated and a as an alias for this table.
JOIN data_1 b joins the same table data_1 to itself using the alias b.
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID specifies the condition to join the two tables, i.e. join the rows where ParcelID is the same but UniqueID is different.
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress) updates the PropertyAddress column of table a by using the IFNULL function to check if the PropertyAddress column of table a is null, and if it is, then set it to the value of the PropertyAddress column of table b.
WHERE a.PropertyAddress IS NULL specifies the condition to update only the rows where PropertyAddress in table a is null.
*/

-------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out address into individual columns (Address, city, state)


select PropertyAddress
from data_1;


select 
SUBSTRING(PropertyAddress, 1, locate(',',PropertyAddress)) as address
from data_1


-- explanation 
/* SUBSTRING function is used to extract a substring from the PropertyAddress column. The first argument is the column name, the second argument is the starting position (in this case, 1), and the third argument is the length of the substring. The third argument is calculated using the LOCATE function.
LOCATE(',', PropertyAddress) function returns the position of the first occurrence of the comma (",") in the PropertyAddress column.*/

-- now since locate is returning a number and we want to avoid ',' so we do -1 

select 
SUBSTRING(PropertyAddress, 1, locate(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, locate(',',PropertyAddress)+1, LENGTH(PropertyAddress)) as city
from data_1


-- adding columns 

alter table data_1
add PropertyAddressSplit varchar(255)

Update data_1
set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, locate(',',PropertyAddress)-1);

alter TABLE data_1
add PropertyCity VARCHAR(255)

UPDATE data_1
set PropertyCity = SUBSTRING(PropertyAddress, locate(',',PropertyAddress)+1, LENGTH(PropertyAddress))

select * from data;


-- alternative method

select OwnerAddress
from data_1;

SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', -1) AS address1,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS address2,
SUBSTRING_INDEX(OwnerAddress, ',', 1) AS address3
FROM data_1;



/*SUBSTRING_INDEX function is used to extract parts of the string based on the delimiter (comma in this case).
The first address is extracted using SUBSTRING_INDEX with a negative index of -1 to get the last part of the string.
The second address is extracted using SUBSTRING_INDEX with a nested SUBSTRING_INDEX to get the second-to-last part of the string, and then the first part of that using an index of 1.
The third address is extracted using SUBSTRING_INDEX with a positive index of 2 to get the first two parts of the string..*/

--------------------------


-- change y and n to yes and no respectively 

select DISTINCT(SoldAsVacant)
from data_1


 SELECT SoldAsVacant,
 case WHEN SoldAsVacant = 'N' Then 'No'
 When SoldAsVacant = 'Y' Then 'Yes'
 else SoldAsVacant
 end 
 from data_1
 
 UPDATE data_1
 Set SoldAsVacant =  case WHEN SoldAsVacant = 'N' Then 'No'
 When SoldAsVacant = 'Y' Then 'Yes'
 else SoldAsVacant
 end 
 
  
-- Remove Duplicates


With RownNumCte as ( 
select *, ROW_NUMBER() over (
Partition By ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order BY
UniqueID
) row_num
from data_1
)

DELETE
from RownNumCte
where row_num > 1 







