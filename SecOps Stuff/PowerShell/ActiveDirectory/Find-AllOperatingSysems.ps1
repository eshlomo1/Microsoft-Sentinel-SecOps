Get-ADComputer -Filter * -Properties * | select OperatingSystem -Unique
