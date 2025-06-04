Import-Module ../src/SupportTools/SupportTools.psd1
AddUsersToGroup -CsvPath './users.csv' -GroupName 'MyGroup'
