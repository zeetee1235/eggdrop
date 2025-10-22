@echo off
chcp 65001 > nul
echo ========================================
echo FreeCAD 3D 모델 열기 - Windows
echo ========================================
echo.

:: 프로젝트 루트 디렉토리로 이동
cd /d "%~dp0\.."

:: 일반적인 FreeCAD 설치 경로들 확인
set FREECAD_EXE=""

if exist "C:\Program Files\FreeCAD 1.0\bin\FreeCAD.exe" (
    set FREECAD_EXE="C:\Program Files\FreeCAD 1.0\bin\FreeCAD.exe"
    echo ✅ FreeCAD 1.0 발견
) else if exist "C:\Program Files\FreeCAD 0.21\bin\FreeCAD.exe" (
    set FREECAD_EXE="C:\Program Files\FreeCAD 0.21\bin\FreeCAD.exe"
    echo ✅ FreeCAD 0.21 발견
) else if exist "%USERPROFILE%\AppData\Local\Programs\FreeCAD 1.0\bin\FreeCAD.exe" (
    set FREECAD_EXE="%USERPROFILE%\AppData\Local\Programs\FreeCAD 1.0\bin\FreeCAD.exe"
    echo ✅ FreeCAD 1.0 (사용자 설치) 발견
) else if exist "%USERPROFILE%\AppData\Local\Programs\FreeCAD 0.21\bin\FreeCAD.exe" (
    set FREECAD_EXE="%USERPROFILE%\AppData\Local\Programs\FreeCAD 0.21\bin\FreeCAD.exe"
    echo ✅ FreeCAD 0.21 (사용자 설치) 발견
) else (
    echo ❌ FreeCAD를 찾을 수 없습니다.
    echo.
    echo FreeCAD 설치 경로를 직접 입력해주세요:
    echo 예: C:\Program Files\FreeCAD 1.0\bin\FreeCAD.exe
    set /p FREECAD_EXE=FreeCAD 경로: 
)

if %FREECAD_EXE%=="" (
    echo FreeCAD 경로가 지정되지 않았습니다.
    pause
    exit /b 1
)

echo.
echo 어떤 모델을 열겠습니까?
echo 1. 공학_기술_기반의_설계 (정사면체 기반)
echo 2. 자유_설계 (정육면체 기반)
echo 3. 둘 다 열기
echo 4. 스크립트로 새로 생성
echo.
set /p choice=선택 (1-4): 

if "%choice%"=="1" (
    if exist "공학_기술_기반의_설계\EggDrop.FCStd" (
        echo 공학_기술_기반의_설계 모델을 여는 중...
        start "" %FREECAD_EXE% "공학_기술_기반의_설계\EggDrop.FCStd"
    ) else (
        echo ❌ 공학_기술_기반의_설계\EggDrop.FCStd 파일이 없습니다.
    )
) else if "%choice%"=="2" (
    if exist "자유_설계\VisibleCube.FCStd" (
        echo 자유_설계 모델을 여는 중...
        start "" %FREECAD_EXE% "자유_설계\VisibleCube.FCStd"
    ) else (
        echo ❌ 자유_설계\VisibleCube.FCStd 파일이 없습니다.
    )
) else if "%choice%"=="3" (
    if exist "공학_기술_기반의_설계\EggDrop.FCStd" (
        echo 공학_기술_기반의_설계 모델을 여는 중...
        start "" %FREECAD_EXE% "공학_기술_기반의_설계\EggDrop.FCStd"
    )
    if exist "자유_설계\VisibleCube.FCStd" (
        echo 자유_설계 모델을 여는 중...
        start "" %FREECAD_EXE% "자유_설계\VisibleCube.FCStd"
    )
) else if "%choice%"=="4" (
    echo.
    echo 어떤 스크립트를 실행하겠습니까?
    echo 1. 공학_기술_기반의_설계 스크립트
    echo 2. 자유_설계 스크립트
    set /p script_choice=선택 (1-2): 
    
    if "%script_choice%"=="1" (
        if exist "공학_기술_기반의_설계\script.py" (
            echo 공학_기술_기반의_설계 스크립트 실행 중...
            start "" %FREECAD_EXE% "공학_기술_기반의_설계\script.py"
        ) else (
            echo ❌ 공학_기술_기반의_설계\script.py 파일이 없습니다.
        )
    ) else if "%script_choice%"=="2" (
        if exist "자유_설계\visible_cube.py" (
            echo 자유_설계 스크립트 실행 중...
            start "" %FREECAD_EXE% "자유_설계\visible_cube.py"
        ) else (
            echo ❌ 자유_설계\visible_cube.py 파일이 없습니다.
        )
    )
) else (
    echo 잘못된 선택입니다.
)

echo.
pause
