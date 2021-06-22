/*

 Nettoyage de données avec SQL

*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------

--1. Afficher la date sous format standard avec CONVERT

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

----------------------------------------------------------------------------------------------------------------

--2. Peupler les données de PropertyAdress

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID 

SELECT a.ParcelID, a.PropertyAddress, B.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------

--3. Diviser PropertyAddress en colonnes individuelles (Adress, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

-- Formule:

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing

--Ajout des tables:

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--3. Diviser OwnerAddress en colonnes individuelles (Adress, City, State)

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

-- Avec la fonction PARSENAME:

SELECT
PARSENAME(REPLACE (OwnerAddress,',','.') ,3),
PARSENAME(REPLACE (OwnerAddress,',','.') ,2),
PARSENAME(REPLACE (OwnerAddress,',','.') ,1)
FROM PortfolioProject..NashvilleHousing

-- Ajout des tables:

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress,',','.') ,3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress,',','.') ,2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress,',','.') ,1)

SELECT *
FROM PortfolioProject..NashvilleHousing
----------------------------------------------------------------------------------------------------------------

--5. Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

-- Avec CASE:

SELECT SoldAsVacant,
	(CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END)
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant =
	(CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END)

----------------------------------------------------------------------------------------------------------------

--6. Retirer les doublons

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER()	OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------

--7. Supprimer les colonnes inutilisées

SELECT * 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate










