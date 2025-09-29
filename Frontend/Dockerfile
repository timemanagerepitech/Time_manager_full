# stage 1: build
FROM node:18-alpine AS build
WORKDIR /app

# copy package files first to cache installs
COPY package*.json ./
RUN npm install

# copy source and build
COPY . .
RUN npm run build

# stage 2: serve with nginx
FROM nginx:alpine
# Remove default nginx html
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
