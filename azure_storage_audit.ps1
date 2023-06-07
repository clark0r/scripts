# As administrator (ask IT)
Install-Module -Name Az -Repository PSGallery -Force

# Login to Azure using your account
Connect-AzAccount

# Set output CSV and write headers
$file = "c:\Users\clipper\Desktop\storage.csv"

$output = "subscription,resourcegroup,storageaccount,storageaccount_allowpublicblob,storageaccount_defaultfirewall,container,container_accesslevel"
Write-Output $output | Tee-Object -file $file

# we're only looking for enabled temenos cloud subscriptions
$subs = Get-AzSubscription | where-object {($_.name -like '*prod') -or ($_.name -like '*Customer*') -and ($_.name -notlike '*finops') -and ($_.State -eq 'Enabled')}

$counter = 0

foreach ($sub in $subs) {
    $counter++
    $status = 'Querying storage accounts in ' + $sub.name
    Write-Progress -Activity $status -CurrentOperation $sub.name -PercentComplete (($counter / $subs.count) * 100)

    set-azcontext $sub
    $accounts = Get-AzStorageAccount

    foreach ($account in $accounts) {
        $ctx = $account.Context
        $containers = Get-AzStorageContainerAcl -Context $ctx -ErrorAction SilentlyContinue
 
        if (!$containers){ # skip if no containers in account
            continue
        }

        $containers = $containers | Where-Object -Property PublicAccess -ne "Off" # only looking for containers where anon access is permitted
            foreach ($c in $containers) {
                $output = "" + $sub.Name + "," + $account.resourcegroupname + "," + $account.storageaccountname + "," + $account.AllowBlobPublicAccess + "," + $account.NetworkRuleSet.DefaultAction + "," + $c.Name + "," + $c.PublicAccess
                Write-Output $output | Tee-Object -file $file -Append

#                [PSCustomObject]@{
#                Subscription = $sub.Name
#                ResourceGroup  = $account.resourcegroupname
#                StorageAccount = $account.storageaccountname
#                AccountNetworkRulSet = $account.NetworkRuleSet.DefaultAction
#                BlobPublicAccess = $account.AllowBlobPublicAccess
#                Container = $c.Name
#                ContainerPublicAccess = $c.PublicAccess
#            }        
        }
    }
}
