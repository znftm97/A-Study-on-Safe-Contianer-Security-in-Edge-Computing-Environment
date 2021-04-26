#!/bin/bash
help() {
    echo -e "Usage:  script.sh [OPTIONS] COMMAND\n"
    echo "Options:"
    echo "  -b image             입력한 이름으로 빌드"
    echo "  -e container image   컨테이너 실행"
    echo "  -r [con|img] name    컨테이너 혹은 이미지 삭제"
    echo "  -a name              컨테이너 접속(attach)"
    echo "  -q anchore           Anchore 중지 및 삭제(선택)"
    echo "  -h                   도움말"
}
err() {
    local OPTIND
    echo "- 오류 발생: [$2]"
    while getopts ":a:b:c:" opt; do
        case $opt in
        a) break ;;
        b) docker images ;;
        c) docker ps -a --format "table {{.Names}}\t{{.Image}}" ;;
        esac
    done
    echo "- '-h' 옵션으로 사용법을 확인하세요"
    exit 1
}
arg_chk1() {
    if [ ! ${2} == 2 ] || [ ! ${1} == ${3} ]; then
        help
        exit 1
    fi
}
arg_chk2() {
    if [ ! ${4} == 3 ] || [[ ${3:0:1} == - ]]; then
        help
        exit 1
    fi
}
image_build() {
    echo "---------------------"
    echo "- 빌드를 시작합니다 -"
    echo "---------------------"
    docker build --pull --rm -f "./docker/dockerfile" -t $1 "./docker"
    if [ $? -eq 0 ]; then
        echo "-------------"
        echo "- 빌드 완료 -"
        echo "-------------"
        echo "- 이미지명: $1"
    else
        err -a "Dockerfile 찾을 수 없음"
    fi
}
container_run() {
    if [[ "$(docker images -q $2 2>/dev/null)" == "" ]]; then
        err -b "이미지가 존재하지 않음"
    fi
    docker inspect --format="{{.State.Running}}" $1 2>/dev/null
    if [ $? -eq 1 ]; then
        echo "------------------------"
        echo "- 컨테이너를 실행합니다 -"
        echo "------------------------"
        container_gateway=$(docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}')
        mkdir -p ./result
        docker run -e "gw=$container_gateway" -v /var/run/docker.sock:/var/run/docker.sock -it --name $1 $2
        docker cp $1:/root/result ./

        apt install npm -y
        npm install -g jsonexport
        for i in $(ls ./result -ltr | tail -2 | awk '{print $9}'); do
            jsonexport ./result/$i >./result/${i//.json/}.csv
        done
        docker rm -f $1 >/dev/null 2>&1

    else
        err -c "컨테이너명 중복"
    fi
}
delete_img() {
    if [[ $2 != *:* ]]; then
        err -b "이미지명 형식 오류, [*:*]"
    fi
    if [[ "$(docker images -q $2 2>/dev/null)" == "" ]]; then
        err -b "이미지가 존재하지 않음"
    else
        echo "-----------------------"
        echo "- 이미지를 삭제합니다 -"
        echo "-----------------------"
        docker rmi -f $2
        echo -e "\n이미지 삭제 완료: [$2]"
        ask_yn -d "Dangling 이미지를 삭제하시겠습니까? [y/N]: "
    fi
}
connect_con() {
    container_status=$(docker inspect --format='{{.State.Running}}' $1 2>/dev/null)
    if [[ $container_status = "true" ]]; then
        echo "------------------------"
        echo "- 컨테이너에 접속합니다 -"
        echo "------------------------"
        docker attach $1
    elif [[ $container_status = "false" ]]; then
        echo "------------------------"
        echo "- 컨테이너에 접속합니다 -"
        echo "------------------------"
        docker start $1 >/dev/null
        docker attach $1
    else
        err -c "컨테이너가 존재하지 않음"
    fi
}
delete_con() {
    docker inspect $2 >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        err -c "컨테이너가 존재하지 않음"
    else
        echo "------------------------"
        echo "- 컨테이너를 삭제합니다 -"
        echo "------------------------"
        docker rm -f $2 >/dev/null 2>&1
        echo "컨테이너 삭제 완료: [$2]"
    fi
}
quit_anchore() {
    echo "---------------------------"
    echo "- Stop Anchore Containers -"
    echo "---------------------------"
    docker stop anchore_db_1
    docker stop anchore_analyzer_1
    docker stop anchore_api_1
    docker stop anchore_policy-engine_1
    docker stop anchore_queue_1
    docker stop anchore_catalog_1
    echo -e "\nAnchore 컨테이너 중지 완료"
    ask_yn -q "Anchore 컨테이너를 삭제하시겠습니까? [y/N]: "
}
ask_yn() {
    local OPTIND
    while true; do
        read -p "$2" yn
        case $yn in
        y | Y) break ;;
        n | N | "") exit ;;
        *) echo "'Y'또는 'N'만 입력해주세요" ;;
        esac
    done
    while getopts ":d:q:" opt; do
        case $opt in
        d)
            docker image prune -f
            exit
            ;;
        q)
            docker rm anchore_db_1
            docker rm anchore_analyzer_1
            docker rm anchore_api_1
            docker rm anchore_policy-engine_1
            docker rm anchore_queue_1
            docker rm anchore_catalog_1
            exit
            ;;
        esac
    done
}
if [[ $EUID -ne 0 ]]; then
    echo "---본 스크립트는 root 권한으로 실행해야 합니다---"
    exit 1
fi
if [[ -z "$1" ]]; then
    help
    exit 1
fi
while getopts ":a:b:e:r:n:q:h:" opt; do
    case $opt in
    a)
        arg_chk1 ${1} $# "-a"
        arg_a=$OPTARG
        connect_con $arg_a
        ;;
    b)
        arg_chk1 ${1} $# "-b"
        arg_b=$OPTARG
        if [[ $arg_b == *:* ]]; then
            image_build $arg_b
        else
            echo "실행 오류: 이미지 이름은 [*:*] 형식으로 입력해주세요"
        fi
        ;;
    e)
        arg_chk2 ${1} ${2} ${3} $#
        arg_e=$OPTARG
        container_run $arg_e ${3}
        ;;
    r)
        arg_chk2 ${1} ${2} ${3} $#
        arg_r=$OPTARG
        if [[ $arg_r == img ]]; then
            delete_img $arg_r ${3}
        elif [[ $arg_r == con ]]; then
            delete_con $arg_r ${3}
        else
            err -a "'-r con|img'"
        fi
        ;;
    q)
        arg_q=$OPTARG
        if [[ $arg_q == anchore ]]; then
            quit_anchore
        else
            echo "현재 anchore 외 지원하지 않습니다"
        fi
        ;;
    h) help ;;
    ?)
        help
        exit 1
        ;;
    esac
done
