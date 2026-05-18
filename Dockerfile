# ETAPA 1: Construcción (Build)
# Aquí usamos la imagen de Node que SÍ tiene 'npm'
FROM node:18-alpine AS build 

WORKDIR /app

# Copiamos los archivos de dependencias
COPY package*.json ./

# Instalamos dependencias (Aquí ya no fallará porque estamos en node)
RUN npm install

# Copiamos el resto del código y construimos la app
COPY . .
RUN npm run build


# ETAPA 2: Producción (Servidor Web)
# Aquí usamos Nginx (recomendable la versión unprivileged por seguridad)
FROM nginxinc/nginx-unprivileged:alpine

# Copiamos la build terminada desde la Etapa 1 hacia la carpeta de Nginx
COPY --from=build /app/dist /usr/share/nginx/html 
# (NOTA: Cambia /app/dist por /app/build si usaste Create React App)

# Exponemos el puerto
EXPOSE 80

# Arrancamos Nginx
CMD ["nginx", "-g", "daemon off;"]