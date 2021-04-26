# Changelog

## 2020년 10월 11일
- Added - CSV 변환 기능 추가
- Added - 진단 후 사용한 컨테이너 삭제하는 로직 추가 

## 2020년 10월 9일
- 끝

## 2020년 10월 8일
- 2차 완성
- Added - 옵션 -e 사용 시 테스팅부터 결과 출력까지 수행

## 2020년 10월 4일
- 1차 완성
- Added - buildrun.sh 제작 완료 (build, run, attach, container|image remove, stop anchore)
- Added - Entrypoint에서 백그라운드 동작하도록 제작, 컨테이너 꺼지지 않도록 함

## 2020년 10월 3일
- Added - Trivy 성공
- Fix - Docker in Docker(DIND) 해결, Docker 서비스 실행 성공

## 2020년 10월 1일
- trivy 이식은 간단
- 컨테이너 안에서 Docker 서비스 실행 실패 (alpine:3.12.0/Ubuntu:18.04)
- Added - Alpine, Ubuntu 각 버전 별로 Dockerfile 생성