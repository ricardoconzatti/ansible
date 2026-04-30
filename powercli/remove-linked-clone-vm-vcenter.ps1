param(
    [string]$labId
)

$ErrorActionPreference = "Stop"

# === LOCK CONFIG ===
$LockDir = "/home/conza/scripts/ip-locks"

try {

    # Disable PowerCLI warnings
    Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null

    # === CONFIG ===
    $vCenter = "vcenter.caverna.local"
    #$vcUser = "no"
    #$vcPass = "no"

    if (-not $labId) {
        throw "labId parameter is required"
    }

    # === VM NAME ===
    $VMName = "kasten-lab-$labId"

    # === CONNECT ===
    Connect-VIServer -Server $vCenter #-User $vcUser -Password $vcPass | Out-Null

    # === GET VM ===
    $vm = Get-VM -Name $VMName -ErrorAction SilentlyContinue

    if (-not $vm) {
        throw "VM $VMName not found"
    }

    # === GET IP
    $vmGuest = Get-VMGuest -VM $vm -ErrorAction SilentlyContinue
    $vmIP = $null

    if ($vmGuest -and $vmGuest.IPAddress) {
        $vmIP = $vmGuest.IPAddress | Where-Object { $_ -like "192.168.10.*" } | Select-Object -First 1
    }

    # === POWER OFF (if needed) ===
    if ($vm.PowerState -eq "PoweredOn") {
        Stop-VM -VM $vm -Confirm:$false -ErrorAction Stop | Out-Null

        $timeout = 30
        $elapsed = 0

        while ((Get-VM -Name $VMName).PowerState -ne "PoweredOff") {
            Start-Sleep -Seconds 2
            $elapsed += 2

            if ($elapsed -ge $timeout) {
                throw "Timeout waiting VM to power off"
            }
        }
    }

    # === REMOVE VM ===
    Remove-VM -VM $vm -DeletePermanently -Confirm:$false -ErrorAction Stop | Out-Null

    # === REMOVE LOCK ===
    $lockRemoved = $false

    if ($vmIP) {
        $lockFile = "$LockDir/$vmIP.lock"

        if (Test-Path $lockFile) {
            Remove-Item $lockFile -ErrorAction SilentlyContinue
            $lockRemoved = $true
        }
    }

    # === SUCCESS OUTPUT ===
    $result = @{
        status        = "success"
        vm_name       = $VMName
        action        = "Removed"
        ip            = $vmIP
        lock_removed  = $lockRemoved
    }

}
catch {
    $result = @{
        status  = "error"
        message = $_.Exception.Message
    }
}

# === FINAL OUTPUT ===
$result | ConvertTo-Json -Depth 5
