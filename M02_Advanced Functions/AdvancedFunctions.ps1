#region slide 12 PSBoundParameters

function Test-PSBountParameter {
    param (
        [string]$DefinedParam
    )
    # Change the $defined parameter
    $DefinedParam = 'New Value'
    # Display the original $defined parameter
    Write-Host "`nOriginal `$DefinedParam parameter value is:$($PSBoundParameters['DefinedParam'])"
    # Display the current $defined parameter
    Write-Host "`nDefined Parameter: $DefinedParam"
}

Test-PSBountParameter -DefinedParam 'MyParam'

#endregion slide 12 PSBoundParameters

#--------------------------------------------------


#region slide 13 $args

function Test-Args {
    param (
        [string]$DefinedParam
    )

    # Display the defined parameter
    Write-Host "Defined Parameter: $DefinedParam"

    # Display any undefined parameters captured in $args
    if ($args.Count -gt 0) {
        Write-Host "Undefined Parameters and Values:"
        foreach ($arg in $args) {
            Write-Host " - $arg"
        }
    } else {
        Write-Host "No undefined parameters provided."
    }
} 

Test-Args -DefinedParam 'Defined' 'one' 55


#endregion slide 13 $args


#--------------------------------------------------


#region slide 14 Positional Arguments

function Add-Numbers {
    $sum = 0
    foreach ($arg in $args){
        $sum += $arg
    }
    Write-Output $sum
}
Add-Numbers 45 76 89 23 74 # 307
Add-Numbers 32 52 34 12 45 67 89 23 74 # 428

#endregion slide 14 Positional Arguments

#--------------------------------------------------

#region slide 18 Switch parameter

function SwitchExample {
    Param([switch]$LightSwitch)
    if ($LightSwitch) {
        Write-Host "Power is on"
    } else {
        Write-Host "Power is off"
    }
}
 
SwitchExample 
SwitchExample -LightSwitch

# Do not use this syntax
SwitchExample -LightSwitch:$false
SwitchExample -LightSwitch:$true

#endregion slide 18 Switch parameter


#--------------------------------------------------


#region Slide 22 SupportsShouldProcess

function Remove-DemoFile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    # Simulate file removal
    # The "File at '$FilePath'" message is displayed in the -WhatIf output you can set it to anything you want
    if ($PSCmdlet.ShouldProcess("File at '$FilePath'", "Remove")) {
        Write-Host "Simulating file removal at $FilePath" -BackgroundColor black -ForegroundColor Green
        # Actual removal logic would go here, e.g.:
        # Remove-Item -Path $FilePath
    }
    else {
        Write-Host "Operation skipped: $FilePath not removed." -BackgroundColor Black -ForegroundColor Yellow
    }
}

Remove-DemoFile -FilePath C:\temp\1.ps1
Remove-DemoFile -FilePath C:\temp\1.ps1 -WhatIf
Remove-DemoFile -FilePath C:\temp\1.ps1 -Confirm

#endregion Slide 22 SupportsShouldProcess


#--------------------------------------------------


#region Slide 23 ConfirmImpact

function Remove-DemoFile {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    # Simulate file removal
    if ($PSCmdlet.ShouldProcess("File at '$FilePath'", "Remove")) {
        Write-Host "Simulating file removal at $FilePath" -BackgroundColor Black -ForegroundColor Green
    } else {
        Write-Host "Operation skipped: $FilePath not removed." -BackgroundColor Black -ForegroundColor Yellow
    }
}

# Notice that the ConfirmImpact is set to 'High' and MUST BE along with SupportsShouldProcess

# Test Examples
Remove-DemoFile -FilePath C:\temp\1.ps1                 # Prompts for confirmation
Remove-DemoFile -FilePath C:\temp\1.ps1 -Confirm        # Explicit confirmation
Remove-DemoFile -FilePath C:\temp\1.ps1 -Confirm:$false # Skips confirmation

#endregion Slide 23 ConfirmImpact



#--------------------------------------------------


#region Slide 24 DefaultParameterSetName

function Remove-DemoFile2 {
    [CmdletBinding(DefaultParameterSetName = 'RelativePath')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'RelativePath', Position = 0)]
        [string]$RelativePath,

        [Parameter(Mandatory, ParameterSetName = 'FullPath', Position = 0)]
        [string]$FullPath
    )

    # Logic for RelativePath
    if ($PSCmdlet.ParameterSetName -eq 'RelativePath') {
        Write-Host "Simulating file removal at relative path: $RelativePath" -BackgroundColor Black -ForegroundColor Green
    }
    # Logic for FullPath
    if ($PSCmdlet.ParameterSetName -eq 'FullPath') {
        Write-Host "Simulating file removal at full path: $FullPath" -BackgroundColor Black -ForegroundColor Green
    }
}

Remove-DemoFile2 'C:\temp\1.ps1' 
# Notice that we are not specifying the parameter name, but the function will use the default parameter set 'RelativePath'

#endregion Slide 24 DefaultParameterSetName



#--------------------------------------------------



#region  Slide 25 Helpuri

function Get-HelpUri {
    [CmdletBinding(HelpUri = 'https://aka.ms/powershell')]
    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    # Simulate file removal
    Write-Host "Simulating file removal at $FilePath" -BackgroundColor Black -ForegroundColor Green
}

Get-Help Get-HelpUri -Online

#endregion Slide 25 Helpuri


#--------------------------------------------------



#region Slide 26 SupportsPaging

$ErrorActionPreference = 'SilentlyContinue'
function Get-PagedService {
    [CmdletBinding(SupportsPaging=$true)]
    param ()

    # Get all services
    $services = Get-Service

    # Check if paging is requested
    if ($PSCmdlet.PagingParameters) {
        $skip = $PSCmdlet.PagingParameters.Skip
        $first = $PSCmdlet.PagingParameters.First

        # Apply paging logic
        $pagedServices = $services | Select-Object -Skip $skip -First $first
    } else {
        # If no paging parameters, return all services
        $pagedServices = $services
    }

    # Output the services
    $pagedServices | ForEach-Object {
        [PSCustomObject]@{
            Name       = $_.Name
            DisplayName = $_.DisplayName
            Status      = $_.Status
        }
    }
}

# Get first 5 services by running the Get-PagedService function
Get-PagedService -First 5 | Select-Object -Property name, displayname, status
# Verify Test Get-Service for the first 5 services
Get-Service | Select-Object -Property name, displayname, status -First 5

# Get services 6-10 by running the Get-PagedService function
Get-PagedService -skip 5 -First 5 | Select-Object -Property name, displayname, status
# Test Get-Service for Services 6-10
Get-Service | Select-Object -First 10 | Select-Object -Property name, displayname, status -Last 5

$ErrorActionPreference = 'Continue'

#endregion Slide 26 SupportsPaging


#--------------------------------------------------


#region Slide 27 PositionalBinding

function Test-SimpleFunction {
    param (
        [string]$Param1,
        [string]$Param2
    )
    
    Write-Host "`$Param1: $Param1, `$Param2: $Param2" -BackgroundColor Black -ForegroundColor Green
}

Test-SimpleFunction 'Value1' 'Value2'


function Test-PositionalBinding {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        # [parameter(position=0)]
        [string]$Param1,

        [string]$Param2
    )
    
    Write-Host "`$Param1: $Param1, `$Param2: $Param2" -BackgroundColor Black -ForegroundColor Green
}

# Calling the function with named parameters
Test-PositionalBinding -Param1 "Value1" -Param2 "Value2"
Test-PositionalBinding "Value1" "Value2"

# Now remove the remark from the [parameter(position=0)] attribute and reload the function
# This will successfully run using the positional parameter for $Param1
Test-PositionalBinding "Value1" -Param2 "Value2"
Test-PositionalBinding -Param2 "Value2" "Value1"

# This will result in an error because positional parameters are not supported
Test-PositionalBinding "Value1" "Value2"
Test-PositionalBinding -Param1 "Value1" "Value2"

#endregion Slide 27 PositionalBinding


#--------------------------------------------------


#region Slide 30 Begin / Process / End

function Test-BeginProcessEnd_AddNumbers {
    begin { $total = 0 }
    process { $total += $_ }
    end { Write-Host "Total of numbers is $total" -BackgroundColor Black -ForegroundColor Green }
} 

1..10 | Test-BeginProcessEnd_AddNumbers 
2,4,6,8 | Test-BeginProcessEnd_AddNumbers 

#endregion Slide 30 Begin / Process / End



#--------------------------------------------------



#region Slide 32 Pipeline Input

#Now lets work without the Begin / Process / End blocks
function Test-AddNumbersUsingInput {
    $total = 0
    foreach ($item in $input) {
        $total += $item
    }
    Write-Host "Total of numbers is $total" -BackgroundColor Black -ForegroundColor Green
}
1..10 | Test-AddNumbersUsingInput
2,4,6,8 | Test-AddNumbersUsingInput
  
# The $input variable is a collection of objects that are passed to the function
# The $input variable is an enumerator that contains the input to the function

# You should prefer using the Begin / Process / End blocks for better performance
# Using this method, you can process each item as it is received, rather than waiting for all items to be received before processing them.
# If you plan to use this function as a part of long pipelines, you should use the Begin / Process / End blocks.
  

#endregion Slide 32 Pipeline Input


#--------------------------------------------------


