# Load WPF Assemblies
Add-Type -Assembly PresentationFramework            
Add-Type -Assembly PresentationCore            

# Load the XAML
[xml]$XAML = Get-Content '.\M10_Create a GUI in PowerShell\FirstApplication\Timer3.xaml'
$XAMLReader = New-Object System.Xml.XmlNodeReader $XAML
$Window = [Windows.Markup.XamlReader]::Load($XAMLReader)

# Access WPF controls
$Clock = $Window.FindName("Clock")

# Create and start the clock timer
$timer_clock = New-Object System.Windows.Threading.DispatcherTimer
$timer_clock.Interval = [TimeSpan]"0:0:0.25" # Update every 0.25 seconds
$timer_clock.Add_Tick({
    $Window.Resources["Value_clock"] = (Get-Date -UFormat '%Y/%m/%d - %H:%M:%S')
})
$timer_clock.Start()

# Show the window
$Window.ShowDialog() | Out-Null

# Stop the timer when the window is closed
$timer_clock.Stop()
