SELECT * 
FROM nashvillehousing;

-- Standardize Date Format

Alter Table nashvillehousing
Add Column SaleDateFormatted Date;

Update nashvillehousing
Set SaleDateFormatted = STR_TO_DATE(SaleDate, '%M %e, %Y');

Select SaleDate, SaleDateFormatted
From nashvillehousing
Limit 10;

-- Populate Property Address Data

Select *
From nashvillehousing
-- Where PropertyAddress is null
Order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
From nashvillehousing a
Join nashvillehousing b
On a.ParcelID = b.ParcelID
And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

Update nashvillehousing a 
Join nashvillehousing b
On a.ParcelID = b.ParcelID
And a.UniqueID <> b.UniqueID
Set a.PropertyAddress = b.PropertyAddress
Where a.PropertyAddress is null;

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From nashvillehousing;

Select
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, length(PropertyAddress)) AS Address
From nashvillehousing;


Alter Table nashvillehousing
Add Column PropertySplitAddress varchar(255);

Update nashvillehousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);


Alter Table nashvillehousing
Add Column PropertySplitCity varchar(255);

Update nashvillehousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, length(PropertyAddress));

Select *
From nashvillehousing;

Select 
SUBSTRING_INDEX(OwnerAddress, ',', 1),
TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1))
From nashvillehousing;

Alter Table nashvillehousing
Add Column OwnerSplitAddress varchar(255);

Update nashvillehousing
Set OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

Alter Table nashvillehousing
Add Column OwnerSplitCity varchar(255);

Update nashvillehousing
Set OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

Alter Table nashvillehousing
Add Column OwnerSplitState varchar(255);

Update nashvillehousing
Set OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillehousing
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
     END
From nashvillehousing;

Update nashvillehousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
     END;
     
-- Remove Duplicates

With RowNumCTE As (
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
From nashvillehousing
-- Order by ParcelID
)
Select * 
From RowNumCTE
Where row_num >1;

Delete nh
From nashvillehousing nh
Join (
  Select UniqueID
  From (
    Select 
      UniqueID,
      ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
      ) As row_num
    From nashvillehousing
  ) As ranked
  Where row_num > 1
) As duplicates
On nh.UniqueID = duplicates.UniqueID;

-- Delete Unused Columns

Select *
From nashvillehousing;

Alter Table nashvillehousing
Drop column OwnerAddress, 
Drop column TaxDistrict, 
Drop column PropertyAddress;










