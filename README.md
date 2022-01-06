**This is home value data for the hot Nashville market.** There are 56,000+ rows altogether. 



# Nashville-Housing-Data-Cleaning-Project-using-SQL Server Management Studio

 SELECT *
FROM NashvilleProject..NashvilleHousing

----- Standardize Date Format

SELECT saleDate 
FROM NashvilleProject..NashvilleHousing

SELECT saleDate, CONVERT(Date,SaleDate)
FROM NashvilleProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

-----Converted successuflly by using ALTER TABLE queri..
ALTER TABLE NashvilleHousing
ADD NewSaleDate Date;

Update NashvilleHousing 
set NewSaleDate = CONVERT(Date,SaleDate)

--Now let's check for the converted new Date
SELECT NewSaleDate
FROM NashvilleProject..NashvilleHousing

----------------------------------------------------------------------------------
-- Populate Property Address data

SELECT PropertyAddress
FROM NashvilleProject..NashvilleHousing
where PropertyAddress is null

----Look at everything for Null value in PropertyAddress

Select *
FROM NashvilleProject..NashvilleHousing
where PropertyAddress is null

----Now let's look using PercelID
Select *
FROM NashvilleProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

---We found lot of same data in the table, for instance, a same Parcel ID with same Property adress for a particular ID and address.
----Resolution - If this Parcel ID# 018 07 0 142.00 have an address# 301  MYSTIC HILL DR, GOODLETTSVILLE, and this Parcel ID# 018 07 0 142.00 doesnot have address, then, let's populate with lis address#301  MYSTIC HILL DR, GOODLETTSVILLE.

-----First we need to JOIN the table Parcel ID and PropertyAddress.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleProject..NashvilleHousing a
JOIN NashvilleProject..NashvilleHousing b
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
FROM NashvilleProject..NashvilleHousing a
JOIN NashvilleProject..NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----It's done, and let's cross check what has transformed...

Select *
FROM NashvilleProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

----------------------------------------------------------------------------------------------------------------------
