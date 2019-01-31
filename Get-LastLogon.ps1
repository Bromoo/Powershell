
function _Get-ADUserLastLogon
{
    Param
    (
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [String]$User,

        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Object]$Domain
    )


    # Validate domain
    Try
    {
        # Validate Domainname
        Get-ADDomain -Identity $Domain -ErrorAction Stop | Out-Null
        
        # Validate Domaincontrollers
        $DCs = Get-ADDomainController -Filter * -Server $Domain
        If ($DCs)
        {
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
        Else
        {
            Throw "Unable to resolve domaincontrollers from [$Domain]"
        }
    }
    Catch
    {
        Throw $_
    }

    If ($User)
    {
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
    Else
    {
        return $false
    }
}

_Get-ADUserLastLogon -User SamAccountName -Domain Domain.com
