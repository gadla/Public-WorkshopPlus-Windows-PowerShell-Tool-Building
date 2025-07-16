<#
.SYNOPSIS
Demonstrates using runspaces in PowerShell to process multiple food delivery orders concurrently.

.DESCRIPTION
This script simulates a food delivery dispatch system, using PowerShell runspaces to process multiple
customer orders in parallel rather than sequentially. Each runspace represents a delivery employee handling
one customer's order, including random food selection and a random estimated delivery time.

A runspace pool with configurable minimum and maximum threads manages the workload.
The script demonstrates:
- creating a runspace pool
- asynchronously processing customer orders with BeginInvoke
- collecting results with EndInvoke
- measuring the speedup compared to estimated sequential processing time

This shows how parallel processing can improve efficiency dramatically compared to a sequential approach.

.PARAMETER DeliveryEmployees
Specifies the maximum number of delivery employees (runspaces) to use in the pool.
Default is 5.

.EXAMPLE
PS> .\Parallel-FoodDelivery-Demo.ps1

Runs the food delivery simulation with the default pool of 5 delivery employees (runspaces).

.EXAMPLE
PS> .\Parallel-FoodDelivery-Demo.ps1 -DeliveryEmployees 10

Runs the food delivery simulation with a pool of up to 10 delivery employees (runspaces).

.NOTES
You can adjust the DeliveryEmployees parameter to simulate different numbers of delivery workers.

Author: Gadi Lev-Ari

#>
[CmdletBinding(PositionalBinding=$false)]
param (
    [int]$DeliveryEmployees = 5
)




# Define the script block that each runspace will execute
$scriptBlock = {
    param($CustomerName, $CustomerAddress, $FoodProduct, $wait)
    Start-Sleep -Seconds $wait
    "$FoodProduct delivered to $CustomerName at $CustomerAddress, the order took $wait seconds"
}
 
# Create a runspace pool with 5 instances
$pool = [runspacefactory]::CreateRunspacePool(1, $DeliveryEmployees) # Change here the number of delivery employees
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