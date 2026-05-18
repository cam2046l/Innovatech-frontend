# interfaz de usuario desarrollada para Innovatech Chile, diseñada para la gestión eficiente de ventas y la generación de órdenes de despacho. Esta SPA (Single Page Application) permite a los operadores visualizar compras en tiempo real y gestionar la logística de salida de productos.

# Tecnologías Principales
React 18 + Vite: Framework de alta velocidad para la construcción de interfaces.

Tailwind CSS: Framework de utilidades para un diseño responsivo y moderno.

Axios: Cliente HTTP para la comunicación con los microservicios de backend.

Nginx: Servidor web de alto rendimiento utilizado para el despliegue productivo.

# Arquitectura de Contenedorización (IE1 & IE6)
El frontend ha sido contenerizado siguiendo estándares de la industria para asegurar su portabilidad:

Multi-Stage Build: 1.  Stage 1 (Build): Utiliza Node.js para compilar el código JSX/Vite y generar los archivos estáticos optimizados.
2.  Stage 2 (Production): Utiliza una imagen ligera de Nginx Alpine para servir los archivos, eliminando dependencias de desarrollo y reduciendo el tamaño de la imagen final.

Manejo de Rutas: Se configuró un archivo de servidor personalizado en Nginx para gestionar correctamente el enrutamiento de React (SPA fallback) y evitar errores 404 al refrescar la página.

 Integración con Microservicios (IE5 & IE7)
Para garantizar que el sistema sea escalable y fácil de mantener, la conexión con el backend se gestiona mediante Variables de Entorno:

VITE_API_URL: Define la dirección del microservicio de Ventas/Despachos.

External Configuration: Al utilizar archivos .env, el código fuente permanece agnóstico al entorno (Desarrollo, IP institucional o AWS), cumpliendo con los estándares de configuración externa exigidos por la pauta.

 Despliegue Automático (CI/CD) (IE3 & IE8)
El despliegue se automatiza mediante GitHub Actions cada vez que se realiza un push a la rama deploy:

Linter & Build: Se valida el código y se genera el artefacto de producción.

Docker Push: La imagen resultante se sube a Docker Hub.

SSH Deploy: Se notifica a la instancia EC2 para que actualice el contenedor sin intervención manual.

 # Instalación Local
Si deseas ejecutar este frontend fuera de un contenedor:

Clonar el repositorio.

Instalar dependencias: npm install.

Configurar la IP del backend en .env.

Ejecutar: npm run dev.