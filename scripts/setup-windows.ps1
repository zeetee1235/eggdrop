# 계란낙하 보호구조 프로젝트 - PowerShell Setup
# UTF-8 인코딩 설정
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "계란낙하 보호구조 프로젝트 - PowerShell Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] 필요한 소프트웨어 확인 중..." -ForegroundColor Yellow

# Git 확인
try {
    $gitVersion = git --version 2>$null
    Write-Host "✅ Git 설치 확인됨: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git이 설치되지 않았습니다." -ForegroundColor Red
    Write-Host "   https://git-scm.com/download/win 에서 Git을 설치하세요." -ForegroundColor Yellow
}

# Python 확인
try {
    $pythonVersion = python --version 2>$null
    Write-Host "✅ Python 설치 확인됨: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Python이 설치되지 않았습니다." -ForegroundColor Yellow
    Write-Host "   https://www.python.org/downloads/ 에서 Python을 설치하세요." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[2/4] LaTeX 환경 확인 중..." -ForegroundColor Yellow

# LaTeX 확인
try {
    $latexVersion = pdflatex --version 2>$null | Select-Object -First 1
    Write-Host "✅ LaTeX 설치 확인됨: $latexVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️  LaTeX가 설치되지 않았습니다." -ForegroundColor Yellow
    Write-Host "   MiKTeX: https://miktex.org/download" -ForegroundColor Yellow
    Write-Host "   또는 TeX Live: https://www.tug.org/texlive/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/4] FreeCAD 확인 중..." -ForegroundColor Yellow

# FreeCAD 확인
$freecadPaths = @(
    "C:\Program Files\FreeCAD 1.0\bin\FreeCAD.exe",
    "C:\Program Files\FreeCAD 0.21\bin\FreeCAD.exe",
    "$env:USERPROFILE\AppData\Local\Programs\FreeCAD 1.0\bin\FreeCAD.exe",
    "$env:USERPROFILE\AppData\Local\Programs\FreeCAD 0.21\bin\FreeCAD.exe"
)

$freecadFound = $false
foreach ($path in $freecadPaths) {
    if (Test-Path $path) {
        Write-Host "✅ FreeCAD 설치 확인됨: $path" -ForegroundColor Green
        $freecadFound = $true
        break
    }
}

if (-not $freecadFound) {
    Write-Host "⚠️  FreeCAD가 설치되지 않았습니다." -ForegroundColor Yellow
    Write-Host "   https://www.freecad.org/downloads.php 에서 FreeCAD를 설치하세요." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[4/4] 프로젝트 폴더 구조 확인 중..." -ForegroundColor Yellow

$folders = @("공학_기술_기반의_설계", "자유_설계", "보고서_회의록")
foreach ($folder in $folders) {
    if (Test-Path $folder) {
        Write-Host "✅ $folder 폴더 확인됨" -ForegroundColor Green
    } else {
        Write-Host "❌ $folder 폴더가 없습니다." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "설정 완료!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host "1. .\build-pdf.ps1 : PDF 문서 생성" -ForegroundColor White
Write-Host "2. .\open-freecad.ps1 : FreeCAD로 3D 모델 열기" -ForegroundColor White
Write-Host "3. .\run-tests.ps1 : 테스트 실행" -ForegroundColor White
Write-Host ""

Read-Host "계속하려면 Enter를 누르세요"
