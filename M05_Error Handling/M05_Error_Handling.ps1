#region Slide 12 Stream Cmdlets

Write-Output 'Output stream'
Write-Verbose 'Verbose stream'
Write-Error 'Error stream'
Write-Warning 'Warning stream'
Write-Information 'Information stream'

# What do you think about Write-Host?
Write-Host 'Host stream'
# Write-Host is not a stream cmdlet, it writes directly to the console and does not support redirection or capturing.

#endregion Slide 12 Stream Cmdlets

# ------------------------------------------------------------------------------------


#region Slide 18 Demonstrating Streams

$ErrorActionPreference
Write-Error "This is an error message"
$ErrorActionPreference = 'SilentlyContinue'
# The following line will not generate an error message
Write-Error "This is another error message"
$ErrorActionPreference = 'Continue'

$VerbosePreference
# The following line will not generate a verbose message
Write-Verbose "This is a verbose message"
$VerbosePreference = 'Continue'
Write-Verbose "This is another verbose message"
$WarningPreference = 'SilentlyContinue'



#endregion Slide 18 Demonstrating Streams



# ------------------------------------------------------------------------------------

#region Slide 25 Demonstrating Write-Information
# **********************************************************************************
# Example 1: Demonstrating the use of Write-Host and Write-Information in PowerShell
# **********************************************************************************

$informationMessages = & {
    Write-Information "This is a tagged error-like informational message" -Tags "error"
    Write-Information "This is a second error-like informational message" -Tags "error"
    Write-Information "This is an informational update" -Tags "info"
    Write-Information "Another information message" -Tags "info"
    Write-Information "One more information message" -Tags "info"
    Write-Host "This is a message using Write-Host 6"
    Write-Host "This is a message using Write-Host 7" -NoNewline
    Write-Host "This is a message using Write-Host 8" -BackgroundColor Black -ForegroundColor Yellow
} *>&1 | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }

# Filter messages by their tags
$filteredErrors = $informationMessages | Where-Object { $_.Tags -contains "error" }
$filteredInfo   = $informationMessages | Where-Object { $_.Tags -contains "info" }
$filteredHost   = $informationMessages | Where-Object { $_.Tags -contains "PSHost" }

# Display results
Write-Host "`nFiltered Error-like Messages:" -ForegroundColor Red
$filteredErrors | ForEach-Object { $_.MessageData }

Write-Host "`nFiltered Informational Messages:" -ForegroundColor Green
$filteredInfo | ForEach-Object { $_.MessageData }

Write-Host "`nFiltered Write-Host Messages:" -ForegroundColor Yellow
$filteredHost | ForEach-Object { $_.MessageData }

# **********************************************************************************
# Example 2: Demonstrating PowerShell Information stream with Enums
# **********************************************************************************

# Define an Enum for message categories
enum TagEnum {
    Status
    Main
    Cleanup
}

# FunctionOne with explicit string tag
function FunctionOne {
    Write-Information "FunctionOne executed" -Tags ([TagEnum]::Status)
}

# FunctionTwo with explicit string tag
function FunctionTwo {
    Write-Information "FunctionTwo executed" -Tags ([TagEnum]::Status)
}

# A cleanup phase to illustrate another tag
function Cleanup {
    Write-Information "Cleanup completed" -Tags ([TagEnum]::Cleanup)
}

# Main function
function Main {
    Write-Information "Starting script execution" -Tags ([TagEnum]::Main)
    FunctionOne
    FunctionTwo
    Cleanup
    Write-Host "Script main function execution completed" -BackgroundColor Black -ForegroundColor Yellow
}

# Capture the information stream
$informationMessages = & {
    Main
} *>&1 | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }

# Display with tags
Write-Host "`nCaptured Information Stream Messages:`n" -ForegroundColor Cyan
$informationMessages | ForEach-Object {
    Write-Host "[$($_.Tags -join ',')]" -ForegroundColor DarkGreen -NoNewline
    Write-Host " - $($_.MessageData)"
}

#endregion Slide 25 Demonstrating Write-Information



# ------------------------------------------------------------------------------------



#region Slide 32 $Error - View all properties of ErrorRecord object

# Create some errors
$Error.Clear()
Get-MyNonExistentCmdlet 
Get-Service -Name 'NonExistentService' -ErrorAction 'SilentlyContinue'
$? # Check if the last command was successful

$Error
$Error[0]
$Error[0] | Format-List -Property * -Force
$error[0] | Select-Object -Property *
$Error[0] | get-member -MemberType Properties
$Error[0].CategoryInfo
$Error[0].InvocationInfo
$Error[0].Exception
$Error[0].ScriptStackTrace

#endregion Slide 32 $Error - View all properties of ErrorRecord object


# ------------------------------------------------------------------------------------



#region Slide 41 Write-Error

# Clear previous errors to start fresh
$Error.Clear()

# Write a non-terminating error
Write-Error 'This is an error message'
$Error
$Error.Count

# Add another error
Write-Error 'This is another error message'
$Error
$Error.Count

# Show the most recent error
$Error[0]

# Show its Exception details for deeper understanding
$Error[0].Exception
$Error[0].CategoryInfo

# This will write an error but suppress it from the console display
Write-Error 'This is a hidden error' -ErrorAction 'SilentlyContinue'

# Show command success, still true since error is non-terminating
$?

# Still gets into $Error
$Error[0]

# Note:
# - Write-Error generates non-terminating errors, letting the script continue.
# - The $Error variable is a li



# Here is a demo of using Write-Error in functions
# ------------------------------------------------

# Auxiliary function to validate employee ID
function Test-EmployeeId {
    param (
        [int]$Id
    )

    if ($Id -le 0) {
        Write-Error "Test-EmployeeId: Employee ID must be greater than zero." -ErrorAction 'SilentlyContinue'
        return $false
    }
    return $true
}

# Main function to register an employee
function Register-Employee {
    param (
        [int]$Id,
        [string]$Name
    )

    if (-not (Test-EmployeeId -Id $Id -ErrorAction 'SilentlyContinue')) {
        Write-Host "Employee registration failed due to invalid ID." -ForegroundColor Yellow
        Write-Host "Error is $($Error[0].Exception.Message)`n" -ForegroundColor Red
        Write-Host "Error stack trace: $($Error[0].ScriptStackTrace)" -ForegroundColor DarkYellow
        return
    }

    Write-Host "Employee [$Name] with ID [$Id] has been registered." -ForegroundColor Green
}

# Clean error stack
$Error.Clear()

# Run the main function with invalid input
Register-Employee -Id 0 -Name "John Doe"

# Show error list to demonstrate reusable error reporting
$Error

# Run with valid input
Register-Employee -Id 101 -Name "Jane Smith"

# Remarks for participants:
# - Test-EmployeeId uses the approved verb "Test" to validate data.
# - Register-Employee uses "Register" for creating the employee.
# - The reusable validation function reports errors back via Write-Error.
# - The main function then decides whether to continue or abort based on the validation result.
# - The $Error variable still collects these messages for consistent error tracking.


#endregion Slide 41 Write-Error




# ------------------------------------------------------------------------------------



#region Slide 46 Throw

function test-throw {
    throw 'This is an error message'
    write-host 'This line will not be executed'
}

try{
    test-throw 
}
catch {
    write-host "Error message: $_"
}


try{
    test-throw -ErrorAction silentlycontinue
}
catch {
    Write-Host "Error message: " -BackgroundColor Black -ForegroundColor Magenta
    Write-Host "$_"
    Write-Host "`nError category: "  -BackgroundColor Black -ForegroundColor Magenta
    $Error[0].CategoryInfo
    write-host "`nError invocation info: " -BackgroundColor Black -ForegroundColor Magenta
    $Error[0].InvocationInfo
    Write-Host "`nError exception: " -BackgroundColor Black -ForegroundColor Magenta
    $Error[0].Exception
    Write-Host "`nError script stack trace: " -BackgroundColor Black -ForegroundColor Magenta
    $Error[0].ScriptStackTrace
}

#endregion Slide 46 Throw



# ------------------------------------------


#region Slide 49 Trap


# In order to force the errors to be terminating errors, we set the ErrorAction parameter to Stop
# Play with continue and break in the trap block to see the difference
$ErrorActionPreference = 'Stop'
function Get-Trap {
    trap {
        # In demo remark the Continue and Break to see the difference
        Write-Output 'Trap caught'
        #continue
        break
    }
    Get-WmiObject -ComputerName NoComputer -Class win32_bios
    Write-Host 'exiting Get-Trap function' -BackgroundColor Black -ForegroundColor Yellow
}

# Clear error stack
$Error.Clear()

# Call the function
Get-Trap

# Show stored error records
$Error

# Remarks for participants:
# - trap is a legacy error handling mechanism that comes from very early PowerShell (and inherited from traditional shells).
# - Trap only handles *terminating* errors, so $ErrorActionPreference is set to Stop.
# - continue inside trap allows function to continue after handling
# - break inside trap exits the function immediately
# - errors are still recorded in $Error after trap completes


#endregion Slide 49 Trap

# ------------------------------------------

#region Slide 52 Try, Catch, Finally

function Get-FileContent {
    param (
        [string]$Path
    )

    try {
        Write-Host "Attempting to read: $Path" -ForegroundColor Cyan
        $content = Get-Content -Path $Path -ErrorAction Stop
        Write-Host "File contents loaded successfully:" -ForegroundColor Green
        $content
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Write-Host "Finished attempting to read the file (cleanup step)." -ForegroundColor Yellow
    }
}

# Demo:
Get-FileContent -Path "C:\doesnotexist.txt"


#endregion Slide 52 Try, Catch, Finally

# ------------------------------------------

#region Slide 54 Multiple Catch Blocks

function Get-FileContent {
    param (
        [string]$Path
    )

    try {
        Write-Host "Attempting to read: $Path" -ForegroundColor Cyan
        $content = Get-Content -Path $Path -ErrorAction Stop
        Write-Host "File contents loaded successfully:" -ForegroundColor Green
        $content
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        Write-Host "File not found: $($_.Exception.Message)" -ForegroundColor Red
    }
    catch [System.UnauthorizedAccessException] {
        Write-Host "Access denied: $($_.Exception.Message)" -ForegroundColor Magenta
    }
    catch {
        Write-Host "A general error occurred: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    finally {
        Write-Host "Finished attempting to read the file (cleanup step)." -ForegroundColor DarkYellow
    }
}


# Demos:
# 1️⃣ Non-existent file triggers FileNotFoundException
Get-FileContent -Path "C:\no_such_file.txt"

# 2️⃣ A protected system file might trigger UnauthorizedAccessException
# (depending on permissions, you might demo with something like below)
New-Item -Path "C:\Temp\protected_file.txt" -ItemType File -Force | Out-Null
# Remove all permissions for the current user
$acl = Get-Acl -Path "C:\Temp\protected_file.txt"
$acl.SetAccessRuleProtection($true, $false)   # disable inheritance
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }
Set-Acl -Path 'C:\Temp\protected_file.txt' -AclObject $acl
Get-FileContent -Path "C:\Temp\protected_file.txt"

# 3️⃣ A general error (e.g., invalid path format)
Get-FileContent -Path $null

#endregion Slide 54 Multiple Catch Blocks


#-------------------------------------------





#region Slide 56 Scopes and Try, Catch, Finally

# Set the ErrorActionPreference to SilentlyContinue to suppress errors (optional)
$ErrorActionPreference = 'SilentlyContinue' 

Function function3 {
    Try {NonsenseCommand}
    Catch { write-host "Error trapped inside function" -BackgroundColor Black -ForegroundColor Magenta
            Throw 
    }
    Write-Host "Function3 was completed"
}

Try {Function3}
Catch { Write-Host "Internal Function error re-thrown: $($_.ScriptStackTrace)" -BackgroundColor Black -ForegroundColor DarkYellow}
Write-Host "Script Completed" -BackgroundColor Black -ForegroundColor Green 


# Reset the ErrorActionPreference to Continue
$ErrorActionPreference = 'Continue'

#endregion Slide 56 Scopes and Try, Catch, Finally