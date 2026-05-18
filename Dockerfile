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

# 🚀 LÍNEA CLAVE NUEVA: Reemplaza la configuración por defecto de Nginx con tu puente proxy
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiamos la compilación estática de la etapa 1
COPY --from=build /app/dist /usr/share/nginx/html 

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]