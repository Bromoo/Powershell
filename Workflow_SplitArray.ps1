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
            $Entry        = $Using:Entry
            $Result_Inner = @()

            foreach ($Item in $Entry)
            {
                Write-Verbose -Message $Item

                $Result_Inner += $Item
            }

            Return $Result_Inner
        }
    }

    $Result_Total
}

function Split-array 
{
    <#  
    .SYNOPSIS   
    Split an array
    .PARAMETER inArray
    A one dimensional array you want to split
    .EXAMPLE  
    Split-array -inArray @(1,2,3,4,5,6,7,8,9,10) -parts 3
    .EXAMPLE  
    Split-array -inArray @(1,2,3,4,5,6,7,8,9,10) -size 3
    #> 

    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]  
        [Array]$inArray,

        [Parameter(Mandatory=$false)] 
        [ValidateNotNullOrEmpty()]  
        [Int]$Parts,

        [Parameter(Mandatory=$false)] 
        [ValidateNotNullOrEmpty()]  
        [Int]$Size
    )

    if ($Parts) {
        $PartSize = [Math]::Ceiling($inArray.count / $parts)
    } 
    if ($size) {
        $PartSize = $size
        $Parts    = [Math]::Ceiling($inArray.count / $size)
    }

    $outArray = New-Object 'System.Collections.Generic.List[psobject]'

    for ($i=1; $i -le $parts; $i++)
    {
        $Start = (($i-1)*$PartSize)
        $End   = (($i)  *$PartSize) - 1

        If ($End -ge $inArray.count)
        {
            $End = $inArray.count -1
        }
        
        $outArray.Add(@($inArray[$Start..$End]))
    }
    
    return ,$outArray
}

$a = (1..1000)

$b = Split-array -inArray $a -Parts 5

# Executing workflow
$Output = _Workflow -Entries $b
