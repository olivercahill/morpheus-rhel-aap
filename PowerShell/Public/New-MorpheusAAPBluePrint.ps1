<#
    .SYNOPSIS
        This function will create a  Morpheus blue print which defines a RHEL Based Ansible Automation Platform from a CloudFormation File (YAML). All steps will be logged in the default location unless otherwise changed in a parameter. 
    .DESCRIPTION
        API Documentation can be found at: https://apidocs.morpheusdata.com/reference/addblueprint. AAP Documentation can be found at: https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.0-ea/html-single/red_hat_ansible_automation_platform_installation_guide/index#standalone-controller-non-inst-database
    .EXAMPLE
        New-MorpheusAAPBluePrint -MorpheusURL "https://HPEMorpheus.com" -Token $token

    .NOTES
        Author:         Oliver Cahill
        Team:           
        Creation Date:  12/24/2025
        ---------------------------------------------------
        Change Record:
            12/24/2025: Initial Development
#>
function New-MorpheusAAPBluePrint
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

        #Specify the log path
        [Parameter()]
        [string]
        $LogPath = "/Users/olivercahill/Morpheus Create BP -$( Get-Date -Format FileDateTime ).log"
    )
    begin
    {
        Set-StrictMode -Version 2.0
    }

    process
    {
        try
        {
            "{0} - Creating the log file for for New-MorpheusAAPBluePrint" -f ( Get-Date -Format FileDateTime ) | Out-File $LogPath -Append

            $headers = @{}
            $headers.Add("accept", "application/json")
            $headers.Add("content-type", "application/json")
            $headers.Add("authorization", "Bearer $Token")
            "{0} - Successfully created the headers for the API Call" -f ( Get-Date -Format FileDateTime ) | Out-File $LogPath -Append

            $url = '{0}/api/blueprints' -f $MorpheusURL
            "{0} - Successfully converted the URL to connect to the correct section of the API : {1}" -f ( Get-Date -Format FileDateTime ), $url | Out-File $LogPath -Append

            $response = Invoke-WebRequest -Uri $url -Method POST -Headers $headers -ContentType 'application/json' -Body '{"type":"cloudFormation","cloudFormation":{"configType":"yaml","IAM":false,"CAPABILITY_NAMED_IAM":false,"CAPABILITY_AUTO_EXPAND":false,"installAgent":false,"cloudInitEnabled":false,"yaml":"--- Resources:   MyInstance:     Type: AWS::EC2::Instance     Properties:       AvailabilityZone: us-east-1a       ImageId: ami-069e612f612be3a2b #RHEL AMI       InstanceType: m4.large #minimum size for AAP       UserData:         Fn::Base64: |           #!/bin/bash -xe           #running install commands per section 2.1, Installing automation controller with a database on the same node.           #Creating working directory           mkdir -p /opt/aap           cd /opt/aap           #retrieve/extract the AAP Installation Bundle from an S3 bucket           aws s3 cp s3://hpe-s3-bucket/ansible-automation-platform-setup-bundle-<latest-version>.tar.gz .           tar xvzf ansible-automation-platform-setup-bundle-<latest-version>.tar.gz           #the pool ID would be provided or retrieved from Parameter Store, Secrets Manager, etc           subscription-manager attach --pool=<pool_id>           #Copying the generic inventory file referenced in AAP Documentation to opt/aap. Below hypothetical situation would have it in an S3 Bucket.           aws s3 cp s3://hpe-s3-bucket/inventory.txt /opt/aap/inventory.txt"},"name":"RHEL BluePrint"}'
            "{0} - Successfully created the blue print: {1}" -f ( Get-Date -Format FileDateTime ), $response | Out-File $LogPath -Append
        }
        catch
        {
            "{0} - Error: {1}" -f ( Get-Date -Format FileDateTime ), $PSItem | Out-File $LogPath -Append
            $PSCmdlet.ThrowTerminatingError( $PSItem )
        }
    }        
}
