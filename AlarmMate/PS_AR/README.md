# AlarmMate

This repository is intended to be published to GitHub under the name `AlarmMate`.

- Project folder: `PS_AR/` (contains the Xcode project and source files).
- Swift / Xcode: Open `PS_AR.xcodeproj` (or workspace) in Xcode.

Contents:
- `PS_AR/` — main app source, assets, and CoreML models.

Notes for publishing:
 - A `.gitignore` is present to exclude user-specific and build artifacts.
 - This repository is licensed under the GNU Affero General Public License v3 (AGPLv3).
	 If you intended a different license variant of "YOLO11n", please confirm.

Note: The repository top-level folder is `PS_AR/`. When you publish to GitHub,
you can name the repository `AlarmMate` — the folder name on disk does not need
to change.

If you prefer to store the project under `AlarmMate/PS_AR` on disk, a helper
script is available at `AlarmMate/relocate_to_alarmmate.sh`. Run it from the
repo root to move files into `AlarmMate/PS_AR` using `git mv` when possible.
# AlarmMate

AlarmMate는 시간표 사진에서 자동으로 수업 시작 시간을 분석해 요일별 알람을 생성해주는 iOS 앱 프로젝트입니다.

요약
- 로컬 프로젝트 폴더: `PS_AR/` (Xcode 프로젝트 포함)
- 권장 GitHub 저장소 이름: `AlarmMate` (원격 저장소 이름은 자유롭게 설정 가능)
- 라이선스: GNU Affero General Public License v3 (AGPLv3)

빠른 시작
1. Xcode에서 프로젝트 열기
	 - 열기: `PS_AR/PS_AR.xcodeproj` 또는 `PS_AR/PS_AR.xcworkspace` (Swift Package 또는 워크스페이스 사용 시)
2. 필요 시 시뮬레이터 또는 실제 기기에서 빌드/실행
3. 시간표 이미지를 선택하고 "AI Auto Scheduling"을 눌러 분석을 진행

프로젝트 구조
- `PS_AR/` — 앱 소스 코드와 에셋, CoreML 모델(.mlpackage) 포함
	- `PS_AR/PS_AR/` — SwiftUI 소스 파일
	- `PS_AR/PS_AR.xcodeproj` — Xcode 프로젝트 파일
- `.gitignore` — Xcode/macOS 불필요 파일 제외
- `LICENSE` — AGPLv3 전문

CoreML 모델
- `best1.mlpackage`, `best1_2.mlpackage`, `best1_3.mlpackage`, `best3.mlpackage` 등이 포함되어 있습니다.
	- 모델은 프로젝트에서 감지(Detection) 엔진으로 사용됩니다.

원격에 푸시하기 (예시)
1. 로컬에서 Git 초기화(이미 되어 있지 않다면)

```bash
git init
git add .
git commit -m "Initial commit — AlarmMate (PS_AR project)"
git remote add origin https://github.com/<your-username>/AlarmMate.git
git branch -M main
git push -u origin main
```

주의사항
- 개인 사용자 설정(예: `xcuserdata/`, `*.xcuserstate`) 및 빌드 아티팩트는 `.gitignore`에 포함되어 있어야 합니다.
- 프로젝트 내 일부 파일(에셋 카탈로그, 큰 모델 파일)은 저장공간 및 이식성 문제로 레포에 포함하지 않고 별도 아카이브로 관리하는 것을 권장합니다.

문제 발생 시
- Git 인덱싱 오류가 발생하면(파일 손상/읽기 오류 등) 문제 파일을 백업하고 임시로 레포에서 제외한 뒤 나머지 파일을 먼저 커밋·푸시하세요.

도움이 필요하면 제가 원격 설정, CI 설정, 또는 README 보강을 도와드리겠습니다.
