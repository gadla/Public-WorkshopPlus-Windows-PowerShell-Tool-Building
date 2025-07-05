#region Slide 7 Breakpoints - $PSDebugContextAutomatic variable

# When we are running and debugging a script, we can use the automatic variable $PSDebugContext to access the current debugging context.
# This variable is only available in the console for interactive debugging.
# The $PSDebugContext variable is a rich object that contains a lot of information about the current debugging context.
# We can use this variable to inspect the current state of the script, the call stack, and the variables in the current scope.



# The following code will not work in a script file, as $PSDebugContext is only available in the console.
#--------------------------------------------------------------------------------------------------------
# To test this code, you can copy and paste it into the console and run it.
# Don't forget to set a breakpoint in the script to see the debugging context.

Write-Host "Run this code in the console (F10)." -ForegroundColor Yellow
if($PSDebugContext) {
    # Display the current debugging context
    $PSDebugContext
} else {
    Write-Host "`$PSDebugContext is only populated while you're inside the debugger prompt, not while script code is actively running.” -ForegroundColor Yellow
}

# Create a breakpoint in the script
Set-PSBreakpoint -Script $MyInvocation.MyCommand.Path -Line 15

# ***************************************************
# In the console, check the $PSDebugContext variable
# ***************************************************

break

#endregion Slide 7 Breakpoints - $PSDebugContext Automatic variable



# -------------------------------------------------------


#region Slide 10-11 Debug common parameter

function Test-DebugCommonParameter {
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    Write-Debug "Debug message: The name is $Name"
    Write-Host "Hello, $Name!"
}

# The Debug common parameter is used to enable or disable debug messages in the output.
# It is a common parameter that is available in all cmdlets and functions.
Test-DebugCommonParameter -Name 'John Doe'
Test-DebugCommonParameter -Name 'John Doe' -Debug

# Change the DebugPreference to 'Continue' to see debug messages
$DebugPreference = 'Continue'
Test-DebugCommonParameter -Name 'Jane Doe'

# Note that when we change the DebugPreference to 'Continue', all debug messages will be displayed in the console.
# To reset the DebugPreference to the default value, we can set it to 'SilentlyContinue'.
$DebugPreference = 'SilentlyContinue'


#endregion Slide 10-11 Debug common parameter


# -------------------------------------------------------






#region Slide 12-17 Debugging with breakpoints

# Live demo: Debugging with breakpoints
# (F5) Continue 
# (F9) Toggle breakpoint
# (F10) Step over
# (F11) Step into
# (Shift + F11) Step out


# Working with BreakPoints cmdlets
# Get-PSBreakpoint
# Set-PSBreakpoint -Script .\M05_Debugging.ps1 -Line 14
# Line Breakpoint
# Command Breakpoint
Set-PSBreakpoint -Command 'Get-Service' -Action {write-host 'Get-Service activated' -BackgroundColor Black -ForegroundColor Magenta}
Get-Service -Name 'Spooler'
# Variable Breakpoint
$MyVar = 'Hello'
Set-PSBreakpoint -Variable 'MyVar' -Mode Read -Action {write-host 'MyVar read' -BackgroundColor Black -ForegroundColor Magenta}
$MyVar
Set-PSBreakpoint -Variable 'MyVar' -Mode Write -Action {Write-Host 'MyVar written' -BackgroundColor Black -ForegroundColor DarkBlue}
$MyVar = 'Hello World'


# Demo Debugging in VS Code vs PowerShell ISE
# In VS Code, you can set breakpoints by clicking on the left margin next to the line number.
# Demo Conditional Breakpoint
#   (1) Expression: we can declare an evaluation of an expression when the breakpoint is hit.
#     if the expression evaluates to true, the breakpoint is hit.

function Test-ExpressionBreakpoint {
    $counter = 0
    while ($counter -lt 5) {
        Write-Host "Counter is $counter"
        Start-Sleep -Seconds 1
        $counter++
    }
}


#   (2) Hit count: we can specify how many times the breakpoint should be hit before it is triggered.

function Test-HitCount {
    1..100 | ForEach-Object {
        Write-Host "Processing item $_"
        Start-Sleep -Milliseconds 100
    }
}
# Create a breakpoint with a hit count on line 'Write-Host "Processing item $_"'
Test-HitCount


#  (3) Log message: we can specify a message to be logged when the breakpoint is hit.
function Test-LogMessage {
    $counter = 0
    while ($counter -lt 5) {
        Write-Host "Counter is $counter"
        Start-Sleep -Seconds 1
        $counter++
    }
}

# Create a breakpoint with a log message on line 'Write-Host "Counter is $counter"'
Test-LogMessage




#   (4) Wait for breakpoint: we can specify that the script should wait for the breakpoint to be hit before continuing.
function Test-WaitForBreakpoint {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ($Name -eq 'Bob'){
        Write-Host "Hello, Bob!"
    }

    Write-Host 'You got your breakpoint here!'

   
}
# Create a breakpoint in the script
# then run the function to wait for it
Test-WaitForBreakpoint -Name 'Bob'
# Nothing new here!
# create another breakpoint in the script
# Edit the breakpoint and 'Wait for breakpoint' and choose the first breakpoint
Test-WaitForBreakpoint -Name 'Dan' #Notice that the breakpoint is not hit here
#endregion Slide 12-17 Debugging with breakpoints

#--------------------------------------------------------


#region Slide 29 Command-Line Debugging

# Open a new PowerShell console
# Copy the file from the sample files to the temp folder
Copy-Item -Path 'C:\repo\WorkshopPlus-Windows-PowerShell-Tool-Building-Private\M06_Debugging\Sample files\MyScript.ps1' -Destination 'C:\temp\MyScript.ps1'
# Run the script file in the console
& 'C:\temp\MyScript.ps1'
# Create a line breakpoint in the script file
Set-PSBreakpoint -Script 'C:\temp\MyScript.ps1' -Line 18 # Outside the function
# Run the script file in the console
& 'C:\temp\MyScript.ps1'

# The script will stop at the breakpoint


#endregion Slide 29 Command-Line Debugging

# -------------------------------------------------------



#region Slide 31 Debuging functions in PowerShell Console

# Open a new PowerShell console
# Copy the code and paste it into the console
function Test-DebugFunction {
    begin {
        Write-Host "Begin" 
    }
    process {
       Write-Host "Process"
    }
    end {
       Write-Host "End"
    }
} 

Set-PSBreakpoint -Command Test-DebugFunction
Test-DebugFunction

# The script will stop at the breakpoint
# Use ? to display the help

#endregion Slide 31 Debuging PowerShell Console



# -------------------------------------------------------

#region Slide 37 Debugging remote script using PowerShell Console

# Open up the lab environment
# Login to HybridPc11
# Open PowerShell console
# Enter the following command to start a remote session with the HybridAdConnect server:
Enter-PSSession -ComputerName HybridAdConnect
Set-PSBreakpoint -Script C:\repo\RemoteDebugScript.ps1 -Line 18
# Run the script file in the console
& 'C:\repo\RemoteDebugScript.ps1'

#endregion Slide 37 Debugging remote script using PowerShell Console

#-------------------------------------------------------


#region Slide 39 Debugging remote script using PowerShell ISE

Write-Host 'Debugging remote script using PowerShell ISE' -ForegroundColor Yellow
<#
    Login to HybridPc11 
    Open PowerShell ISE
    Enter the following command to start a remote session with the HybridAdConnect server:

    Enter-PSSession -ComputerName HybridAdConnect
    PSEdit 'C:\repo\RemoteDebugScript.ps1'
    
    # Set a breakpoint in the script using the GUI
    # Run the command

    Get-PSBreakpoint
    
    # The breakpoint will be displayed
    # Run the script

#>

#endregion Slide 39 Debugging remote script using PowerShell ISE



# -------------------------------------------------------


#region Slide 43 Debugging and scopes

Write-Host 'Debugging and scopes' -ForegroundColor Yellow

$scriptContent = @'
Write-Host "Script starting..."
Write-host "the `$DebugExample variable is not defined yet, value is: $DebugExample"
$DebugExample = "Hello, World!"
Write-Host "Value is $DebugExample"
'@

# Create the file
$scriptContent | Out-File -Path C:\temp\DebugScopes.ps1


<#
    Open a new PowerShell console
    Set-PSBreakpoint -Script C:\temp\DebugScopes.ps1 -Line 3
    # Run the script file in the console
    C:\temp\DebugScopes.ps1
    # The script will stop at the breakpoint
    $DebugExample

#>


#endregion Slide 43 Debugging and scopes

# -------------------------------------------------------



#region Slide 45 Debugging scripts (Set-PSDebug)


##################################
#        Set-PSDebug -Step       #
##################################
<#
    # Open a new PowerShell Host
    # Run the following command to enable debugging in the script:
    Set-PSDebug -Step
    Set-PSBreakpoint -Script C:\temp\DebugScopes.ps1 -Line 3
    # Run the script
    c:\temp\debugScopes.ps1
    # The script will stop at the first line
    # You can choose to step through the script [Y] Yes
    # If you choose to step through the script, the script will stop at each line
    # You can choose to pause the script [S] Suspend and enter DEBUG MODE
    # This is a limited interactive debugging mode.
    # To exit the script choose [N] No

    IMPORTANT:
    Don't forget to turn off the debugging mode after you are done with it.
    Set-PSDebug -Off
#>






##################################
#      Set-PSDebug -Trace 2      #
##################################

# Create a script file with the following content
$scriptContent = @'
# Save as C:\temp\DebugSimple.ps1
Write-Host "Trace test starting..."

$number = 5
$number = $number * 2

Write-Host "Result is $number"
'@

$scriptContent |  Out-File -PsPath C:\temp\DebugSimple.ps1

Set-PSDebug -Trace 1
C:\temp\DebugSimple.ps1
Set-PSDebug -Off

Set-PSDebug -Trace 2
C:\temp\DebugSimple.ps1
Set-PSDebug -Off


#endregion Slide 45 Debugging scripts (Set-PSDebug)


# -------------------------------------------------------


#region Slide 47 Set-StrictMode

<#
    The Set-StrictMode cmdlet enforces strict coding practices in PowerShell scripts.
    Versions:
    
    | Strict Mode Version | Introduced In  | Key Features                                                                                            | Use Case                                                        
    | ------------------- | -------------- | ----------------------------------------------------------------------------------------------          | --------------------------------------------------------------- 
    | Off (Default)       | PowerShell 1.0 | No strict enforcement of variable declaration or type constraints.                                      | Useful for quick scripts or backward compatibility.             
    | Version 1           | PowerShell 1.0 | Requires variables to be declared before use.<br>Prevents referencing non-existent properties.          | Helps catch typos and ensures variables are explicitly defined. 
    | Version 2           | PowerShell 2.0 | Includes all Version 1 features.<br>Disallows referencing non-existent function arguments.              | Adds stricter checks for function arguments.                    
    | Version 3           | PowerShell 3.0 | Includes all Version 2 features.<br>Disallows referencing uninitialized variables.                      | Ensures variables are initialized before use.                   
    | Latest              | PowerShell 5.0 | Includes all previous features.<br>Disallows using variables that are not defined in the current scope. | Enforces strict variable scoping and initialization.            
#>

#######################
# Set-StrictMode -Off #
#######################

Set-StrictMode -Off

Remove-Variable -Name myVar -ErrorAction SilentlyContinue
$var -gt 5

#Set-StrictMode -Version 1.0
# This will throw an error because $myVar is not defined
Set-StrictMode -Version 1.0
Remove-Variable -Name myVar -ErrorAction SilentlyContinue
$myVar -gt 5



###############################
# Set-StrictMode -Version 2.0 #
###############################

$string = 'This is a string'
$null -eq $string.Month
# This will not throw an error

Set-StrictMode -Version 2.0
$null -eq $string.Month
# This will throw an error because $string does not have a property called Month


###############################
# Set-StrictMode -Version 3.0 #
###############################

$a = @(1)
$null -eq $a[2]
$null -eq $a['abc'] # This doesn't make sense, but it will not throw an error

Set-StrictMode -Version 3.0
$null -eq $a[2] # This will throw an error because the index is out of bounds
$null -eq $a['abc'] # This will throw an error because the index is

#endregion Slide 47 Set-StrictMode

# -------------------------------------------------------

#region Slide 51 Get-PSCallStack


function FunctionA {
    FunctionB
}

function FunctionB {
    FunctionC
}

function FunctionC {
    Get-PSCallStack  # Retrieves the call stack
}

FunctionA

<#
Call Stack and Debugging
------------------------
When a breakpoint is hit or an error occurs, 
the call stack helps trace the sequence of operations that led to the issue. 
This is especially useful in complex scripts or nested function calls.
#>

#endregion Slide 51 Get-PSCallStack


# -------------------------------------------------------



#region Slide 52 Trace-Command

Trace-Command -Expression {Get-Service -Name BITS} -PSHost -Option All -Name ParameterBinding # Named parameter
Trace-Command -Expression {Get-Service BITS} -PSHost -Option All -Name ParameterBinding # Positional parameter

Trace-Command -Expression {Get-Service -Name BITS} -PSHost -Option All -Name CommandDiscovery
set-alias -Name Get-Service -Value Get-Date
Get-Service
Trace-Command -Expression {Get-Service -Name BITS} -PSHost -Option All -Name CommandDiscovery


# The name parameter specifies the trace to display
# What names of traces are available?
Get-TraceSource


#endregion Slide 52 Trace-Command