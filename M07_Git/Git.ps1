#region Git first demo


# Create a directory for the demo
if(get-item -Path 'c:\temp\GitDemo' -ErrorAction SilentlyContinue) {
    Remove-item -Path 'c:\temp\GitDemo' -Recurse -Force
    New-Item -Name 'GitDemo' -Path c:\temp -ItemType Directory -Force | Out-Null
} else {
    New-Item -Name 'GitDemo' -Path c:\temp -ItemType Directory -Force | Out-Null
}

set-location -Path 'c:\temp\GitDemo'
# Initialize a new Git repository
git init
# Create a new file and add some content
set-content -Path 'File1.txt' -Value 'First version of the file'

git status
# Note that the file is untracked
# Add the file to the staging area
git add .\File1.txt

git status
# The file is now staged for commit 

# Commit the changes with a message
git commit -m 'First commit with File1.txt'

# Check the commit history
git log

# Modify the file
set-content -Path 'File1.txt' -Value 'Second version of the file'

# Check the status again
git status

# The file is modified but not staged
# Stage the modified file
git add .\File1.txt 
# Check the status again
git status

# Commit the changes with a message
git commit -m 'Second commit with modified File1.txt'

# Check the commit history again
git log

# Moving between commits
git checkout 'Place the commit hash here'
get-content -Path 'File1.txt'
# Note that the content of the file is now the first version
# Move back to the latest commit
git checkout master
# Check the content of the file again
get-content -Path 'File1.txt'


#endregion Git first demo

#############################################
#############################################
#       Lab Git - Introduction to Git       #
#############################################
#############################################


#region Slide 37 git init:Initialize a repository

# After completing the lab, let's dive a bit deeper into Git commands and concepts.
# What happens when you run `git init`?
# It initializes a new Git repository in the current directory, creating a `.git` subdirectory
set-location -Path 'c:\temp\GitDemo'
get-childitem -Hidden
set-location -Path .\.git
get-childitem
set-location -Path '.\..'

#endregion Slide 37 git init:Initialize a repository



#-----------------------------------------------------


#region Slide 38 .gitignore:Ignore files

set-content -Path 'TempFile.txt' -Value 'Personal data that should not be tracked by Git'
set-content -Path '.gitignore' -Value 'TempFile.txt'
# The .gitignore file tells Git to ignore the TempFile.txt file
# Check the status of the repository
git status

# IMPORTANT: The .gitignore file is used to specify files and directories that should be ignored by Git.
# This is useful for excluding temporary files, logs, or any other files that should not be tracked in the repository.
# Remember to add .gitignore to the content of the file itself, so it is tracked by Git.
# Add the .gitignore file to the staging area
add-content -Path '.gitignore' -Value '.\gitignore'

# Check the status again
git status



#endregion Slide 38 .gitignore:Ignore files



#------------------------------------------------------


#region Slide 39 git add:Add changes

New-Item -Name 'File2.txt' -Path c:\temp\GitDemo -ItemType File -Force | Out-Null
New-Item -Name 'File3.txt' -Path c:\temp\GitDemo -ItemType File -Force | Out-Null

# Add only File2.txt to the staging area
git status
git add .\File2.txt

# Check the status again
git status

# Create a new commit with the staged changes
git commit -m 'Added File2.txt to the repository'

# Check the commit history
git log --oneline


git status

Remove-Item -Path '.\File3.txt' -Force
git status


#endregion Slide 39 git add:Add changes

#------------------------------------------------------

#############################################
#############################################
#          Lab Git - Working with GIT       #
#############################################
#############################################