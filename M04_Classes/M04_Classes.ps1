#region Slide 4 Moving from PSCustom Objects to Classes

$person = [pscustomobject]@{
    Name= “Gadi"
    age = 50
    Office= "Home"
    Title= “CSA"
    Planet= "Earth"
    Dimension= "c137"
} 

$person.GetType().fullname
$person | Get-Member

<# 
Why should we use classes?
--------------------------
1. Stronger typing for predictable behavior
2. Encapsulation of data and behavior
3. Reusable templates with Build-in Methods
4. Inheritance and Polymorphism

Summary Comparison: 
PSCustomObject vs. Classes
Feature	                PSCustomObject	          Classes
-------                 --------------            ------- 
Typing	                | Dynamic and flexible 	|  Strong and enforced
Reusability	            | Limited	            |  High (inheritance, methods)
Validation	            | Manual	            |  Built-in
IntelliSense	        | Limited	            |  Extensive
#>

#endregion Slide 4 Moving from PSCustom Objects to Classes



# -----------------------------------------------



#region Slide 5 the class experience

# Class definition
class Person {
    #region properties
    [int]    $Age
    [string] $Dimension
    [string] $Name
    [string] $Office
    [string] $Planet
    [string] $Title
 
    #endregion properties

    #Default Constructor
    person()
    {
        $this.Name = "Gadi"
        $this.Age = 50
        $this.Office = "Home"
        $this.Title = "PFE Wannabe"
        $this.Planet = "Earth"
        $this.Dimension = "Sherman Tank"
    }

    #region methods
    [void] GrowOlder([int]$Years)
    {
        $this.Age += $Years
    }

    [string] SaySomething([string]$Something) 
    {
        return "I say: $Something"
    }

    [string] SaySomething() 
    {
        return $this.SaySomething("something")
    }
    #endregion methods
}

$person = [person]::new()
$person | Get-Member

#endregion Slide 5 the class experience



# -----------------------------------------------



#region Slide 8-9 Class Syntax

class Person2
{
    # Public Properties
    [String] $Name
    [Int32]  $Age


    #public methods
    [String] SaySomething()
    {
        return "Something!"
    } 
}  

#endregion Slide 8-9 Class Syntax

# -----------------------------------------------

#region Slide 10 Creating an instace of your class

# new object
$person = New-Object -TypeName Person2
$person.name = "Kory"
$person.age = 28 

$person


# New-Object using a hashtable (Like PSCustomObject)
$vals = @{
    name = "Dave"
    age = 25
}
$person = New-Object -TypeName Person -Property $vals 

$person


# Default Constructor
$person = [Person]::new()
$person.Name = "Daniel"
$person.Age = 32

$person


#endregion Slide 10 Creating an instace of your class



# -----------------------------------------------

#region Slide 13 Methods with parameters

class Person3
{
    # Public Properties
    [String] $Name
    [Int32]  $Age


    #public methods
    [String] SaySomething([String]$Something)
    {
        return "$Something"
    }
} 

$person3 = [Person3]::new()
$person3.SaySomething("Hello, World!")

#endregion slide 13 Methods with parameters

# -----------------------------------------------


#region Slide 14 Overloading a Method

class Person4
{
    # Public Properties
    [String] $Name
    [Int32]  $Age


    #public methods
    [String] SaySomething([String]$Something)
    {
        return "$Something"
    }

    [String] SaySomething()
    {
        return "something"
    }
} 

$person4 = [Person4]::new()
$person4.SaySomething()
$person4.SaySomething("Hello, World!")

#endregion Slide 14 Overloading a Method


# -----------------------------------------------


#region slide 17 $this keyword

class Person5
{
    # Public Properties
    [String] $Name
    [Int32]  $Age


    #public methods
    [String] SaySomething([String]$Something)
    {
        return "$Something"
    }

    [String] SaySomething()
    {
        return $this.SaySomething("something")
    }
} 
    

$person5 = [Person5]::new()
$person5.SaySomething()


#endregion slide 17 $this keyword



# -----------------------------------------------



#region slide 18 $this - Example with Properties

class Person6
{
    [string]$Name
    [int]$Age

    [void] GrowOlder([int]$Years)
    {
        $this.Age += $Years
    }
}

$person6 = [Person6]::new()
$person6.Age = 30
$person6.Age # Displays the value of the Age property
$person6.GrowOlder(5)
$person6.Age # Displays the updated value of the Age property

#endregion slide 18 $this - Example with Properties


# -----------------------------------------------


#region Slide 21 Basic Constructors

# A constructor is a special method that is called when an object is created
# Default one takes in no parameters and sets no values

class Person7
{
    # This class has no default constructor
    [String] $Name
    [Int32]  $Age    
}

$person7 = [Person7]::new()
$person7.name = 'Gadi'
$person7.age = 50
$person7


# A constructor can be created to set default values

class Person8
{
    [String] $Name
    [Int32]  $Age

    Person8()
    {
        $this.Name = "John Doe"
        $this.Age = 25
    }
}

$person8 = [Person8]::new()
$person8


#endregion Slide 21 Basic Constructors



# -----------------------------------------------



#region Slide 22 Constructors overloads

class Person9
{
    [String] $Name
    [Int32]  $Age

    Person9()
    {
        $this.Name = 'John Doe'
        $this.Age = 25
    }

    Person9([String]$Name, [Int32]$Age)
    {
        $this.Name = $Name
        $this.Age = $Age
    }
}

$person9 = [Person9]::new() # Default constructor
$person9
$person9 = [Person9]::new('Derek', 30)
$person9
$person9 = [Person9]::new('Derek') # Error: Missing argument

# Note: You cannot use named arguments like you do with parameters
# For example, the following will not work:
# $person9 = [Person9]::new(Name='Derek', Age=30)

# Note: You must provide all constructor arguments in the correct order
# You cannot skip arguments like you can with parameters


#endregion Slide 22 Constructors overloads



# -----------------------------------------------



#region Slide 23 Static Members

class person10
{
    [String] $Name
    [Int32]  $Age

    static [String] $Planet = "Earth"
}

[person10]::Planet
$person10 = [person10]::new()
$person10.Planet # Error: Cannot access static property from an instance

#endregion Slide 23 Static Members



# -----------------------------------------------



#region Slide 24 Hidden Members

class Person11
{
    [String] $Name
    [Int32]  $Age

    hidden [String] $Planet = "Earth"
}
$person11 = [Person11]::new()
$person11.Planet
# Hidden members are not displayed by default
$person11 | Get-Member -MemberType Properties

# Use the -Force parameter to see hidden members
$person11 | Get-Member -MemberType Properties -Force

# Note: Hidden members are not private - they are just not displayed by default
# They are simply hidden from the discovery tools (e.g., Get-Member)
# Using Get-Member with -Force will reveal them


# Practical use cases for hidden members in PowerShell classes:
# - Keep internal or supporting properties out of user-facing autocomplete and Get-Member to reduce clutter
# - Expose diagnostic or metadata fields only for advanced troubleshooting while hiding them from normal usage
# - Reserve properties for future features or backward compatibility without showing them to users until needed




#endregion Slide 24 Hidden Members



# -----------------------------------------------



#region Slide 27 Inheritance

# Base class
class Mammal {
    [string]$Name

    [string] Speak() {
        return "$($this.Name) makes a sound."
    }
}

# Derived Cat class
class Cat : Mammal {
    [string]$FavoriteToy
}

# Create an instance of the base class
$animal = [Mammal]::new()
$animal.Name = "Generic mammal"
$animal.Speak() # Output: Generic Animal makes a sound.


# Create an instance of the Cat class
$cat = [Cat]::new()
$cat.Name = "Whiskers"
$cat.FavoriteToy = "Ball of yarn"
$cat
$cat.Speak() 


# Derived class
class Dog : Mammal {
    [string] Speak() {
        # Use base class property
        return "$($this.Name) barks."
    }
}



# Create an instance of dog class
$dog = [Dog]::new()
$dog.Name = "Wolfy"
$dog.Speak() # Output: Wolfy barks.


#endregion Slide 27 Inheritance



# -----------------------------------------------



#region Slide 28 Enums (Enumerations)

enum NinjaTurtles {
    Leonardo
    Michelangelo
    Donatello
    Raphael
}

# Accessing enum members
[NinjaTurtles]::Leonardo # Output: Leonardo
# [NinjaTurtles]:: (Press Tab or CRTL + Space)



# We can also assign values to the enum members
enum NinjaTurtles2 {
    Leonardo = 100
    Michelangelo = 200
    Donatello = 300
    Raphael = 400
}

[NinjaTurtles2]::Leonardo.value__


#endregion Slide 28 Enums (Enumerations)



# -----------------------------------------------



#region Slide 29 Enums (continued) - usage in functions

enum NinjaTurtles3 {
    Leonardo = 1
    Michelangelo = 2
    Donatello = 300
    Raphael = 4
}

function TurtlesInTest {
    param(
        [NinjaTurtles3]$Turtle
    )
    switch ($Turtle) {
        "Leonardo" { return "You selected Leonardo! His weapon is twin katanas." }
        "Michelangelo" { return "You selected Michelangelo! His weapon is nunchaku." }
        "Donatello" { return "You selected Donatello! His weapon is a bō staff." }
        "Raphael" { return "You selected Raphael! His weapon is twin sai." }
        Default { return "Unknown turtle." } # In our example this will never be reached
    }    
}

TurtlesInTest -Turtle 'Leonardo'
TurtlesInTest -Turtle 'Michelangelo'
TurtlesInTest -Turtle 'Shredder' # Output: Unknown turtle.

# A more practical example of using enums in a function
# Define the employee types enum
enum EmployeeType {
    FTE      = 1   # Full Time Employee
    PTE      = 2   # Part Time Employee
    FTC      = 3   # Fixed Term Contractor
    PTC      = 4   # Part Time Contractor
    Retired  = 5
}

function Get-EmployeeType {
    param(
        [EmployeeType]$Employee
    )
    switch ($Employee) {
        "FTE"     { return "Full Time Employee: eligible for full benefits." }
        "PTE"     { return "Part Time Employee: benefits on a pro-rated basis." }
        "FTC"     { return "Fixed Term Contractor: hired for a specific project or timeframe." }
        "PTC"     { return "Part Time Contractor: project-based, part-time." }
        "Retired" { return "Retired: no active employment, but eligible for retiree programs." }
    }
}

# Test examples
Get-EmployeeType -Employee #Hit CTRL + Space to see the enum members
Get-EmployeeType -Employee 'FTE'
Get-EmployeeType -Employee 'Retired'
Get-EmployeeType -Employee 2 # Output: Part Time Employee: benefits on a pro-rated basis.
Get-EmployeeType -Employee 'Unknown'  # Output: Unknown employee type.

#endregion Slide 29 Enums (continued) - usage in functions