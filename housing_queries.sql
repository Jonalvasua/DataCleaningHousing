-- DATA CLEANING WITH SQL


-------Standardize Date Format(Column SalesDate imported as DateTime, we need to change it to Date)--------

SELECT * 
  FROM [housing].[dbo].[NashvilleHousing];

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate); -- No changes so we have to creat a new column

ALTER TABLE NashvilleHousing
ADD SaleDataConverted Date;

UPDATE NashvilleHousing
SET SaleDataConverted = CONVERT(Date, SaleDate);

--------------------------Populate Property Address data----------------------------------

-- We have some null values

SELECT *
	FROM [housing].[dbo].[NashvilleHousing]
	WHERE PropertyAddress IS NULL
	ORDER BY ParcelID;

  -- We see thet the ParcelID have the address information so we are going to populate
  
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM [housing].[dbo].[NashvilleHousing] a
	JOIN [housing].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress IS NULL;

-- We update the data

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [housing].[dbo].[NashvilleHousing] a
JOIN [housing].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;





-------------------------Breaking out Adress into individual Columns (Adress, City, State)---------------------

SELECT PropertyAddress
	FROM [housing].[dbo].[NashvilleHousing];

  -- We check all the data and notices that in all cases the adress and city are separated with a , so this is the dellimeter

SELECT 
	  SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1)) AS Address
	  , SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+1), LEN(PropertyAddress)) AS City
	  FROM [housing].[dbo].[NashvilleHousing];


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1));

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+1), LEN(PropertyAddress));




-------------------------------- Now we will change the OwnerAddress column -----------------------------------

SELECT OwnerAddress 
  FROM [housing].[dbo].[NashvilleHousing];

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
  FROM [housing].[dbo].[NashvilleHousing];

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


------------------------ Change 1 and 0 to Yes and No in 'SoldAsVacant' column-------------------------------



SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
  FROM [housing].[dbo].[NashvilleHousing]
  GROUP BY SoldAsVacant;

-- We have to create a new column because SoldAsVacant is a bit column a we need to put strings
ALTER TABLE NashvilleHousing
ADD SoldAsVacant_ NVARCHAR(10);

UPDATE NashvilleHousing
SET SoldAsVacant_ = SoldAsVacant

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant_ = 1 THEN 'Yes'
	WHEN SoldAsVacant_ = 0 THEN 'No'
	ELSE SoldAsVacant_
	END
FROM [housing].[dbo].[NashvilleHousing];

UPDATE NashvilleHousing
SET SoldAsVacant_ = CASE WHEN SoldAsVacant_ = 1 THEN 'Yes'
	WHEN SoldAsVacant_ = 0 THEN 'No'
	ELSE SoldAsVacant_
	END

SELECT DISTINCT SoldAsVacant_, COUNT(SoldAsVacant_)
  FROM [housing].[dbo].[NashvilleHousing]
  GROUP BY SoldAsVacant_;


-------------------------- Remove duplicates with window function ----------------------------------------

WITH RowNumCTE AS(
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
  FROM [housing].[dbo].[NashvilleHousing]
  )
  SELECT * FROM RowNumCTE WHERE row_num > 1;


  WITH RowNumCTE AS(
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
  FROM [housing].[dbo].[NashvilleHousing]
  )
  DELETE FROM RowNumCTE WHERE row_num > 1;



  --------------------------- Delete unused columns that we don't want ---------------------------------------
  SELECT * 
  FROM [housing].[dbo].[NashvilleHousing];

  ALTER TABLE [housing].[dbo].[NashvilleHousing]
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

    ALTER TABLE [housing].[dbo].[NashvilleHousing]
  DROP COLUMN SoldAsVacant, SaleDate;