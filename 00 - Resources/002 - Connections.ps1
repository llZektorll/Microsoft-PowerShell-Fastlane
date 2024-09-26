Connect-ExchangeOnline -AppId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -Organization $Tenant 

Connect-MgGraph -ClientId $Application_ID -CertificateThumbprint $Certificate_Thumb_Print -TenantId $TenantId

Connect-PnPOnline -Url $SPO_Site -Tenant $TenantId -ClientId $Application_ID -Thumbprint $CertThumbprint

Connect-MicrosoftTeams -CertificateThumbprint $CertThumbprint -ApplicationId $Application_ID -TenantId $TenantId