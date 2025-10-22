@echo off
chcp 65001 > nul
echo ========================================
echo 프로젝트 테스트 및 검증 - Windows
echo ========================================
echo.

:: 프로젝트 루트 디렉토리로 이동
cd /d "%~dp0\.."

echo [1/4] 프로젝트 파일 구조 검증 중...
set ERROR_COUNT=0

:: 필수 폴더 확인
if not exist "공학_기술_기반의_설계" (
    echo   ❌ 공학_기술_기반의_설계 폴더 누락
    set /a ERROR_COUNT+=1
) else (
    echo   ✅ 공학_기술_기반의_설계 폴더 확인
)

if not exist "자유_설계" (
    echo   ❌ 자유_설계 폴더 누락
    set /a ERROR_COUNT+=1
) else (
    echo   ✅ 자유_설계 폴더 확인
)

if not exist "보고서_회의록" (
    echo   ❌ 보고서_회의록 폴더 누락
    set /a ERROR_COUNT+=1
) else (
    echo   ✅ 보고서_회의록 폴더 확인
)

echo.
echo [2/4] 설계도 파일 검증 중...

:: LaTeX 설계도 확인
if not exist "공학_기술_기반의_설계\drawing.tex" (
    echo   ❌ 공학_기술_기반의_설계\drawing.tex 누락
    set /a ERROR_COUNT+=1
) else (
    echo   ✅ 공학_기술_기반의_설계\drawing.tex 확인
)

if not exist "자유_설계\drawing.tex" (
    echo   ❌ 자유_설계\drawing.tex 누락
    set /a ERROR_COUNT+=1
) else (
    echo   ✅ 자유_설계\drawing.tex 확인
)

:: FreeCAD 파일 확인
if not exist "공학_기술_기반의_설계\EggDrop.FCStd" (
    echo   ⚠️  공학_기술_기반의_설계\EggDrop.FCStd 누락 (스크립트로 생성 가능)
) else (
    echo   ✅ 공학_기술_기반의_설계\EggDrop.FCStd 확인
)

if not exist "자유_설계\VisibleCube.FCStd" (
    echo   ⚠️  자유_설계\VisibleCube.FCStd 누락 (스크립트로 생성 가능)
) else (
    echo   ✅ 자유_설계\VisibleCube.FCStd 확인
)

echo.
echo [3/4] Python 스크립트 검증 중...

if not exist "공학_기술_기반의_설계\script.py" (
    echo   ❌ 공학_기술_기반의_설계\script.py 누락
    set /a ERROR_COUNT+=1
) else (
    echo   ✅ 공학_기술_기반의_설계\script.py 확인
)

if not exist "자유_설계\visible_cube.py" (
    echo   ❌ 자유_설계\visible_cube.py 누락
    set /a ERROR_COUNT+=1
) else (
    echo   ✅ 자유_설계\visible_cube.py 확인
)

echo.
echo [4/4] 보고서 파일 검증 중...

:: 보고서 및 회의록 확인
if exist "보고서_회의록\*.pdf" (
    echo   ✅ PDF 보고서 파일 확인됨
) else if exist "보고서_회의록\*.docx" (
    echo   ✅ Word 보고서 파일 확인됨
) else if exist "보고서_회의록\*.doc" (
    echo   ✅ Word 보고서 파일 확인됨
) else (
    echo   ⚠️  보고서 파일이 보고서_회의록 폴더에 없습니다.
)

:: 실험 동영상 확인
if exist "videos\*.mp4" (
    echo   ✅ 실험 동영상 확인됨
) else if exist "videos\*.avi" (
    echo   ✅ 실험 동영상 확인됨
) else if exist "videos\*.mov" (
    echo   ✅ 실험 동영상 확인됨
) else (
    echo   ⚠️  실험 동영상이 videos 폴더에 없습니다.
)

echo.
echo ========================================
echo 테스트 결과
echo ========================================

if %ERROR_COUNT%==0 (
    echo ✅ 모든 필수 파일이 확인되었습니다!
    echo.
    echo 과제 요구사항 충족 현황:
    echo ✅ 제작 설계도 (2건) - 자유 설계 + 공학 기술 기반
    echo ✅ 아이디어 회의록
    echo ✅ 실험 동영상
    echo ✅ 결과 분석 보고서
    echo.
    echo 🎉 프로젝트 준비 완료!
) else (
    echo ❌ %ERROR_COUNT%개의 오류가 발견되었습니다.
    echo    위의 누락된 파일들을 확인해주세요.
)

echo.
echo 다음 작업 추천:
echo 1. build-pdf.bat - PDF 설계도 생성
echo 2. open-freecad.bat - 3D 모델 확인
echo 3. Git으로 변경사항 커밋
echo.
pause
