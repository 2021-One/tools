#!/usr/bin/env bash

## 用户输入模组 User Input moudle

userinput_standard(){
set +e
clear
if [[ ${install_status} == 1 ]]; then
  if (whiptail --title "Installed" --yes-button "读取" --no-button "修改" --yesno "检测到现有配置，读取/修改现有配置?(Installed,read configuration?)" 8 68); then
    readconfig
  fi
fi

if [[ -z ${check_trojan} ]]; then
  check_trojan="on"
fi
if [[ -z ${check_dns} ]]; then
  check_dns="off"
fi
if [[ -z ${check_speed} ]]; then
  check_speed="off"
fi
if [[ -z ${check_fail2ban} ]]; then
  check_fail2ban="off"
fi
if [[ -z ${check_tjp} ]]; then
  check_tjp="off"
fi
if [[ -z ${check_ss} ]]; then
  check_ss="off"
fi
if [[ -z ${fastopen} ]]; then
  fastopen="on"
fi

whiptail --clear --ok-button "下一步" --backtitle "Hi,请按空格以及方向键来选择需要安装/更新的软件,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "Install checklist" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装/更新的软件。" 18 65 10 \
"Back" "返回上级菜单(Back to main menu)" off \
"trojan" "Trojan-GFW+TCP-BBR+Hexo Blog" on \
"net" "Netdata(监测伺服器运行状态)" on \
"fast" "TCP Fastopen" ${fastopen} \
"tjp" "Trojan-panel" ${check_tjp} \
"ss" "shadowsocks-rust" ${check_ss} \
"speed" "Speedtest(测试本地网络到VPS的延迟及带宽)" ${check_speed} \
"fail2ban" "Fail2ban(防SSH爆破用)" ${check_fail2ban} \
"port" "自定义Trojan端口(除nat机器外请勿选中)" off \
"test-only" "test-only" off 2>results

while read choice
do
  case $choice in
    Back) 
    MasterMenu
    break
    ;;
    trojan)
    install_trojan=1
    install_bbr=1
    ;;
    ss)
    install_ss_rust=1
    ;;
    stun)
    install_stun="1"
    ;;
    dns)
    install_dnscrypt=1
    ;;
    fast)
    tcp_fastopen="true"
    ;;
    tjp)
    install_trojan_panel=1
    install_php=1
    install_mariadb=1
    install_redis=1
    ;;
    net)
    install_netdata=1
    ;;
    speed)
    check_speed="on"
    install_speedtest=1
    install_php=1
    ;;
    fail2ban)
    check_fail2ban="on"
    install_fail2ban=1
    ;;
    11) 
    install_trojan_panel=1
    install_php=1
    install_nodejs=1
    install_mariadb=1
    ;;
    port)
    trojan_other_port=1
    ;;
    *)
    ;;
  esac
done < results

rm results

if [[ ${trojan_other_port} == 1 ]]; then
  trojanport=$(whiptail --inputbox --nocancel "Trojan-GFW 端口(若不確定，請直接回車)" 8 68 443 --title "port input" 3>&1 1>&2 2>&3)
  if [[ -z ${trojanport} ]]; then
  trojanport="443"
  fi
fi

while [[ -z ${domain} ]]; do
domain=$(whiptail --inputbox --nocancel "请輸入你的域名,例如 example.com(请先完成A/AAAA解析) | Please enter your domain" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
TERM=ansi whiptail --title "检测中" --infobox "检测域名是否合法中..." 7 68
colorEcho ${INFO} "Checking if domain is vaild."
host ${domain}
if [[ $? != 0 ]]; then
  whiptail --title "Warning" --msgbox "Warning: Invaild Domain" 8 68
  domain=""
  clear
fi
done
clear
hostnamectl set-hostname ${domain}
echo "${domain}" > /etc/hostname
rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
echo "" >> /etc/hosts
echo "$(jq -r '.ip' "/root/.trojan/ip.json") ${domain}" >> /etc/hosts
if [[ ${install_trojan} = 1 ]]; then
  while [[ -z ${password1} ]]; do
password1=$(whiptail --passwordbox --nocancel "Trojan-GFW Password One(推荐自定义密码,***请勿添加特殊符号***)" 8 68 --title "password1 input" 3>&1 1>&2 2>&3)
if [[ -z ${password1} ]]; then
password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
fi
done
while [[ -z ${password2} ]]; do
password2=$(whiptail --passwordbox --nocancel "Trojan-GFW Password Two(若不確定，請直接回車，会随机生成)" 8 68 --title "password2 input" 3>&1 1>&2 2>&3)
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
done
fi
if [[ ${password1} == ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password1} ]]; then
  password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
  if [[ ${install_mail} == 1 ]]; then
  mailuser=$(whiptail --inputbox --nocancel "Please enter your desired mailusername(邮箱用户名)" 8 68 admin --title "Mail user input" 3>&1 1>&2 2>&3)
  if [[ -z ${mailuser} ]]; then
  mailuser=$(head /dev/urandom | tr -dc a-z | head -c 4 ; echo '' )
  fi
fi
  if [[ $install_qbt = 1 ]]; then
    while [[ -z $qbtpath ]]; do
    qbtpath=$(whiptail --inputbox --nocancel "Qbittorrent Nginx Path(路径)" 8 68 /qbt/ --title "Qbittorrent path input" 3>&1 1>&2 2>&3)
    done
  fi
  if [[ ${install_aria} == 1 ]]; then
    ariaport=$(shuf -i 13000-19000 -n 1)
    while [[ -z ${ariapath} ]]; do
    ariapath=$(whiptail --inputbox --nocancel "Aria2 RPC Nginx Path(路径)" 8 68 /aria2/ --title "Aria2 path input" 3>&1 1>&2 2>&3)
    done
    while [[ -z $ariapasswd ]]; do
    ariapasswd=$(whiptail --passwordbox --nocancel "Aria2 rpc token(密码)" 8 68 --title "Aria2 rpc token input" 3>&1 1>&2 2>&3)
    if [[ -z ${ariapasswd} ]]; then
    ariapasswd=$(head /dev/urandom | tr -dc 0-9 | head -c 10 ; echo '' )
    fi
    done
  fi
  if [[ ${install_file} = 1 ]]; then
    while [[ -z ${filepath} ]]; do
    filepath=$(whiptail --inputbox --nocancel "Filebrowser Nginx 路径" 8 68 /file/ --title "Filebrowser path input" 3>&1 1>&2 2>&3)
    done
  fi
}

userinput_full(){
set +e
clear
if [[ ${install_status} == 1 ]]; then
  if (whiptail --title "Installed" --yes-button "读取" --no-button "修改" --yesno "检测到现有配置，读取/修改现有配置?(Installed,read configuration?)" 8 68); then
    readconfig
  fi
fi

if [[ -z ${check_trojan} ]]; then
  check_trojan="on"
fi
if [[ -z ${check_dns} ]]; then
  check_dns="off"
fi
if [[ -z ${check_rss} ]]; then
  check_rss="off"
fi
if [[ -z ${check_chat} ]]; then
  check_chat="off"
fi
if [[ -z ${check_qbt} ]]; then
  check_qbt="off"
fi
if [[ -z ${check_aria} ]]; then
  check_aria="off"
fi
if [[ -z ${check_file} ]]; then
  check_file="off"
fi
if [[ -z ${check_speed} ]]; then
  check_speed="off"
fi
if [[ -z ${check_mariadb} ]]; then
  check_mariadb="off"
fi
if [[ -z ${check_fail2ban} ]]; then
  check_fail2ban="off"
fi
if [[ -z ${check_mail} ]]; then
  check_mail="off"
fi
if [[ -z ${check_qbt_origin} ]]; then
  check_qbt_origin="off"
fi
if [[ -z ${check_tracker} ]]; then
  check_tracker="off"
fi
if [[ -z ${check_cloud} ]]; then
  check_cloud="off"
fi
if [[ -z ${check_tor} ]]; then
  check_tor="off"
fi
if [[ -z ${check_i2p} ]]; then
  check_i2p="off"
fi
if [[ -z ${check_tjp} ]]; then
  check_tjp="off"
fi
if [[ -z ${check_ss} ]]; then
  check_ss="off"
fi
if [[ -z ${fastopen} ]]; then
  fastopen="on"
fi
if [[ -z ${stun} ]]; then
  stun="off"
fi

whiptail --clear --ok-button "下一步" --backtitle "Hi,请按空格以及方向键来选择需要安装/更新的软件,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "Install checklist" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装/更新的软件。" 24 65 16 \
"Back" "返回上级菜单(Back to main menu)" off \
"trojan" "Trojan-GFW+TCP-BBR+Hexo Blog" on \
"net" "Netdata(监测伺服器运行状态)" on \
"fast" "TCP Fastopen" ${fastopen} \
"tjp" "Trojan-panel" ${check_tjp} \
"ss" "shadowsocks-rust" ${check_ss} \
"nextcloud" "Nextcloud(私人网盘)" ${check_cloud} \
"rss" "RSSHUB + TT-RSS(RSS生成器+RSS阅读器)" ${check_rss} \
"mail" "Mail service(邮箱服务,需2g+内存)" ${check_mail} \
"chat" "Rocket Chat" ${check_chat} \
"qbt" "Qbittorrent增强版(可全自动屏蔽吸血行为)" ${check_qbt} \
"aria" "Aria2下载器" ${check_aria} \
"file" "Filebrowser(用于拉回Qbt/aria下载完成的文件)" ${check_file} \
"speed" "Speedtest(测试本地网络到VPS的延迟及带宽)" ${check_speed} \
"fail2ban" "Fail2ban(防SSH爆破用)" ${check_fail2ban} \
"i2p" "自建i2p网站" ${check_i2p} \
"tor" "自建onion网站" ${check_tor} \
"stun" "stunserver(用于测试nat类型)" ${stun} \
"dns" "Dnscrypt-proxy(Doh客户端)" ${check_dns} \
"7" "MariaDB数据库" ${check_mariadb} \
"redis" "Redis缓存数据库" off \
"其他" "以下选项请勿选中,除非必要(Others)" off  \
"port" "自定义Trojan端口(除nat机器外请勿选中)" ${check_qbt_origin} \
"10" "Bt-Tracker(Bittorrent-tracker服务)" ${check_tracker} \
"13" "Qbt原版(除PT站指明要求,请勿选中)" ${check_qbt_origin} \
"test-only" "test-only" off 2>results

while read choice
do
  case $choice in
    Back) 
    MasterMenu
    break
    ;;
    trojan)
    install_trojan=1
    install_bbr=1
    ;;
    ss)
    install_ss_rust=1
    ;;
    stun)
    install_stun="1"
    ;;
    dns)
    install_dnscrypt=1
    ;;
    fast)
    tcp_fastopen="true"
    ;;
    chat)
    install_chat=1
    install_docker=1
    ;;
    tjp)
    install_trojan_panel=1
    install_php=1
    install_mariadb=1
    install_redis=1
    ;;
    net)
    install_netdata=1
    ;;
    nextcloud)
    install_nextcloud=1
    install_php=1
    install_mariadb=1
    install_redis=1
    ;;
    redis)
    install_redis=1
    ;;
    rss)
    check_rss="on"
    install_rsshub=1
    install_redis=1
    install_php=1
    install_mariadb=1
    ;;
    qbt)
    check_qbt="on"
    install_qbt=1
    ;;
    aria)
    check_aria="on"
    install_aria=1
    ;;
    file)
    check_file="on"
    install_file=1
    ;;
    speed)
    check_speed="on"
    install_speedtest=1
    install_php=1
    ;;
    7)
    check_mariadb="on"
    install_mariadb=1
    ;;
    fail2ban)
    check_fail2ban="on"
    install_fail2ban=1
    ;;
    mail)
    check_mail="on"
    install_mail=1
    install_php=1
    install_mariadb=1
    ;;
    10)
    check_tracker="on"
    install_tracker=1
    ;;
    11) 
    install_trojan_panel=1
    install_php=1
    install_nodejs=1
    install_mariadb=1
    ;;
    tor)
    install_tor=1
    ;;
    i2p)
    install_i2p=1
    ;;
    13)
    check_qbt_origin="on"
    install_qbt_origin=1
    ;;
    port)
    trojan_other_port=1
    ;;
    *)
    ;;
  esac
done < results

rm results

if [[ ${trojan_other_port} == 1 ]]; then
  trojanport=$(whiptail --inputbox --nocancel "Trojan-GFW 端口(若不確定，請直接回車)" 8 68 443 --title "port input" 3>&1 1>&2 2>&3)
  if [[ -z ${trojanport} ]]; then
  trojanport="443"
  fi
fi

system_upgrade=1
if [[ ${system_upgrade} == 1 ]]; then
  if [[ $(lsb_release -cs) == jessie ]]; then
      debian9_install=1
  fi
  if [[ $(lsb_release -cs) == xenial ]]; then
      ubuntu18_install=1
  fi
fi

while [[ -z ${domain} ]]; do
domain=$(whiptail --inputbox --nocancel "请輸入你的域名,例如 example.com(请先完成A/AAAA解析) | Please enter your domain" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
TERM=ansi whiptail --title "检测中" --infobox "检测域名是否合法中..." 7 68
colorEcho ${INFO} "Checking if domain is vaild."
host ${domain}
if [[ $? != 0 ]]; then
  whiptail --title "Warning" --msgbox "Warning: Invaild Domain" 8 68
  domain=""
  clear
fi
done
clear
hostnamectl set-hostname ${domain}
echo "${domain}" > /etc/hostname
rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
echo "" >> /etc/hosts
echo "$(jq -r '.ip' "/root/.trojan/ip.json") ${domain}" >> /etc/hosts
if [[ ${install_trojan} = 1 ]]; then
  while [[ -z ${password1} ]]; do
password1=$(whiptail --passwordbox --nocancel "Trojan-GFW Password One(推荐自定义密码,***请勿添加特殊符号***)" 8 68 --title "password1 input" 3>&1 1>&2 2>&3)
if [[ -z ${password1} ]]; then
password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
fi
done
while [[ -z ${password2} ]]; do
password2=$(whiptail --passwordbox --nocancel "Trojan-GFW Password Two(若不確定，請直接回車，会随机生成)" 8 68 --title "password2 input" 3>&1 1>&2 2>&3)
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
done
fi
if [[ ${password1} == ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password1} ]]; then
  password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
  if [[ ${install_mail} == 1 ]]; then
  mailuser=$(whiptail --inputbox --nocancel "Please enter your desired mailusername(邮箱用户名)" 8 68 admin --title "Mail user input" 3>&1 1>&2 2>&3)
  if [[ -z ${mailuser} ]]; then
  mailuser=$(head /dev/urandom | tr -dc a-z | head -c 4 ; echo '' )
  fi
fi
  if [[ $install_qbt = 1 ]]; then
    while [[ -z $qbtpath ]]; do
    qbtpath=$(whiptail --inputbox --nocancel "Qbittorrent Nginx Path(路径)" 8 68 /qbt/ --title "Qbittorrent path input" 3>&1 1>&2 2>&3)
    done
  fi
  if [[ ${install_aria} == 1 ]]; then
    ariaport=$(shuf -i 13000-19000 -n 1)
    while [[ -z ${ariapath} ]]; do
    ariapath=$(whiptail --inputbox --nocancel "Aria2 RPC Nginx Path(路径)" 8 68 /aria2/ --title "Aria2 path input" 3>&1 1>&2 2>&3)
    done
    while [[ -z $ariapasswd ]]; do
    ariapasswd=$(whiptail --passwordbox --nocancel "Aria2 rpc token(密码)" 8 68 --title "Aria2 rpc token input" 3>&1 1>&2 2>&3)
    if [[ -z ${ariapasswd} ]]; then
    ariapasswd=$(head /dev/urandom | tr -dc 0-9 | head -c 10 ; echo '' )
    fi
    done
  fi
  if [[ ${install_file} = 1 ]]; then
    while [[ -z ${filepath} ]]; do
    filepath=$(whiptail --inputbox --nocancel "Filebrowser Nginx 路径" 8 68 /file/ --title "Filebrowser path input" 3>&1 1>&2 2>&3)
    done
  fi
}