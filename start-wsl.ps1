$wslList = @("k3s-master1","k3s-master2","LB")

foreach ($distro in $wslList) {
    $state = (wsl -l -v | Where-Object {$_ -match $distro} | ForEach-Object { ($_ -split "\s+")[2] })
    if ($state -eq "Stopped") {
        Write-Host "Menyalakan distro $distro..."
        wsl -d $distro
    } else {
        Write-Host "Distro $distro sudah berjalan."
    }
}
