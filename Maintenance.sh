# This script should be used with caution. If you have any specific settings such as display resolution
# or the boot chime is enabled (pre-Big Sur), it will be cleared on restart. It also runs the maintenance
# scripts that come with macOS. Also, I'm not sure what will happen if you don't have Homebrew installed,
# and I can't be bothered testing it as this script is mainly for me.

# Tested on macOS 11.0.1 (Big Sur)

if [ `whoami` != root ]; then
    echo Please run this script as root or using sudo
    exit
fi

# Clear NVRAM
nvram -c

# Reset LaunchServices
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain u -domain s -domain l -v

# Reset dyld shared cache
update_dyld_shared_cache -force

# Run maintenance scripts
periodic daily weekly monthly

# Renew DHCP Lease
ipconfig set en0 DHCP

# Clear DNS Cache
sudo dscacheutil -flushcache && \
sudo killall -HUP mDNSResponder

# Clear memory cache
sudo purge

# Brew Stuff
brew update
brew upgrade
brew cask upgrade
brew cask outdated | cut -f 1 | xargs brew cask reinstall
brew doctor
brew missing
brew cleanup -s

# XPC Cache
sudo /usr/libexec/xpchelper --rebuild-cache

# Rebuild Coreduet
sudo rm -fr /var/db/coreduet/* 

# Boot Cache
sudo rm -f /private/var/db/BootCache.playlist

# Kernel Extension Cache
sudo touch /System/Library/Extensions && sudo kextcache -u /

echo "All done!"
