<#
    .SYNOPSIS
        This function will deploy a  Morpheus blue print which defines a RHEL Based Ansible Automation Platform from a CloudFormation File (YAML). All steps will be logged in the default location unless otherwise changed in a parameter. 
    .DESCRIPTION
        API Documentation can be found at: https://apidocs.morpheusdata.com/reference/addapps. AAP Documentation can be found at: https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.0-ea/html-single/red_hat_ansible_automation_platform_installation_guide/index#standalone-controller-non-inst-database
    .EXAMPLE
        New-MorpheusRHELAAP -MorpheusURL "https://HPEMorpheus.com" -Token $token -Name "RHEL AAP" -BluePrintID 1234

    .NOTES
        Author:         Oliver Cahill
        Team:           
        Creation Date:  12/24/2025
        ---------------------------------------------------
        Change Record:
            12/24/2025: Initial Development
#>
function New-MorpheusRHELAAP
{
    [CmdletBinding()]
    param
    (
        #Specify the URL to the Morpheus Instance
        [Parameter()]
        [string]
        $MorpheusURL = "https://changeme",

        # Specifies the token generated from the UN/PW provided in the New-MorpheusToken f(x)
        [Parameter( Mandatory )]
        [string]
        $Token,
        
        # Specifies the Name of the App that you want to create
        [Parameter( Mandatory )]
        [string]
        $Name,

        # Specifies the ID of the Blue Print that you want to deploy
        [Parameter( Mandatory )]
        [Int64]
        $BluePrintID,

        #Specify the log path
        [Parameter()]
        [string]
        $LogPath = "/Users/olivercahill/Morpheus Deploy BP -$( Get-Date -Format FileDateTime ).log"
    )
    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            "{0} - Creating the log file for for New-MorpheusAAP" -f ( Get-Date -Format FileDateTime ) | Out-File $LogPath -Append

            $headers=@{}
            $headers.Add("accept", "application/json")
            $headers.Add("content-type", "application/json")
            $headers.Add("authorization", "Bearer $Token")
            "{0} - Successfully created the headers for the API Call" -f ( Get-Date -Format FileDateTime ) | Out-File $LogPath -Append

            $body = "{'blueprintId':$BluePrintID ,'name':$Name}" | ConvertTo-Json
            "{0} - Successfully converted the body to JSON which will be passed into the API Call as : {1}" -f ( Get-Date -Format FileDateTime ), $body | Out-File $LogPath -Append
            
            $url = '{0}/api/apps' -f $MorpheusURL
            "{0} - Successfully converted the URL to connect to the correct section of the API : {1}" -f ( Get-Date -Format FileDateTime ), $url | Out-File $LogPath -Append

            $response = Invoke-WebRequest -Uri $url -Method POST -Headers $headers -Body $body
            "{0} - Successfully deployed the blue print: {1}" -f ( Get-Date -Format FileDateTime ), $response | Out-File $LogPath -Append
        }
        catch
        {
            "{0} - Error: {1}" -f ( Get-Date -Format FileDateTime ), $PSItem | Out-File $LogPath -Append
            $PSCmdlet.ThrowTerminatingError( $PSItem )
        }
    }
}