# Apply-RussianTranslation.ps1
# Скрипт для применения русских переводов к файлам WinUtil

param(
    [string]$TranslationFile = "winutil-translations-ru.json",
    [string]$ConfigPath = "config"
)

$ErrorActionPreference = "Stop"

# Загрузка переводов
$translations = Get-Content $TranslationFile -Raw | ConvertFrom-Json

# Функция для применения переводов к applications.json
function Apply-AppTranslations {
    param($FilePath, $Translations)
    
    $apps = Get-Content $FilePath -Raw | ConvertFrom-Json
    $modified = $false
    
    foreach ($key in $Translations.applications.PSObject.Properties.Name) {
        if ($apps.$key) {
            $apps.$key.description = $Translations.applications.$key.description
            $modified = $true
        }
    }
    
    # Перевод категорий
    foreach ($appKey in $apps.PSObject.Properties.Name) {
        $category = $apps.$appKey.category
        if ($Translations.categories.$category) {
            $apps.$appKey.category = $Translations.categories.$category
        }
    }
    
    if ($modified) {
        $apps | ConvertTo-Json -Depth 10 | Out-File $FilePath -Encoding UTF8
        Write-Host "Updated: $FilePath" -ForegroundColor Green
    }
}

# Функция для применения переводов к tweaks.json
function Apply-TweakTranslations {
    param($FilePath, $Translations)
    
    $tweaks = Get-Content $FilePath -Raw | ConvertFrom-Json
    
    foreach ($key in $Translations.tweaks.PSObject.Properties.Name) {
        if ($tweaks.$key) {
            $tweaks.$key.Content = $Translations.tweaks.$key.Content
            $tweaks.$key.Description = $Translations.tweaks.$key.Description
        }
    }
    
    # Перевод категорий
    foreach ($tweakKey in $tweaks.PSObject.Properties.Name) {
        $category = $tweaks.$tweakKey.category
        if ($Translations.categories.$category) {
            $tweaks.$tweakKey.category = $Translations.categories.$category
        }
    }
    
    $tweaks | ConvertTo-Json -Depth 10 | Out-File $FilePath -Encoding UTF8
    Write-Host "Updated: $FilePath" -ForegroundColor Green
}

# Функция для применения переводов к feature.json
function Apply-FeatureTranslations {
    param($FilePath, $Translations)
    
    $features = Get-Content $FilePath -Raw | ConvertFrom-Json
    
    foreach ($key in $Translations.features.PSObject.Properties.Name) {
        if ($features.$key) {
            $features.$key.Content = $Translations.features.$key.Content
            $features.$key.Description = $Translations.features.$key.Description
        }
    }
    
    # Перевод категорий
    foreach ($featureKey in $features.PSObject.Properties.Name) {
        $category = $features.$featureKey.category
        if ($Translations.categories.$category) {
            $features.$featureKey.category = $Translations.categories.$category
        }
    }
    
    $features | ConvertTo-Json -Depth 10 | Out-File $FilePath -Encoding UTF8
    Write-Host "Updated: $FilePath" -ForegroundColor Green
}

# Применение переводов
Write-Host "Applying Russian translations..." -ForegroundColor Cyan

if (Test-Path "$ConfigPath\applications.json") {
    Apply-AppTranslations -FilePath "$ConfigPath\applications.json" -Translations $translations
}

if (Test-Path "$ConfigPath\tweaks.json") {
    Apply-TweakTranslations -FilePath "$ConfigPath\tweaks.json" -Translations $translations
}

if (Test-Path "$ConfigPath\feature.json") {
    Apply-FeatureTranslations -FilePath "$ConfigPath\feature.json" -Translations $translations
}

Write-Host "`nTranslation complete!" -ForegroundColor Green
Write-Host "Note: Some strings may still be in English. Add them to $TranslationFile and run again." -ForegroundColor Yellow
