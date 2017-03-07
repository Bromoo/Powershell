function _Resolve-ADuser
{
<# 
.Synopsis 
    Resolve a user Get-ADuser from active directory
.DESCRIPTION 
    Resolve a user from Active Directory with a switch that automaticly selects the filter depending on the input.
    Filters:
        *(*
            If string contains the ( the Searchfilter will look for the Name property
        *@*
            If string contains the ( the Searchfilter will look for the Mail property
        *300*
            If string contains the ( the Searchfilter will look for the user ID property
        Default
            Search for the accountname if none of the filters apply

    The function will return the ADobject or nothing
.PARAMETER Identity 
    Input search string 
.PARAMETER Properties 
    Search for specific properties for the AD account (default is *)
.PARAMETER OU 
    Specify the SearchBase for the search
.PARAMETER DC 
    Specify the domaincontroller to do the search
.EXAMPLE 
    _Resolve-ADuser -Identity 'Doe, J (Jane)' -Properties ExtensionAttribute5 -OU 'OU=Users,OU=Domain OU,DC=Company,DC=com' -DC DC001

    Search the user 'Doe, J (Jane)' with the additional property 'ExtensionAttribute5' in OrganizationalUnit 'OU=Users,OU=Domain OU,DC=Company,DC=com' using 'DC001'
#>

    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Identity,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Array]$Properties="*",

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$OU = "DC=" + (([system.directoryservices.activedirectory.domain]::GetCurrentDomain()).name).Replace(".",",DC="),
    
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$DC = ([system.directoryservices.activedirectory.domain]::GetCurrentDomain()).name
    )   

    switch ($Identity)
    {
        {($_ -like "*(*")}
            {$SearchFilter = "Name"; break}
        {($_ -like "*@*")}
            {$SearchFilter = "Mail"; break}
        {($_ -like "300*")}
            {$SearchFilter = "Rabo-id"; break}
        {($_ -like "fm.*")}
            {$SearchFilter = "Other"; break}
        {($_ -like "rs.*")}
            {$SearchFilter = "Other"; break}
        default
            {$SearchFilter = "SamAccountName"}
    }

    If ($SearchFilter -eq "Other")
    {
        $UserObject = Get-ADUser -Filter {DisplayName -eq $Identity} -Properties $Properties -SearchBase $OU -Server $DC
        If (!$UserObject)
        {
            $UserObject = Get-ADUser -Filter {SamAccountName -eq $Identity} -Properties $Properties -SearchBase $OU -Server $DC
            If (!$UserObject)
            {
                $UserObject = Get-ADUser -Filter {CN -eq $Identity} -Properties $Properties -SearchBase $OU -Server $DC
                If (!$UserObject)
                {
                    $UserObject = Get-ADUser -Filter {Name -eq $Identity} -Properties $Properties -SearchBase $OU -Server $DC
                }
            }
        }
    }
    Else
    {
        $UserObject = Get-ADUser -Filter {$SearchFilter -eq $Identity} -Properties $Properties -SearchBase $OU -Server $DC
    }

    return $UserObject
}
