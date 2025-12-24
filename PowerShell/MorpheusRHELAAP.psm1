# Import public functions
$publicFunctions = Get-ChildItem -Path $PSScriptRoot/Public/*.ps1 -Recurse

foreach ( $file in $publicFunctions )
{
    . $file.FullName
}
