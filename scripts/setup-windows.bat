@echo off
chcp 65001 > nul
echo ========================================
echo 계란낙하 보호구조 프로젝트 - Windows Setup
echo ========================================
echo.

echo [1/4] 필요한 소프트웨어 확인 중...

:: Git 확인
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git이 설치되지 않았습니다.
    echo    https://git-scm.com/download/win 에서 Git을 설치하세요.
    pause
    exit /b 1
) else (
    echo ✅ Git 설치 확인됨
)

:: Python 확인 (FreeCAD Python API용)
python --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Python이 설치되지 않았습니다.
    echo    https://www.python.org/downloads/ 에서 Python을 설치하세요.
) else (
    echo ✅ Python 설치 확인됨
)

echo.
echo [2/4] LaTeX 환경 확인 중...

:: MiKTeX 또는 TeX Live 확인
pdflatex --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  LaTeX가 설치되지 않았습니다.
    echo    MiKTeX: https://miktex.org/download
    echo    또는 TeX Live: https://www.tug.org/texlive/
) else (
    echo ✅ LaTeX 설치 확인됨
)

echo.
echo [3/4] FreeCAD 확인 중...

:: FreeCAD 확인 (일반적인 설치 경로들)
set FREECAD_FOUND=0
if exist "C:\Program Files\FreeCAD 0.21\bin\FreeCAD.exe" set FREECAD_FOUND=1
if exist "C:\Program Files\FreeCAD 1.0\bin\FreeCAD.exe" set FREECAD_FOUND=1
if exist "%USERPROFILE%\AppData\Local\Programs\FreeCAD 0.21\bin\FreeCAD.exe" set FREECAD_FOUND=1
if exist "%USERPROFILE%\AppData\Local\Programs\FreeCAD 1.0\bin\FreeCAD.exe" set FREECAD_FOUND=1

if %FREECAD_FOUND%==1 (
    echo ✅ FreeCAD 설치 확인됨
) else (
    echo ⚠️  FreeCAD가 설치되지 않았습니다.
    echo    https://www.freecad.org/downloads.php 에서 FreeCAD를 설치하세요.
)

echo.
echo [4/4] 프로젝트 폴더 구조 확인 중...

if exist "공학_기술_기반의_설계" (
    echo ✅ 공학_기술_기반의_설계 폴더 확인됨
) else (
    echo ❌ 공학_기술_기반의_설계 폴더가 없습니다.
)

if exist "자유_설계" (
    echo ✅ 자유_설계 폴더 확인됨
) else (
    echo ❌ 자유_설계 폴더가 없습니다.
)

if exist "보고서_회의록" (
    echo ✅ 보고서_회의록 폴더 확인됨
) else (
    echo ❌ 보고서_회의록 폴더가 없습니다.
)

echo.
echo ========================================
echo 설정 완료!
echo ========================================
echo.
echo 다음 단계:
echo 1. build-pdf.bat : PDF 문서 생성
echo 2. open-freecad.bat : FreeCAD로 3D 모델 열기
echo 3. run-tests.bat : 테스트 실행
echo.
pause
