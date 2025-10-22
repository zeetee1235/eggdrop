#!/bin/bash
# 전체 프로젝트 빌드 스크립트
# 사용법: ./build-all.sh

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 색상 출력
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

main() {
    echo "=========================================="
    echo "   계란낙하 프로젝트 전체 빌드 스크립트"
    echo "=========================================="
    echo
    
    # 프로젝트 루트 디렉토리로 이동
    cd "$(dirname "$0")/.."
    
    print_status "1. FreeCAD 3D 모델 생성 중..."
    if scripts/run-freecad.sh; then
        print_success "FreeCAD 3D 모델 생성 완료"
    else
        print_warning "FreeCAD 3D 모델 생성에 일부 실패했지만 계속 진행합니다."
    fi
    
    echo
    print_status "2. LaTeX 문서를 PDF로 변환 중..."
    if scripts/build-pdf.sh; then
        print_success "PDF 문서 생성 완료"
    else
        print_warning "PDF 문서 생성에 일부 실패했지만 계속 진행합니다."
    fi
    
    echo
    print_status "3. 생성된 파일 목록:"
    echo
    
    # 공학_기술_기반의_설계 폴더
    if [ -d "공학_기술_기반의_설계" ]; then
        print_status "공학_기술_기반의_설계 폴더:"
        if [ -f "공학_기술_기반의_설계/EggDrop.FCStd" ]; then
            local size=$(du -h "공학_기술_기반의_설계/EggDrop.FCStd" | cut -f1)
            echo "  ✓ EggDrop.FCStd ($size)"
        else
            echo "  ✗ EggDrop.FCStd (없음)"
        fi
        
        if [ -f "공학_기술_기반의_설계/drawing.pdf" ]; then
            local size=$(du -h "공학_기술_기반의_설계/drawing.pdf" | cut -f1)
            echo "  ✓ drawing.pdf ($size)"
        else
            echo "  ✗ drawing.pdf (없음)"
        fi
    fi
    
    # 자유_설계 폴더
    if [ -d "자유_설계" ]; then
        print_status "자유_설계 폴더:"
        if [ -f "자유_설계/drawing.pdf" ]; then
            local size=$(du -h "자유_설계/drawing.pdf" | cut -f1)
            echo "  ✓ drawing.pdf ($size)"
        else
            echo "  ✗ drawing.pdf (없음)"
        fi
        
        if [ -f "자유_설계/자유_설계_설계도.jpg" ]; then
            local size=$(du -h "자유_설계/자유_설계_설계도.jpg" | cut -f1)
            echo "  ✓ 자유_설계_설계도.jpg ($size)"
        else
            echo "  ✗ 자유_설계_설계도.jpg (없음)"
        fi
    fi
    
    echo
    print_success "전체 빌드 프로세스가 완료되었습니다!"
    echo
    print_status "다음 명령어로 개별 실행 가능:"
    echo "  ./run-freecad.sh     # FreeCAD 3D 모델 생성/열기"
    echo "  ./build-pdf.sh       # LaTeX PDF 변환"
    echo "  ./run-freecad.sh 공학_기술_기반의_설계  # 특정 폴더만"
    echo "  ./build-pdf.sh 자유_설계              # 특정 폴더만"
}

# 도움말 표시
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "계란낙하 프로젝트 전체 빌드 스크립트"
    echo ""
    echo "이 스크립트는 다음 작업을 수행합니다:"
    echo "  1. FreeCAD Python 스크립트를 실행하여 3D 모델 (.FCStd) 생성"
    echo "  2. LaTeX 파일을 컴파일하여 PDF 문서 생성"
    echo "  3. 생성된 파일들의 목록과 크기 표시"
    echo ""
    echo "사용법:"
    echo "  $0                # 전체 빌드 실행"
    echo "  $0 -h, --help    # 도움말 표시"
    echo ""
    echo "요구사항:"
    echo "  - FreeCAD 설치 (flatpak, apt, yum 등)"
    echo "  - LaTeX 설치 (pdflatex)"
    echo "  - 실행 권한: chmod +x build-all.sh"
    exit 0
fi

# 메인 함수 실행
main "$@"
