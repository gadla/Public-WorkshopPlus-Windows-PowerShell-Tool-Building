#region Slide 7 Creating a utility function

function Get-MyService {
<#
.SYNOPSIS
Gets information about a specified Windows service and its required services, 
on a local or remote computer.

.DESCRIPTION
This function retrieves the status of the specified service, as well as its required services, 
and returns a structured object containing:
- the service name
- its current status
- the required services' names
- their statuses
- a timestamp

This helps administrators quickly review service dependencies on a machine.

Note: This function requires Windows PowerShell 5.1 or lower because 
the `Get-Service` cmdlet with the `-ComputerName` parameter is *not* supported in PowerShell 7 and above.

.PARAMETER ServiceName
The name of the service to check. This parameter is mandatory.

.PARAMETER ComputerName
The name of the target computer. Defaults to the local computer if not specified.

.EXAMPLE
Get-MyService -ServiceName spooler

Retrieves the spooler service and its dependencies on the local computer.

.EXAMPLE
Get-MyService -ServiceName spooler -ComputerName DC01

Retrieves the spooler service and its dependencies on the remote computer DC01.

.OUTPUTS
[PSCustomObject]
Returns an object containing the service name, status, required services, their statuses, and timestamp.

#>
    param (
        [Parameter(Mandatory)]
        [string]$ServiceName,

        [string]$ComputerName = $env:COMPUTERNAME
    )

    Write-Host "Checking required services for '$ServiceName' on $ComputerName..."

    $MainService = Get-Service -Name $ServiceName -ComputerName $ComputerName

    # Get its required services
    $RequiredService = Get-Service -Name $ServiceName -RequiredServices -ComputerName $ComputerName

    [PSCustomObject]@{
        ServiceName       = $MainService.Name
        ServiceStatus     = $MainService.Status
        RequiredServices  = $RequiredService.Name -join ", "
        RequiredStatuses  = ($RequiredService | ForEach-Object { "$($_.Name):$($_.Status)" }) -join ", "
        CheckedAt         = Get-Date
    }
}

Get-MyService -ServiceName 'Spooler'



function Test-HostConnection {
<#
.SYNOPSIS
Tests network connectivity to a specified computer and summarizes the results.

.DESCRIPTION
This function uses Test-Connection to send ICMP echo requests (pings) to the specified 
computer and returns a structured report including:
- the computer name
- number of successful pings
- number of pings sent
- success rate as a percentage
- timestamp of the check

**Important:** This function is designed to work with PowerShell 5.1 or lower
- In Windows PowerShell 5.1, Test-Connection typically returns objects only for successful replies. 
  Failed ping attempts may not be returned depending on switches and parameters.
- In PowerShell 7 and above, Test-Connection returns an object for *every* attempt, 
  including those that time out, with the `Status` property indicating `Success` or `TimedOut`.

.PARAMETER ComputerName
Specifies the name or IP address of the computer to ping.
This parameter is mandatory.

.PARAMETER Count
Specifies the number of ping requests to send.
Defaults to 4 if not specified.

.EXAMPLE
Test-HostConnection -ComputerName dc01

Sends 4 pings to dc01 and returns the summary report.

.EXAMPLE
Test-HostConnection -ComputerName 192.168.1.10 -Count 10

Sends 10 pings to the IP address 192.168.1.10 and returns the summary report.

.OUTPUTS
[PSCustomObject]
An object containing the target computer name, number of successful pings, 
number of pings sent, success rate, and timestamp.


#>
    param (
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [int]$Count = 4
    )

    Write-Host "Testing connectivity to $ComputerName with $Count pings..." -ForegroundColor Green

    $results = Test-Connection -ComputerName $ComputerName -Count $Count

    $successful = $results.Count
    $successRate = [math]::Round(($successful / $Count) * 100, 1)

    [PSCustomObject]@{
        ComputerName    = $ComputerName
        SuccessfulPings = $successful
        SentPings       = $Count
        SuccessRate     = "$successRate%"
        TimeStamp       = Get-Date
    }
}

Test-HostConnection -ComputerName www.google.com -Count 8 

#endregion Slide 7 Creating a utility function

#region slide 12 PSBoundParameters

function Test-PSBountParameter {
    param (
        [string]$Param1
    )
    # Change the $defined parameter
    $Param1 = 'New Value'
    # Display the original $defined parameter
    Write-Host "`nOriginal `$Param1 parameter value is: $($PSBoundParameters['Param1'])" -BackgroundColor Black -ForegroundColor yellow
    # Display the current $defined parameter
    Write-Host "`nCurrent value of `$Param1 is: $Param1" -BackgroundColor Black -ForegroundColor Green
}

Test-PSBountParameter -Param1 'MyParam'

#endregion slide 12 PSBoundParameters

#--------------------------------------------------


#region slide 13 $args

function Test-Args {
    param (
        [string]$Param1
    )

    # Display the defined parameter
    Write-Host "Param1 value is: $Param1"

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

Test-Args -Param1  'One' 'two' 55
Test-Args 'One' 'two' 66

#endregion slide 13 $args


#--------------------------------------------------


#region slide 14 Positional Arguments

function Add-Numbers {
    $sum = 0
    foreach ($arg in $args){
        $sum += $arg
    }
    Write-Host "Total Sum: $sum" -ForegroundColor Yellow
}

Add-Numbers 45 76 89 23 74 # 307
Add-Numbers 32 52 34 12 45 67 89 23 74 # 428

#endregion slide 14 Positional Arguments

#--------------------------------------------------


#region Slide 15 Named Parameters

function Test-NamedParameters {
    param (
        [string]$Param1,
        [int]$Param2
    )
    Write-Host "Param1 is: $Param1"
    Write-Host "Param2 is: $Param2"
}

Test-NamedParameters -Param1 'Hello' -Param2 42
Test-NamedParameters -Param2 42 -Param1 'World'

# Using splatting to pass parameters
$Parameters = @{
    Param1 = 'Hello'
    Param2 = 42
}
Test-NamedParameters @Parameters

#endregion Slide 15 Named Parameters


#--------------------------------------------------

#region slide 17 Switch parameter

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

# Practical switch parameter use cases:
# - Toggle compression on/off (e.g. -Archive)
# - Enable or disable alerting in a monitoring tool (e.g. -EnableAlerting)
# - Select detailed versus summary report output (e.g. -Detailed)
# - Force an operation regardless of conditions (e.g. -ForceRestart)
# - Activate optional features or modules in a script (e.g. -EnableModuleX)


#endregion slide 17 Switch parameter


#--------------------------------------------------

#region Slide 21 [CmdletBinding()] Attribute - Parameter checks only for valid parameter
function Test-ValidParameter {
    [CmdletBinding()]
    param (
        [string]$Choice
    )

    Write-Host "You selected: $Choice" -BackgroundColor Black -ForegroundColor Green
}
Test-ValidParameter -Choice 'Option1'  # Valid parameter
Test-ValidParameter -Choice1 'Option2' # Invalid parameter, will throw an error

#---------------------------------------------------

#region Slide 22 SupportsShouldProcess

function Remove-DemoFile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    # Simulate file removal
    # The "File at '$FilePath'" message is displayed in the -WhatIf output you can set it to anything you want
    if ($PSCmdlet.ShouldProcess("$FilePath", "Remove")) {
        Write-Host "Simulating file removal at $FilePath" -BackgroundColor black -ForegroundColor Green
        # Actual removal logic would go here, e.g.:
        # Remove-Item -Path $FilePath
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
    [CmdletBinding(DefaultParameterSetName = 'FullPath')]
    # Note that both parameters are positional parameters
    # This is a design error, but it is done to demonstrate the DefaultParameterSetName
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

Get-Command Remove-DemoFile2 -Syntax
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
        [parameter(position=0)]
        [string]$Param1,

        [string]$Param2
    )
    
    Write-Host "`$Param1: $Param1, `$Param2: $Param2" -BackgroundColor Black -ForegroundColor Green
}

# Calling the function with named parameters
Test-PositionalBinding -Param1 'Value1' -Param2 'Value2'
Test-PositionalBinding 'Value1' -Param2 'Value2'
Test-PositionalBinding -Param2 'Value2' '`Value1'
Test-PositionalBinding 'Value1' 'Value2'

# Now remove the remark from the [parameter(position=0)] attribute and reload the function
# This will successfully run using the positional parameter for $Param1
Test-PositionalBinding 'Value1' -Param2 'Value2'
Test-PositionalBinding -Param2 'Value2' 'Value1'

# This will result in an error because positional parameters are not supported
Test-PositionalBinding 'Value1' 'Value2'
Test-PositionalBinding -Param1 'Value1' 'Value2'

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

function Test-AddNumbersUsingInput {
    $total = 0

    # First, move to the first element
    $input.MoveNext() | Out-Null

    for (; $input.Current -ne $null; $input.MoveNext()) {
        $total += $input.Current
    }

    Write-Host "Total of numbers is $total" -BackgroundColor Black -ForegroundColor Green
}

1..10 | Test-AddNumbersUsingInput
2,4,6,8 | Test-AddNumbersUsingInput

# You should prefer using the Begin / Process / End blocks for better performance
# Using this method, you can process each item as it is received, rather than waiting for all items to be received before processing them.
# If you plan to use this function as a part of long pipelines, you should use the Begin / Process / End blocks.
  

#endregion Slide 32 Pipeline Input


#--------------------------------------------------


