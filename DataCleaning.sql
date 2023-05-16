/*
Cleaning Data in SQL Quries
*/
Select * from PortfolioProject.dbo.nationalhousing
-----------------------------------------------------------------------------------------------------------------------------------------
---Stabdardize Date FOrmat

Select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.nationalhousing


--- This Update function works 20% times only 
Update nationalhousing
SET SaleDate = CONVERT(Date,SaleDate)

--- Hence we are using Alter Table

ALTER Table nationalhousing
Add SaleDateConverted Date;

Update nationalhousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


Select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.nationalhousing
--------------------------------------------------------------------------------------------------------------------------------------------------------
--- Populate Property Address Data
Select *
from PortfolioProject.dbo.nationalhousing
--where PropertyAddress is Null
order by ParcelID

-- here parcel no and property address are some null and we are going merged them
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.nationalhousing a
JOIN PortfolioProject.dbo.nationalhousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.nationalhousing a
JOIN PortfolioProject.dbo.nationalhousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------
--- Breaking Out Address into Individual Columns (Address, City, State)
Select PropertyAddress
from PortfolioProject.dbo.nationalhousing
--where PropertyAddress is Null
--order by ParcelID
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) As Address
from PortfolioProject.dbo.nationalhousing
-- what it is doing is starting from 1 value and going till comma in property address
---but we dont need comma in end of every address so we need to replace one
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) As Address,CHARINDEX(',',PropertyAddress)
from PortfolioProject.dbo.nationalhousing
-- we are using charindex to check index number on which , is present which 25 aas per that but we can use in charindex like below to remove the same
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1,LEN(PropertyAddress)) As City
from PortfolioProject.dbo.nationalhousing

ALTER Table nationalhousing
Add PropertyAddresss NVARCHAR(255);

Update nationalhousing
SET PropertyAddresss = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER Table nationalhousing
Add City NVARCHAR(255);

Update nationalhousing
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1,LEN(PropertyAddress))

Select *
from PortfolioProject.dbo.nationalhousing

----------------------------------------------------------------------------------------------------------------------------------------------
--- Owners Address
Select OwnerAddress
from PortfolioProject.dbo.nationalhousing
where OwnerAddress is not null

Select
Parsename(REPLACE(OwnerAddress, ',','.'),3) as Adress,
Parsename(REPLACE(OwnerAddress, ',','.'),2) as City,
Parsename(REPLACE(OwnerAddress, ',','.'),1) as States
from PortfolioProject.dbo.nationalhousing
where OwnerAddress is not null

ALTER Table nationalhousing
Add OwnerPropertyAddresss NVARCHAR(255);

Update nationalhousing
SET OwnerPropertyAddresss = Parsename(REPLACE(OwnerAddress, ',','.'),3)

ALTER Table nationalhousing
Add OwnerCity NVARCHAR(255);

Update nationalhousing
SET OwnerCity = Parsename(REPLACE(OwnerAddress, ',','.'),2)

ALTER Table nationalhousing
Add OwnerState NVARCHAR(255);

Update nationalhousing
SET OwnerState = Parsename(REPLACE(OwnerAddress, ',','.'),1)

Select *
from PortfolioProject.dbo.nationalhousing

-----------------------------------------------------------------------------------------------------------------------------------
---- Change Y and N to Yes and No in SOld as Vacant Field
select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.nationalhousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'YES'
When SoldASVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
from PortfolioProject.dbo.nationalhousing


Update nationalhousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
When SoldASVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

------------------------------------------------------------------------------------------------------------------------------------
---- Remove Duplicate

--- Below one shows all Duplicate
With ROWNUMCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress,SaleDate,LegalReference
ORDER By UniqueID) row_num
from PortfolioProject.dbo.nationalhousing
--order by ParcelID
)
Select *
from ROWNUMCTE
where row_num>1
Order by PropertyAddress

--- Now to Delete Duplicate we use Deletefunction
With ROWNUMCTE AS(
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress,SaleDate,LegalReference
ORDER By UniqueID) row_num
from PortfolioProject.dbo.nationalhousing
--order by ParcelID
)
Delete
from ROWNUMCTE
where row_num>1
------------------------------------------------------------------------------------------------------------------------------------
-- Select Unused Columns
Select *
from PortfolioProject.dbo.nationalhousing

Alter Table PortfolioProject.dbo.nationalhousing
Drop COLUMN OwnerAddress, PropertyAddress
Alter Table PortfolioProject.dbo.nationalhousing
Drop COLUMN SaleDate