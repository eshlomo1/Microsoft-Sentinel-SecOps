$cats = (Get-CMCategory -CategoryType DriverCategories).LocalizedCategoryInstanceName
foreach ($cat in $cats) {  Remove-CMCategory -Name "$cat" -Force -Verbose -CategoryType DriverCategories}
