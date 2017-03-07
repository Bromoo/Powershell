function _Copy-ADuserAttributes
{
<# 
.Synopsis 
    Resolve the SourceUser and TargetUser and copy the specified Object Attributes

    Can be used with _Resolve-ADuser function
.DESCRIPTION 
    This function copies a specified array of ADuser-object Attributes and set the attributes on the target user.

    The _Resolve-ADuser can be used in combination with this function for easy searches.

    If the _Resolve-ADuser function is not present the function will use the Get-ADuser command accepting only default input.
.PARAMETER SourceIdentity 
    Input User where attributes need to be copied FROM
.PARAMETER TargetIdentity 
    Input User where attributes need to be copied TO
.PARAMETER Properties 
    SPecify what properties need to be copied
.PARAMETER OU 
    Specify the SearchBase for the search
.PARAMETER DC 
    Specify the domaincontroller to do the search from
.EXAMPLE 
    _Copy-ADuserAttributes -SourceIdentity SchafferPS -TargetIdentity "Doe, J (Jane)" -Properties ('Description','ExtensionAttribute5') -OU 'OU=Users,OU=Domain OU,DC=Company,DC=com' -DC DC001
#>
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$SourceIdentity,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$TargetIdentity,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Array]$Properties,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$OU = "DC=" + (([system.directoryservices.activedirectory.domain]::GetCurrentDomain()).name).Replace(".",",DC="),
    
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$DC = ([system.directoryservices.activedirectory.domain]::GetCurrentDomain()).name
    )

    $Valid       = $false
    $SourceUser  = $false
    $TargetValid = $false

    # Resolve Source user
    If (Get-Command _Resolve-ADuser)
    {
        $SourceUser     = _Resolve-ADUser -Identity $SourceIdentity -Properties $Properties -DC $DC -OU $OU
        $TargetInstance = _Resolve-ADUser -Identity $TargetIdentity -Properties $Properties -DC $DC -OU $OU

        If ($SourceUser -and $TargetInstance)
        {
            $Valid = $true
        }
    }
    Else
    {
        $SourceUser =  Get-ADUser -Filter $SourceIdentity -Properties $Properties -SearchBase $OU -Server $DC
        If ($SourceUser)
        {
            $SourceValid = $true
        }

        $TargetInstance =  Get-ADUser -Identity $TargetIdentity -Properties $Properties -SearchBase $OU -Server $DC
        If ($TargetInstance)
        {
            $TargetValid = $true
        }
    }

    # Copy attributes to targetuser
    If (($Valid) -or ($SourceValid -and $TargetValid))
    {
        $Properties | %{
            $Attribute = $_
            $TargetInstance.$Attribute = $SourceUser.$Attribute
        }

        Set-ADUser -Instance $TargetInstance
        Write-Verbose -Message "Copy completed"
    }
    Else
    {
        Write-Verbose -Message "Copy Failed"
    }
}
