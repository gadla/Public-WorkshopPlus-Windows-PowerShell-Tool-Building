
#region Before the presentation - Foreach-Object -Parallel
#---------------------------------------------------------
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
Measure-Command -Expression {1..10 | ForEach-Object -parallel $ScriptBlock -throttleLimit 3}

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
Write-Host "Invoking the runspace..."
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

# Display the runspaces again, notice the new runspace created using the [PowerShell] type
Get-Runspace

$PowerShell.Invoke()

# display the runspaces
Get-Runspace

$powershell.Dispose()

# Notice that the runspace created using the [PowerShell] type is removed.
Get-Runspace


#endregion Slide 13 - Runspaces Cmdlets





#-----------------------------------------------------------------



#region Slide 21 Creating and Iniializing Custom Runspaces
$Instructor = 'Ely'
$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault() 
$sessionVariable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new("name", $Instructor, 'Description')
$InitialSessionState.Variables.Add($sessionVariable) 
$PowerShell = [powershell]::Create($InitialSessionState) 
$PowerShell.AddScript({Write-Output "`$name is $name";Get-Process | Select-Object -First 5}) | Out-Null
$PowerShell.Invoke()
$PowerShell.Dispose()

# Change the value of the variable from $name to $var and 


<#
    What else can I do with InitialSessionState?
    Preload Modules
    $InitialSessionState.ImportPSModule("ActiveDirectory")
    $InitialSessionState.ImportPSModulesFromPath("Full Path to your module")

    Preload Scripts
    $InitialSessionState.Scripts.Add("Path\To\StartupScript.ps1")

    Restrict Cmdlets
    $InitialSessionState.Commands.Clear()
    $WriteOutputCmd = [System.Management.Automation.Runspaces.SessionStateCmdletEntry]::new(
        "Write-Output", 
        [Microsoft.PowerShell.Commands.WriteOutputCommand], 
        $null
    )
    $InitialSessionState.Commands.Add($WriteOutputCmd)
    $sessionVariable = [System.Management.Automation.Runspaces.SessionStateVariableEntry]::new("name", "value", $null)
    $InitialSessionState.Variables.Add($sessionVariable)
    $PowerShell = [powershell]::Create($InitialSessionState)
    $PowerShell.AddScript({
        Write-Output "`$name is $name"
        Get-Process | Select-Object -First 5 # This should fail
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



#region Slide 22 Creating and Initializing Custom Runspaces using PSSC file

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
$PowerShell.AddScript({Start-Sleep -Seconds 15; Write-Output 'Done'})

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



#region Slide 37-39 - Using RunspacePool

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
        $wait = Get-Random -Minimum 1 -Maximum 3
        Start-Sleep -Seconds $wait
        Write-Output "Runspace $RunspaceInstance completed in $wait seconds"
    })
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

#endregion Slide 37-39 - Using RunspacePool


# -----------------------------------------------------------------



#region Slides 42-47 - Debugging Runspace 


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


#endregion Slides 42-47 - Debugging Runspace



# -----------------------------------------------------------------


#region Slide 46 Runspace Streams

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


#endregion Slide 46 Runspace Streams


# -----------------------------------------------------------------


#region Another Example of RunspacePool


<#
This PowerShell demo demonstrates the use of runspaces to process multiple customer food orders concurrently, 
significantly improving efficiency over sequential processing. 
A runspace pool with up to 100 threads manages the tasks, 
each representing an order with customer details, a random food item, and an estimated delivery time. 
The script uses BeginInvoke for asynchronous execution and EndInvoke to collect results after completion. 
This approach minimizes execution time while logging progress and results, 
showcasing the power of parallel processing in PowerShell.

You can control the number of delivery employees (runspaces) 
by adjusting the minimum and maximum values in the CreateRunspacePool method.
#>


# Define the script block that each runspace will execute
$scriptBlock = {
    param($CustomerName, $CustomerAddress, $FoodProduct, $wait)
    Start-Sleep -Seconds $wait
    "$FoodProduct delivered to $CustomerName at $CustomerAddress, the order took $wait seconds"
}
 
# Create a runspace pool with 5 instances
$pool = [runspacefactory]::CreateRunspacePool(1, 5) # Change here the number of delivery employees
$pool.Open()
 
# Collection to hold the runspaces
$runspaces = @()
 
# Define customer list
$customers = @(
    @{ Name = "John Doe"; Address = "123 Main St" },
    @{ Name = "Jane Smith"; Address = "456 Oak Ave" },
    @{ Name = "Alice Brown"; Address = "789 Maple St" },
    @{ Name = "Bob Johnson"; Address = "101 Pine Rd" },
    @{ Name = "Chris Evans"; Address = "202 Elm Dr" },
    @{ Name = "Diana Prince"; Address = "303 Willow Ln" },
    @{ Name = "Ethan Hunt"; Address = "404 Cedar Ct" },
    @{ Name = "Fiona Gallagher"; Address = "505 Birch Blvd" },
    @{ Name = "George Clooney"; Address = "606 Aspen Way" },
    @{ Name = "Hannah Montana"; Address = "707 Chestnut Ave" },
    @{ Name = "Bruce Wayne"; Address = "900 Wayne Manor" },
    @{ Name = "Clark Kent"; Address = "1000 Daily Planet" },
    @{ Name = "Peter Parker"; Address = "20 Ingram St" },
    @{ Name = "Tony Stark"; Address = "10880 Malibu Point" },
    @{ Name = "Natasha Romanoff"; Address = "S.H.I.E.L.D HQ" },
    @{ Name = "Steve Rogers"; Address = "Brooklyn Heights" },
    @{ Name = "Thor Odinson"; Address = "Asgard" },
    @{ Name = "Wanda Maximoff"; Address = "Westview" },
    @{ Name = "Stephen Strange"; Address = "177A Bleecker St" },
    @{ Name = "T'Challa"; Address = "Wakanda" },
    @{ Name = "Bruce Banner"; Address = "Culver University" },
    @{ Name = "Scott Lang"; Address = "San Francisco" },
    @{ Name = "Hope Van Dyne"; Address = "San Francisco" },
    @{ Name = "Carol Danvers"; Address = "Orbit Station" },
    @{ Name = "Nick Fury"; Address = "The Helicarrier" },
    @{ Name = "Sam Wilson"; Address = "Washington DC" },
    @{ Name = "Bucky Barnes"; Address = "Brooklyn" },
    @{ Name = "Shuri"; Address = "Wakanda Tech Lab" },
    @{ Name = "Loki Laufeyson"; Address = "The Void" },
    @{ Name = "Groot"; Address = "Planet X" },
    @{ Name = "Rocket Raccoon"; Address = "Knowhere" },
    @{ Name = "Drax"; Address = "The Quadrant" },
    @{ Name = "Gamora"; Address = "Zen-Whoberi" },
    @{ Name = "Star-Lord"; Address = "Milano" },
    @{ Name = "Nebula"; Address = "Thanos' Ship" },
    @{ Name = "Yondu"; Address = "Ravager Ship" },
    @{ Name = "Mantis"; Address = "The Quadrant" },
    @{ Name = "Vision"; Address = "Avengers HQ" },
    @{ Name = "Pepper Potts"; Address = "Stark Industries" },
    @{ Name = "Rhodey"; Address = "Avengers HQ" }
)
 
# Define product list
$products = @(
    "Pizza", "Burger", "Pasta", "Salad", "Sushi", "Sandwich", "Steak", "Tacos", "Soup", "Dessert"
)
 
# Initialize and start the stopwatch to see how long it took to run all orders
$sequentialTimer = [System.Diagnostics.Stopwatch]::StartNew()
$sequentialTimer.Start()
$TotalWaitSeconds = 0
 
# Add customers and products to process
$customers | ForEach-Object {
    $product = Get-Random -InputObject $products
    $wait = Get-Random -Minimum 3 -Maximum 5
    $TotalWaitSeconds += $wait
   
    # Create a new PowerShell object for each customer
    $ps = [powershell]::Create()
 
    # Add the script block to the PowerShell object
    $ps.AddScript($scriptBlock)  | Out-Null # we are outputing the returning object from $ps.AddScript($scriptBlock) to null
 
    # Add each argument for the script block
    $ps.AddArgument($_.Name)    | Out-Null # Add customer name
    $ps.AddArgument($_.Address) | Out-Null # Add customer address
    $ps.AddArgument($product)   | Out-Null # Add food product
    $ps.AddArgument($wait)      | Out-Null # Add wait time
   
    # Set the runspace pool for the PowerShell object
    $ps.RunspacePool = $pool
 
    # Write the order details to the console
    Write-Host "Order in: $($_.Name) at $($_.Address) for $product, Estimated delivery: $wait seconds" -ForegroundColor Blue
    Start-Sleep -Milliseconds 200
 
    # Begin invoking the script block asynchronously
    $handle = $ps.BeginInvoke()
 
    # Add the runspace and handle to the collection
    $runspaces += [PSCustomObject]@{Pipe = $ps; Handle = $handle}
}
 
# Wait for all runspaces to complete and collect results
$results = $runspaces | ForEach-Object {
    $result = $_.Pipe.EndInvoke($_.Handle)
    $_.Pipe.Dispose()
    $result
}
 
# Clean up the runspace pool
$pool.Close()
$pool.Dispose()
 
# Output the results
$results | ForEach-Object { Write-Host $_ -ForegroundColor Green }
$sequentialTimer.Stop()
 
# Output the total time taken
Write-Host "`nAll orders completed in $($sequentialTimer.Elapsed.ToString()) instead of $TotalWaitSeconds seconds" -ForegroundColor Yellow
$sequentialTimer.Reset()

#endregion Another Example of RunspacePool