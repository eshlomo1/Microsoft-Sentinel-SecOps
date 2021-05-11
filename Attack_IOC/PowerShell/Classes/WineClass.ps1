Class Wine {
    [string]$Name
    [string]$Winery
    [int32]$Year
    [ValidateSet("Red", "White", "Rose")][string]$Color
    [Double]$Price = 0.0

    [string]NiceString(){
                    $wineName = $this.Name
                    $WineYear = $this.Year
                    return "$wineName ($wineyear) is a fine wine."
    }
    [string]NiceString([int]$Rating)
    {
                    $wineName = $this.Name
                    $WineYear = $this.Year
                    return "$wineName ($wineyear) is a fine wine."
    }

    Wine ([string]$WineName)
    {
                    $this.Name = $WineName          
    }
    }
 
$mywine = [Wine]::New('PoshWine')
$myWine.Winery = 'Omaha'

$Duck = [Wine]@{
    Winery = 'Escalante Winery';
    Year = 2003;
    Color = 'White';
    Price = 32
    Name = "Great Duck";
}