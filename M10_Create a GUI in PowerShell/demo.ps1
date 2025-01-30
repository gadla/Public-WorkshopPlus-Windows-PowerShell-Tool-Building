# Define the xaml code for the window
[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="Let's Eat!"
    SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen" >
    <Grid>
    <TabControl Margin="5">
            <TabItem>
                <TabItem.Header>
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="Food" Margin="5" />
                    </StackPanel>
                </TabItem.Header>
                <StackPanel Margin="5" >
                    <TextBlock Text="Food" FontSize="20" FontWeight="Bold" />
                    <TextBlock Text="Food is any substance consumed to provide nutritional support for an organism." />
                    <Expander Header="Different types of food" Margin="5" >
                        <ListView>
                            <ListViewItem Content="Healthy"/>
                            <ListViewItem Content="Unhealthy"/>
                        </ListView>
                    </Expander>
                    <StackPanel Orientation="Horizontal">
                        <Label Content="Click on a food item to know more" />
                    </StackPanel>
                    <StackPanel Orientation="Horizontal">
                        <Button Name="Eggs" Content="Eggs" Margin="5"/>
                        <Button Name="Butter" Content="Butter" Margin="5"/>
                        <Button Name="Rice" Content="Rice" Margin="5"/>
                        <Button Name="Beans" Content="Beans" Margin="5"/>
                    </StackPanel>
                    <Slider Width="480" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Maximum="100" Minimum="0"/>
                </StackPanel>
            </TabItem>
            <TabItem >
                <TabItem.Header>
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="Drink" Margin="5" />
                    </StackPanel>
                </TabItem.Header>
                <StackPanel Margin="5">
                    <TextBlock Text="Drink" FontSize="20" FontWeight="Bold" />
                    <TextBlock Text="A drink is a liquid intended for human consumption." />
                </StackPanel>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
'@

# Load the WPF assembly
Add-Type -AssemblyName PresentationFramework

# Load the window and named elements as variables in a hash table
$UI = [System.Collections.Hashtable]::Synchronized(@{})
$UI.Window = [System.Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | 
    ForEach-Object -Process {
        $UI.$($_.Name) = $UI.Window.FindName($_.Name)
    }

# Bring window to the fore
$UI.Window.Add_Loaded({
    $This.Activate()
})

# Add a click event to the Eggs button
$UI.Eggs.Add_Click({
    ## Pop a simple wscript notification 
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Eggs are a good source of protein and other nutrients",0,"Eggs",0x1)
})

# Show the window
[void]$UI.Window.ShowDialog()