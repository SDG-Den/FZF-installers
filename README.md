# FZF-installers
a collection of FZF installers for various software repositories

global requirements:
- fzf
- sudo (though you can easily replace this in multiple ways, provided below)


the following scripts are available and require the following package managers:

## linux software
apk-install - requires the Alpine Package Keeper (apk) package manager, found on Alpine Linux

apt-install - requires the Advanced Package Tool (APT) package manager, found on Debian and Ubuntu flavours

aur-install - requires both the pacman package manager and the yay AUR helper, found on arch-based distro's

brew-install - requires the homebrew or package manager, found on macOS and linuxbrew. 

dnf-install - requires the Dandified Yum package manager, found on fedora flavours/spins

emerge-install - requires the emerge package manager, found on gentoo

equo-install - requires the entropy package manager, found on sabayon linux

flatpak-install - requires flatpak to be installed, cross-platform

guix-install - requires the guix package manager, found on guix

nix-env-install - uses nix-env to install software, cross-platform, found on nixos. do note, nix-env is not the recommended way of installing software with nix. please make use of declarative configs instead.

nix-shell-install - uses nix-shell to install software, cross-platform, found on nixos. nix-shell is *temporary* to trial software. this is primarily meant to allow you to trial software before adding it to your configuration.nix. 

opkg-install - uses the opkg package manager, found in OpenWRT and LEDE

pac-install - uses the pacman package manager, found in arch flavours

slackpkg-install - uses the slackpkg package manager, found in slackware.

snap-install - uses snap to install packages, cross-platform

swupd-install - uses the swupd package manager, found in clear linux. 

taz-install - uses the tazpkg package manager, found in sliTaz

xbps-install - uses the xbps package manager, found in void linux

yum-install.sh - uses the yellowdog updater modified package manager, found in older versions of rhel, centos and fedora. 

zypper-install.sh - uses the zypper package manager, found in openSUSE distributions


## development
conda-install - requires the anaconda python package manger

cargo-install - requires the cargo rust package manager

composer-install - requires the composer php package manager

gem-install - require the ruby gems package manager

pip-install - requires the pip python package manager

pnpm-install - requires the pnpm node.js package manager


## other

multi-install - this is a wrapper that presents you with all the available package managers on your system, then opens the related scripts. this requires you to have all the scripts you want to use in the same directory as multi-install

updater.sh - this script will check which package managers are installed and check updates for all of them, presenting you a menu to check and run full updates. this script *can* take a while if you do development, since the cargo, pip, pnpm and *especially* gem update checks can take pretty long. 

defs.list and preview.sh are just dependencies for updater.sh and need to be placed in the same folder as updater.sh


## use

to use, simply clone this repository, copy the scripts you want to use to your preferred location, then make them executable by running `chmod a+x scriptname.sh` for each. 

then call with ./scriptname.sh to launch. 

optionally, you can also copy multi-install to the same directory, make it executable, and launch it. this will give you an initial menu to select which script to use. 


### set up an alias
if using multiple package managers, it is recommended to use the multi-install.sh script to avoid having multiple aliasses.

you can add an alias to launch them as a command in your shell config:
```sh 

# bash:
alias pactui='~/path/to/pac-install.sh'

# zsh:
alias pactui='~/path/to/pac-install.sh'

# fish:
alias pactui "~/path/to/pac-install.sh"
```

### set up a launch menu entry
if using multiple package managers, it is recommended to use the multi-install.sh script to avoid having multiple desktop entries.

to add this to your launch menu (both for WMs and desktop environments), you can create a .desktop file in /.local/share/applications:

make the file with `touch ~/.local/share/applications/pactui.desktop`

then open it in any editor:

`nano ~/.local/share/applications/pactui.desktop`

`micro ~/.local/share/applications/pactui.desktop`

`vim ~/.local/share/applications/pactui.desktop`

`nvim ~/.local/share/applications/pactui.desktop`

and add the following text:

```
[Desktop Entry]
Version=1.0
Type=Application
Name=Pacman TUI
Comment=Short pacman TUI
Exec=/path/to/the/script
Icon=/path/to/your/icon.png
Terminal=true
Categories=Utility;
```

if you have no text editor, you can instead type the following in the terminal to use a heredoc:

```
cat <<EOF >> ~/.local/share/applications/pactui.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Pacman TUI
Comment=Short pacman TUI
Exec=/path/to/the/script.sh
Icon=/path/to/your/icon.png
Terminal=true
Categories=Utility;
EOF
```

then make the file executable:

`chmod a+x ~/.local/share/applications/pactui.desktop`


### window manager binds
if using multiple package managers, it is recommended to use the multi-install.sh script to avoid having multiple binds.

if you are using a window manager and want to use a bind, you can do so by adding the following to your WM config:

in this case, alacritty is used as the terminal, replace it with whichever terminal you use. all examples use SUPER+Y. 
```
# mangowm:
bind=SUPER,Y,spawn_shell,alacritty -e /path/to/the/script.sh

# hyprland (v0.55+):
hl.bind("SUPER + Y", hl.dsp.exec_cmd("/path/to/the/script.sh"))

# hyprland (old hyprlang):
bind=SUPER, Y, exec, alacritty -e /path/to/script.sh

# niri:
binds {
    Super+Y { spawn "alacritty" "-e" "/path/to/the/script.sh"; }
}

# i3/sway
bindsym Super+Y exec "alacritty -e /path/to/the/script.sh";
```


## repositories

these scripts use the actual package manager to fetch available packages and list their details.

this means that these scripts do not need any configuration to work with your repositories, if your package manager is set up with a repository, the script will show the software from that repository. 

you will need to figure out how to install the package manager and its repositories yourself if it is not installed for you. 


## replacing sudo

if your system does not use sudo, but instead another privilege escalation utility, you can replace sudo in the scripts in two ways:

#1: simply open the script in your text editor of choice and replace every instance of sudo with your prefered tool (eg doas)

#2: set an alias in your shell, for example:
`alias sudo=doas`

if you do not have any privilege escalation utility installed and do not want to install one, you can also switch to root and run the script afterwards, but this is not advised and will not work with package managers that expect to be run without root privileges (which in their script, do not use sudo) like flatpak and the AUR.
```
su root
/path/to/script.sh
```

