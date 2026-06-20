# Imagem de producao do back-end CuidaBem.
FROM node:20-alpine

ENV NODE_ENV=production
WORKDIR /app

# Instala apenas dependencias de producao.
COPY package*.json ./
RUN npm install --omit=dev --no-audit --no-fund

COPY src ./src

EXPOSE 3000
CMD ["node", "src/server.js"]
