# Update Import Paths Script
# Mengupdate semua import statement dari struktur lama ke struktur baru

Write-Host "Updating import paths in all Dart files..." -ForegroundColor Cyan

$libPath = "c:\GitHub Clone\New_PBL_Jawara\pbl_new\lib"

# Define replacements
$replacements = @{
    # Auth screens
    "import 'screens/login_screen.dart'" = "import 'package:pbl_new/features/auth/screens/login_screen.dart'"
    "import 'screens/register_screen.dart'" = "import 'package:pbl_new/features/auth/screens/register_screen.dart'"
    "import 'screens/splash_screen.dart'" = "import 'package:pbl_new/features/auth/screens/splash_screen.dart'"
    "import '../screens/login_screen.dart'" = "import 'package:pbl_new/features/auth/screens/login_screen.dart'"
    
    # Warga screens
    "import 'screens/beranda_screen.dart'" = "import 'package:pbl_new/features/warga/screens/beranda_screen.dart'"
    "import 'screens/jualan_screen.dart'" = "import 'package:pbl_new/features/warga/screens/jualan_screen.dart'"
    "import 'screens/chat_screen.dart'" = "import 'package:pbl_new/features/warga/screens/chat_screen.dart'"
    "import 'screens/chat_detail_screen.dart'" = "import 'package:pbl_new/features/warga/screens/chat_detail_screen.dart'"
    "import 'screens/profil_screen.dart'" = "import 'package:pbl_new/features/warga/screens/profil_screen.dart'"
    "import 'screens/add_product_screen.dart'" = "import 'package:pbl_new/features/warga/screens/add_product_screen.dart'"
    "import 'screens/product_detail_screen.dart'" = "import 'package:pbl_new/features/warga/screens/product_detail_screen.dart'"
    "import 'screens/camera_detection_screen.dart'" = "import 'package:pbl_new/features/warga/screens/camera_detection_screen.dart'"
    
    # RT screens
    "import 'screens/rt_main_screen.dart'" = "import 'package:pbl_new/features/rt/screens/rt_main_screen.dart'"
    "import 'screens/rt_dashboard_screen.dart'" = "import 'package:pbl_new/features/rt/screens/rt_dashboard_screen.dart'"
    "import 'screens/rt_warga_list_screen.dart'" = "import 'package:pbl_new/features/rt/screens/rt_warga_list_screen.dart'"
    "import 'screens/rt_approval_screen.dart'" = "import 'package:pbl_new/features/rt/screens/rt_approval_screen.dart'"
    "import 'screens/rt_profil_screen.dart'" = "import 'package:pbl_new/features/rt/screens/rt_profil_screen.dart'"
    
    # Admin screens
    "import 'screens/admin_main_screen.dart'" = "import 'package:pbl_new/features/admin/screens/admin_main_screen.dart'"
    "import 'screens/admin_dashboard_screen.dart'" = "import 'package:pbl_new/features/admin/screens/admin_dashboard_screen.dart'"
    "import 'screens/admin_profile_screen.dart'" = "import 'package:pbl_new/features/admin/screens/admin_profile_screen.dart'"
    
    # Services (relative to absolute)
    "import '../services/" = "import 'package:pbl_new/core/services/"
    "import 'services/" = "import 'package:pbl_new/core/services/"
    
    # Models (relative to absolute)
    "import '../models/" = "import 'package:pbl_new/core/models/"
    "import 'models/" = "import 'package:pbl_new/core/models/"
    
    # Widgets
    "import '../widgets/product_card.dart'" = "import 'package:pbl_new/features/warga/widgets/product_card.dart'"
    "import 'widgets/product_card.dart'" = "import 'package:pbl_new/features/warga/widgets/product_card.dart'"
    
    # Config
    "import '../config/" = "import 'package:pbl_new/config/"
}

# Get all Dart files
$dartFiles = Get-ChildItem -Path $libPath -Filter *.dart -Recurse

$totalFiles = 0
$updatedFiles = 0

foreach ($file in $dartFiles) {
    $totalFiles++
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $modified = $false
    
    foreach ($old in $replacements.Keys) {
        $new = $replacements[$old]
        if ($content -match [regex]::Escape($old)) {
            $content = $content -replace [regex]::Escape($old), $new
            $modified = $true
        }
    }
    
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated: $($file.FullName)" -ForegroundColor Green
        $updatedFiles++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Import Path Update Complete!" -ForegroundColor Green
Write-Host "Total files scanned: $totalFiles" -ForegroundColor Yellow
Write-Host "Files updated: $updatedFiles" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
