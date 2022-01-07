--data cleaning

--Let observe the data first
select * 
from portfolio_project..Nashville_housingdata$

-- so here i can see that we have dateformate, duplicates , so many null values, date and time togather, and 
--  soldascacant has no,n,yes,y ,so we have to handle this much.

------------------------------------------------------------------------------------------------------------------------

--stardardise date formate
select SaleDate, CONVERT(date,SaleDate) 
from portfolio_project..Nashville_housingdata$

update portfolio_project..Nashville_housingdata$
set SaleDate =CONVERT(date,SaleDate)

----if it doesn't work
------------for date--------------------------------------------------
--step 1. alter table, add new column

ALTER TABLE portfolio_project..Nashville_housingdata$
Add SaleDateConverted Date;

--step 2. update table , set new column by covert(date, actual date column)

Update portfolio_project..Nashville_housingdata$
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- step 3. check , you can also delete old column

select *
from portfolio_project..Nashville_housingdata$
-----------------------------now same for time-----------------------------
ALTER TABLE portfolio_project..Nashville_housingdata$
Add SaletimeConverted time;

Update portfolio_project..Nashville_housingdata$
SET SaletimeConverted = CONVERT(time,SaleDate)

select *
from portfolio_project..Nashville_housingdata$

----------------------------------------------------------------------------------------------------------------------------------------------------

--populate property address data
-- check that you have null value in property address data 

select *
from portfolio_project..Nashville_housingdata$
where PropertyAddress is null

-- there are 29 raws, which have null values . so now we need to handle the null values
-- now lets see the table by parcel id , if we find something 

select *
from portfolio_project..Nashville_housingdata$
where PropertyAddress is null 
order by ParcelID

-- here we can see that parcelid is same, so address should be same for the null value
-- we are going to populate the address where parcelid is same 

--step 1. join the same table with inself where parcelid is same but uniqueid is diffrent 
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolio_project..Nashville_housingdata$ a
join portfolio_project..Nashville_housingdata$ b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]

where a.PropertyAddress is null
--by now you can see that there are 35 raws are null with same parcel id so now we need to populate(copy) address 

--step 2 . now put the condition on slect isnull
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_project..Nashville_housingdata$ a
join portfolio_project..Nashville_housingdata$ b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]

where a.PropertyAddress is null

-- now you can see that we coppied address from b 
-- step 3. let populate address to a, now we need to update table and set the column

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_project..Nashville_housingdata$ a
join portfolio_project..Nashville_housingdata$ b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]
	 where a.PropertyAddress is null


	 -------------------------------------------------------------------------------------------------------------------------------------------------
	 -- breaking address to street , city, state

	 select *-- PropertyAddress
	 from portfolio_project..Nashville_housingdata$

	--- step 1. seprate string using Substring and charactar index 
	-- what is charactar index = it is actully search specific value. Charindex('what you want to search', where you want to search)
	-- if we run without -1 then it return street address with ','.we do not need ',' so we return -1.
	-- substring(where, first position, search)
	--- as same for the right hand side charctar if we use +1 then it dows not take ',' as first letter of the city.
	 select 
	 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
	 SUBSTRING(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

	From portfolio_project..Nashville_housingdata$

	--step 2 .now alter the table and add new column name streetaddress 

	Alter table portfolio_project..Nashville_housingdata$
	add Streetaddress varchar(250)

	--step 3. now update the table and copy the value to that column 

	update portfolio_project..Nashville_housingdata$
	set Streetaddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

	-- step 4. repeat step 2 and step 3 for city column

    Alter table portfolio_project..Nashville_housingdata$
	add propertycity varchar(250)
	
	update portfolio_project..Nashville_housingdata$
	set propertycity=SUBSTRING(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress))
	                              --------------------------------------------

	--another way to breaking address to street and city

	 select *
	 from portfolio_project..Nashville_housingdata$

	--- we have seprate owner address by street, city, state
	--parsename is seprate the address using period('.')
	-- parcename(objectname, period)
	--parsename(replace(where, 'seprated by space or ',','period as '.'',object part as 1,2 or 3)
	select 
	PARSENAME(replace(OwnerAddress,',','.'),1),
	parsename(replace(OwnerAddress,',','.'),2),
	parsename(replace(OwnerAddress,',','.'),3)
	from portfolio_project..Nashville_housingdata$

    Alter table portfolio_project..Nashville_housingdata$
	add ownerstate varchar(250)

	update portfolio_project..Nashville_housingdata$
	set ownerstate = PARSENAME(replace(OwnerAddress,',','.'),1)

	Alter table portfolio_project..Nashville_housingdata$
	add ownercity varchar(250)

	update portfolio_project..Nashville_housingdata$
	set ownercity = PARSENAME(replace(OwnerAddress,',','.'),2)

	Alter table portfolio_project..Nashville_housingdata$
	add ownerstreetaddress varchar(250)

	update portfolio_project..Nashville_housingdata$
	set ownerstreetaddress = PARSENAME(replace(OwnerAddress,',','.'),3)

	---------------------------------------------------------------------------------------------------------------------------------------------
   --change y and N to yes and no 
       Select SoldAsVacant
       ,CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
       From portfolio_project..Nashville_housingdata$

       update portfolio_project..Nashville_housingdata$
       set SoldAsVacant=CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



	   select *
	   from portfolio_project..Nashville_housingdata$

	   -------------------------------------------------------------------------------------------------------------------------------------
	   --remove duplicates

	   /*so here, i am using rownumber fuction to find the duplicates, here i check the duplicates in  ParcelID,PropertyAddress,SalePrice, SaleDate,
	   LegalReference. if it has duplicates then it shows numrow as 2,3 according to repeated data, so i use delete command to delete the duplicate. */
	  with rownumCTE as ( 
	   
	   select * , 
	      ROW_NUMBER() over (
		  partition by ParcelID,PropertyAddress,SalePrice, SaleDate, LegalReference
		  order by UniqueID) row_num
	  
	  from portfolio_project..Nashville_housingdata$

	
	  
	  )
	  Delete from rownumCTE
	  where row_num>1

	  -------------------------------------------------------------------------------------------------------------------------------
	  --delete unused columns
	  select * 
	  from portfolio_project..Nashville_housingdata$

	  Alter table portfolio_project..Nashville_housingdata$
	  drop column OwnerAddress,PropertyAddress, SaleDate,city
	  --------------------------------------------**************************-------------------------------------------------------------
