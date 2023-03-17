--Cleaning data in SQL

Select *
From master.dbo.NashvilleHousing

-- Standardize Data Format

Select SaleDateConverted, Convert(Date,SaleDate)
From master.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)



--Populate Property Address Data

Select *
From master.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From master.dbo.NashvilleHousing a
Join master.dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From master.dbo.NashvilleHousing a
Join master.dbo.NashvilleHousing b
		on a.ParcelID = b.ParcelID
		and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking out Address into Individual Cloumns (Address, City, State)

Select PropertyAddress
From master.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select
Substring(PropertyAddress, 1,Charindex(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) as Address

From master.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1,Charindex(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress))



Select *
From master.dbo.NashvilleHousing


Select OwnerAddress
From master.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From master.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From master.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From master.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From master.dbo.NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

-- Remove Duplicates

With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by 
					UniqueID
					) row_num

From master.dbo.NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--order by PropertyAddress


Select *
From master.dbo.NashvilleHousing

-- Delete Unused Columns

Select *
From master.dbo.NashvilleHousing

Alter Table master.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table master.dbo.NashvilleHousing
Drop column SaleDate