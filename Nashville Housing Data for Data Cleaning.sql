/*

Cleaning Data in SQL Queries

*/

select * 
from NashvilleHousingDataforDataCleaning..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format 
-- reason - not having time for any row so just keep date for standardize date format

select SaleDate, cast(SaleDate as date) as SaleDateConverted
from NashvilleHousingDataforDataCleaning..NashvilleHousing

alter table NashvilleHousingDataforDataCleaning..NashvilleHousing
alter column SaleDate date

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data - missing values [null]
-- parcelid is same for property address as per data check so we check parcelId with available address and same parcelId for not null address and populate it for data analysis

select *
from NashvilleHousingDataforDataCleaning..NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousingDataforDataCleaning..NashvilleHousing a
join NashvilleHousingDataforDataCleaning..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = b.PropertyAddress
from NashvilleHousingDataforDataCleaning..NashvilleHousing a
join NashvilleHousingDataforDataCleaning..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City) for PropertyAddress

select PropertyAddress,PropertySplitAddress,PropertySplitCity
from NashvilleHousingDataforDataCleaning..NashvilleHousing

select SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
       SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from NashvilleHousingDataforDataCleaning..NashvilleHousing 

alter table NashvilleHousingDataforDataCleaning..NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousingDataforDataCleaning..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) 


alter table NashvilleHousingDataforDataCleaning..NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousingDataforDataCleaning..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) for OwnerAddress

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity,OwnerSplitState
from NashvilleHousingDataforDataCleaning..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as city,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as state
from NashvilleHousingDataforDataCleaning..NashvilleHousing

alter table NashvilleHousingDataforDataCleaning..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousingDataforDataCleaning..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

alter table NashvilleHousingDataforDataCleaning..NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousingDataforDataCleaning..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

alter table NashvilleHousingDataforDataCleaning..NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousingDataforDataCleaning..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant, COUNT(*) 
from NashvilleHousingDataforDataCleaning..NashvilleHousing
group by SoldAsVacant

select SoldAsVacant,
case 
    when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousingDataforDataCleaning..NashvilleHousing

update NashvilleHousingDataforDataCleaning..NashvilleHousing
set SoldAsVacant = case 
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with NashvilleHousingDuplicateFinds 
as (
select *,
     ROW_NUMBER() over(
	 partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	 order by UniqueId
	 )row_num
from NashvilleHousingDataforDataCleaning..NashvilleHousing
)
select * 
from NashvilleHousingDuplicateFinds
where row_num >1
order by PropertyAddress

--delete 
--from NashvilleHousingDuplicateFinds
--where row_num >1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

alter table NashvilleHousingDataforDataCleaning..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

