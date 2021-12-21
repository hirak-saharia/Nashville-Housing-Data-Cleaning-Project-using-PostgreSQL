SELECT *
FROM NashvilleProject.dbo.NashvilleHousing

----- Standardize Date Format

SELECT saleDate 
FROM NashvilleProject.dbo.NashvilleHousing

SELECT saleDate, CONVERT(Date,SaleDate)
FROM NashvilleProject.dbo.NashvilleHousing

update NashvilleProject.dbo.NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

-----Converted successuflly by using ALTER TABLE queri..
ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD NewSaleDate Date;

Update NashvilleProject.dbo.NashvilleHousing
set NewSaleDate = CONVERT(Date,SaleDate)

--Now let's check for the converted new Date
SELECT NewSaleDate
FROM NashvilleProject..NashvilleHousing

----------------------------------------------------------------------------------
-- Populate Property Address data

SELECT PropertyAddress
FROM NashvilleProject.dbo.NashvilleHousing
where PropertyAddress is null

----Look at everything for Null value in PropertyAddress

Select *
FROM NashvilleProject.dbo.NashvilleHousing
where PropertyAddress is null

----Now let's look using PercelID
Select *
FROM NashvilleProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

---We found lot of same data in the table, for instance, a same Parcel ID with same Property adress for a particular ID and address.
----Resolution - If this Parcel ID# 018 07 0 142.00 have an address# 301  MYSTIC HILL DR, GOODLETTSVILLE, and this Parcel ID# 018 07 0 142.00 doesnot have address, then, let's populate with lis address#301  MYSTIC HILL DR, GOODLETTSVILLE.

-----First we need to JOIN the table Parcel ID and PropertyAddress.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleProject.dbo.NashvilleHousing a
JOIN NashvilleProject.dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID]
   where a.PropertyAddress is null

---Now puts the b.PropertyAddress in a.PropertyAddress to fill Null vlaues

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleProject..NashvilleHousing a
JOIN NashvilleProject..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleProject.dbo.NashvilleHousing a
JOIN NashvilleProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----It's done, and let's cross check what has transformed...

Select *
FROM NashvilleProject.dbo.NashvilleHousing
where PropertyAddress is null
--order by ParcelID

----------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-----Ways-1 Which is the hard one to split address....

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From NashvilleProject.dbo.NashvilleHousing


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From NashvilleProject.dbo.NashvilleHousing

----Similary we have to break out for Owner Address also....

-----Let's split with a very easy way by PERSING method....

Select OwnerAddress
FROM NashvilleProject.dbo.NashvilleHousing

----Now we need to seperate address, city and State...

Select 
PARSENAME(Replace(OwnerAddress,',','.') , 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM NashvilleProject.dbo.NashvilleHousing

-----Update Table for Address.....
ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

---------Update Table for City..........
ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


-------Update table for State........
ALTER TABLE NashvilleProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

---------Now let's check what we have implemanted....

SELECT *
FROM NashvilleProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant
FROM NashvilleProject.dbo.NashvilleHousing

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2
--------Now let's change them to "Yes" and "No" from "Y" and "N"......

SELECT SoldAsVacant 
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
FROM NashvilleProject.dbo.NashvilleHousing

-----Now let's update it....

UPDATE NashvilleProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
------Check if its updated....

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

----------------------------------------------------------------------------------------------------------------

----REMOVE DUPLICATES.....

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleProject.dbo.NashvilleHousing
--order by ParcelID
)
--DELETE
SELECT *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

----CHECK---
SELECT *
FROM NashvilleProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------
-- Delete Unused Columns



Select *
From NashvilleProject.dbo.NashvilleHousing


ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate








