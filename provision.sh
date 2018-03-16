#!/bin/bash

# Debian

# Locales
sed -i 's/# nl_BE.UTF-8 UTF-8/nl_BE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

# Timezone
echo "Europe/Brussels" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Custom bash prompt
echo "PS1='[\[\033[00;34m\]\u@\h \e[1mTESTING-WORKSHOP\[\033[00m\] \[\033[00;31m\]\w\[\033[00m\]]\n\\$ '" >> /etc/bash.bashrc
echo "PS1='[\[\033[00;34m\]\u@\h \e[1mTESTING-WORKSHOP\[\033[00m\] \[\033[00;31m\]\w\[\033[00m\]]\n\\$ '" >> /home/vagrant/.bashrc

# Console keyboard
sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="be"/' /etc/default/keyboard
setupcon --force

# Enable backports
echo -e "\ndeb http://ftp.de.debian.org/debian stretch-backports main" >> /etc/apt/sources.list

# Sync package index files
apt-get update
apt-get install -y apt-transport-https lsb-release ca-certificates

# Tools

apt-get install -y tmux htop zip unzip strace curl tcpdump netcat tree git jq supervisor

# Vim

apt-get install -y vim

cat << EOF >/etc/vim/vimrc.local
let skip_defaults_vim=1
syntax on
"colors elflord
"set softtabstop=4
set expandtab
set tabstop=4
set number
"set showcmd
"set cursorline
"set cursorcolumn
highlight CursorLine ctermbg=lightgray
"set wildmenu
"set lazyredraw
set showmatch
set incsearch
set hlsearch " nohl to undo
set nofoldenable " disable folding
EOF

update-alternatives --set editor /usr/bin/vim.basic

# PHP

# Add deb.sury.org repository
wget -O- https://packages.sury.org/php/apt.gpg | apt-key add -

cat << EOF >/etc/apt/sources.list.d/sury.list
deb https://packages.sury.org/php/ stretch main
EOF

# Sync package index files
apt-get update

apt-get -y install php7.2-cli php7.2-fpm php7.2-dev php7.2-curl php7.2-intl \
    php7.2-mysql php7.2-sqlite3 php7.2-gd php7.2-mbstring php7.2-xml

# PHP config
sed -i 's/;date.timezone.*/date.timezone = Europe\/Brussels/' /etc/php/7.2/cli/php.ini
sed -i 's/;date.timezone.*/date.timezone = Europe\/Brussels/' /etc/php/7.2/fpm/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 20M/' /etc/php/7.2/fpm/php.ini
sed -i 's/post_max_size = .*/post_max_size = 24M/' /etc/php/7.2/fpm/php.ini
sed -i 's/^user = www-data/user = vagrant/' /etc/php/7.2/fpm/pool.d/www.conf
sed -i 's/^group = www-data/group = vagrant/' /etc/php/7.2/fpm/pool.d/www.conf

# Install APCu
printf "\n" | pecl install apcu

cat << EOF >/etc/php/7.2/mods-available/apcu.ini
extension=apcu.so
EOF

ln -s /etc/php/7.2/mods-available/apcu.ini /etc/php/7.2/cli/conf.d/20-apcu.ini
ln -s /etc/php/7.2/mods-available/apcu.ini /etc/php/7.2/fpm/conf.d/20-apcu.ini

# Install Xdebug
pecl install xdebug

PHP_API=`php -i | grep "PHP API => " | cut -d' ' -f4`

cat << EOF >/etc/php/7.2/mods-available/xdebug.ini
zend_extension=/usr/lib/php/${PHP_API}/xdebug.so
xdebug.remote_enable=1
xdebug.remote_autostart=1
xdebug.remote_host=192.168.33.1
xdebug.max_nesting_level=256
; xdebug.profiler_enable=1
; xdebug.profiler_output_dir=/vagrant/dumps
EOF

ln -s /etc/php/7.2/mods-available/xdebug.ini /etc/php/7.2/cli/conf.d/10-xdebug.ini
ln -s /etc/php/7.2/mods-available/xdebug.ini /etc/php/7.2/fpm/conf.d/10-xdebug.ini

# Reload FPM
service php7.2-fpm restart

# composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin
ln -s /usr/bin/composer.phar /usr/bin/composer

su - vagrant -c 'composer global require --dev phpmd/phpmd'
echo "export PATH=\"/home/vagrant/.composer/vendor/bin:/vagrant/htdocs/vendor/bin:$PATH\"" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc

# phpunit
wget -P /usr/bin https://phar.phpunit.de/phpunit.phar
chmod +x /usr/bin/phpunit.phar
ln -s /usr/bin/phpunit.phar /usr/bin/phpunit

# Java

apt-get install -y openjdk-8-jre-headless

# Testing tools

cd /vagrant
composer.phar install


