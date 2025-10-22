#!/bin/bash

set -e  # 에러 발생 시 스크립트 중단

echo "========================================="
echo "FreeCAD Python 개발 환경 설정 시작"
echo "========================================="
echo ""

# uv가 설치되어 있는지 확인
if ! command -v uv &> /dev/null; then
    echo "📦 uv를 설치하는 중..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # PATH에 uv 추가
    export PATH="$HOME/.cargo/bin:$PATH"
    echo "✅ uv 설치 완료"
else
    echo "✅ uv가 이미 설치되어 있습니다."
fi

echo ""

# Python 가상환경이 존재하는지 확인
if [ ! -d ".venv" ]; then
    echo "🐍 Python 가상환경을 생성하는 중..."
    uv venv .venv
    echo "✅ 가상환경 생성 완료"
else
    echo "✅ 가상환경이 이미 존재합니다."
fi

echo ""

# 가상환경 활성화
echo "🔄 가상환경을 활성화하는 중..."
source .venv/bin/activate
echo "✅ 가상환경 활성화 완료"

echo ""

# FreeCAD 설치 확인 (Flatpak 또는 시스템)
FREECAD_FLATPAK=""
FREECAD_PATH=""

# Flatpak FreeCAD 설치 확인
if command -v flatpak &> /dev/null; then
    if flatpak list | grep -q "org.freecad.FreeCAD\|org.freecadweb.FreeCAD"; then
        FREECAD_FLATPAK="true"
        echo "✅ Flatpak을 통해 FreeCAD를 찾았습니다."
    fi
fi

# 시스템 FreeCAD 설치 확인
if [ -z "$FREECAD_FLATPAK" ]; then
    FREECAD_PATH=$(which freecad 2>/dev/null)
    if [ -n "$FREECAD_PATH" ]; then
        echo "✅ 시스템 PATH에서 FreeCAD를 찾았습니다: $FREECAD_PATH"
    fi
fi

echo ""

# FreeCAD가 없으면 설치
if [ -z "$FREECAD_FLATPAK" ] && [ -z "$FREECAD_PATH" ]; then
    echo "⚠️  FreeCAD가 설치되어 있지 않습니다."
    echo "📦 Flatpak을 사용하여 FreeCAD를 설치합니다..."

    # Flatpak이 설치되어 있는지 확인
    if ! command -v flatpak &> /dev/null; then
        echo "📦 Flatpak이 설치되어 있지 않습니다. Flatpak을 설치합니다..."
        sudo dnf install -y flatpak
        echo "✅ Flatpak 설치 완료"
    fi

    # Flathub 저장소 추가 (아직 추가되지 않은 경우)
    if ! flatpak remote-list | grep -q flathub; then
        echo "📦 Flathub 저장소를 추가합니다..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        echo "✅ Flathub 저장소 추가 완료"
    fi

    # FreeCAD 설치
    echo "📦 FreeCAD를 설치합니다..."
    flatpak install -y flathub org.freecad.FreeCAD
    FREECAD_FLATPAK="true"
    echo "✅ FreeCAD 설치가 완료되었습니다!"
fi

echo ""

# FreeCAD 개발을 위한 추가 Python 패키지 설치
echo "📦 script.py에 필요한 Python 패키지를 설치합니다..."
echo "  - numpy (수학 연산)"
echo "  - matplotlib (그래프 및 시각화)"
uv pip install numpy matplotlib
echo "✅ Python 패키지 설치 완료"

echo ""
echo "⚠️  참고: FreeCAD Python 바인딩은 Flatpak 내부에 포함되어 있습니다."
echo "   스크립트를 실행하려면 다음 명령을 사용하세요:"
echo "   flatpak run org.freecad.FreeCAD --console script.py"
echo ""
echo "========================================="
echo "✅ 설정이 완료되었습니다!"
echo "========================================="
echo ""
echo "📌 사용 방법:"
echo "  - 가상환경 활성화: source .venv/bin/activate"
echo "  - FreeCAD GUI 실행: flatpak run org.freecad.FreeCAD"
echo "  - Python 스크립트 실행: flatpak run org.freecad.FreeCAD --console script.py"
echo ""
echo "📝 script.py에 필요한 라이브러리:"
echo "  - FreeCAD (Flatpak에 포함됨)"
echo "  - Part (FreeCAD 모듈)"
echo "  - Draft (FreeCAD 모듈)"
echo "  - math (Python 기본 모듈)"
echo ""

# 가상환경을 활성화된 상태로 새 쉘 실행
echo "🚀 가상환경이 활성화된 새 쉘을 시작합니다..."
echo ""
exec bash --rcfile <(cat <<EOF
source .venv/bin/activate
echo "========================================="
echo "✅ 가상환경이 활성화되었습니다!"
echo "========================================="
echo ""
echo "📌 바로 사용 가능한 명령:"
echo "  - python --version                              # Python 버전 확인"
echo "  - pip list                                      # 설치된 패키지 목록"
echo "  - flatpak run org.freecad.FreeCAD               # FreeCAD GUI 실행"
echo "  - flatpak run org.freecad.FreeCAD --console 공학_기술_기반의_설계/script.py  # 스크립트 실행"
echo ""
echo "📦 설치된 라이브러리:"
echo "  - numpy, matplotlib (가상환경)"
echo "  - FreeCAD, Part, Draft (Flatpak 내부)"
echo ""
PS1="(venv) \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
EOF
)
