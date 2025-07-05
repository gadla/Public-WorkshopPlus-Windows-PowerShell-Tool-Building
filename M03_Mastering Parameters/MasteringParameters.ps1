#region Slide 6 ParameterSetName

function Test-ParameterSetName {
    Param(
        [Parameter(Mandatory,
        ParameterSetName="Computer")]
        [string]
        $ComputerName,

        [Parameter(Mandatory,
        ParameterSetName="User")]
        [string]
        $UserName,

        [switch]
        $Summary,

        [pscredential]
        $Credential = (Get-Credential)
    )
}

Get-Command Test-ParameterSetName -Syntax
# Note that in the syntax, the parameter Summary is in both parameter sets.
# This is because we did not specify the ParameterSetName for the Summary parameter.

#endregion Slide 6 ParameterSetName



# -------------------------------------------------



#region Slide 7 Mandatory and position

function Test-MandatoryParameter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name
    )

    Write-Host "Hello, $Name!" -BackgroundColor Black -ForegroundColor Green
}

# Call the function without the mandatory parameter
# Note that the user will be prompted for the mandatory parameter
Test-MandatoryParameter

function Test-PositionParameter {
    param (
        [int]$EmployeeID,

        [Parameter(Position=0)]
        [string]$Name
    )

    Write-Host "Hello, $Name your employee number is $EmployeeID!" -BackgroundColor Black -ForegroundColor Green
}

# Call the function with the parameters in the correct order
# Notice that this demonstrated why you should use named parameters and not positional parameters
# As a best practice, always use named parameters
Test-PositionParameter -Name 'John' -EmployeeID 1234
Test-PositionParameter 'John' -EmployeeID 1234 

# Reminder: when you declare one parameter as positional you lose the ability to use positional parameters for the rest of the parameters
Test-PositionParameter 'John' -EmployeeID 1234 # this works
Test-PositionParameter -Name 'John' 1234       # this will not work



#endregion Slide 7 Mandatory and position



# -------------------------------------------------


#region Slides 8 HelpMessage

function Test-HelpMessage {
<#
.Description
        This function greets a person.
.PARAMETER Name
    The name of the person to greet.
#>
    param (
        [Parameter(Mandatory,
                    HelpMessage = "Please provide your name.")]
        [string]$Name
    )

    Write-Host "Hello, $Name!" -BackgroundColor Black -ForegroundColor Green
} 

# Get help for the parameter Name (as described in the comment based help)
Get-Help -Name Test-HelpMessage -Parameter Name

# Demonstrate the HelpMessage parameter attribute (Note the difference between the comment based help and the HelpMessage)
Test-HelpMessage 


#endregion Slide 8 HelpMessage 

# -------------------------------------------------

#region Slide 9-10 Remaining Arguments
function Test-NoValueFromRemainingArguments {
    Param($Surname,$GivenName,$MiddleOrOther)  

    Write-Host "`$Surname $Surname"
    Write-Host "`$GivenName $GivenName"
    Write-Host "`$MiddleOrOther $MiddleOrOther" -BackgroundColor Black -ForegroundColor Green
}

  # Notice that MiddleOrOther will return only Sally
  Write-Host 'Without using ValueFromRemainingArguments' -BackgroundColor Black -ForegroundColor Green
  Test-NoValueFromRemainingArguments Jane Doe Sally Smith
  
  
function Test-ValueFromRemainingArguments {
    Param(
        $Surname,

        $GivenName,

        [Parameter(ValueFromRemainingArguments=$true)]
        $MiddleOrOther
    )
    Write-Host "`$Surname $Surname"
    Write-Host "`$GivenName $GivenName"
    Write-Host "`$MiddleOrOther $MiddleOrOther" -BackgroundColor Black -ForegroundColor Green
}

# Notice that now #MiddleOrOther is an array of the remaining arguments
Write-Host 'Using ValueFromRemainingArguments' -BackgroundColor Black -ForegroundColor Green
Test-ValueFromRemainingArguments Jane Doe Sally Smith  

#endregion Slide 9-10 Remaining Arguments



# -------------------------------------------------



#region Slide 14 Alias attribute

function Test-AliasParameter{
    param (
        [Alias('cn','MachineName')]
        [string]
        $ComputerName
    )
    Write-Host "Computer name passed is: $ComputerName" -BackgroundColor Black -ForegroundColor Green
}

# Get the syntax of the function
# Note that in the syntax, only the ComputerName parameter is shown, but the aliases are not shown.
Get-Command -name Test-AliasParameter -Syntax

# Get the help of the parameter
# The help shows the aliases of the parameter.
get-help Test-AliasParameter -Parameter ComputerName

# Test the function
Test-AliasParameter -ComputerName MyComputer
Test-AliasParameter -cn MySecondComputer
Test-AliasParameter -MachineName MyThirdComputer

# Practical [Alias()] parameter use cases:
# - Preserve backward compatibility after renaming a parameter (e.g. keep -ServerName working after switching to -ComputerName)
# - Align with external or third-party naming conventions for familiarity (e.g. -ResourceName for -VMName)
# - Enhance usability by allowing multiple common names for the same parameter (e.g. -Host, -Node, -Server all map to -ComputerName)



#endretion Slide 14 Alias attribute


# -------------------------------------------------


#region Slide 15 ValidateSet

function Get-CpuCounter {
    Param (
        [ValidateSet("% Processor Time","% Privileged Time","% User Time")]
        $perfcounter)

    Get-Counter -Counter "\Processor(_Total)\$perfcounter"
}
    
Get-CpuCounter -perfcounter #Now hit CRTL+Space to display the predefined values
Get-CpuCounter -perfcounter "Memory\Available MBytes"

#endregion Slide 15 ValidateSet


# -------------------------------------------------


#region Slide 16 Null Validation Attributes

#AllowNull
function Get-AllowNull{
    Param(
        [Parameter(Mandatory)] # When Mandatory is set, the parameter cannot be $null
        #[AllowNull()] # Uncomment this line to allow $null
        [hashtable]
        $ComputerInfo
    )
    Write-Output $ComputerInfo    
}

Get-AllowNull -ComputerInfo @{'value' = 1}
Get-AllowNull -ComputerInfo $null
# Now remove the remark AllowNull attribute and try to pass $null
Get-AllowNull -ComputerInfo $null


#AllowEmptyString
function Get-AllowEmptyString{
    Param(
        [Parameter(Mandatory)] # When Mandatory is set, the parameter cannot be an empty string
        # [AllowEmptyString()]
        [string]
        $ComputerName
    )
    Write-Host "`$ComputerName passed is: $ComputerName" -BackgroundColor Black -ForegroundColor Green
}

Get-AllowEmptyString -ComputerName ''
Get-AllowEmptyString -ComputerName 'MyComputer'
# Now remove the remark from AllowEmptyString attribute and try to pass an empty string
# Don't forget to rerun the function after each change
Get-AllowEmptyString -ComputerName ''


#AllowEmptyCollection
function Get-AllowEmptyCollection{
    Param(
        [Parameter(Mandatory)] # When Mandatory is set, the parameter cannot be an empty collection
        # [AllowEmptyCollection()] # Uncomment this line to allow an empty collection
        [string[]]$ComputerName)

    Write-Output $ComputerName
}

Get-AllowEmptyCollection -ComputerName @()
Get-AllowEmptyCollection -ComputerName @('MyComputer')
# Now remove the remark from AllowEmptyCollection attribute and try to pass an empty collection
Get-AllowEmptyCollection -ComputerName @()


#endregion Slide 16 Null Validation Attributes


# -------------------------------------------------


#region Slide 17 Not null validation attributes

# ValidateNotNull
function Get-ValidateNotNull {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]  # Comment this line to allow $null
        [string[]]$ComputerName
    )

    Write-Output $ComputerName
}

Get-ValidateNotNull -ComputerName $null
# This will throw an error because $null is not allowed by ValidateNotNull

# Comment the ValidateNotNull line in the function definition to see the difference
Get-ValidateNotNull -ComputerName $null
# This will throw an error because of how PowerShell handles parameter binding



# NotNullOrEmpty
function Test-ValidateNotNullOrEmpty {
    Param(
        [Parameter(Mandatory)] # When Mandatory is set, the parameter cannot be an empty string
         [ValidateNotNullOrEmpty()] # Uncomment this line to allow an empty string
        [string[]]
        $UserName
    )
    Write-Host "`$username passed is: $UserName" -BackgroundColor Black -ForegroundColor Green
}

Test-ValidateNotNullOrEmpty -UserName 'Gadi'
Test-ValidateNotNullOrEmpty -UserName ''
Test-ValidateNotNullOrEmpty -UserName $null
# Now remove the remark from ValidateNotNullOrEmpty attribute and try to pass an empty string
Test-ValidateNotNullOrEmpty -UserName ''
Test-ValidateNotNullOrEmpty -UserName $null

# Note again although there is an error on both cases one is created by PowerShell's way of Parameter binding
# Yet, after using ValidateNotNullOrEmpty the error comes from the validation attribute itself


#endregion Slide 17 Not null validation attributes


# -------------------------------------------------


#region Slide 18 Count Validate Attributes

# ValidateCount
function Test-ValidateCount {
    Param(
        [Parameter(Mandatory)]
        [Validatecount(2,3)]
        [string[]]
        $ComputerName
    )
    Write-Host "$ComputerName passed is $ComputerName" -BackgroundColor Black -ForegroundColor Green
}

Test-ValidateCount -ComputerName pc1,pc2,pc3
Test-ValidateCount -ComputerName pc1
Test-ValidateCount -ComputerName pc1,pc2,pc3,pc4


# ValidateLength
function Test-ComputerNameValidation {
    Param(
        [Parameter(Mandatory)]
        [ValidateLength(1,15)]
        [string[]]
        $ComputerName
    )
    Write-Host "$ComputerName passed is $ComputerName" -BackgroundColor Black -ForegroundColor Green
}

Test-ComputerNameValidation -ComputerName pc1
Test-ComputerNameValidation -ComputerName MyGreatComputerName


# ValidatePattern
function Test-ComputernameCharacters {
    Param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [string[]]
        $ComputerName
    )
    Write-Host "$ComputerName passed is $ComputerName" -BackgroundColor Black -ForegroundColor Green
}

Test-ComputernameCharacters -ComputerName 'pc1'
Test-ComputernameCharacters -ComputerName 'pc1*'

# A different approach is to use a custom validation function
function Test-ComputernameCharacters {
    Param(
        [Parameter(Mandatory)]
        [string[]]
        $ComputerName
    )

    foreach ($character in $ComputerName) {
        # Custom validation logic
        if ($character -notmatch '^[a-zA-Z0-9]+$' -or $ComputerName.Length -gt 15) {
            Write-Error "Invalid computer name: '$name'. Only alphanumeric characters are allowed." -ErrorAction SilentlyContinue
            return $false
        }
    }

    Write-Output $true
}

function Test-ComputerNameValidation {
    Param(
        [Parameter(Mandatory)]
        [string[]]
        $ComputerName
    )
    if(Test-ComputernameCharacters -ComputerName $ComputerName) {
        Write-Host "Computername $ComputerName is valid" -BackgroundColor Black -ForegroundColor Green
    } else{
        Write-Host "Computername $ComputerName is invalid. $($error[0].Exception.Message)" -BackgroundColor Black -ForegroundColor Red
    }
}

# Test Cases
Test-ComputerNameValidation -ComputerName 'pc1'
Test-ComputerNameValidation -ComputerName 'pc1*'


#endregion Slide 18 Count Validate Attributes



# -------------------------------------------------



#region Slide 19 Range and Script Validate Attributes

# Validate Range
function Test-ValidateRange {
    Param(
        [Parameter(Mandatory)]
        [ValidateRange(1,10)]
        [int]
        $Number
    )
    Write-Host "Number $Number is within the accepted range" -BackgroundColor Black -ForegroundColor Green
}

Test-ValidateRange -Number 5
Test-ValidateRange -Number 15


# Validate Script
function Test-ValidateScript {
    Param(
        [Parameter(Mandatory)]
        [ValidateScript({$_ -lt 10})]
        [int]
        $Soda
    )
    Write-Host "Soda price is reasonable" -BackgroundColor Black -ForegroundColor Green
}

Test-ValidateScript -Soda 5
Test-ValidateScript -Soda 15


# Why use an auxiliary function for validation?
# - Keeps the main function’s parameter block clean and easy to read
# - Separates the validation logic from the business logic, improving clarity
# - Makes the validation reusable for other functions in your script
# - Supports easier testing and maintenance of the validation rules
# - Overall, improves readability and maintainability of your parent function


function Test-MyValidator {
    param($price)
    return ($price -lt 10)
}

function Test-ValidateScript {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-MyValidator $_ })]
        [int]
        $Soda
    )
    Write-Host "Soda price is reasonable" -BackgroundColor Black -ForegroundColor Green
}

Test-ValidateScript -Soda 5
Test-ValidateScript -Soda 15


#endregion Slide 19 Range and Script Validate Attributes


# -------------------------------------------------



#region Slide 26 Supporting Risk Mitigation - Example


Function Test-KillProcess
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
    Param(
        [String]$Name
    )

    $TargetProcess = Get-Process -Name $Name
    If ($pscmdlet.ShouldProcess($Name, "Terminating Process"))
    {
        $TargetProcess.Kill()
    }
}

Get-Help -Name Test-KillProcess -ShowWindow
Start-Process -FilePath (Get-Command -Name mspaint.exe).Source
Test-KillProcess -Name mspaint -WhatIf

Function Test-KillProcess
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    Param(
        [String]$Name
    )

    $TargetProcess = Get-Process -Name $Name
    If ($pscmdlet.ShouldProcess($Name, "Terminating Process"))
    {
        $TargetProcess.Kill()
    }
}

Test-KillProcess -Name mspaint
Test-KillProcess -Name mspaint -Confirm:$false


#endregion Slide 26 Supporting Risk Mitigation - Example



# -------------------------------------------------

#region Slide 31 Help example


function Test-KillProcess {
    <#
    .SYNOPSIS
    Safely terminates a process by its name with confirmation and WhatIf support.

    .DESCRIPTION
    The Test-KillProcess function retrieves a process by its name and attempts to terminate it.
    It uses CmdletBinding with SupportsShouldProcess and a ConfirmImpact level of High, so that you can preview
    and confirm before performing a potentially destructive action.
    This helps protect critical processes from being terminated accidentally.

    .PARAMETER Name
    Specifies the name of the process you want to terminate.
    This should match the name shown in Task Manager or returned by Get-Process.

    .EXAMPLE
    Test-KillProcess -Name notepad

    Prompts for confirmation (due to ConfirmImpact High) before attempting to terminate all Notepad processes.

    .EXAMPLE
    Test-KillProcess -Name explorer -WhatIf

    Displays what would happen if you tried to terminate the Explorer process, but does not actually kill it.

    .EXAMPLE
    Test-KillProcess -Name powershell -Confirm:$false

    Explicitly bypasses confirmation prompts when terminating PowerShell, demonstrating how to override Confirm.

    .INPUTS
    [String]
    Accepts the name of a process as a string.

    .OUTPUTS
    None.
    This function does not produce output, but will terminate the specified process if confirmed.

    .NOTES
    Author: YourName
    Date: 2025-07-03
    Demo function for illustrating SupportsShouldProcess with ConfirmImpact.

    .LINK
    https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/supportsshouldprocess?view=powershell-7.4
    #>
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    Param(
        [Parameter(Mandatory)]
        [String]$Name
    )

    $TargetProcess = Get-Process -Name $Name -ErrorAction Stop
    If ($pscmdlet.ShouldProcess($Name, "Terminating Process"))
    {
        $TargetProcess.Kill()
    }
}


Get-Help -Name Test-KillProcess -ShowWindow

#endregion Slide 31 Help example


#--------------------------------------------------


#region Slide 33 OutputType

function Test-OutputType {
    [CmdletBinding()]
    [OutputType([datetime])] # Note that [OutputType()] is only a declaration and does not enforce the output type.
    Param(
        [Parameter(Mandatory)]
        [int]
        $Number
    )
    Write-Host "`$Number is $Number" -BackgroundColor Black -ForegroundColor Green
}

Test-OutputType -Number 5
# Demo here using this code and then trigger the intelisense to see the output type
# (Test-OutputType). CRTL + SPACE to trigger the intelisense

(Get-Command -Name Test-OutputType).OutputType
<# The output will be:
Name            Type            TypeDefinitionAst
----            ----            -----------------
System.DateTime System.DateTime
#>


#endregion Slide 32 OutputType
