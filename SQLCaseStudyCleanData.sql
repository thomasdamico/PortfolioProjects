/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashVilleHousing

-- Standardize Date Format

Select SaleDateConverted
From PortfolioProject..NashVilleHousing

Update NashVilleHousing
SET SaleDate = CONVERT(Date, Saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashVilleHousing
SET SaleDateConverted = CONVERT(Date, Saledate)

-- Populate the propriety adress data

Select *
From PortfolioProject..NashVilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Owner Adress into Individual Columns (Adress, City, State)


--Elaborate Methoud
SELECT 
  SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1) AS Adress,
  SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress)+1)-CHARINDEX(',', OwnerAddress)-1) AS City,
  SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress)+1)+1, LEN(OwnerAddress)-CHARINDEX(',', REVERSE(OwnerAddress))) AS State

From PortfolioProject..NashVilleHousing

ALTER TABLE NashvilleHousing
Add AddressNew nvarchar(255),
CityNew nvarchar(255),
StateNew nvarchar(255);

--Smart one
UPDATE NashVilleHousing 
SET AddressNew = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    CityNew = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
    StateNew = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..NashVilleHousing

-- CHANGE Y AND N IN Yes and No in "SoldASVacant" field

Select DISTINCT(SoldAsVacant)
From PortfolioProject..NashVilleHousing

Select SoldAsVacant,
Case WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashVilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--- REMOVE DUPLICATES

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashVilleHousing
)
--ORDER BY ParcelID
SELECT *
FROM RowNumCTE
WHERE row_num>1

-- REMOVE UNUSED COLUMNS

SELECT *
From PortfolioProject..NashVilleHousing

ALTER TABLE PortfolioProject..NashVilleHousing
DROP COLUMN SaleDate