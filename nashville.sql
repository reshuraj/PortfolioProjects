SELECT *
FROM portfolioprojects.dbo.nashvillehousing

-----------------------------------------------------------------------------
--standardize date format

SELECT SaleDate, CONVERT(DATE, SaleDate) 
FROM portfolioprojects.dbo.nashvillehousing

UPDATE portfolioprojects.dbo.nashvillehousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE portfolioprojects.dbo.nashvillehousing
ADD SaleDateConverted DATE;

UPDATE portfolioprojects.dbo.nashvillehousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-----------------------------------------------------------------------------
--populate Property Address data

SELECT *
FROM portfolioprojects.dbo.nashvillehousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ] , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioprojects.dbo.nashvillehousing a
JOIN portfolioprojects.dbo.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolioprojects.dbo.nashvillehousing a
JOIN portfolioprojects.dbo.nashvillehousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------------------------
--breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM portfolioprojects.dbo.nashvillehousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
FROM portfolioprojects.dbo.nashvillehousing


ALTER TABLE portfolioprojects.dbo.nashvillehousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE portfolioprojects.dbo.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE portfolioprojects.dbo.nashvillehousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE portfolioprojects.dbo.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



SELECT *
FROM portfolioprojects.dbo.nashvillehousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM portfolioprojects.dbo.nashvillehousing

ALTER TABLE portfolioprojects.dbo.nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE portfolioprojects.dbo.nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)


ALTER TABLE portfolioprojects.dbo.nashvillehousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE portfolioprojects.dbo.nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)


ALTER TABLE portfolioprojects.dbo.nashvillehousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE portfolioprojects.dbo.nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)



---------------------------------------------------------------------------------------------------
--change Y and N to Yes and No in 'SoldAsVacant' field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioprojects.dbo.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM portfolioprojects.dbo.nashvillehousing


UPDATE portfolioprojects.dbo.nashvillehousing
SET	SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------------------------------------------
--remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   )row_num

FROM portfolioprojects.dbo.nashvillehousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


----------------------------------------------------------------------------------------------------------------
--delete unused columns


SELECT *
FROM portfolioprojects.dbo.nashvillehousing

ALTER TABLE portfolioprojects.dbo.nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolioprojects.dbo.nashvillehousing
DROP COLUMN SaleDate