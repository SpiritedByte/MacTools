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