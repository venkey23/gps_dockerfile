#!/bin/bash
#Author: Benjamin Perseghetti
#Email: bperseghetti@rudislabs.com
#For installing default CogniPilot

UBUNTU_RELEASE="`lsb_release -rs`"
if [[ "${UBUNTU_RELEASE}" == "14.04" ]]; then
	echo "Ubuntu 14.04 is no longer supported, please use 20.04"
	exit 1
elif [[ "${UBUNTU_RELEASE}" == "16.04" ]]; then
	echo "Ubuntu 16.04 is no longer supported, please use 20.04"
	exit 1
elif [[ "${UBUNTU_RELEASE}" == "18.04" ]]; then
	echo "Ubuntu 18.04 is no longer supported, please use 20.04"
	exit 1
elif [[ "${UBUNTU_RELEASE}" == "20.04" ]]; then
	echo "Configuring for Ubuntu 20.04"
fi

if [ "$1" == "-h" ]; then
	echo "Usage: $0 [-s <ssh_github_key_install>][-m <minimal_install>][-g <git_install>][-p <place_holder>]"
	echo "-s flag is used if you already have a github account and you want to register newly generated ssh keys [0, 1]"
	echo "-m flag is used if you only want to install minimal components [0, 1]"
	echo "-g flag is used if you only want to clone git repo [0, 1]"
	echo "-p flag not implemenmted yet"
	exit 1
fi

while getopts s:m:g:p option
do
	case "${option}"
	in
		s) SG=${OPTARG};;
		m) MI=${OPTARG};;
		g) GCO=${OPTARG};;
		p) PH=${OPTARG};;
	esac
done

sshGit=${SG:=0}
minInstall=${MI:=0}
gitCloneOnly=${GCO:=0}

if [ "$minInstall" == "True" ] || [ "$minInstall" == "1" ] || [ "$minInstall" == "true" ]; then
	minInstall="true"
else
	minInstall="false"
fi
if [ "$sshGit" == "True" ] || [ "$sshGit" == "1" ] || [ "$sshGit" == "true" ]; then
	sshGit="true"
else
	sshGit="false"
fi
if [ "$gitCloneOnly" == "True" ] || [ "$gitCloneOnly" == "1" ] || [ "$gitCloneOnly" == "true" ]; then
	gitCloneOnly="true"
else
	gitCloneOnly="false"
fi

if [ "$minInstall" == "false" ] && [ "$gitCloneOnly" == "false" ]; then
	printf "\nPerforming full install.\n"
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	sudo apt-get update -y
	sudo apt-get dist-upgrade -y
	sudo snap install gimp
	sudo snap install blender --classic
	sudo snap install slack --classic
	sudo snap install sublime-text --classic
	sudo apt-get install -y \
		python3-pip\
		checkinstall \
		google-chrome-stable \
		xclip \
		git \
		simplescreenrecorder \
		vim \
		psensor \
		indicator-multiload \
		htop
	sudo -H pip3 install jupyterlab
	printf "\nSetting Wallpaper to something scenic.\n"
	wget -O /home/$USER/Pictures/OhioStream.jpg "https://github.com/rudislabs/wallpaper/raw/main/OhioStream.jpg"
	gsettings set org.gnome.desktop.background picture-uri file:////home/$USER/Pictures/OhioStream.jpg
	printf "\n\nSetting up launch bar with default icons.\n"
	dconf write /org/gnome/shell/favorite-apps "['org.gnome.Nautilus.desktop', 'sublime-text_subl.desktop', 'org.gnome.Terminal.desktop', 'slack_slack.desktop', 'google-chrome.desktop', 'blender_blender.desktop', 'gimp_gimp.desktop', 'simplescreenrecorder.desktop', 'snap-store_ubuntu-software.desktop']"

elif [ "$minInstall" == "true" ] && [ "$gitCloneOnly" == "false" ]; then
	printf "\nPerforming minimal install.\n"
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	sudo apt-get update -y
	sudo apt-get dist-upgrade -y
	sudo snap install blender --classic
	sudo apt-get install -y \
		python3-pip\
		checkinstall \
		google-chrome-stable \
		xclip \
		git \
		simplescreenrecorder \
		vim \
		psensor \
		indicator-multiload \
		htop
	sudo -H pip3 install jupyterlab
	printf "\nSetting Wallpaper to something scenic.\n"
	wget -O /home/$USER/Pictures/OhioStream.jpg "https://github.com/rudislabs/wallpaper/raw/main/OhioStream.jpg"
	gsettings set org.gnome.desktop.background picture-uri file:////home/$USER/Pictures/OhioStream.jpg
	printf "\n\nSetting up launch bar with minimal install default icons.\n"
	dconf write /org/gnome/shell/favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'google-chrome.desktop', 'blender_blender.desktop', 'simplescreenrecorder.desktop', 'snap-store_ubuntu-software.desktop']"
else
	printf "\nPerforming a git clone only.\n"
fi


if [ "$sshGit" == "true" ]; then
	printf "\n\n***Warning! This will install new SSH keys!***\n"
	echo "Do you wish to proceed?"
	select yn in "Yes" "No"; do
    	case $yn in
        	Yes ) break;;
        	No ) printf "\nPlease rerun with -s 0 \n***EXITING***\n";exit 1;;
    	esac
	done
	printf "\nCreating SSH Key for use with github, use your github email address and optional passphrase.\n"
	ssh-keygen
	printf "\n\nWait for chrome to pop-up.\n Set chrome as default web browser and login to user account then close (all) chrome browser(s) and press enter in terminal.\n"
	sleep 6
	google-chrome
	sleep 2
	read -p "Press any key to continue after fully exiting chrome... " -n1 -s
	printf "\nSSH key copied to clipboard.\n"
	xclip -sel clip < ~/.ssh/id_rsa.pub
	printf "\n\nWait for chrome to pop-up again.\n"
	printf "\nLogin to github.com, correct page (https://github.com/settings/keys) will open in chrome and paste new ssh key in clipboard after entering name of computer, then close chrome.\n"
	printf "\nMake sure to completely exit chrome once credentials are saved then press enter in terminal\n"
	sleep 6
	google-chrome https://github.com/settings/keys
	sleep 2
	read -p "Press any key to continue after fully exiting chrome... " -n1 -s
fi

if [ ! -d "/home/${USER}/git" ];then 
	printf "\nCreating /home/${USER}/git directory\n"
	mkdir -p /home/${USER}/git
fi

if [ ! -d "/home/${USER}/git/zephyr" ];then 
	printf "\nNow cloning git repository using HTTPS.\n"
	cd /home/${USER}/git
	git clone https://github.com/CogniPilot/zephyr.git
else
	printf "\nGit repo already exists at /home/${USER}/git/zephyr, not re-cloning.\n"
fi

printf "\nAll done! Please continue by following the installation instructions in:\n\t/home/${USER}/git/zephyr/README.md\n"

