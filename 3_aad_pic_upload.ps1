# Vorgehen: Die Userfotos sind in einem Ordner abgelegt (hier: \portaits) mit dem Username so wie dieser im AAD erscheint 
# In diesem Ordner existiert der Unterordner \thumbnails
# Die Fotos werden komprimiert auf 96x96 und im Ordner \thumbnails abgelegt.
# Der Fotoname wird mit dem User auf AAD gemappt
# Die Userid dieses User wird gezogen um das entsprechende Thumbnail hochzuladen.
# --> Falls der User bereits ein Foto hat wird er übersprungen
# --> Falls es für einen User kein Foto gibt, kommt eine Meldung.

# Foto Pfad
$portraits = "C:\Users\lucs\Downloads\portraits"

# Install-Module AzureAD
Connect-AzureAD -Confirm  #ein Anmeldefenster sollte hier erscheinen

# überprüfe die Verbindung (auskommentieren)
# Get-AzureADUser -Top 10

# Alle AD USer
$alluser = Get-AzureADUser -All $True

# resize images
Get-ChildItem $portraits | .\ImgConvert.ps1 –ScaleXto 96 –ScaleYto 96 –Folder $portraits\thumbnails

# aktualisiere die Userfotos
ForEach ($user in $alluser) {
    # Hat user schon ein foto?
    $PhotoExists = $Null
    Try {$PhotoExists = Get-AzureADUserThumbnailPhoto -ObjectId $user[0].ObjectId }
        Catch {  # Nope - so update account picture
        Write-Host "Kein Foto fuer" $user.DisplayName "- lade Foto aus Ablage"
        Try{Set-AzureADUserThumbnailPhoto -ObjectId $user.ObjectId -FilePath "$portraits\thumbnails\$($user.DisplayName).jpg" }
            Catch{# Kein Foto in Ablage
            Write-Host "Fuer" $user.DisplayName "existiert kein Foto in der Ablage"}
        }
    }

#Test mit test user4
Get-AzureADUserThumbnailPhoto -ObjectId b91c05c8-ceab-4d62-ad51-78968fd427fd
Get-AzureADUser -ObjectId b91c05c8-ceab-4d62-ad51-78968fd427fd