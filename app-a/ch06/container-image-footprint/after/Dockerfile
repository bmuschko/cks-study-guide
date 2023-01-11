FROM node:19-alpine
ENV NODE_ENV development
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3001
CMD ["node", "app.js"]