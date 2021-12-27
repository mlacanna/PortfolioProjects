--Cleaning Data In SQL Queries

Select *
From PortfolioProjects.dbo.NashvilleHousing

------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, SaleDate
From PortfolioProjects.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


----------------------------------------------------------------------

--Populate Property Adress data, check to see if there is any null variables

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- updating the address

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects..NashvilleHousing a
Join PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


------------------------------------------------------------------------

-- Breaking out Address into individual Coulmns (address, City, State)

Select PropertyAddress
From PortfolioProjects..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress))



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProjects..NashvilleHousing



ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-----------------------------------------------------------------------------

-- Y and N to Yes and No in "sold in vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects..NashvilleHousing
Group by SoldasVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From PortfolioProjects..NashvilleHousing

Update PortfolioProjects..NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

--------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
From PortfolioProjects.dbo.NashvilleHousing
)

DELETE
From RowNumCTE
Where row_num >1
Order By PropertyAddress



Select *
From PortfolioProjects.dbo.NashvilleHousing


----------------------------------------------------------------

--Delete Unused Columns

Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop COLUMN SaleDate