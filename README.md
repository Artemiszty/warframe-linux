## Installation Instructions

REQUIREMENTS:  

1. Install wine-staging and wine dependencies (follow guide here for your distro):  
[How to get out of Wine Dependency Hell](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/)  

2. Install some tools you'll need for the script. You'll have to search for these packages yourself as I do not have/know the package names for every distro:  
winetricks, tar, lzma/unlzma, curl, wget, md5sum

Option A: Download Lutris:  

If you have lutris already, please make sure it is updated to version 0.4.14 or higher, as older versions had problems running batch scripts.  Next, run my Lutris install script for warframe:  
[Lutris 0.4.18](https://lutris.net/downloads/)  
[Warframe Install Script for Lutris](https://lutris.net/games/warframe/)  
Enable DXVK in the configuration options for the game in lutris, then run it from lutris.

Option B: Without Lutris:  

1. Download a copy of my warframe wine wrapper repo and extract it somewhere: [warframe-linux-master](https://github.com/GloriousEggroll/warframe-linux/archive/master.zip)  

2. Open the extracted folder in a terminal and:  

```shell
  chmod a+x install.sh
```

```shell
  ./install.sh
```

An optional parameter may be passed to specify the target installation
directory. Run `./install.sh --help` to see all available options.

3. Launch the game via any of the following methods:  

```
  Applications>Games>Warframe
  Warframe desktop shortcut
  type "warframe" in a terminal
```

NOTE: The launcher will open and run in a terminal. It will then launch two "black boxes", one after another. This is Warframe.exe double checking for missed updates, and then optimizing the game cache. Once these launch they will close by themselves, and the game will launch.

## Uninstallation/Removal Instructions
This applies to non-lutris only: 

```shell
  ./uninstall.sh
```

