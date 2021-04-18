class Helper
{
    [HashTable] Splat([String[]] $Properties)
    {
        $splat = @{}

        foreach($prop in $Properties)
        {
            if($this.GetType().GetProperty($prop))
            {
                if ($this.$prop){
                    $splat.Add($prop, $this.$prop)
                }
            }
        }

        return $splat
    }
}

class Action : Helper
{
    [string]$Execute
    [string]$Argument
    [string]$WorkingDirectory

    Action ()
    {

    }
}

function Get-Meaning ($Name, $Answer)
{
    "The meaning of {0} is {1}." -f $Name, $Answer
}