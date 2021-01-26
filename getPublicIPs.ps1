$sublist = Get-AzSubscription

$iplist = @()
$prefixlist = @()
$counter = 0
foreach ($sub in $sublist)
{
    $counter++
    $status = "Collecting IP for Subscription $counter of " + $sublist.count
    Write-Progress -Activity $status -CurrentOperation $sub.name -PercentComplete (($counter / $sublist.count) * 100)
    
    Select-AzSubscription -Subscription $sub.Id
    
    $subips = Get-AzPublicIpAddress
    $subips | Add-Member -NotePropertyName SubscriptionId -NotePropertyValue $sub.SubscriptionId
    $subips | Add-Member -NotePropertyName SubscriptionName -NotePropertyValue $sub.Name
    $iplist += $subips.where({$_.IpAddress -ne 'Not Assigned'})
}

foreach ($ip in $iplist)
{
    $url = "https://" + $ip.IpAddress
    $request = Invoke-WebRequest $url

    if ($request.StatusCode -eq 200){
        print $request.headers
    }
}

$iplist | Select-Object -Property SubscriptionName,Name,ResourceGroupName,PublicIpAllocationMethod,IPAddress
