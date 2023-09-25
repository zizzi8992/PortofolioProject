/* 
CLEANING DATA
*/

SELECT*
FROM [PortofolioProject].[dbo].[NashvilleHousing]

/* Standarize date format */
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [PortofolioProject].[dbo].[NashvilleHousing]

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM [PortofolioProject].[dbo].[NashvilleHousing]

/* Populated property address data */
SELECT *
FROM [PortofolioProject].[dbo].[NashvilleHousing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [PortofolioProject].[dbo].[NashvilleHousing] A
JOIN [PortofolioProject].[dbo].[NashvilleHousing] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [PortofolioProject].[dbo].[NashvilleHousing] A
JOIN [PortofolioProject].[dbo].[NashvilleHousing] B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

/* Breaking out PropertyAddress into individual columns (address, city) */
SELECT PropertyAddress
FROM [PortofolioProject].[dbo].[NashvilleHousing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [PortofolioProject].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM [PortofolioProject].[dbo].[NashvilleHousing]

/* Breaking out OwnerAddress into individual columns (address, city, state) */
SELECT OwnerAddress
FROM [PortofolioProject].[dbo].[NashvilleHousing]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [PortofolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortofolioProject].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [PortofolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [PortofolioProject].[dbo].[NashvilleHousing]
ADD OwnerSplitCity nvarchar(255);

UPDATE [PortofolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [PortofolioProject].[dbo].[NashvilleHousing]
ADD OwnerSplitState nvarchar(255);

UPDATE [PortofolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [PortofolioProject].[dbo].[NashvilleHousing]

/* Changing Y and N to yes and no in 'sold as vacant' field */
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortofolioProject].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM [PortofolioProject].[dbo].[NashvilleHousing] 

UPDATE [PortofolioProject].[dbo].[NashvilleHousing] 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

/* Looking for duplicates */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
						) row_num
FROM [PortofolioProject].[dbo].[NashvilleHousing] 
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1

/* Remove duplicates */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
						) row_num
FROM [PortofolioProject].[dbo].[NashvilleHousing] 
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

/* Delete unnecessary columns */
SELECT*
FROM [PortofolioProject].[dbo].[NashvilleHousing]

ALTER TABLE [PortofolioProject].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortofolioProject].[dbo].[NashvilleHousing]
DROP COLUMN SaleDate