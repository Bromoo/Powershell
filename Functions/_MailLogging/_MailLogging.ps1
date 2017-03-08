#Function for sending the completion e-mail
function _MailLogging
{
<# 
.Synopsis 
    Send an e-mail to the specified addresses and adds a signature with images
.DESCRIPTION 
    Send an e-mail through a relay server with a specified html file as body. 
.PARAMETER TOAddress 
    Specify the TO address
.PARAMETER CCAddress 
    Specify the CC address
.PARAMETER BCCAddress 
    Specify the BCC address
.PARAMETER RelayAddress 
    Specify the Relay address where the e-mail is sent from
.PARAMETER Subject 
    Specify the subject of the e-mail address
.PARAMETER HtmlBodyPath 
    Specify the path for the HTML file with the e-mail body

.EXAMPLE 
    _MailLogging -TOAddress 'to-address@company.com' -CCAddress 'cc-address@company.com' -RelayAddress 'relay-address@company.com' -Subject 'Test e-mail' -HtmlBodyPath "\\\Path\EmailBody.html"
#>

    Param 
    ( 
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [Array]$TOAddress,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Array]$CCAddress,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [Array]$BCCAddress,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$RelayAddress,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Subject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$HtmlBodyPath="$PSScriptRoot\email\Email.html"
    )    

    $Valid = $false

    If (Test-Path -Path $HtmlBodyPath)
    {
        $Valid = $true

        # Setting email file
        $EmailBody = $HtmlBodyPath
    }

    # Include Image1
    $Image1 = "$PSScriptRoot\email\Image1.png"
    
    $pic1 = New-Object Net.Mail.Attachment($image1)
    $pic1.contentType.Mediatype = "image/png"
    $pic1.Contentid = "Attachment1" 
    
    $EmailMsg.Attachments.add($pic1)

    # Include Image2
    $Image2 = "$PSScriptRoot\email\Image2.png"
    
    $pic2 = New-Object Net.Mail.Attachment($image2)
    $pic2.contentType.Mediatype = "image/png"
    $pic2.Contentid = "Attachment2" 
    
    $EmailMsg.Attachments.add($pic2)

    # Setting email from address
    $EmailFrom = $RelayAddress

    # Compose email message
    $EmailMsg = New-Object System.Net.Mail.MailMessage
    $EmailMsg.From = $RelayAddress

    # Add TO addresses
    If ($TOAddress)
    {
        foreach ($To in $SendToAddress)
        {
            $EmailMsg.to.add($To)
        }
    }

    # Add CC addresses
    If ($CCAddress)
    {
        foreach ($CC in $SendToAddress)
        {
            $EmailMsg.cc.add($CC)
        }
    }

    # Add BCC addresses
    If ($BCCAddress)
    {
        foreach ($BCC in $SendToAddress)
        {
            $EmailMsg.bcc.add($BCC)
        }
    }

    $EmailMsg.IsBodyHtml = $true

    # Set the subject
    $EmailMsg.Subject = $Subject
                                                                                              
    # Import the HTML file as plain text
    $OrgMsgBody = Get-Content $EmailBody
    $MsgBody = @()

    # Replace strings in the HTML body to add variables                                                                                          
	foreach ($Line in $OrgMsgBody) {
	    # If more variables are added to the message, just copy and modIfy the lines below.
	    $line = $line `
        -Replace "VARsummary",$Summary
	    $MsgBody += $line
	}
    $EmailMsg.body = $MsgBody

    #send email message ( comment to test without mail ) 
    $smtp = New-Object Net.Mail.SmtpClient($SMTPserver)
    $smtp.Send($EmailMsg)  
}

_MailLogging -TOAddress 'to-address@company.com' -CCAddress 'cc-address@company.com' -RelayAddress 'relay-address@company.com' -Subject 'Test e-mail' -HtmlBodyPath "\\\Path\EmailBody.html"
