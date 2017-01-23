DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p /etc/postfix
sudo ln -s $DIR/sysctl/60-debugging.conf /etc/sysctl.d/60-debugging.conf
sudo ln -s $DIR/pam.d/chsh /etc/pam.d/chsh
sudo ln -s $DIR/postfix/main.cf /etc/postfix/main.cf
sudo ln -s $DIR/opendkim.conf /etc/opendkim.conf
sudo ln -s $DIR/default/opendkim /etc/default/opendkim
