#region Slide 6: Create a GUI with Label and Button in PowerShell

# Load required .NET assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Demo Form"
$Form.Size = New-Object System.Drawing.Size(400, 200)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::Aquamarine

# Create the label
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "Welcome"                          # Initial text
$Label1.Font = New-Object System.Drawing.Font("Arial", 14)
$Label1.AutoSize = $true                          # Automatically adjust size to fit text
$Label1.Location = New-Object System.Drawing.Point(150, 50) # Position of the label
$Form.Controls.Add($Label1)

# Create the button
$Button = New-Object System.Windows.Forms.Button
$Button.Text = "Click Me"
$Button.Font = New-Object System.Drawing.Font("Arial", 12)
$Button.Size = New-Object System.Drawing.Size(100, 40)
$Button.Location = New-Object System.Drawing.Point(150, 100) # Position of the button
$Form.Controls.Add($Button)

# Define the button's click event
$Button.Add_Click({
    $Label1.Text = "Hello, World!"               # Change the label text when button is clicked
})

# Display the form
$Form.ShowDialog()


#endregion Slide 6: Create a GUI in PowerShell



#--------------------------------------------------

#region Slide 11 Tools to create XAML code - WINUI 2 Gui

# Search for "WinUI 2 Gallery" in the Microsoft Store
# Install the WinUI 2 Gallery app

# Open the app and explore the controls
# You can copy the XAML code for the controls you want to use

#--------------------------------------------------


#region Slide 21: Using Visual Studio Code to Create a GUI in PowerShell

<#
    -----------------------------------------------------------------------------------------------------
    Change the code for your needs, this code is create using c:\repo\WPF\WpfApp1\WpfApp1\MainWindow.xaml
    -----------------------------------------------------------------------------------------------------

    Create a new WPF project in Visual Studio
    Crate your GUI using the designer
    Create one button and one label
    Set the button text to "Click Me"
    Set the label text to "Welcome"
    Save the XAML file
    Close Visual Studio



    Load the XAML file in PowerShell
    Bind the controls to PowerShell variables !!!!
    ----------------------------------------------

#>

#region Create a GUI in Visual Studio
#------------------------------------

# Load WPF Assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore

# Path to the XAML file
#$XamlPath = "YOUR XAML FILE PATH HERE"
$XamlPath = '.\M10_Create a GUI in PowerShell\FirstApplication\FirstApplication.xaml'

# Read the XAML file as XML
$Xaml = [xml](Get-Content -Path $XamlPath -Raw)

# Remove design-time attributes (if necessary)
# This step is optional and depends on the XAML file structure
# If you have created your XAML file in Visual Studio or another design tool, you may need to remove design-time attributes before loading it in PowerShell
$Xaml.Window.RemoveAttribute('x:Class')
$Xaml.Window.RemoveAttribute('xmlns:local')
$Xaml.Window.RemoveAttribute('xmlns:d')
$Xaml.Window.RemoveAttribute('xmlns:mc')
$Xaml.Window.RemoveAttribute('mc:Ignorable')

# Load the XAML into a WPF object
$XamlReader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($XamlReader)

# Show the window
$Window.ShowDialog() | Out-Null

#endregion Create a GUI in Visual Studio
#---------------------------------------




#region add the code to bind the controls to PowerShell variables
#----------------------------------------------------------------

# Load WPF Assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore

# Path to the XAML file
$XamlPath = ".\M10_Create a GUI in PowerShell\FirstApplication\FirstApplication.xaml"

# Read the XAML file as XML
$Xaml = [xml](Get-Content -Path $XamlPath -Raw)

# Remove design-time attributes (if necessary)
# This step is optional and depends on the XAML file structure
# If you have created your XAML file in Visual Studio or another design tool, you may need to remove design-time attributes before loading it in PowerShell
$Xaml.Window.RemoveAttribute('x:Class')
$Xaml.Window.RemoveAttribute('xmlns:local')
$Xaml.Window.RemoveAttribute('xmlns:d')
$Xaml.Window.RemoveAttribute('xmlns:mc')
$Xaml.Window.RemoveAttribute('mc:Ignorable')

# Load the XAML into a WPF object
$XamlReader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($XamlReader)

# Bind the controls to PowerShell variables
$Button1 = $Window.FindName("Button1")
$Label1 = $Window.FindName("Label1")


# Define the button's click event
$Button1.Add_Click({
    $Label1.Content = "Hello, World!"               # Change the label text when button is clicked
})

# Show the window
$Window.ShowDialog() | Out-Null


#endregion add the code to bind the controls to PowerShell variables


#-------------------------------------------------------------------


#endregion Slide 21: Using Visual Studio Code to Create a GUI in PowerShell





#--------------------------------------------------



#region Slide 36 Converting GUI form to Hash Table


# Load WPF Assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore

# Path to the XAML file
$XamlPath = Resolve-Path ".\M10_Create a GUI in PowerShell\FirstApplication\FirstApplication.xaml"

# Read the XAML file as XML
$Xaml = [xml](Get-Content -Path $XamlPath -Raw)

# Remove design-time attributes (optional)
$Xaml.Window.RemoveAttribute('x:Class')
$Xaml.Window.RemoveAttribute('xmlns:local')
$Xaml.Window.RemoveAttribute('xmlns:d')
$Xaml.Window.RemoveAttribute('xmlns:mc')
$Xaml.Window.RemoveAttribute('mc:Ignorable')

# Load the XAML into a WPF object
$XamlReader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($XamlReader)

# Add XML namespace manager
$XmlNamespaceManager = [System.Xml.XmlNamespaceManager]::New($XAML.NameTable)
$XmlNamespaceManager.AddNamespace('x', 'http://schemas.microsoft.com/winfx/2006/xaml')

# Create a hash table containing all controls
$GUI = @{}
$namedNodes = $XAML.SelectNodes("//*[@x:Name]", $XmlNamespaceManager)
$namedNodes | ForEach-Object {
    $GUI.Add($_.Name, $Window.FindName($_.Name))
}

<#    Why should you use a hash table to store the controls?
    
    Dynamic Flexibility:
    If you have a large number of controls, especially in complex GUIs, dynamically populating a hash table 
    ensures you don’t need to write individual declarations for every control. 
    This saves time during development.
    
    Scalability:
    When the XAML changes (e.g., new controls are added or names are updated), the script dynamically adapts 
    without requiring manual changes to the variable declarations.
    
    Simplifies Access to All Controls:
    The hash table acts as a central repository for controls. 
    If you need to loop through all controls (e.g., to apply a common style or reset values), 
    it’s much easier to iterate over the hash table than to manage individual variables.
#>

$GUI.Button1.Content = "New Button Text"

# Show the window
$Window.ShowDialog() | Out-Null




#endregion Slide 36 Converting GUI form to Hash Table




#--------------------------------------------------



#region Slide 42 Event Driven Actions


# This is a demo for Event Driven Actions
# It monitors a folder for file content changes and logs the events


# Define the folder to monitor
$FolderPath = "C:\Temp\SimpleDemoFolder"

# Ensure the folder exists
if (-not (Test-Path -Path $FolderPath)) {
    New-Item -ItemType Directory -Path $FolderPath | Out-Null
}

# Define the log file
$LogFilePath = "C:\Temp\SimpleDemoLog.txt"
if (-not (Test-Path -Path (Split-Path -Path $LogFilePath))) {
    New-Item -ItemType Directory -Path (Split-Path -Path $LogFilePath) | Out-Null
}
if (-not (Test-Path -Path $LogFilePath)) {
    New-Item -ItemType File -Path $LogFilePath | Out-Null
}

Write-Host "Monitoring folder for file content changes: $FolderPath" -ForegroundColor Yellow
Write-Host "Modify a file in this folder to trigger an event." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the script." -ForegroundColor Yellow

# Create a FileSystemWatcher to monitor the folder
$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $FolderPath
$Watcher.Filter = '*.*'  # Monitor all file types
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true

# Create a hashtable to track events (for debouncing)
$EventTracker = @{}

# Define cleanup actions for graceful termination
$CleanupAction = {
    Unregister-Event -SourceIdentifier FileChangedEvent -ErrorAction SilentlyContinue
    $Watcher.Dispose()
    Write-Host "Cleaned up and exiting." -ForegroundColor Yellow
}

# Register the event for file content changes
Register-ObjectEvent -InputObject $Watcher -EventName Changed -SourceIdentifier FileChangedEvent -Action {
    $EventArgs = $Event.SourceEventArgs
    $FileName = $EventArgs.Name
    $FullPath = $EventArgs.FullPath
    $Timestamp = Get-Date

    # Check if this file event was recently processed (debounce logic)
    if ($EventTracker.ContainsKey($FileName) -and ((Get-Date) - $EventTracker[$FileName]).TotalSeconds -lt 2) {
        return  # Ignore duplicate events within 2 seconds
    }

    # Update the tracker with the current timestamp
    $EventTracker[$FileName] = $Timestamp

    # Log the event
    $LogEntry = "[$Timestamp] The file '$FileName' was modified at '$FullPath'"
    Add-Content -Path $LogFilePath -Value $LogEntry
    Write-Host $LogEntry -ForegroundColor Green
}

try {
    # Keep the script running until manually stopped
    while ($true) {
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "Script interrupted." -ForegroundColor Red
} finally {
    # Ensure cleanup actions are performed
    & $CleanupAction
}



#endregion Slide 42 Event Driven Actions



#--------------------------------------------------



#region Slide 44 Form Unresponsive Issue

# Load WPF Assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore

# Path to the XAML file
$XamlPath = ".\M10_Create a GUI in PowerShell\FirstApplication\FirstApplication.xaml"

# Read the XAML file as XML
$Xaml = [xml](Get-Content -Path $XamlPath -Raw)

# Remove design-time attributes (if necessary)
# This step is optional and depends on the XAML file structure
# If you have created your XAML file in Visual Studio or another design tool, you may need to remove design-time attributes before loading it in PowerShell
$Xaml.Window.RemoveAttribute('x:Class')
$Xaml.Window.RemoveAttribute('xmlns:local')
$Xaml.Window.RemoveAttribute('xmlns:d')
$Xaml.Window.RemoveAttribute('xmlns:mc')
$Xaml.Window.RemoveAttribute('mc:Ignorable')

# Load the XAML into a WPF object
$XamlReader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($XamlReader)

# Bind the controls to PowerShell variables
$Button1 = $Window.FindName("Button1")
$Label1 = $Window.FindName("Label1")


# Define the button's click event
$Button1.Add_Click({                                # Update the form to show the new label text
    Start-Sleep -Seconds 10
    $Label1.Content = "Hello, World!"               # Change the label text when button is clicked
})

# Show the window
$Window.ShowDialog() | Out-Null

#endregion Slide 44 Form Unresponsive Issue



#--------------------------------------------------



#region Slide 48 Data Binding

 #region Load GUI
 Add-Type -AssemblyName presentationframework, presentationcore
 $XAML= [XML](Get-Content -Path '.\M10_Create a GUI in PowerShell\FirstApplication\DataBinding.xaml' -Raw)
 $XAML.Window.RemoveAttribute('x:Class')
 $XAML.Window.RemoveAttribute('xmlns:local')
 $XAML.Window.RemoveAttribute('xmlns:d')
 $XAML.Window.RemoveAttribute('xmlns:mc')
 $XAML.Window.RemoveAttribute('mc:Ignorable')
   
 #Read XML as XAML
 $XAMLreader = New-Object System.Xml.XmlNodeReader $XAML
 $Rawform = [Windows.Markup.XamlReader]::Load($XAMLreader)
   
 #Add XML namespace manager
 $XmlNamespaceManager = [System.Xml.XmlNamespaceManager]::New($XAML.NameTable)
 $XmlNamespaceManager.AddNamespace('x','http://schemas.microsoft.com/winfx/2006/xaml')
   
 #Create hash table containing a representation of all controls
 $GUI = @{}
 $namedNodes = $XAML.SelectNodes("//*[@x:Name]",$XmlNamespaceManager)
 $namedNodes | ForEach-Object -Process {$GUI.Add($_.Name, $Rawform.FindName($_.Name))}
 #endregion Load GUI
   
 $RootPath = $null #to be populated when the search button is clicked
   
 $ButtonSB = {
     $Script:RootPath = $GUI["PathTextBox"].text
     $GUI["DisplayListBox"].Items.Clear()
     if(!(Test-Path $GUI["PathTextBox"].text))
     {
         $GUI["DisplayListBox"].Items.Add("INVALID PATH")
         return
     }
     if($GUI["FileRadioButton"].isChecked){$data = Get-ChildItem -Path $GUI["PathTextBox"].text -file}
     else{$data = Get-ChildItem -Path $GUI["PathTextBox"].text -Directory}
     foreach ($item in $data)
     {
         $GUI["DisplayListBox"].Items.add($item.Name)
     }
 }
   
 $DoubleClickSB = {
     $Gui["DisplayListView"].Items.clear()
     $ItemPath = "$rootPath/$($Gui["DisplayListBox"].selecteditem)"
     $SelectedItem = Get-Itemproperty -Path $ItemPath -ErrorAction SilentlyContinue
     $SelectedItem.psobject.properties | foreach {$Gui["DisplayListView"].Items.add("$($_.name): $($_.value)")}
 }
   
 $Gui["DisplayListBox"].Add_MouseDoubleClick($DoubleClickSB)
 $GUI["SearchButton"].Add_Click($ButtonSB)
   
   
 $Rawform.ShowDialog() | Out-Null 

#endregion Slide 48 Data Binding



#--------------------------------------------------



