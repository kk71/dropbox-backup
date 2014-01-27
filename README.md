dropbox backup
==============

backup files or folders into dropbox.

### Environmet Requirement

* bash
* git
* [dropbox_uploader](https://github.com/andreafabrizi/Dropbox-Uploader)(auto-download supported)

### Installation

```bash
    #run in root user
    cd
    git clone https://github.com/kk71/dropbox_backup.git
    cd dropbox_backup
    chmod +x backup.sh
    ./backup.sh
    vim ~/.dropbox_backup #add folders or files to backup.
```


### Usage

'''bash
    ./dropbox_backup.sh #install and initial, or show help
    ./dropbox_backup.sh --help #show help

    #run in root user
    ./dropbox_backup.sh --daemon [backup interval] #run as a daemon,and backup accord to interval
    ./dropbox_backup.sh --now #backup right now

    #for systemd
    ./dropbox_backup.sh --install-service [backup interval] #install as a service and start
    ./dropbox_backup.sh --delete-service #delete service
'''

intervals are hours(h).

### Notice

system-wide proxy is supported. since dropbox is often unreacheable in some countries, it's recommanded to use a proxy or a wall-breaker to access dropbox.
[GoAgent - a gae proxy forked from gappproxy/wallproxy](https://code.google.com/p/goagent/)
