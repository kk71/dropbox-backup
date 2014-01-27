#!/bin/bash
#coding=utf-8
#backup files or folders into your dropbox
#author:kk(http://imkk.me)
#dependences & help please refer to README.md

#configurations which needn't be changed only if you know what you're doing
#must end up with "/"
tmpdir="/tmp/dropbox-backup/"
dropbox_dir="/autobackup/"
dropbox_uploader_git_repo="https://github.com/andreafabrizi/Dropbox-Uploader.git"
cd `dirname $0` 

#show info in green font
function put {
    echo -e "\033[032m$@\033[m";
}

#test if git exists
gitver=`git --version 2> /dev/null` 
if [[ ${gitver:0:11} != "git version" ]];then
    put "git error. please install latest git."
    exit
fi

#test if dropbox_uploader exists
#otherwise clone it from it's repo
if ! [ -d "Dropbox-Uploader" ];then
    git clone $dropbox_uploader_git_repo
    if [ $? -ne 0 ];then
        put "network error or git configuration error? please manually clone dropbox_uploader into local path."
        put "dropbox_uploader git repo : $dropbox_uploader_git_repo"
        exit
    fi
    put "dropbox_uploader is installed and now please configure it..."
    put "==========================="
    chmod +x Dropbox-Uploader/dropbox_uploader.sh
    bash Dropbox-Uploader/dropbox_uploader.sh
    put "==========================="
    put "finished. now please fulfill ~/.dropbox_backup for files to backup.\\n"
    exit
fi

#run as a daemon
if [[ $1 == "--daemon" ]];then
    put "dropbox backup is running as a daemon..."
    while :;do
        ./dropbox_backup.sh --now
        sleep $2h
    done
    exit
fi

#create/delete and enable/disable a systemd service
pwd=`pwd`
pwd_slash_escaped=$(echo $pwd|sed 's/\//\\\//g') #escape pwd slashes
if [[ $1 == "--install-service" ]];then
    if [[ -z $2 ]];then
        put "interval invalid."
        exit
    fi
    sed "s/dropbox_backup_pwd/$pwd_slash_escaped/g;s/backup_interval/$2/g" dropbox_backup.service > /etc/systemd/system/dropbox_backup.service;
    systemctl enable dropbox_backup.service
    if [[ $? != "0" ]];then
        put "failed. please make sure you're doing this with root previlege or in sudo."
    fi
    exit
else if [[ $@ == "--delete-service" ]];then
    systemctl disable dropbox_backup.service
    rm /etc/systemd/system/dropbox_backup.service
    if [[ $? != "0" ]];then
        put "failed. please make sure you're doing this with root previlege or in sudo."
    fi
    exit
fi fi

#backup now
if [[ $@ == "--now" ]];then
    put "backup now..."
    pwd=`pwd` #save current path
    files_to_backup=`cat ~/.dropbox_backup 2>/dev/null`;
    if [[ $files_to_backup == "" ]];then
        put "no backup files defined in ~/.dropbox_backup."
        exit
    fi
    rm -rf $tmpdir
    mkdir $tmpdir
    for f in $files_to_backup;do
        cd `dirname $f`
        tar -cjf ${tmpdir}${f//"/"/"-"}.tar.gz `basename $f`
        if [ $? -ne 0 ];then
            put "error at creating tarball for $f"
        fi
    done
    put "uploading to dropbox..."
    datenow=`date -d today +"%Y-%m-%d-%H:%M:%S"`
    #-k switches ssl certificate check off(for system-wide proxy)
    ${pwd}/Dropbox-Uploader/dropbox_uploader.sh -k upload $tmpdir ${dropbox_dir}$datenow
    put "finished."
    exit
fi

#if no arguments or with --help then show help info
cat README.md
if [ $? != "0" ];then
    put "README.md not found."
fi
