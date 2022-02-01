/* Data cleaning project */


Select *
From Portofolio.dbo.datacleaning

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE Portofolio.dbo.datacleaning
Add SaleDateConverted Date;

Update Portofolio.dbo.datacleaning
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From Portofolio.dbo.datacleaning


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Portofolio.dbo.datacleaning
Where PropertyAddress is null
order by ParcelID
/* Looking forward we can see that there is some property address missing , and looking our data we know that the parcelID is linked to a property adress
So we are going to set a propertyaddress to a propertyaddress missing when the parcelID is the same between 2 uniqueID */


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portofolio.dbo.datacleaning a
JOIN Portofolio.dbo.datacleaning b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portofolio.dbo.datacleaning a
JOIN Portofolio.dbo.datacleaning b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select *
From Portofolio.dbo.datacleaning
Where PropertyAddress is null
order by ParcelID

-- Now we see that there is no more missing values 

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address (property and owner address) into Individual Columns (Address, City, State)

--Property address cleaning

Select PropertyAddress
From Portofolio.dbo.datacleaning
--Where PropertyAddress is null
--order by ParcelID

alter table Portofolio.dbo.datacleaning
add propertysplitaddress  Nvarchar(255);
update Portofolio.dbo.datacleaning
set propertysplitaddress = parsename(replace(propertyaddress,',','.'),2)


alter table Portofolio.dbo.datacleaning
add propertysplitcity  Nvarchar(255);
update Portofolio.dbo.datacleaning
set propertysplitcity = parsename(replace(propertyaddress,',','.'),1)


select propertysplitaddress,propertysplitcity
from Portofolio.dbo.datacleaning
 







--Owner address cleaning

Select OwnerAddress
From Portofolio.dbo.datacleaning


ALTER TABLE  Portofolio.dbo.datacleaning
Add OwnerSplitAddress Nvarchar(255);
Update Portofolio.dbo.datacleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Portofolio.dbo.datacleaning
Add OwnerSplitCity Nvarchar(255);
Update Portofolio.dbo.datacleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE  Portofolio.dbo.datacleaning
Add OwnerSplitState Nvarchar(255);
Update Portofolio.dbo.datacleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select OwnerSplitAddress, OwnerSplitCity,  OwnerSplitState
From Portofolio.dbo.datacleaning






--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portofolio.dbo.datacleaning
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portofolio.dbo.datacleaning


Update Portofolio.dbo.datacleaning
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portofolio.dbo.datacleaning
Group by SoldAsVacant
order by 2

--We can see that everything is working




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
Select * 
from portofolio.dbo.datacleaning
-- for that we have to find  the variables that should be unique ! for exemple it should not exists 2 uniqueid with the same parcelid,propertyaddress, saledate,saleprice,legalreference

with uniquecte 
as(
select *,
row_number() over ( partition by parcelid,propertyaddress, saledate,saleprice,legalreference order by uniqueid) as row_num
From Portofolio.dbo.datacleaning
)
Select * 
from uniquecte
Where row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete unnecessary Columns


ALTER TABLE Portofolio.dbo.datacleaning
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


Select *
From Portofolio.dbo.datacleaning




