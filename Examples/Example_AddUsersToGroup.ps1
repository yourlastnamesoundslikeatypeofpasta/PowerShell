Import-Module ../src/SupportTools/SupportTools.psd1
Add-UsersToGroup -CsvPath './users.csv' -GroupName 'MyGroup'
