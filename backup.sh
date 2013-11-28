#!/bin/bash
#coding=utf-8
#backup files or folders into your dropbox
#author:kk(http://imkk.me)

#configurations which needn't be changed only if you know what you're doing
#must end up with "/"
tmpdir="/tmp/dropbox-backup/"
dropbox_dir="/raspibackup/"
dropbox_uploader_git_repo="https://github.com/andreafabrizi/Dropbox-Uploader.git"

#test if git exists
gitver=`git --version 2> /dev/null` 
if [[ ${gitver:0:11} != "git version" ]];then
    echo "git error. please install the latest git."
    exit
fi

#test if dropbox_uploader exists
if ! [ -d "Dropbox-Uploader" ];then
    git clone $dropbox_uploader_git_repo
    if [ $? -ne 0 ];then
        echo "network error or git configuration error? please manually clone dropbox_uploader into local path."
        echo "dropbox_uploader git repo : $dropbox_uploader_git_repo"
        exit
    fi
    echo "dropbox_uploader is installed and now please configure it..."
    echo "==========================="
    chmod +x Dropbox-Uploader/dropbox_uploader.sh
    bash Dropbox-Uploader/dropbox_uploader.sh
    echo "==========================="
    echo "finished. now please fulfill ~/.dropbox_backup for files to backup.\n"
    exit
fi

#backup
pwd=`pwd` #save current path
files_to_backup=`cat ~/.dropbox_backup 2>/dev/null`;
if [[ $files_to_backup == "" ]];then
    echo "no backup files defined in ~/.dropbox_backup."
    exit
fi
rm -rf $tmpdir
mkdir $tmpdir
for f in $files_to_backup;do
    cd `dirname $f`
    tar -cjf ${tmpdir}${f//"/"/"-"}.tar.gz `basename $f`
    if [ $? -ne 0 ];then
        echo "error at creating tarball for $f"
    fi
done
echo "Uploading to dropbox..."
datenow=`date -d today +"%Y-%m-%d-%H:%M:%S"`
bash ${pwd}/Dropbox-Uploader/dropbox_uploader.sh upload $tmpdir ${dropbox_dir}$datenow -q
echo "finished."
