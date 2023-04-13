#!/bin/bash
#Mise à jour des repos
GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m' # No Color
YELLOW='\033[33m\033[1m'

protected=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -t|--token) token="$2"; shift 2;;
    -d|--domain) domain="$2"; shift 2;;
    -p|--protected) protected=1; shift;;
    *) echo "Usage: ./script.sh -t <token> -d <domain> [-p]"; exit 1;;
  esac
done

if [ -z "$token" ] || [ -z "$domain" ]; then
  echo -e "${YELLOW}Les deux arguements sont requis"
  echo -e "Usage: ./script.sh -t <token> -d <domain>${NC}"
  exit 1
fi
apt-get update > /dev/null 2>&1

echo -e "${GREEN}[+] install git${NC}"
apt install -y git > /dev/null 2>&1

echo -e "${GREEN}[+] install docker${NC}"
# Install de Docker 
apt-get install -y  \
    ca-certificates \
    curl \
    gnupg \
    lsb-release > /dev/null 2>&1
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg  --yes  > /dev/null 2>&1
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update > /dev/null 2>&1
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null 2>&1

#Install docker-compose
echo -e "${GREEN}[+] install docker-compose${NC}"
sudo curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose > /dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1

#Clone repo
echo -e "${GREEN}[+] Clonage des repository${NC}"
git clone https://$token@github.com/PwnHubCTF/PownCTF.git > /dev/null 2>&1

#Set les variables d'environnements
export PRODUCTION=true
export DB_HOST=db
export API_URL=api
export MYSQL_USER=user
export MYSQL_PASSWORD=root
export MYSQL_DATABASE=pwnme
export DOMAIN=$domain
export JWT_SECRET=`cat /proc/sys/kernel/random/uuid | md5sum`
export SIGNED_FLAG_SECRET=`cat /proc/sys/kernel/random/uuid | md5sum`
if [ $protected -eq 1 ]; then
  export BASIC_ENABLED='true'
  export BASIC_USER='pwnhub'
  export BASIC_PASSWORD=`echo -n $(md5sum <<< $(cat /proc/sys/kernel/random/uuid) |awk '{print $1}')`
else
  export BASIC_ENABLED='false'
fi

cd PownCTF
cp .env.example .env >/dev/null 2>&1
docker-compose up -d --build

#Install nginx
echo -e "${GREEN}[+] install nginx${NC}"
apt-get install -y nginx > /dev/null 2>&1
unlink /etc/nginx/sites-enabled/default > /dev/null 2>&1

echo -e "${GREEN}[+] install setup reverse proxy${NC}"
cat << EOF > /etc/nginx/sites-enabled/reverse-proxy.conf
server{
    listen 80;
    server_name $domain;
    location / {
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

echo -e "${GREEN}[+] Install certbot${NC}"
apt install certbot python3-certbot-nginx -y > /dev/null 2>&1

certbot --nginx -d $domain --non-interactive --agree-tos -m webmaster@email.com > /dev/null 2>&1


service nginx restart > /dev/null 2>&1
echo -e "${GREEN}[+] Done${NC}"

if [ $protected -eq 1 ]; then
  echo -e "${GREEN}#################################################"
  echo -e "# BASIC Password : ${BASIC_PASSWORD}  #"
  echo -e "#################################################${NC}"
fi
