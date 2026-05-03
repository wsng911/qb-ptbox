#!/bin/bash
# System Tuning Script for qb-ptbox
# Run this on the HOST machine (not inside Docker) to optimize network and disk performance
# Usage: sudo bash Install.sh [-x] [-3]
#   -x : Install BBRx (tweaked BBR)
#   -3 : Install BBRv3
#   -h : Help

## Load Seedbox Components
source <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/seedbox_installation.sh)
if [ $? -ne 0 ]; then
    echo "Component ~Seedbox Components~ failed to load"
    echo "Check connection with GitHub"
    exit 1
fi

## Load loading animation
source <(wget -qO- https://raw.githubusercontent.com/Silejonu/bash_loading_animations/main/bash_loading_animations.sh)
if [ $? -ne 0 ]; then
    fail "Component ~Bash loading animation~ failed to load"
    fail_exit "Check connection with GitHub"
fi
trap BLA::stop_loading_animation SIGINT

## Install function
install_() {
    info_2 "$2"
    BLA::start_loading_animation "${BLA_classic[@]}"
    $1 1> /dev/null 2> $3
    if [ $? -ne 0 ]; then
        fail_3 "FAIL"
    else
        info_3 "Successful"
        export $4=1
    fi
    BLA::stop_loading_animation
}

## Check Root Privilege
if [ $(id -u) -ne 0 ]; then
    fail_exit "This script needs root permission to run"
fi

## Check OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

if [[ ! "$OS" =~ "Debian" ]] && [[ ! "$OS" =~ "Ubuntu" ]]; then
    fail "$OS $VER is not supported"
    info "Only Debian 10+ and Ubuntu 20.04+ are supported"
    exit 1
fi

## Read input arguments
while getopts "x3h" opt; do
    case ${opt} in
        x )
            unset bbrv3_install
            bbrx_install=1
            ;;
        3 )
            unset bbrx_install
            bbrv3_install=1
            ;;
        h )
            info "Usage: sudo bash Install.sh [-x] [-3]"
            info "  -x : Install BBRx (tweaked BBR congestion control)"
            info "  -3 : Install BBRv3"
            info "  -h : Show this help"
            exit 0
            ;;
        \? )
            info "Usage: sudo bash Install.sh [-x] [-3] [-h]"
            exit 1
            ;;
    esac
done

## System Update
info "Start System Update & Dependencies Install"
update

## System Tuning
tput sgr0; clear
info "Start Doing System Tuning"

install_ tuned_ "Installing tuned" "/tmp/tuned_error" tuned_success
install_ set_txqueuelen_ "Setting txqueuelen" "/tmp/txqueuelen_error" txqueuelen_success
install_ set_file_open_limit_ "Setting File Open Limit" "/tmp/file_open_limit_error" file_open_limit_success

systemd-detect-virt > /dev/null
if [ $? -eq 0 ]; then
    warn "Virtualization detected, skipping some tuning"
    install_ disable_tso_ "Disabling TSO" "/tmp/tso_error" tso_success
else
    install_ set_disk_scheduler_ "Setting Disk Scheduler" "/tmp/disk_scheduler_error" disk_scheduler_success
    install_ set_ring_buffer_ "Setting Ring Buffer" "/tmp/ring_buffer_error" ring_buffer_success
fi

install_ set_initial_congestion_window_ "Setting Initial Congestion Window" "/tmp/initial_congestion_window_error" initial_congestion_window_success
install_ kernel_settings_ "Setting Kernel Settings" "/tmp/kernel_settings_error" kernel_settings_success

# BBRx
if [[ ! -z "$bbrx_install" ]]; then
    if [[ ! -z "$(lsmod | grep bbrx)" ]]; then
        warn "Tweaked BBR is already installed"
    else
        install_ install_bbrx_ "Installing BBRx" "/tmp/bbrx_error" bbrx_install_success
    fi
fi

# BBRv3
if [[ ! -z "$bbrv3_install" ]]; then
    install_ install_bbrv3_ "Installing BBRv3" "/tmp/bbrv3_error" bbrv3_install_success
fi

## Configure Boot Script (re-apply tuning on reboot)
info "Configuring Boot Script"
touch /root/.boot-script.sh && chmod +x /root/.boot-script.sh
cat > /root/.boot-script.sh << 'EOF'
#!/bin/bash
sleep 120s
source <(wget -qO- https://raw.githubusercontent.com/jerry048/Seedbox-Components/main/seedbox_installation.sh)
if [ $? -ne 0 ]; then
    exit 1
fi
set_txqueuelen_
systemd-detect-virt > /dev/null
if [ $? -eq 0 ]; then
    disable_tso_
else
    set_disk_scheduler_
    set_ring_buffer_
fi
set_initial_congestion_window_
EOF

cat > /etc/systemd/system/boot-script.service << 'EOF'
[Unit]
Description=boot-script
After=network.target

[Service]
Type=simple
ExecStart=/root/.boot-script.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
systemctl enable boot-script.service

## Done
info "System Tuning Complete"
if [[ ! -z "$bbrx_install_success" ]]; then
    info "BBRx installed, please reboot for it to take effect"
fi
if [[ ! -z "$bbrv3_install_success" ]]; then
    info "BBRv3 installed, please reboot for it to take effect"
fi

exit 0
