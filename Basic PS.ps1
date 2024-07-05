# Define variables
$resourceGroupName = "autoVM"
$subscriptionId = "YourSubscriptionId"

# Authenticate to Azure if not already authenticated
Connect-AzAccount

# Select the subscription
Select-AzSubscription -SubscriptionId $subscriptionId

# Get all VMs in the specified resource group
$vms = Get-AzVM -ResourceGroupName $autoVM

# Loop through each VM
foreach ($vm in $vms) {
    # Check the VM status
    $vmStatus = $vm.Statuses[1].DisplayStatus  # Assuming the second status is the current status
    
    # Take a snapshot regardless of VM status
    Write-Output "Taking snapshot of VM $($vm.Name)..."
    $snapshotName = "Snapshot-$(Get-Date -Format '20240707-093000')"
    New-AzSnapshotConfig -SourceUri $vm.Id -CreateOption Copy -Snapshot $snapshotName | New-AzSnapshot -ResourceGroupName $autoVM -SnapshotName $autoVM

    # Reboot VM if status is either running or starting
    if ($vmStatus -eq "VM running" -or $vmStatus -eq "VM starting") {
        Write-Output "VM $($vm.Name) is $vmStatus. Rebooting..."

        # Reboot the VM asynchronously
        Restart-AzVM -ResourceGroupName $autoVM -Name $vm.Name -Force -AsJob
    }
    else {
        Write-Output "VM $($vm.Name) is $vmStatus. Skipping reboot."
    }
}

Write-Output "Script execution completed."
