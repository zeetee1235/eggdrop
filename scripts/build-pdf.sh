#!/bin/bash
# LaTeX 파일을 PDF로 변환하는 스크립트
# 사용법: ./build-pdf.sh [설계폴더명]

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

# LaTeX 파일을 PDF로 변환하는 함수
build_latex() {
    local dir=$1
    local tex_file="$dir/drawing.tex"
    
    if [ ! -f "$tex_file" ]; then
        print_error "$tex_file 파일이 존재하지 않습니다."
        return 1
    fi
    
    print_status "$dir 폴더의 LaTeX 파일을 PDF로 변환 중..."
    
    cd "$dir"
    
    # pdflatex 실행 (두 번 실행하여 목차 생성)
    print_status "첫 번째 pdflatex 실행..."
    if pdflatex -interaction=nonstopmode -halt-on-error drawing.tex > build.log 2>&1; then
        print_status "두 번째 pdflatex 실행 (목차 생성)..."
        if pdflatex -interaction=nonstopmode -halt-on-error drawing.tex >> build.log 2>&1; then
            if [ -f "drawing.pdf" ]; then
                local size=$(du -h drawing.pdf | cut -f1)
                print_success "PDF 생성 완료: $dir/drawing.pdf ($size)"
                
                # 임시 파일 정리
                rm -f *.aux *.log *.toc *.out *.fdb_latexmk *.fls *.synctex.gz
                print_status "임시 파일 정리 완료"
            else
                print_error "PDF 파일이 생성되지 않았습니다."
                return 1
            fi
        else
            print_error "두 번째 pdflatex 실행 실패"
            print_warning "build.log 파일을 확인하세요."
            return 1
        fi
    else
        print_error "첫 번째 pdflatex 실행 실패"
        print_warning "build.log 파일을 확인하세요."
        return 1
    fi
    
    cd ..
    return 0
}

# 메인 실행 부분
main() {
    echo "======================================"
    echo "   LaTeX to PDF 변환 스크립트"
    echo "======================================"
    
    # pdflatex 설치 확인
    if ! command -v pdflatex &> /dev/null; then
        print_error "pdflatex가 설치되어 있지 않습니다."
        print_warning "다음 명령어로 설치하세요:"
        echo "  Ubuntu/Debian: sudo apt-get install texlive-latex-base texlive-fonts-recommended texlive-latex-extra"
        echo "  CentOS/RHEL: sudo yum install texlive-latex texlive-collection-fontsrecommended"
        echo "  Arch Linux: sudo pacman -S texlive-core texlive-fontsextra"
        exit 1
    fi
    
    # 프로젝트 루트 디렉토리로 이동
    cd "$(dirname "$0")/.."
    
    # 인자가 제공된 경우 해당 폴더만 처리
    if [ $# -eq 1 ]; then
        if [ -d "$1" ]; then
            build_latex "$1"
        else
            print_error "폴더 '$1'이 존재하지 않습니다."
            exit 1
        fi
    else
        # 모든 설계 폴더 처리
        success_count=0
        fail_count=0
        
        for dir in "공학_기술_기반의_설계" "자유_설계"; do
            if [ -d "$dir" ]; then
                if build_latex "$dir"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                echo
            else
                print_warning "폴더 '$dir'이 존재하지 않습니다."
            fi
        done
        
        echo "======================================"
        print_status "변환 완료 - 성공: $success_count, 실패: $fail_count"
        
        if [ $fail_count -eq 0 ]; then
            print_success "모든 PDF 변환이 성공적으로 완료되었습니다!"
        else
            print_warning "일부 변환에 실패했습니다. 로그를 확인하세요."
        fi
    fi
}

# 도움말 표시
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "LaTeX to PDF 변환 스크립트"
    echo ""
    echo "사용법:"
    echo "  $0                    # 모든 설계 폴더의 LaTeX 파일을 PDF로 변환"
    echo "  $0 [폴더명]           # 특정 폴더의 LaTeX 파일을 PDF로 변환"
    echo "  $0 -h, --help        # 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0"
    echo "  $0 공학_기술_기반의_설계"
    echo "  $0 자유_설계"
    echo ""
    echo "참고:"
    echo "  - 각 폴더에 drawing.tex 파일이 있어야 합니다"
    echo "  - pdflatex가 설치되어 있어야 합니다"
    echo "  - 생성된 PDF는 각 폴더의 drawing.pdf 파일입니다"
    exit 0
fi

# 메인 함수 실행
main "$@"
