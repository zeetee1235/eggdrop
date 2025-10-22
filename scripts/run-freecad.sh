#!/bin/bash
# FreeCAD 스크립트를 실행하고 GUI로 열어주는 스크립트
# 사용법: ./run-freecad.sh [설계폴더명]

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

# FreeCAD 설치 확인 함수
check_freecad() {
    if command -v freecad &> /dev/null; then
        return 0
    elif command -v FreeCAD &> /dev/null; then
        return 0
    elif flatpak list | grep -q org.freecad.FreeCAD; then
        return 0
    else
        return 1
    fi
}

# FreeCAD 명령어 찾기
get_freecad_command() {
    if command -v freecad &> /dev/null; then
        echo "freecad"
    elif command -v FreeCAD &> /dev/null; then
        echo "FreeCAD"
    elif flatpak list | grep -q org.freecad.FreeCAD; then
        echo "flatpak run org.freecad.FreeCAD"
    else
        echo ""
    fi
}

# Python 스크립트 실행 및 FCStd 파일 생성
run_freecad_script() {
    local dir=$1
    local script_file=""
    local fcstd_file=""
    
    # 스크립트 파일 찾기
    if [ -f "$dir/script.py" ]; then
        script_file="$dir/script.py"
        fcstd_file="$dir/EggDrop.FCStd"
    elif [ -f "$dir/visible_cube.py" ]; then
        script_file="$dir/visible_cube.py"
        fcstd_file="$dir/VisibleCube.FCStd"
    else
        print_error "$dir 폴더에 FreeCAD 스크립트 파일이 없습니다."
        print_warning "다음 파일 중 하나가 있어야 합니다: script.py, visible_cube.py"
        return 1
    fi
    
    print_status "$dir 폴더의 FreeCAD 스크립트 실행 중..."
    print_status "스크립트 파일: $(basename $script_file)"
    
    cd "$dir"
    
    # FreeCAD 명령어 가져오기
    local freecad_cmd=$(get_freecad_command)
    
    # 콘솔 모드로 스크립트 실행
    print_status "FreeCAD 콘솔 모드로 3D 모델 생성 중..."
    if $freecad_cmd --console "$(basename $script_file)" > freecad.log 2>&1; then
        if [ -f "$(basename $fcstd_file)" ]; then
            local size=$(du -h "$(basename $fcstd_file)" | cut -f1)
            print_success "FCStd 파일 생성 완료: $(basename $fcstd_file) ($size)"
        else
            print_warning "FCStd 파일이 생성되지 않았지만 스크립트 실행은 성공했습니다."
        fi
    else
        print_error "FreeCAD 스크립트 실행 실패"
        print_warning "freecad.log 파일을 확인하세요."
        cd ..
        return 1
    fi
    
    cd ..
    return 0
}

# FreeCAD GUI로 파일 열기
open_freecad_gui() {
    local dir=$1
    local fcstd_file=""
    
    # FCStd 파일 찾기
    if [ -f "$dir/EggDrop.FCStd" ]; then
        fcstd_file="$dir/EggDrop.FCStd"
    elif [ -f "$dir/VisibleCube.FCStd" ]; then
        fcstd_file="$dir/VisibleCube.FCStd"
    else
        print_warning "$dir 폴더에 FCStd 파일이 없습니다."
        return 1
    fi
    
    local freecad_cmd=$(get_freecad_command)
    
    print_status "FreeCAD GUI로 파일을 여는 중..."
    print_status "파일: $fcstd_file"
    
    # 백그라운드로 FreeCAD GUI 실행
    $freecad_cmd "$fcstd_file" &> /dev/null &
    local pid=$!
    print_success "FreeCAD GUI가 실행되었습니다."
    print_status "프로세스 ID: $pid"
    
    return 0
}

# 메인 실행 부분
main() {
    echo "======================================"
    echo "   FreeCAD 스크립트 실행기"
    echo "======================================"
    
    # 프로젝트 루트 디렉토리로 이동
    cd "$(dirname "$0")/.."
    
    # FreeCAD 설치 확인
    if ! check_freecad; then
        print_error "FreeCAD가 설치되어 있지 않습니다."
        print_warning "다음 중 하나의 방법으로 설치하세요:"
        echo "  Ubuntu/Debian: sudo apt-get install freecad"
        echo "  CentOS/RHEL: sudo yum install FreeCAD"
        echo "  Arch Linux: sudo pacman -S freecad"
        echo "  Flatpak: flatpak install flathub org.freecad.FreeCAD"
        echo "  웹사이트: https://www.freecad.org/downloads.php"
        exit 1
    fi
    
    local freecad_cmd=$(get_freecad_command)
    print_status "FreeCAD 명령어: $freecad_cmd"
    
    # 인자가 제공된 경우 해당 폴더만 처리
    if [ $# -eq 1 ]; then
        if [ -d "$1" ]; then
            if run_freecad_script "$1"; then
                echo
                read -p "FreeCAD GUI로 파일을 열까요? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    open_freecad_gui "$1"
                fi
            fi
        else
            print_error "폴더 '$1'이 존재하지 않습니다."
            exit 1
        fi
    else
        # CAD 설계가 있는 폴더만 처리
        success_count=0
        fail_count=0
        
        # 공학_기술_기반의_설계만 처리 (자유_설계는 실제 제작물이므로 CAD 파일 없음)
        dir="공학_기술_기반의_설계"
        if [ -d "$dir" ]; then
            if run_freecad_script "$dir"; then
                ((success_count++))
            else
                ((fail_count++))
            fi
            echo
        else
            print_warning "폴더 '$dir'이 존재하지 않습니다."
        fi
        
        print_status "자유_설계는 실제 제작물이므로 CAD 파일이 없습니다."
        
        echo "======================================"
        print_status "스크립트 실행 완료 - 성공: $success_count, 실패: $fail_count"
        
            if [ $success_count -gt 0 ]; then
                echo
                read -p "FreeCAD GUI로 파일을 열까요? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    open_freecad_gui "공학_기술_기반의_설계"
                fi
            fi
        
        if [ $fail_count -eq 0 ] && [ $success_count -gt 0 ]; then
            print_success "모든 FreeCAD 스크립트가 성공적으로 실행되었습니다!"
        elif [ $fail_count -gt 0 ]; then
            print_warning "일부 스크립트 실행에 실패했습니다. 로그를 확인하세요."
        fi
    fi
}

# 도움말 표시
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "FreeCAD 스크립트 실행기"
    echo ""
    echo "사용법:"
    echo "  $0                    # 모든 설계 폴더의 FreeCAD 스크립트 실행"
    echo "  $0 [폴더명]           # 특정 폴더의 FreeCAD 스크립트 실행"
    echo "  $0 -h, --help        # 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0"
    echo "  $0 공학_기술_기반의_설계"
    echo "  $0 자유_설계"
    echo ""
    echo "기능:"
    echo "  1. Python 스크립트를 콘솔 모드로 실행하여 FCStd 파일 생성"
    echo "  2. 생성된 FCStd 파일을 FreeCAD GUI로 열기 (선택사항)"
    echo ""
    echo "참고:"
    echo "  - 각 폴더에 script.py 또는 visible_cube.py 파일이 있어야 합니다"
    echo "  - FreeCAD가 설치되어 있어야 합니다"
    echo "  - 생성된 FCStd 파일은 각 폴더에 저장됩니다"
    exit 0
fi

# 메인 함수 실행
main "$@"
