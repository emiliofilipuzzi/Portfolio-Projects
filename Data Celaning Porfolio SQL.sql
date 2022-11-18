--CLEANING DATA IN SQL QUERIES
--Limpieza de Datos en SQL


SELECT *
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------
--STANDARIZE DATA FORMAT
--Estandariza el Formato de los Datos.

SELECT SaleDateConerted, CONVERT(date,SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
add SaleDateConerted Date;

Update NashvilleHousing
set SaleDateConerted = CONVERT(date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------------
--Populate property Adress data
--Com`pletar los datos de la direccion de la propiedades

SELECT *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Update the data in the table
--Actualizar los datos en la tabla

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------

--Breaking out adress into Indvidual Columns (Address, City, State)
--Dividir la dirección en columnas individuales (Dirección, Ciudad, Estado)

SELECT *
FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) as Adress
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Adress

FROM PortfolioProject..NashvilleHousing

-- 2 new columns
--Creamos 2 Nuevas columnas

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
From PortfolioProject..NashvilleHousing

select
parsename(REPLACE(OwnerAddress, ',', '.') ,3)
,parsename(REPLACE(OwnerAddress, ',', '.') ,2)
,parsename(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID

-- 3 new columns
--Creamos 3 Nuevas columnas

ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress= parsename(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState  = parsename(REPLACE(OwnerAddress, ',', '.') ,1)

--------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to YES AND NO IN "Sold as Vacant" filed

Select distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant
, case when SoldAsVacant = 'Y' then 'YES'
	   when SoldAsVacant = 'N' then 'NO'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
	   when SoldAsVacant = 'N' then 'NO'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------------

--Romove Duplicates
--Remover los datos duplicados

WITH RowNumCTE as (
SELECT	*,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing
--order by ParcelID
)
Select * 
--DELETE
FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------- 

--Delete Unused Columns
--Eliminar las columnas que no usamos.

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate




