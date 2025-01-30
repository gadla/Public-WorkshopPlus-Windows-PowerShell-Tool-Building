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



#endregion Slide 18 Demonstrating Streams



# ------------------------------------------------------------------------------------


#region Slide 26 Demonstrating Write-Information
# **********************************************************************************
# Example 1: Demonstrating the use of Write-Host and Write-Information in PowerShell
# **********************************************************************************

# To capture messages written to the Information stream, we use a script block (& {})
# and redirect the output using the *>&1 syntax, which captures all streams into a variable.
# This allows us to process Information stream messages programmatically.
$informationMessages = & {
    Write-Information "This is an error message 1" -Tags "error"
    Write-Information "This is an error message 2" -Tags "error"
    Write-Information "This is an information message 3" -Tags "information"
    Write-Information "This is an information message 4" -Tags "information"
    Write-Information "This is an information message 5" -Tags "information"
    Write-Host "This is a message using Write-Host 6"
    Write-Host "This is a message using Write-Host 7"
    Write-Host "This is a message using Write-Host 8"
} *>&1 | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }

# Filtering and Sorting Messages by Tags

$filteredErrors = $informationMessages | Where-Object { $_.Tags -contains "error" }
$filteredInfo = $informationMessages | Where-Object { $_.Tags -contains "information" }
$filteredWriteHost = $informationMessages | Where-Object { $_.Tags -contains "PSHost" }
# Display the filtered messages by category. Note that these are InformationRecord objects,
# so their properties (e.g., MessageData) can be accessed if needed.
Write-Host "`nFiltered Error tag Messages:" -ForegroundColor Red
$filteredErrors | ForEach-Object { $_.MessageData }

Write-Host "`nFiltered Information tag Messages:" -ForegroundColor Green
$filteredInfo | ForEach-Object { $_.MessageData }

Write-Host "`nFiltered Write-Host tag Messages:" -ForegroundColor Yellow
$filteredWriteHost | ForEach-Object { $_.MessageData.Message }


# ***********************************************************************************
# Example 2: Demonstrating how to better work with the PowerShell Information stream.
# ***********************************************************************************

# Define an Enum for Tags
enum TagEnum {
    Status
    Main
}

# Define FunctionOne
function FunctionOne {
    Write-Information "FunctionOne executed" -Tags ([TagEnum]::Status)
}

# Define FunctionTwo
function FunctionTwo {
    Write-Information "FunctionTwo executed" -Tags ([TagEnum]::Status)
}

# Define Main function
function Main {
    Write-Information "Starting script execution" -Tags ([TagEnum]::Main)
    FunctionOne
    FunctionTwo
    Write-Host "Script main function execution completed" -BackgroundColor Black -ForegroundColor Yellow
}

# Capture and process Information stream output
$informationMessages = & {
    Main
} *>&1

# Display captured Information stream messages
$informationMessages | ForEach-Object {
    Write-Host "[$($_.Tags)]" -BackgroundColor Black -ForegroundColor Green -NoNewline
    Write-Host " - $($_.MessageData)"
}

#endregion Slide 26 Demonstrating Write-Information


# ------------------------------------------------------------------------------------



#region Slide 31 $Error - View all properties of ErrorRecord object

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

#endregion Slide 31 $Error - View all properties of ErrorRecord object


# ------------------------------------------------------------------------------------



#region Slide 41 Write-Error

$Error.Clear()
Write-Error 'This is an error message'
$Error
Write-Error 'This is another error message'
$Error
$Error[0]
Write-Error 'This is a hidden error' -ErrorAction 'SilentlyContinue'
$?
$Error[0]

#endregion Slide 41 Write-Error




# ------------------------------------------------------------------------------------



#region Slide 48-49 Throw

function test-throw {
    throw 'This is an error message'
    write-host 'This line will not be executed'
}

try{
    test-throw 
}
catch {
    "Error message: $_"
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

#endregion Slide 48-49 Throw



# ------------------------------------------


#region Slide 55 Trap


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
Get-Trap


#endregion Slide 55 Trap



# ------------------------------------------



#region Slide 60 Example: Try/Catch/Finally

function Test-MultipleCatch {
    param (
        [ScriptBlock]$Action
    )
    
    try {
        # Execute the action passed as a parameter
        & $Action
    } catch [System.DivideByZeroException] {
        Write-Output "Caught a divide by zero exception: $($_.Exception.Message)"
    } catch {
        Write-Output "Caught a general exception: $($_.Exception.Message)"
    }
    finally {
        Write-Host "Finally block executed" -BackgroundColor Black -ForegroundColor Green
    }
}

# Simulate error-triggering operations
$divideByZeroAction = { 1 / 0 }
$genericErrorAction = { throw "Unknown operation" }

# Test cases
Write-Host "`nTesting divide by zero exception:" -ForegroundColor Yellow
Test-MultipleCatch -Action $divideByZeroAction   # Handles divide by zero

Write-Host "`nTesting general exception:" -ForegroundColor Yellow
Test-MultipleCatch -Action $genericErrorAction   # Handles general exception


#endregion Slide 60 Example: Try/Catch/Finally



# ------------------------------------------



#region Slide 61 Scopes and Try, Catch, Finally

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

#endregion Slide 61 Scopes and Try, Catch, Finally