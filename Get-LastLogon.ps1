
function _Get-ADUserLastLogon
{
    Param
    (
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [String]$User,

        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Object]$DCs
    )

    # Default Vars
    $Time = 0
    $Date = $null

    # Query all DCs for lastlogonstimestamp and return the most recent
    foreach ($DC in $DCs)
    { 
        $LastLogon = Get-ADUser $User -Server $DC -Properties LastLogonTimestamp
        If ($LastLogon.LastLogontimestamp -gt $Time)
        {
            $Time        = $LastLogon.LastLogontimestamp
            $LastLogonDC = $DC.Hostname
        }
    }

    # If date can not be resolved set date to unknown
    If ($Date -eq "01-01-1601 01:00:00")
    {
        $Date = "Unknown"
    }
    Else
    {
        $Date = [DateTime]::FromFileTime($Time).ToString('dd-MM-yyyy HH:mm:ss')
    }

    return $Date, $LastLogonDC
}


$Domain = 'Domain'
$User   = 'SamAccountName'

# Validate domain
Try
{
    Get-ADDomain -Identity $Domain -ErrorAction Stop | Out-Null
    $DomainValid = $true

    # Validate User
    Try
    {
        $User = Get-ADUser -Identity $User -Server $Domain -ErrorAction Stop
    }
    Catch
    {
        Throw $_
    }
}
Catch
{
    Throw $_
}

If ($User)
{
    # Retrieve all domaincontrollers from specified domain.
    $DCs    = Get-ADDomainController -Filter * -Server $Domain
    If ($DCs)
    {
        # Retrieve most recent logon
        Try
        {
            $GetLastLogon = _Get-ADUserLastLogon -User $User.SamAccountName -DCs $DCs
            Write-Host "LastLogon for user [$($User.SamAccountName)]: $($GetLastLogon[0]) from DC [$($GetLastLogon[1])]"
        }
        Catch
        {
            Throw $_
        }
    }
    Else
    {
        Throw "No Domaincontrollers could be resolved from domain [$($Domain)]"
    }
}
