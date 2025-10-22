@echo off
chcp 65001 > nul
echo ========================================
echo PDF 문서 생성 - Windows
echo ========================================
echo.

:: 프로젝트 루트 디렉토리로 이동
cd /d "%~dp0\.."
set "CURRENT_DIR=%CD%"

echo [1/2] 공학_기술_기반의_설계 PDF 생성 중...
if exist "공학_기술_기반의_설계\drawing.tex" (
    cd "공학_기술_기반의_설계"
    echo   - pdflatex 실행 중 (1차)...
    pdflatex -interaction=nonstopmode drawing.tex > nul 2>&1
    echo   - pdflatex 실행 중 (2차, 목차 생성)...
    pdflatex -interaction=nonstopmode drawing.tex > nul 2>&1
    
    if exist "drawing.pdf" (
        echo   ✅ 공학_기술_기반의_설계\drawing.pdf 생성 완료
    ) else (
        echo   ❌ PDF 생성 실패
    )
    cd "%CURRENT_DIR%"
) else (
    echo   ❌ 공학_기술_기반의_설계\drawing.tex 파일이 없습니다.
)

echo.
echo [2/2] 자유_설계 PDF 생성 중...
if exist "자유_설계\drawing.tex" (
    cd "자유_설계"
    echo   - pdflatex 실행 중 (1차)...
    pdflatex -interaction=nonstopmode drawing.tex > nul 2>&1
    echo   - pdflatex 실행 중 (2차, 목차 생성)...
    pdflatex -interaction=nonstopmode drawing.tex > nul 2>&1
    
    if exist "drawing.pdf" (
        echo   ✅ 자유_설계\drawing.pdf 생성 완료
    ) else (
        echo   ❌ PDF 생성 실패
    )
    cd "%CURRENT_DIR%"
) else (
    echo   ❌ 자유_설계\drawing.tex 파일이 없습니다.
)

echo.
echo ========================================
echo PDF 생성 완료!
echo ========================================
echo.
echo 생성된 파일:
if exist "공학_기술_기반의_설계\drawing.pdf" echo   - 공학_기술_기반의_설계\drawing.pdf
if exist "자유_설계\drawing.pdf" echo   - 자유_설계\drawing.pdf
echo.

:: PDF 파일 열기 (선택사항)
echo PDF 파일을 열겠습니까? (y/n)
set /p choice=입력: 
if /i "%choice%"=="y" (
    if exist "공학_기술_기반의_설계\drawing.pdf" start "" "공학_기술_기반의_설계\drawing.pdf"
    if exist "자유_설계\drawing.pdf" start "" "자유_설계\drawing.pdf"
)

pause
