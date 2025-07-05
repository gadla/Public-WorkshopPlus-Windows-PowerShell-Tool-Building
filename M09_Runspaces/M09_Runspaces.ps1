
#region Before the presentation - Foreach-Object -Parallel
#---------------------------------------------------------

# Note: this code requires PowerShell 7.0 or later to run.
$ScriptBlock = {
    $wait = get-random -Minimum 1 -Maximum 3;start-sleep -Seconds $wait
    Write-Host "I am number $_ , I have slept for $wait seconds"
}

# Run the script and observe the output. The script will display the numbers 1 to 10 with a random sleep time between 1 and 3 seconds.
1..10 | ForEach-Object -Process $ScriptBlock

# Run the script with the -parallel parameter. The script will display the numbers 1 to 10 with a random sleep time between 1 and 3 seconds. The output will be displayed in a random order, as the commands are executed in parallel.
1..10 | ForEach-Object -parallel $ScriptBlock

# Measure the time taken to run the script without the -parallel parameter.
Measure-Command -Expression {1..10 | ForEach-Object $ScriptBlock}

# Measure the time taken to run the script with the -parallel parameter.
Measure-Command -Expression {1..10 | ForEach-Object -parallel $ScriptBlock}

# Run the script with the -throttleLimit parameter. The script will display the numbers 1 to 10 with a random sleep time between 1 and 3 seconds. The output will be displayed in order, with a maximum of 3 commands running in parallel.
1..10 | ForEach-Object -parallel $ScriptBlock -throttleLimit 3
Measure-Command -Expression {1..10 | ForEach-Object -parallel $ScriptBlock -throttleLimit }

#------------------------------------------------------------
#endregion Before the presentation - Foreach-Object -Parallel




#-----------------------------------------------------------------





#region Slides 10 - Runspaces using the [PowerShell] Type

# Step 1: Create a PowerShell object
$PowerShell = [PowerShell]::Create()

# Step 2: Add a simple script block
$ScriptBlock = {
    $wait = Get-Random -Minimum 6 -Maximum 7
    Start-Sleep -Seconds $wait
    Write-Output "Runspace executed: I slept for $wait seconds"
}
$PowerShell.AddScript($ScriptBlock) | Out-Null

# Step 3: Invoke the script synchronously
Write-Host "Invoking the runspace..." -BackgroundColor Black -ForegroundColor Yellow
$Result = $PowerShell.Invoke()

# Step 4: Display the results
Write-Host "Runspace Result:" -BackgroundColor Black -ForegroundColor Green
$Result

# Step 5: Check the runspace state (optional for understanding lifecycle)
Write-Host "Runspace State:"
$PowerShell.Runspace.RunspaceStateInfo

# Step 6: Cleanup the resources
$PowerShell.Dispose()


#endregion Slides 10 - Runspaces using the [PowerShell] Type




#-----------------------------------------------------------------





#region Slide 13 - Runspaces Cmdlets


# Display the runspaces
Get-Runspace

# Create a new runspace using the [PowerShell] type
$PowerShell = [PowerShell]::Create()

# Display the runspaces again, notice that no new runspace is created yet
Get-Runspace

$ScriptBlock = {
    $wait = Get-Random -Minimum 1 -Maximum 3
    Start-Sleep -Seconds $wait
    "Runspace executed: I slept for $wait seconds"
}

# Adding the script to our $PowerShell object will instantiate the runspace.
$PowerShell.AddScript($ScriptBlock) | Out-Null

# Display the runspaces again, notice the new runspace did not created additional runspace.
# This is because the runspace is not yet invoked.
Get-Runspace

$PowerShell.Invoke()

# display the runspaces
Get-Runspace

$powershell.Dispose()

# Notice that the runspace created using the [PowerShell] type is removed.
Get-Runspace


#endregion Slide 13 - Runspaces Cmdlets


#-----------------------------------------------------------------


#region Slide 17 Runspace Session State

$Host.Runspace | Select-Object -Property *
$Host.Runspace.InitialSessionState

#endregion Slide 17 Runspace Session State


#-----------------------------------------------------------------



#region Slide 21 Creating and Iniializing Custom Runspaces -  Example 2
$Name = 'Ely'
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault() 
$sessionVariable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new("Instructor", $Name, 'Description')
$InitialSessionState.Variables.Add($sessionVariable) 
$PowerShell = [powershell]::Create($InitialSessionState) 
$PowerShell.AddScript({Write-Output "`$Instructor is $Instructor";Get-Process | Select-Object -First 5}) | Out-Null
$PowerShell.Invoke()
$PowerShell.Dispose()



<#
    What else can you do with InitialSessionState?

    ▶ Preload Modules
        - Example:
          $InitialSessionState.ImportPSModule("ActiveDirectory")
        - or load from a specific folder:
          $InitialSessionState.ImportPSModulesFromPath("C:\Path\To\Module")

    ▶ Preload Scripts
        - Example:
          $InitialSessionState.Scripts.Add("C:\Path\To\StartupScript.ps1")

    ▶ Restrict Available Cmdlets
        - You can clear all commands:
          $InitialSessionState.Commands.Clear()
        - Then add back only specific ones:
          $WriteOutputCmd = [System.Management.Automation.Runspaces.SessionStateCmdletEntry]::new(
              "Write-Output",
              [Microsoft.PowerShell.Commands.WriteOutputCommand],
              $null
          )
          $InitialSessionState.Commands.Add($WriteOutputCmd)

    ▶ Add Session Variables
        - Example:
          $sessionVariable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new(
              "name", "value", $null
          )
          $InitialSessionState.Variables.Add($sessionVariable)

    ▶ Launch a PowerShell instance with this session state:
        $PowerShell = [powershell]::Create($InitialSessionState)
        $PowerShell.AddScript({
            Write-Output "`$name is $name"
            Get-Process | Select-Object -First 5  # This should fail because Get-Process is not allowed
        })
        $Result = $PowerShell.Invoke()

        if ($PowerShell.Streams.Error.Count -gt 0) {
            $PowerShell.Streams.Error | ForEach-Object { $_.Exception.Message }
        } else {
            $Result
        }
        $PowerShell.Dispose()
#>

#endregion Slide 21 Creating and Iniializing Custom Runspaces




# -----------------------------------------------------------------



#region Slide 22 Creating and Initializing Custom Runspaces using PSSC file - Example 3


$PSSessionConfigParams = @{
            ExecutionPolicy             = 'Bypass'
            Full                        = $true
            LanguageMode                = 'FullLanguage'
            ModulesToImport             = @('ActiveDirectory')
            Path                        = 'C:\temp\pssc1.pssc'
            VisibleCmdlets              = @('Get-Process','Start-Service','Stop-Service')
            VisibleFunctions            = @('Get-Date','Get-Random')
}

New-PSSessionConfigurationFile @PSSessionConfigParams

# Create an InitialSessionState object from the session configuration file
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateFromSessionConfigurationFile("C:\temp\pssc1.pssc")

# Add a variable to the InitialSessionState
$Variable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new("Name", "Gadi Lev-Ari", 'My Name')
$InitialSessionState.Variables.Add($Variable)

# Create a PowerShell instance using the customized session state
$PowerShell = [powershell]::Create($initialSessionState)

# Add a script block that uses the $Name variable
$ScriptBlock = {
    Write-Output "The value of the variable `Name` is: $Name"
}

# Add the script block to the PowerShell instance
$PowerShell.AddScript($ScriptBlock)

# Invoke the script block and capture the output
$Result = $PowerShell.Invoke()

# Output the result
$Result

##############################################################
# Question: Why is the output empty? What can we do to fix it?
##############################################################

<#
📝 Why is the output empty?

👉 You created a PSSession Configuration File (.pssc) with these restrictions:
    🔹 VisibleCmdlets only:
        - Get-Process, Start-Service, Stop-Service
    🔹 VisibleFunctions only:
        - Get-Date, Get-Random

🚫 By default, all other functions/cmdlets, including Write-Output, are not visible
    because they are not on the VisibleCmdlets list.

⚙️ When you run:
      Write-Output "The value of the variable `Name` is: $Name"
    inside that constrained session, the command Write-Output is not visible
    and therefore cannot be found or executed.

❗ That is why you see empty output (effectively the pipeline fails to emit data).

✅ How to fix it?

🛠️ You must explicitly add Write-Output to VisibleCmdlets in the PSSession
    Configuration file, for example:
      VisibleCmdlets = @('Get-Process','Start-Service','Stop-Service','Write-Output')
    then regenerate the .pssc, reload the InitialSessionState, and rerun.
#>



# Dispose of the PowerShell instance
$PowerShell.Dispose()


#endregion Slide 22 Creating and Initializing Custom Runspaces




# -----------------------------------------------------------------




#region Slide 28 Synchronus Processing

# This demonstrates the problem with synchronous processing.
# In synchronous processing, the execution of the script will block
# the current thread until the operation completes, causing delays.

# Create a new PowerShell instance
$Powershell = [PowerShell]::Create() 

# Add a script block to the PowerShell instance
# This script simulates work by pausing for 5 seconds and then outputs 'Done'
$PowerShell.AddScript({Start-Sleep -Seconds 5; 'Done'})

# Invoke the script synchronously
# The execution will block the current thread until the script completes.
# While the script is sleeping for 5 seconds, the program cannot perform other tasks or operations.
$PowerShell.Invoke()

# Clean up the PowerShell instance to release resources
$PowerShell.Dispose()



#endregion Slide 28 Synchronus Processing




# -----------------------------------------------------------------





#region Slide 30 Asynchronous Processing

# Create a new PowerShell instance
$Powershell = [PowerShell]::Create() 

# Add a script block to the PowerShell instance
# The script block simulates work by pausing for 5 seconds and then outputs 'Done'
$PowerShell.AddScript({Start-Sleep -Seconds 15; Write-Output 'Done'}) | Out-Null

# Begin asynchronous execution of the script block
# This starts the script execution but does not block the current thread
$Async = $PowerShell.BeginInvoke()

# Output the async object to show its state
# This object can be used to check the status or retrieve results of the script
$Async

# Retrieve the results of the asynchronous operation
# This waits for the script execution to complete and retrieves the output
$PowerShell.EndInvoke($Async)

# Clean up the PowerShell instance to release resources
$PowerShell.Dispose()


#endregion Slide 30 Asynchronous Processing



# -----------------------------------------------------------------



#region Slide 38 - Using RunspacePool

$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, 5) # Create a runspace pool with a minimum of 1 and a maximum of 5 runspaces
$RunspacePool.Open()                                        # Open the runspace pool
$RunspacePool.GetAvailableRunspaces()                       # Output: 5
[System.Collections.ArrayList]$RunspaceList = @()           # Create an array list to store the runspace instances

foreach ($RunspaceInstance in 1..100) {
    # Create a runspace instance and assign it to the pool
    $powershellinstance = [PowerShell]::Create()
    $powershellinstance.RunspacePool = $RunspacePool
    # Add a script block to the runspace instance
    [void]$powershellinstance.AddScript({
        param($id)
        $wait = Get-Random -Minimum 1 -Maximum 3
        Start-Sleep -Seconds $wait
        Write-Output "Runspace $id completed in $wait seconds"
    }).AddArgument($RunspaceInstance)

    # Add all the data into a results table
    $RunspaceList.Add([PSCustomObject]@{
        RunspaceInstance = $RunspaceInstance
        PowerShellInstance = $powershellinstance
        Status = $powershellinstance.BeginInvoke()
    })
}

# Wait for all runspaces to complete
do {
    # Count the number of runspaces that are not completed
    $IncompleteRunspaces = $RunspaceList | Where-Object { -not $_.Status.IsCompleted }
    $CountIncomplete = $IncompleteRunspaces.Count

    if ($CountIncomplete -gt 0) {
        # Output the count of incomplete runspaces and wait for 500ms
        Write-Host "$CountIncomplete runspaces are still not completed. Waiting..." -BackgroundColor Black -ForegroundColor Yellow
        Start-Sleep -Milliseconds 500
    }
} while ($CountIncomplete -gt 0)

# Collect results from completed runspaces
$RunspacesResults = @()  # Initialize results array

foreach ($Runspace in $RunspaceList) {
    # Retrieve the results of the completed runspace
    $Result = $Runspace.PowerShellInstance.EndInvoke($Runspace.Status)

    # Add the result to the RunspacesResults array
    $RunspacesResults += [PSCustomObject]@{
        RunspaceInstance = $Runspace.RunspaceInstance
        Output = $Result
    }

    # Dispose of the PowerShell instance to free resources
    $Runspace.PowerShellInstance.Dispose()
}

# Clean up the runspace pool
$RunspacePool.Close()
$RunspacePool.Dispose()

# Display the collected results
$RunspacesResults

#endregion Slide 38 - Using RunspacePool


# -----------------------------------------------------------------



#region Slides 43 - Debugging Runspace 


# Run this outside of the vscode

$PowerShell = [PowerShell]::Create()
$PowerShell.Runspace.Name = 'DebugTest'
$PowerShell.AddScript({
    do{
        $Number += 2
        $wait = Get-Random -Minimum 1 -Maximum 3
        Start-Sleep -Seconds $wait
    } while ($true) # Infinite loop    
}) | Out-Null
$PowerShell.BeginInvoke()

# Enter the debugger
Debug-Runspace -Name 'DebugTest'

# clean up
$PowerShell.Dispose()


#endregion Slides 43 - Debugging Runspace



# -----------------------------------------------------------------


#region Slide 45 Runspace Streams

# Create a PowerShell instance
$PowerShell = [PowerShell]::Create()

# Add a script block with intentional errors and informational messages
$PowerShell.AddScript({
    Write-Output "Starting the script..."
    Write-Verbose "This is a verbose message" -Verbose
    Write-Debug "This is a debug message" -Debug
    Write-Warning "This is a warning message"
    Write-Information "This is an informational message"
    1 / 0  # Intentional divide-by-zero error
}) | out-null

# Invoke the script (this will execute it)
$PowerShell.Invoke()

# View the content of all streams
Write-Host "`n--- Runspace Streams ---" -ForegroundColor Cyan
Write-Host "Error Stream:" -ForegroundColor Red
$PowerShell.Streams.Error

Write-Host "`nVerbose Stream:" -ForegroundColor Green
$PowerShell.Streams.Verbose

Write-Host "`nDebug Stream:" -ForegroundColor Blue
$PowerShell.Streams.Debug

Write-Host "`nWarning Stream:" -ForegroundColor Magenta
$PowerShell.Streams.Warning

Write-Host "`nInformation Stream:" -ForegroundColor Cyan
$PowerShell.Streams.Information

# Clean up the PowerShell instance
$PowerShell.Dispose()


#endregion Slide 45 Runspace Streams


# -----------------------------------------------------------------


#############################################
#         a sample runspace demo            #
#############################################
Get-Help -Name 'C:\repo\WorkshopPlus-Windows-PowerShell-Tool-Building-Private\m09_Runspaces\Sample Files\Parallel-FoodDelivery-Demo.ps1' -ShowWindow
& 'C:\repo\WorkshopPlus-Windows-PowerShell-Tool-Building-Private\m09_Runspaces\Sample Files\Parallel-FoodDelivery-Demo.ps1'
& 'C:\repo\WorkshopPlus-Windows-PowerShell-Tool-Building-Private\m09_Runspaces\Sample Files\Parallel-FoodDelivery-Demo.ps1' -DeliveryEmployees 30

