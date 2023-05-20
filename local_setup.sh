#!/bin/bash
cd "$(dirname "$0")" || exit

source .local_env

ENV="NODE_ENV=development\n\
NEXTAUTH_SECRET=$NEXTAUTH_SECRET\n\
NEXTAUTH_URL=http://localhost:3000\n\
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000\n\
DATABASE_URL=file:../db/db.sqlite\n\
NEXT_PUBLIC_WEB_SEARCH_ENABLED=true\n\
SERP_API_KEY=$SERP_API_KEY\n\
HTTP_PROXY=$HTTP_PROXY\n\
HTTPS_PROXY=$HTTPS_PROXY\n\
ALL_PROXY=$ALL_PROXY\n"

echo $ENV

printf $ENV > .env
printf $ENV > .env.docker

docker stop agentgpt
docker rm agentgpt

if [ "$1" = "--docker" ]; then
  source .env.docker
  docker build --build-arg NODE_ENV=$NODE_ENV -t agentgpt .
  docker run -d --name agentgpt -p 3000:3000 -v $(pwd)/db:/app/db agentgpt

  sleep 10
  xdg-open http://localhost:3000
elif [ "$1" = "--docker-compose" ]; then
  docker-compose up -d --remove-orphans

  sleep 10
  xdg-open http://localhost:3000
else
  ./prisma/useSqlite.sh
  npm install
  prisma db push
  npm run dev
fi
