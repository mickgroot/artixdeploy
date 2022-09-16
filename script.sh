#!/usr/bin/env bash
#base 
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo "Please enter hostname:"
read hostname

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j16"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T 16 -z -)/g' /etc/makepkg.conf

echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
locale-gen
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

timedatectl --no-ask-password set-timezone Europe/Amsterdam
timedatectl --no-ask-password set-ntp 1

# Set keymaps
localectl --no-ask-password set-keymap us

# Hostname
hostnamectl --no-ask-password set-hostname $hostname

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#setup
#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "Installing Base System"
echo

PKGS=(

    # --- XORG Display Rendering
        'xorg'                  # Base Package
        'xorg-server'           # XOrg server
        'xorg-xinit'            # XOrg init
        'mesa'                  # Open source version of OpenGL
        'xf86-video-amdgpu'     # XOrg amdgpu video driver
        'arandr'

    # --- Setup Desktop

        'picom'                 # Translucent Windows
        'lxappearance'          # Set System Themes

    # --- Networking Setup
        'networkmanager'     # Network connection manager
        'networkmanager'
        'fail2ban'                  # Ban IP's after man failed login attempts
        'ufw'                       # Uncomplicated firewall
    
    # --- Audio
        'pipewire'
        
    # --- extra
        'pcmanfm'
        'bash-completion'
        'vim'
        'zsh'
        'zsh-autosuggestions'     # Zsh Plugin
        'zsh-syntax-highlighting' # Zsh Plugin
        

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo
echo "Done!"
echo


#brave
#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "INSTALLING brace"
echo

echo "Please enter username:"
read username

cd "${HOME}"

echo "CLONING: YAY"
git clone "https://aur.archlinux.org/yay.git"


PKGS=(

    # COMMUNICATIONS ------------------------------------------------------

    'brave-bin'                 # Brave


)

cd ${HOME}/yay
makepkg -si

# Change default shell
chsh -s $(which zsh)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

echo
echo "Done!"
echo


#security
#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__|
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo "-------------------------------------------------"
echo "Secure Linux                                     "
echo "-------------------------------------------------"

# --- Setup UFW rules
ufw allow 80/tcp
ufw allow 443/tcp
ufw default deny incoming  
ufw default allow outgoing
ufw enable


# --- PREVENT IP SPOOFS
cat <<EOF > /etc/host.conf
order bind,hosts
multi on
EOF

# --- Enable ufw
 ln -s /etc/runit/sv/ufw /etc/runit/runsvdir/default

# --- Enable fail2ban
curl https://raw.githubusercontent.com/johnynfulleffect/secure-linux/master/jail.local -o /etc/fail2ban/jail.local

 ln -s /etc/runit/sv/fail2ban /etc/runit/runsvdir/default
