#!/bin/bash
# Verbose mode
set -x

# Installing aws-cli recently version
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# System update, docker installation, docker service enable and ec2-user added to docker group
sudo yum update -y
sudo amazon-linux-extras install docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

REGION="us-east-1"
PARAM_DB_HOST="/config/db_host"
PARAM_DB_NAME="/config/db_name"
PARAM_DB_USER="/config/db_user"
SECRET_DB_PASSWORD="db_password"
MAX_RETRIES=10
RETRY_DELAY=5

update_db_host() {
  DB_HOST=$(aws rds describe-db-instances --region $REGION --query "DBInstances[?DBInstanceIdentifier=='deelassessmentdb'].Endpoint.Address" --output text)
  if [ -n "$DB_HOST" ]; then
    aws ssm put-parameter --name "$PARAM_DB_HOST" --value "$DB_HOST" --type "String" --overwrite --region $REGION
    echo "db_host atualizado no Parameter Store: $DB_HOST"
  else
    echo "Erro: Não foi possível obter o DB_HOST do RDS."
    exit 1
  fi
}

update_db_host

fetch_parameters() {
  DB_HOST=$(aws ssm get-parameter --name "$PARAM_DB_HOST" --region $REGION --query "Parameter.Value" --output text 2>/dev/null)
  DB_NAME=$(aws ssm get-parameter --name "$PARAM_DB_NAME" --region $REGION --query "Parameter.Value" --output text 2>/dev/null)
  DB_USER=$(aws ssm get-parameter --name "$PARAM_DB_USER" --region $REGION --query "Parameter.Value" --output text 2>/dev/null)
  DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$SECRET_DB_PASSWORD" --region $REGION --query "SecretString" --output text 2>/dev/null)
}

sudo amazon-linux-extras enable postgresql14
sudo yum clean metadata
sudo yum install -y postgresql
psql --version

fetch_parameters  
# export PGPASSWORD="$DB_PASSWORD"

MAX_RETRIES=5
RETRY_DELAY=5
retry_count=0

while [ $retry_count -lt $MAX_RETRIES ]; do
  psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
    CREATE TABLE IF NOT EXISTS ips (
      id SERIAL PRIMARY KEY,
      ip_address VARCHAR(45) NOT NULL,
      reversed_ip VARCHAR(45) NOT NULL
    );
  " && break

  retry_count=$((retry_count + 1))
  echo "Tentativa $retry_count de $MAX_RETRIES para criar a tabela. Aguardando $RETRY_DELAY segundos..."
  sleep $RETRY_DELAY
done

if [ $retry_count -eq $MAX_RETRIES ]; then
  echo "Erro: Não foi possível criar a tabela após $MAX_RETRIES tentativas."
  exit 1
fi

sudo usermod -aG docker ssm-user

sudo docker run --name simple-web -d -it -p 80:80 --restart unless-stopped yeasy/simple-web:latest

sudo aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 089350267643.dkr.ecr.us-east-1.amazonaws.com

sudo docker pull 089350267643.dkr.ecr.us-east-1.amazonaws.com/deel-assessment-reversed-ip-app:latest

sudo docker run --name reversed-ip-app -d -p 8080:5000 --restart unless-stopped \
  -e DB_HOST="$DB_HOST" \
  -e DB_PORT="5432" \
  -e DB_NAME="$DB_NAME" \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  089350267643.dkr.ecr.us-east-1.amazonaws.com/deel-assessment-reversed-ip-app:latest

if [ $? -eq 0 ]; then
  echo "Container Python iniciado com sucesso."
else
  echo "Erro ao iniciar o container Python."
  exit 1
fi