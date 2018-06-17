#!/bin/bash

# Get variable from config file

source /etc/odoo-hw-box-config.conf
ODOO_PIDFILE=${odoo_pid_file}
ODOO_CONFIG_FILE=${odoo_configuration_file}
ODOO_DAEMON_FILE=${odoo_daemon_file}
ODOO_DAEMON_NAME=${odoo_daemon_name}
FILE_MANAGER=${file_manager}
NETWORK_MANEGER=${network_manager}


calc_wt_size() {
    WT_HEIGHT=17
    WT_WIDTH=$(tput cols)

    if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
        WT_WIDTH=80
    fi
    if [ "$WT_WIDTH" -gt 178 ]; then
        WT_WIDTH=120
    fi
    WT_MENU_HEIGHT=$(($WT_HEIGHT-7))
}

do_check_service_status(){
    ps -ef | grep -v grep | grep ${ODOO_DAEMON_NAME}
    if [ $? -eq 0 ]; then
        whiptail --msgbox "Odoo HW Proxy Service is running" 10 60
    else
        whiptail --msgbox "Odoo HW Proxy Service is not running" 10 60
    fi
}

do_manage_module_menu(){
    MENU=$(whiptail --title "Manage Modules" --menu "Select menu" 15 60 4 \
        "A" "Add/Remove Modules" \
        "B" "Update Module List" \
        "C" "Add Repositories"  3>&1 1>&2 2>&3)
    RES=$?
    if [ $RES -eq 1 ]; then
        return 0
    else
        case "$MENU" in
            A)
                whiptail --msgbox "Feature is not available" 10 60
                ;;
            B)
                whiptail --msgbox "Feature is not available" 10 60
                ;;
            C)
                whiptail --msgbox "Feature is not available" 10 60
                ;;
        esac
    fi
    return 0

    # args=("web" "" ON)
    # args+=("hw_proxy" "" ON)
    # MYDIR=/home/andhit_r/odoo8/oca_web
    # for x in $(find $MYDIR -mindepth 1 -maxdepth 1 -type d -not -name "setup" -not -name ".git" -printf "%f\n")
    # do
    #     args+=("${x}" "" ON)
    # done

    # MODULS=$(whiptail --title "Select modules to use" --checklist \
    #     "List of avalaible modules" 15 60 4 \
    #     "${args[@]}" 3>&1 1>&2 2>&3)
    # RES=$?
    # if [ $RES -eq 1 ]; then
    #     return 0
    # else
    #     return 0
    # fi
}

do_open_raspbian_config(){
    command -v raspi-config
    if [ $? -ne 0 ]; then
        whiptail --msgbox "raspi-config is not installed" 10 60
        return 0
    else
        sudo raspi-config
    fi
}

do_open_cups_config(){
    whiptail --msgbox "Feature is not available" 10 60
    return 0
}

do_update_program(){
    whiptail --yesno "Update this program?" 10 60
    RES=$?
    if [ $RES -eq 1 ]; then
        return 0
    else
        cd /tmp
        if [ -f odoo-hw-box-config.sh ]; then
            sudo rm odoo-hw-box-config.sh
            if [ $? -ne 0 ]; then
                whiptail --msgbox "Failed to remove previous version" 10 60
                return 0
            fi
        fi
        wget https://raw.githubusercontent.com/open-synergy/odoo-hw-box-config/master/odoo-hw-box-config.sh
        if [ $? -ne 0 ]; then
            whiptail --msgbox "Failed to download latest version" 10 60
            return 0
        fi
        sudo cp odoo-hw-box-config.sh /usr/bin
        if [ $? -eq 0 ]; then
            exec "odoo-hw-box-config.sh"
            return 0
        else
            whiptail --msgbox "Failed to update program" 10 60
            return 0
        fi
    fi
}

do_open_network_manager(){
    command -v ${NETWORK_MANAGER}
    NETWORK_MANAGER_EXIST=$?
    if [ ${NETWORK_MANAGER_EXIST} -ne 0 ]; then
        whiptail --yesno "Network manager is not installed. Install network manager?" 10 60
        RES=$?
        if [ $RES -eq 0 ]; then
            sudo apt-get install ${NETWORK_MANAGER}
            do_open_network_manager
        else
            return 0
        fi
    else
        ${NETWORK_MANAGER}
    fi
}

do_open_file_manager(){
    command -v ${FILE_MANAGER}
    FILE_MANAGER_EXIST=$?
    if [ ${FILE_MANAGER_EXIST} -ne 0 ]; then
        whiptail --yesno "file manager is not installed. Install file manager?" 10 60
        RES=$?
        if [ $RES -eq 0 ]; then
            sudo apt-get install ${FILE_MANAGER}
            do_open_file_manager
        else
            return 0
        fi
    else
        ${FILE_MANAGER}
    fi
}
        
do_exit_terminal(){
    whiptail --yesno "Quit to terminal?" 10 60
    RES=$?
    if [ $RES -eq 1 ]; then
        return 0
    else
        clear
        exit 0
    fi
}

do_restart_server(){
    whiptail --yesno "Are you sure want to restart server?" 10 60
    RES=$?
    if [ $RES -eq 1 ]; then
        return 0
    else
        sudo reboot
    fi
}

do_shutdown_server(){
    whiptail --yesno "Are you sure want to shutdown server?" 10 60
    RES=$?
    if [ $RES -eq 1 ]; then
        return 0
    else
        sudo halt
    fi
}

do_manage_hw_proxy_box(){
    MENU=$(whiptail --title "HW Proxy Box Configuration" --menu "Select menu" 15 60 4 \
        "A" "Edit Configuration File" \
        "B" "Edit Daemon File" \
        "C" "Edit Configuration File"  3>&1 1>&2 2>&3)
    RES=$?
    if [ $RES -eq 1 ]; then
        return 0
    else
        #TODO: Harusnya kembali ke menu sebelumnya, bukan ke menu utama
        case "$MENU" in
            A)
                sudo vim ${ODOO_CONFIG_FILE}
                return 0
                ;;
            B)
                sudo vim ${ODOO_DAEMON_FILE}
                return 0
                ;;
            C)
                sudo vim /etc/odoo-hw-box-config.conf #TODO
                return 0
                ;;
        esac
    fi
}

do_start_stop_service_menu(){
    MENU=$(whiptail --title "Start/Stop Service" --menu "Select menu" 15 60 4 \
        "A" "Start Service" \
        "B" "Stop Service" \
        "C" "Restart Service"  3>&1 1>&2 2>&3)
    RES=$?
    if [ $RES -eq 1 ]; then
        return 0
    else
        #TODO: Harusnya kembali ke menu sebelumnya, bukan ke menu utama
        case "$MENU" in
            A)
                sudo ${ODOO_DAEMON_FILE} start
                RES=$?
                if [ $RES -ne 0 ]; then
                    whiptail --msgbox "Failed to start Odoo HW Proxy Service" 10 60
                fi
                ;;
            B)
                sudo ${ODOO_DAEMON_FILE} stop
                RES=$?
                if [ $RES -ne 0 ]; then
                    whiptail --msgbox "Failed to stop Odoo HW Proxy Service" 10 60
                fi
                ;;
            C)
                sudo ${ODOO_DAEMON_FILE} restart
                RES=$?
                if [ $RES -ne 0 ]; then
                    whiptail --msgbox "Failed to restart Odoo HW Proxy Service" 10 60
                fi
                ;;
        esac
        return 0
    fi
}

calc_wt_size

while true; do
    WEKS=$(whiptail --backtitle "Odoo HW Proxy Box Configuration" --title "Main Menu" --menu "Select menu" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
        --cancel-button Finish --ok-button Select \
        "A" "Check Server Status" \
        "B" "Stop Start Service" \
        "C" "HW Proxy Box Configuration" \
        "D" "Network Configuration" \
        "E" "Raspbian Configuration" \
        "G" "File Manager" \
        "F" "CUPS Configuration" \
        "W" "Update This Program" \
        "X" "Exit to Terminal" \
        "Y" "Restart Server" \
        "Z" "Shutdown Server"  3>&1 1>&2 2>&3)
    
    result=$?
    if [ $result = 0 ]; then
        case "$WEKS" in
            A)
                do_check_service_status
                ;;
            B) 
                do_start_stop_service_menu
                ;;
            C)
                do_manage_hw_proxy_box
                ;;
            D)
                do_open_network_manager
                ;;
            E)
                do_open_raspbian_config
                ;;
            F)
                do_open_cups_config
                ;;
            G)
                do_open_file_manager
                ;;
            W)
                do_update_program
                ;;
            X)
                do_exit_terminal
                ;;
            Y)
                do_restart_server
                ;;
            Z)
                do_shutdown_menu
                ;;
        esac
    else
        exit 1
    fi
done
