$VerbosePreference = 'Continue'

#Workflow for multi threading
workflow _Workflow
{
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]  
        [Array]$Entries
    )
    
    # Run multiple items from array at the same time
    foreach -parallel -throttle 5 ($Entry in $Entries)
    {
        # Run code story result in Result_Total
        $Workflow:Result_Total += InlineScript
        {
            $Entry = $Using:Entry

            Write-Verbose -Message $Entry


            Return $Entry
        }
    }

    $Result_Total
}

$a = (1..1000)

# Executing workflow
$Output = _Workflow -Entries $a
