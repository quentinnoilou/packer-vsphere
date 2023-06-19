# Désactive SMBv1
Set-SmbServerConfiguration -EnableSMB1Protocol $false

# Désactive les versions de TLS obsolètes
$protocols = Get-TlsCipherSuite | Where-Object { $_.Name -like 'TLS*' -and $_.Name -notlike '*13*' }
foreach ($protocol in $protocols) {
    Set-TlsCipherSuite -Name $protocol.Name -Enabled $false
}

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "FullPrivilegeAuditing" -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "SCENoApplyLegacyAuditPolicy" -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "AuditBaseObjects" -Value 1

foreach ($policy in $advancedAuditPolicy.GetEnumerator()) {
    $name = $policy.Name -replace 'System.Audit.', ''
    $value = $policy.Value
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Audit\$name" -Name "AuditFlags" -Value $value
}

# Active le pare-feu Windows et bloque toutes les connexions entrantes sauf celles spécifiées
Enable-NetFirewallProfile -Profile Domain, Public, Private
Set-NetFirewallProfile -Profile Domain, Public, Private -DefaultInboundAction Block
Set-NetFirewallProfile -Profile Domain, Public, Private -DefaultOutboundAction Allow
New-NetFirewallRule -DisplayName "Allow RDP" -Protocol TCP -LocalPort 3389 -Action Allow
New-NetFirewallRule -DisplayName "Allow WwinRM" -Protocol TCP -LocalPort 5985 -Action Allow

# Active la stratégie de mot de passe complexe
$secpasswd = ConvertTo-SecureString "Password123!" -AsPlainText -Force
$adminuser = New-Object System.Management.Automation.PSCredential ("Administrator", $secpasswd)
Invoke-Command -ScriptBlock {
    Set-LocalUser -Name "Administrator" -PasswordNeverExpires $true -UserMayNotChangePassword $true -Password $args[0]
} -Credential $adminuser

# Exécute Windows Update
Install-WindowsUpdate -AcceptAll -AutoReboot

Write-Host "Le serveur a été durci avec succès."
