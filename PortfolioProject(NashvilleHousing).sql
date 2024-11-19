--Select *
--from PortfolioProject..NashvilleHousing

Select SaleDateConverted,Convert(Date,SaleDate) 
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET Saledateconverted = Convert(Date,SaleDate)

--Populate Property Address Date

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select Parc.ParcelID,Parc.PropertyAddress,PA.ParcelID,PA.PropertyAddress
,ISNULL(Parc.PropertyAddress,PA.PropertyAddress)
From PortfolioProject..NashvilleHousing As Parc
JOIN PortfolioProject..NashvilleHousing As PA
On Parc.ParcelID = PA.ParcelID
 AND Parc.[UniqueID ] <> PA.[UniqueID ]
 Where Parc.PropertyAddress is null

 UPDATE Parc
 SET PropertyAddress = ISNULL(Parc.PropertyAddress,PA.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing AS Parc
 JOIN PortfolioProject..NashvilleHousing AS PA
 ON Parc.ParcelID = PA.ParcelID
  AND Parc.[UniqueID ] <> PA.[UniqueID ]
  Where Parc.PropertyAddress is null


--Breaking out address into individual columns(Address, City, State)

Select Propertyaddress
From PortfolioProject..NashvilleHousing
--Where propertyaddress is null 
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))AS Address
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
FROM PortfolioProject..NashvilleHousing

SELECT Owneraddress
FROM PortfolioProject..NashvilleHousing

--Using PARSENAME

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
    When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
    Else SoldAsVacant
END 
From PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
                   END
From PortfolioProject..NashvilleHousing

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
  ROW_Number() OVER(
      PARTITION BY ParcelID,
	               PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   ORDER BY
				     UniqueID
					 ) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
) 
Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETE Duplicates

WITH RowNumCTE AS(
SELECT *,
  ROW_Number() OVER(
      PARTITION BY ParcelID,
	               PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   ORDER BY
				     UniqueID
					 ) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
) 
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--DELETE Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate


