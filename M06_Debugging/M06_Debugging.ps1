#region Slide 7 Breakpoints - Automatic variable

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
    Write-Host "This script is not running in a debugging context." -ForegroundColor Yellow
}


break


#endregion Slide 7 Breakpoints - Automatic variable



# -------------------------------------------------------


#region Slide 12 Debug common parameter


# Note that this code behaves differently in Windows PowerShell and PowerShell 7
Function Bits {
    [Cmdletbinding()]
    Param()
    $Service = Get-Service -Name Bits
    $Service
    Write-Debug "Debug enabled: status is $($Service.Status)"
}

Bits
$DebugPreference
Bits -Debug
$DebugPreference = 'Continue'
Bits

# Reset the DebugPreference to the default value
$DebugPreference = 'SilentlyContinue'


#endregion Slide 12 Debug common parameter



# -------------------------------------------------------




#region Slide 14-28 Debugging with breakpoints

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
# Variable Breakpoint
$MyVar = 'Hello'
Set-PSBreakpoint -Variable 'MyVar' -Mode Read -Action {write-host 'MyVar read' -BackgroundColor Black -ForegroundColor Magenta}
$MyVar
Set-PSBreakpoint -Variable 'MyVar' -Mode Write -Action {Write-Host 'MyVar written' -BackgroundColor Black -ForegroundColor DarkBlue}
$MyVar = 'Hello World'

#endregion Slide 14-28 Debugging with breakpoints



# -------------------------------------------------------



#region Slide 34 Debuging PowerShell Console

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

# The script will stop at the breakpoint
# Use ? to display the help

#endregion Slide 34 Debuging PowerShell Console



# -------------------------------------------------------





#region Slide 41 Debugging remote script using PowerShell ISE

<#
    Login to CAAD2 server 
    Open PowerShell ISE
    Enter the following command to start a remote session with the CAAD1 server:

    Enter-PSSession -ComputerName CDC1
    PSEdit 'C:\temp\My Script1.ps1'
    
    # Set a breakpoint in the script using the GUI
    # Run the command

    Get-PSBreakpoint
    
    # The breakpoint will be displayed
    # Run the script
    # You can't use the ISE to start the script, you need to use the console

    & 'C:\temp\My Script1.ps1'
    # The script will stop at the breakpoint
    # Use the ISE to debug the script

#>

#endregion Slide 41 Debugging remote script using PowerShell ISE



# -------------------------------------------------------



#region Slide 49 Debugging scripts (Set-PSDebug)


##################################
#        Set-PSDebug -Step       #
##################################
<#
    # Open a new PowerShell Host
    # Run the following command to enable debugging in the script:
    Set-PSDebug -Step
    # Run the script
    c:\temp\MyScript.ps1
    # The script will stop at the first line
    # You can choose to step through the script [Y] Yes
    # If you choose to step through the script, the script will stop at each line
    # You can choose to pause the script [S] Suspend and enter DEBUG MODE
    # This is a limited interactive debugging mode.
    # To exit the script choose [N] No
#>





##################################
#      Set-PSDebug -Trace 2      #
##################################
<#
    # Open a new PowerShell Host
    # Run the following command to enable tracing in the script:
    Set-PSDebug -Trace 1
    # Run any command
    Get-Service -Name BITS

    # Set the trace level to 2
    Set-PSDebug -Trace 2
    Get-Service -Name BITS

    # Turn off the trace
    Set-PSDebug -Trace 0
#>

#endregion Slide 49 Debugging scripts (Set-PSDebug)



# -------------------------------------------------------



#region Slide 51 Debugging scripts (Set-PSDebug)

Set-StrictMode -Version Latest
Write-Output "The value of `$myVar is: $myVar"

# Set-StrictMode
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-5.1
# about_Language_Modes
https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_language_modes?view=powershell-5.1

# Reset the StrictMode to the default value
Set-StrictMode -Off

#endregion Slide 51 Debugging scripts (Set-PSDebug)



# -------------------------------------------------------



#region Slide 55 Get-PSCallStack

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

#endregion Slide 55 Get-PSCallStack



# -------------------------------------------------------




#Slide 56 Trace-Command

Trace-Command -Expression {Get-Service -Name BITS} -PSHost -Option All -Name CommandDiscovery
Trace-Command -Expression {gsv -Name BITS} -PSHost -Option All -Name CommandDiscovery
Trace-Command -Expression {Get-Service -Name BITS} -PSHost -Option All -Name ParameterBinding

# The name parameter specifies the trace to display
# What names of traces are available?
Get-TraceSource


#endregion Slide 51 Debugging scripts (Set-PSDebug)