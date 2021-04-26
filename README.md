# 2020 캡스톤 개발
엣지컴퓨팅 환경에서 Secure Container 연구

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