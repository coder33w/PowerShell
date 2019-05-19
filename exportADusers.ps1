#This script has the following functionalities:

#1 - Exports all user accounts in a specified OU, given you control
#2 - Exported fields (CSV headers) are display in user friendly format, for example "First Name" instead of "GivenName" 
#3 - Displays exported Manager name in DisplayName format as against default AD Distinguised Name (DN) format
#4 - Exports "Account Status" (Enabled or Disabled)
#5 - Exports "Last LogOn Date" - Useful to determine "inactive" users based on your company policy.

#I used this function in a project that required me to export these fields so that the project team can populate missing fields. Once the fields have been populated and sent to me, I updated the users (using the received CSV) using another PowerShell script, Update-ADUsers.

PROCESS #This is where the script executes 
{ 
    $path = Split-Path -parent "$CSVReportPath\*.*" 
    $pathexist = Test-Path -Path $path 
    If ($pathexist -eq $false) 
    {New-Item -type directory -Path $path} 
     
    $reportdate = Get-Date -Format ssddmmyyyy 
 
    $csvreportfile = $path + "\ALLADUsers_$reportdate.csv" 
     
    #import the ActiveDirectory Module 
    Import-Module ActiveDirectory 
     
    #Perform AD search. The quotes "" used in $SearchLoc is essential 
    #Without it, Export-ADUsers returuned error 
                  Get-ADUser -server $ADServer -searchbase "$SearchLoc" -Properties * -Filter * |  
                  Select-Object @{Label = "First Name";Expression = {$_.GivenName}},  
                  @{Label = "Last Name";Expression = {$_.Surname}}, 
                  @{Label = "Display Name";Expression = {$_.DisplayName}}, 
                  @{Label = "Logon Name";Expression = {$_.sAMAccountName}}, 
                  @{Label = "Full address";Expression = {$_.StreetAddress}}, 
                  @{Label = "City";Expression = {$_.City}}, 
                  @{Label = "State";Expression = {$_.st}}, 
                  @{Label = "Post Code";Expression = {$_.PostalCode}}, 
                  @{Label = "Country/Region";Expression = {if (($_.Country -eq 'GB')  ) {'United Kingdom'} Else {''}}}, 
                  @{Label = "Job Title";Expression = {$_.Title}}, 
                  @{Label = "Company";Expression = {$_.Company}}, 
                  @{Label = "Description";Expression = {$_.Description}}, 
                  @{Label = "Department";Expression = {$_.Department}}, 
                  @{Label = "Office";Expression = {$_.OfficeName}}, 
                  @{Label = "Phone";Expression = {$_.telephoneNumber}}, 
                  @{Label = "Email";Expression = {$_.Mail}}, 
                  @{Label = "Manager";Expression = {%{(Get-AdUser $_.Manager -server $ADServer -Properties DisplayName).DisplayName}}}, 
                  @{Label = "Account Status";Expression = {if (($_.Enabled -eq 'TRUE')  ) {'Enabled'} Else {'Disabled'}}}, # the 'if statement# replaces $_.Enabled 
                  @{Label = "Last LogOn Date";Expression = {$_.lastlogondate}} |  
                   
                  #Export CSV report 
                  Export-Csv -Path $csvreportfile -NoTypeInformation     
}
