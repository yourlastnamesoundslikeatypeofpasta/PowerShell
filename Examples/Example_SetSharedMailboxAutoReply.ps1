Import-Module ../src/SupportTools/SupportTools.psd1

$start = Get-Date '2025-06-02T00:00:00'
$end   = Get-Date '2025-06-09T23:59:59'

Set-SharedMailboxAutoReply -MailboxIdentity 'parts@yellowfin.com' \ 
    -StartTime $start -EndTime $end \ 
    -InternalMessage 'Apologies, but I\'m out of the office from 6/2 - 6/9 and will return on 6/10. I will be responding to all emails and phone calls upon my return. If you need immediate assistance, please reach out to Jay Wagner at ext 312.' \ 
    -ExternalMessage 'Apologies, but I\'m out of the office from 6/2 - 6/9 and will return on 6/10. I will be responding to all emails and phone calls upon my return. If you need immediate assistance, please reach out to Jay Wagner at ext 312.' \ 
    -AdminUser 'youradmin@yourdomain.com'
