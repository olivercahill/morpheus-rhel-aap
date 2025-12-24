<#
    .SYNOPSIS
        This function will turn a Morpheus username and password into an access token
    .DESCRIPTION
        API Documentation can be found at: https://apidocs.morpheusdata.com/reference/getaccesstoken
    .EXAMPLE
        New-MorpheusToken -MorpheusURL "https://HPEMorpheus.com" -Credential ( Get-Credential )
    .NOTES
        Author:         Oliver Cahill
        Team:           
        Creation Date:  12/24/2025
        ---------------------------------------------------
        Change Record:
            12/24/2025: Initial Development
#>
function New-MorpheusToken
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        #Specify the URL to the Morpheus Instance
        [Parameter()]
        [string]
        $MorpheusURL = "https://changeme",

        # Specifies the credentials needed to log in to the Morpheus Instance
        [Parameter( Mandatory )]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )
    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            $headers = @{}
            $headers.Add("accept", "application/json")
            $headers.Add("content-type", "application/x-www-form-urlencoded")
            $tokenUrl = '{0}/oauth/token?client_id=morph-api&grant_type=password&scope=write' -f $MorpheusURL
            $loginData = New-Object -TypeName PSObject -Property @{
                username = $( $Credential.UserName )
                password = $( $Credential.GetNetworkCredential().Password )
            }
            $loginJSON = ( ConvertTo-Json -compress $loginData )

            $tokenRetrieval = Invoke-WebRequest -Uri $tokenUrl -Method POST -Headers $headers -Body $loginJSON
            ( ConvertFrom-Json $tokenRetrieval.Content ).response.token
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSItem )
        }
    }
}