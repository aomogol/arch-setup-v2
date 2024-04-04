#!/bin/bash
set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author  :   DarkXero
# Extensive modifications by: vlk (https://github.com/REALERvolker1)
# Website   :   http://xerolinux.xyz
##################################################################################################################

# Set the window title to something pleasant
echo -en "\033]2;XeroLinux Nvidia Setup\007"
# Attempt to fix on Konsole
echo -ne "\033]30;XeroLinux Nvidia Setup\007"

# set to 1 to remove dxvk-bin in the driver uninstall function
XEROLINUX_REMOVE_DXVK_BIN=0 # 1

shopt -s checkwinsize
(
    : # curse you, shfmt
    :
)
# define some useful characters that are hard to type
BOLD="[1m"
RESET="[0m"
# TAB=$'\t' # make shellcheck happy
LF=$'\n'

_print_header() {
    local surround htx i surround fsur width_pad color
    local vert_pad=$'\n'
    local -i width
    local -i halfwidth
    local -i i_width
    local -a prints=()

    for i in "$@"; do
        i_val="${i#*=}" # preprocess
        case "$i" in
        '--width='*)
            width="$i_val"
            ;;
        '--surround_char='*)
            ((${#i_val} == 1)) && surround="$i_val"
            ;;
        '--full-surround') # if you want to have the text surrounded
            fsur=true
            ;;
        '--no-vertical-pad')
            vert_pad=''
            ;;
        '--color='*)
            color="$i_val"
            ;;
        *)
            prints+=("$i")
            ;;
        esac
    done

    ((${#surround} == 1)) || surround='#' # if the surround character is not 1 character long, set it to default
    ((width > 3)) || width="$COLUMNS"     # make sure width is a number, and it is enough to do fun things with later
    htx="$(printf "\e[1${color:+;$color}m%${width}s\e[0m" '')"
    htx="${htx// /$surround}" # first print a bunch of spaces of the desired width, then replace those spaces with the surround character
    if ((${#fsur})); then
        fsur="\e[1;${color:+;$color}m${surround}" # fsur is dual-purpose. If it is set, then turn it from a bool into a fmt string
        width="$((width - 2))"                    # make sure the width is small enough to be completely surrounded
    fi
    ((width % 2)) && width_pad=' ' # pad width with a space on one side if it is not an even number
    halfwidth="$((width / 2))"     # precompute half the width (as an integer)

    echo "${vert_pad:-}$htx"
    for i in "${prints[@]}"; do
        i_width="$((${#i} / 2))" # character count of $i, divided by two
        # if fsur is not set, set it to an empty string. Pad the width in spaces to be centered
        printf "${fsur:=}\e[${color:-0}m%$((i_width + halfwidth))s%$((halfwidth - i_width))s${width_pad:=}${fsur:-}\n" "$i"
    done
    echo "$htx${vert_pad:-}"
}

_pause_for_readability() {
    local delay="${1:?Error, a period of time to delay is required!}"
    echo -en "\e[2m(Pausing $delay seconds for readability)\e[0m"
    # [[ ${1:-} =~ ^([0-9]+)$ ]] && delay="${1:-}"
    # read -r -t "$delay" -p "[2mPress RETURN to skip the $delay-second delay..." delay
    read -r -t "$delay"
    echo -en "\e[2K\r" # Erase the text and return cursor position to normal
}

_wayland_setup() {
    local sudocmd prompt_str REBOOT_CHOICE dkms_pkg i
    if [[ ${1:-} == '--open' ]]; then
        dkms_pkg="nvidia-open-dkms"
        _print_header \
            'Installing Experimental Open-dkms Drivers' \
            '' \
            'Provides Experimental Open-dkms Drivers' \
            'Limited to Turing Series GPUs & Up'

        printf '%s\n' 'This option installs the latest open-source nVidia kernel modules.' \
            'Recommended for tinkering and testing' \
            "${BOLD}Warning${RESET}: Only compatible with ${BOLD}Turing+${RESET} GPUs$RESET"
    else
        dkms_pkg="nvidia-dkms"
        _print_header \
            'Installing Clean Vanilla Drivers (NFB)' \
            '' \
            'Provides Clean Vanilla Drivers' \
            'Limiting you to only 900 Series & Up'

        printf '%s\n' 'This option installs the latest proprietary kernel modules.' \
            'Recommended for most use cases'
    fi
    _pause_for_readability 5
    local should_install_cuda
    _print_header --width=55 'Do you want to include CUDA for Machine Learning?' \
        "${BOLD}WARNING${RESET}: This takes ${BOLD}4.3${RESET} GiB of disk space!!!"
    read -r -p "Do you want to install Cuda ? [y/N] > " should_install_cuda

    # if we do not have sudo perms, warn the user. Redirect all output (stdout, stderr, etc) to /dev/null
    if ((${#DRY})); then
        sudocmd='echo sudo'
        # prompt_str="${BOLD}[Dry run]${RESET} "
    else
        sudocmd='sudo'
        sudo -vn &>/dev/null || echo "${BOLD}[Sudo required]${RESET}"
    fi
    # read, unmangle backslashes, return false after 5 seconds, only read 1 character, prompt with string, no variable
    # read -r -t 5 -n 1 -p "${prompt_str:-}Press Enter to continue, or wait 5 seconds...${LF}"

    local -a required_packages=(
        "$dkms_pkg"
        'nvidia-utils'
        'libxnvctrl'
        'lib32-libxnvctrl'
        'dxvk-bin'
        'opencl-nvidia'
        'lib32-opencl-nvidia'
        'lib32-nvidia-utils'
        'nvidia-settings'
        'libvdpau'
        'lib32-libvdpau'
        'vulkan-icd-loader'
        'lib32-vulkan-icd-loader'
    )
    [[ ${should_install_cuda:-} == y ]] && required_packages+=(cuda)

    # pacman sends currently installed packages to stdout, and not-installed packages to stderr.
    # Take stderr and get only the package name. Disregard any colors.
    local oldifs="$IFS"
    local IFS=$'\n'
    local -a needed_packages=($(pacman -Q "${required_packages[@]}" 2> >(grep -oP --color=never "^error:[^']*'\K[^']*") >/dev/null))
    IFS="$oldifs"

    if ((${#needed_packages[@]})); then
        _print_header --width=35 "Installing packages"
        printf '%s\n' "${needed_packages[@]}"
        _pause_for_readability 5
        $sudocmd pacman -S --needed --noconfirm "${required_packages[@]}" # install everything though because you need to have it all
    else
        _print_header --width=35 "Drivers already installed. Skipping"
    fi

    _print_header --width=35 'Applying Wayland Specific Stuff.'
    _pause_for_readability 3

    local -i no_force_powermgmt=1
    local wants_powermgmt

    local DESKTOP_ENVIRONMENT="${XDG_CURRENT_DESKTOP,,}"
    if [[ "${DESKTOP_ENVIRONMENT:=}" == "kde" || "${DESKTOP_ENVIRONMENT:=}" == "gnome" ]]; then
        echo "Step 1: Updating mkinitcpio configuration"
        _pause_for_readability 2
        $sudocmd sed -i 's/MODULES="\(.*\)"/MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"/; s/crc32c//g' '/etc/mkinitcpio.conf'

        echo "${LF}Step 2: Creating a backup of Grub & adding necessary Kernel Flags"
        _pause_for_readability 2
        $sudocmd cp '/etc/default/grub' '/etc/default/grub.xbk'
        $sudocmd sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT='[^']*\)'/\1 nvidia_drm.modeset=1'/" '/etc/default/grub'
        $sudocmd update-grub

        if [[ "$DESKTOP_ENVIRONMENT" == "gnome" ]]; then
            echo "Step 2a: Applying Extra Gnome Modifications..."
            _pause_for_readability 2
            echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" | (
                # stdin is propagated to subprocesses of subshells
                if ((${#DRY})); then
                    tee
                else
                    $sudocmd tee '/etc/modprobe.d/nvidia-wayland-gnome.conf' >/dev/null
                fi
            )
            # $sudocmd ln -s '/dev/null' '/etc/udev/rules.d/61-gdm.rules'
            $sudocmd mkinitcpio -P
        fi
        wants_powermgmt=y
        no_force_powermgmt=0
    fi

    local -a services=(nvidia-{hibernate,resume,suspend})

    # ((no_force_powermgmt)) && read -r -p "Do you want to enable Nvidia power services? [y/N] > " wants_powermgmt

    local needs_nvidia_powerd
    read -r -p "Do you want to enable 'nvidia-powerd'? For Ampere (RTX 30 series+) laptop GPUs. [y/N] > " needs_nvidia_powerd
    [[ ${needs_nvidia_powerd:-} == 'y' ]] && services+=('nvidia-powerd')

    _print_header --width=35 'Enabling power services' "${services[@]}"
    _pause_for_readability 2

    # if [[ ${wants_powermgmt:-} == y || no_force_powermgmt -eq 1 ]]; then
    if :; then
        $sudocmd systemctl enable "${services[@]}" # &>/dev/null # it's always good to just double check
        if ((${#DRY})); then
            echo "Dry run selected. Skipping reboot"
        else
            _print_header "Reboot required. Press Enter to reboot or any other key to exit."
            read -r REBOOT_CHOICE
            if [[ -z ${REBOOT_CHOICE:-} ]]; then
                $sudocmd reboot
            else
                echo "${LF}Please reboot your system later to apply the changes."
            fi
        fi
    else
        echo "Skipping nvidia power services"
    fi
}

_check_gpu() {
    _print_header 'Checking Installed GPU'
    echo "${LF}Your system has the following GPU(s)${LF}"

    lspci -x | grep --color=always -P '[^A-Za-z]+VGA.*NVIDIA[^\[]+\[\K[^\]]+'
    glxinfo | grep --color=always -P 'OpenGL\s*(vendor|renderer)[^:]*:\s*\K.*'

    nvurl='https://www.nvidia.com/download/index.aspx?lang=en-us'
    skiptext="Skipping opening url '$nvurl'"
    if ((${#DRY})); then
        echo "$skiptext"
    else
        read -r -p "Want to open the nVidia drivers page?${LF}[y/N] > " ans
        if [[ $ans == y ]]; then
            _print_header --width=66 \
                'Opening nVidia Drivers page...' \
                'Check What Version Your GPU Needs Before Installing or Building.'
            _pause_for_readability 2
            xdg-open "$nvurl" &>/dev/null
        else
            echo "$skiptext"
        fi
    fi
}

_remove_everything() {
    _print_header --width=66 'Uninstalling all nVidia Drivers'

    ((XEROLINUX_REMOVE_DXVK_BIN)) && packages+=("dxvk-bin")

    # See driver install function for code explanation
    _print_header --width=35 "Removing packages"
    # local -a removing_packages=($(pacman -Q "${packages[@]}" 2>/dev/null | cut -d ' ' -f 1))
    local -a removing_packages=($(pacman -Q | grep -oE '\S*(nv(idia|ctrl|api)|cuda|vdpau)\S*'))
    ((${#removing_packages[@]})) && printf '%s\n' "${removing_packages[@]}"

    # If the user suddenly doesn't want to remove nvidia drivers, they have a second chance
    local second_thoughts
    read -r -p "Do you want to ${BOLD}REMOVE${RESET} these packages? [y/N] > " second_thoughts
    [[ ${second_thoughts:-} == 'y' ]] || return

    if ((${#DRY})); then
        # echo "Dry run -- skipping removal of ${packages[*]}"
        sudocmd='echo sudo'
    else
        sudocmd='sudo'
    fi
    local package
    for package in "${packages[@]}"; do
        $sudocmd pacman -Rdd --noconfirm "$package" &>/dev/null
    done
    $sudocmd mkinitcpio -P
}

__reset_everything() {
    if [[ ${1:-} == '--header' ]]; then
        _print_header --width=49 'Done!' 'Press ENTER to return to main screen'
    fi
    read -r
    echo -en "${RESET}" # clear formatting
    clear
    # sh '/usr/share/xerowelcome/scripts/nVidia_drivers.sh' # DANGEROUS RECURSION!!
}

DRY=''
# argument parsing
for i in "$@"; do
    case "${i:-}" in
    '--dry-run' | -d)
        DRY=true
        ;;
    '-'*)
        # ARGZERO (the script name), greedily matched until the last slash
        # turns '/home/vlk/Downloads/nVidia_driversNov.sh' into 'nVidia_driversNov.sh'
        echo "${0##*/} [--dry-run (-d)]"
        echo "run ${0##*/} with no args to run the script as usual"
        exit 1
        ;;
    esac
done

# save everything to a variable
header_text="$(
    _print_header --color=91 --no-vertical-pad --full-surround \
        'XeroLinux nVidia (Proprietary) Driver Installer' \
        'Wayland Support Included. This Applies to KDE & Gnome NOT XFCE.' \
        "Note : nvidia-settings GUI isn't Yet Wayland Ready, Plz Use Terminal." \
        'Normally This is Enough For Hybrid Setups, If Not, More Research is Needed.'

    cat <<EOF

###################### Detected GPUs ######################

Hello ${USER:=$(whoami)}, you have the following nVidia GPU(s):

$(
        lspci | grep -oP '^.*VGA[^:]+:\s*\K.*NVIDIA.*\](?=\s*\(.*)' | sed -E 's/(\[)/\1[0;1;91m/g ; s/(\])/[0m\1/g'
    )

################ Vanilla/Open-DKMS Drivers ################

${BOLD}1${RESET}. Latest Vanilla Drivers (900 Series & up).
${BOLD}2${RESET}. Latest Open-dkms Drivers (Experimental/Turing+).

############### Troubleshooting. (Cleanup). ###############

${BOLD}r${RESET}. Remove all Drivers. (Start Fresh)

Type Your Selection. To Exit, press ${BOLD}q${RESET} or close Window.
${RESET}
EOF
)"

while :; do
    CHOICE=''
    # print the header every time
    # read, unmangle backslashes, stop after 1 character, prompt with string, variable
    read -r -n 1 -p "$header_text${LF}${INVALID_OPTION_STR:-}[1|2|r|q] > ${BOLD}" CHOICE
    INVALID_OPTION_STR=''
    echo "${RESET}" # user's answer is bolded. This is required to reset
    case "${CHOICE:=}" in
    1)
        _wayland_setup
        ;;
    2)
        _wayland_setup --open
        ;;
    c)
        _check_gpu
        # __reset_everything --header
        ;;
    r)
        _remove_everything
        ;;
    q)
        exit 0
        ;;
    *)
        # _print_header --width=33 'Choose a valid option!' # no one will see this
        INVALID_OPTION_STR="Invalid option: '${CHOICE:-}' "
        clear
        continue # re-prompt
        ;;

    esac
    __reset_everything --header

done
