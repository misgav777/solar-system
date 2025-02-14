FROM node:18-alpine3.17

WORKDIR /usr/app

COPY package*.json /usr/app/

RUN npm install

COPY . .

ENV MONGO_URI=uri-placeholder
ENV MONGO_USERNAME=usernam-placeholder
ENV MONGO_PASSWORD=password-placeholder

EXPOSE 3000

CMD ["npm", "start"]