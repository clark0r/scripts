# As administrator (ask IT)
Install-Module -Name Az -Repository PSGallery -Force

# Login to Azure using your account
Connect-AzAccount

# Set output CSV and write headers
$file = "c:\Users\clipper\Desktop\storage.csv"
$output = "subscription,resourcegroup,storageaccount,storageaccount_allowpublicblob,storageaccount_defaultfirewall,container,container_accesslevel"
Write-Output $output | Tee-Object -file $file

$subs = Get-AzSubscription

foreach ($sub in $subs) {
 set-azcontext $sub
 $accounts = Get-AzStorageAccount

 foreach ($account in $accounts) {
  # we could write something here to skip if the account is set to public access false, as no container would be aboe to have anonymous access
  # we could also put something in to skip those with network restricted, however we should find all anonymous access whether on a private or public network
 
  $ctx = $account.Context
  $containers = get-azstoragecontainer -context $ctx 2>$null
 
  if (!$containers){ # skip if no containers in account
   continue
  } 
 
  foreach ($con in $containers) {
   $output = "" + $sub + "," + $account.resourcegroupname + "," + $account.storageaccountname + "," + $account.AllowBlobPublicAccess + "," + $account.NetworkRuleSet.DefaultAction + "," + $con.Name + "," + $con.PublicAccess
   Write-Output $output | Tee-Object -file $file -Append
  }
 
 # TODO : add storage account SMB file shares
 # TODO : add storage account SFTP shares
 # TODO : add storage account queues
 # TODO : add storage account tables
 }
}
