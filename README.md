# 2020 캡스톤
엣지컴퓨팅 환경에서의 취약점 진단을 위한 Safe Container 기반 동적 분석 연구

## How To Use
### Help
```bash
sudo ./capstone.sh -h
```
### Build
```bash
sudo ./capstone.sh -b [name:tag]
```
### Run
```bash
sudo ./capstone.sh -e [container_name] [name:tag]
```
### Attach
```bash
sudo ./capstone.sh -a [container_name]
```
### Remove Container|Image
```bash
sudo ./capstone.sh -r [con|img] [name]
```
### Stop Anchore Services
```bash
sudo ./capstone.sh -q anchore
```
