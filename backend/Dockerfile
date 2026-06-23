# Imagem de producao do back-end CuidaBem.
FROM node:20-alpine

# Fuso horario do Brasil (America/Sao_Paulo). Sem isso o container roda em UTC e
# o periodo "hoje" dos relatorios/diario fica deslocado em 3 horas (UC007/UC004).
RUN apk add --no-cache tzdata
ENV TZ=America/Sao_Paulo

ENV NODE_ENV=production
WORKDIR /app

# Instala apenas dependencias de producao.
COPY package*.json ./
RUN npm install --omit=dev --no-audit --no-fund

COPY src ./src

EXPOSE 3000
CMD ["node", "src/server.js"]
