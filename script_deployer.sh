#!/bin/bash
#Mise à jour des repos
GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m' # No Color
YELLOW='\033[33m\033[1m'

while [ "$#" -gt 0 ]; do
  case "$1" in
    -t|--token) token="$2"; shift 2;;
    -d|--domain) domain="$2"; shift 2;;
    *) echo "Usage: ./script.sh -t <token> -d <domain>"; exit 1;;
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
curl -fsSL https://download.docker.com/linux/debian/gpg  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg  --yes  > /dev/null 2>&1
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
git clone https://Eteckq:$token@github.com/PwnHubCTF/deployer.git > /dev/null 2>&1

#Set les variables d'environnements
# CONFIG
export NODE_ENV=prod
export APP_PORT=3000
export SECRET_TOKEN=`echo -n $(md5sum <<< $(cat /proc/sys/kernel/random/uuid) |awk '{print $1}')`
export GITHUB_TOKEN=$token
export SERVER_URL=$domain

# DATABASE
export DB_HOST=bdd
export DB_USER=user
export DB_PASSWORD=userpassword
export DB_PORT=3306
export DB_NAME=deployer

# REDIS
export REDIS_URL=redis://redis:6379

cd deployer
docker compose up -d --build
echo -e "${GREEN}#################################################"
echo -e "# TOKEN  : ${SECRET_TOKEN}  #"
echo -e "#################################################${NC}"
