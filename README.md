# 🚀 Proyecto Innovatech - Arquitectura Cloud y CI/CD

Este repositorio contiene el código fuente y los manifiestos de infraestructura para la plataforma multicapa "Innovatech". El proyecto automatiza el ciclo de vida de la aplicación (Frontend en React, Backend en Spring Boot y Base de Datos MySQL) utilizando un enfoque nativo de la nube (**Cloud Native**).

---

## 🏗️ 1. Arquitectura de Infraestructura en AWS
El sistema se despliega en **Amazon Web Services (AWS)** utilizando infraestructura como código y orquestación de contenedores. **No se utiliza aprovisionamiento manual por SSH hacia máquinas EC2**. Todo el flujo está automatizado y gestionado por Kubernetes.

### Topología de Red (AWS VPC)
Para garantizar el aislamiento y la seguridad, el clúster opera dentro de una **Virtual Private Cloud (VPC)** con bloque CIDR `10.0.0.0/16`, dividida en:
* **Subredes Públicas (`10.0.1.0/24`, `10.0.2.0/24`):** Albergan los recursos que requieren salida directa a internet, específicamente el **Application Load Balancer (ALB)** aprovisionado por el Ingress de Kubernetes, el cual enruta el tráfico HTTP/HTTPS de los usuarios externos.
* **Subredes Privadas (`10.0.3.0/24`, `10.0.4.0/24`):** Albergan los *Worker Nodes* de Amazon EKS. Aquí se ejecutan los pods del Frontend, Backend y la Base de Datos. No tienen IPs públicas, brindando una capa máxima de seguridad. Se conectan a internet para descargas mediante un *NAT Gateway*.

### Security Groups (Hardening)
Se aplicó el principio de mínimo privilegio en los cortafuegos virtuales:
* El Load Balancer acepta tráfico HTTP (puerto 80) desde cualquier IP externa (`0.0.0.0/0`).
* Los Worker Nodes solo aceptan tráfico proveniente del Load Balancer.
* La base de datos MySQL (puerto 3306) restringe su entrada exclusivamente a las peticiones internas de la red del clúster originadas por el microservicio Backend.

---

## ☸️ 2. Orquestación y Escalabilidad (Amazon EKS)
La plataforma es administrada por **Amazon Elastic Kubernetes Service (EKS)**. 

### Alta Disponibilidad y Autoscaling (HPA)
Se implementó un `HorizontalPodAutoscaler` (HPA) para los despliegues del Backend (`ventas-deployment` y `despachos-deployment`). 
* **Justificación de los umbrales:**
  * **Mínimo de réplicas (2):** Garantiza la Alta Disponibilidad (HA). Si un nodo o pod cae, el sistema sigue respondiendo sin interrupción comercial (*Zero Downtime*).
  * **Máximo de réplicas (5):** Establece un techo lógico para prevenir costos descontrolados en la facturación de AWS en caso de un ataque DDoS o picos anormales prolongados.
  * **Target CPU (70%):** Se eligió este umbral para que el clúster se anticipe a la saturación. Escalar al 70% da margen de tiempo para que los nuevos contenedores de Spring Boot (que tardan unos segundos en arrancar) estén listos *antes* de que el servidor actual colapse al 100%.

---

## ⚙️ 3. Pipeline CI/CD Automatizado
El ciclo de integración y despliegue continuo está 100% automatizado mediante **GitHub Actions**, cumpliendo las etapas de *Build -> Push -> Deploy*.

1. **Checkout & Auth:** El pipeline obtiene el código y se autentica en AWS mediante la acción oficial `configure-aws-credentials`, utilizando **GitHub Secrets**. No existen llaves en código plano.
2. **Build & Push:** Construye las imágenes Docker optimizadas (Multi-stage) y las sube a **Amazon ECR**.
3. **Deploy (EKS):** El runner actualiza su contexto con `aws eks update-kubeconfig` y ejecuta de forma declarativa `kubectl apply` para aplicar los manifiestos, finalizando con un `rollout restart` para asegurar la actualización de los pods sin caídas.

> **Análisis de tiempos del Pipeline:**
> Las ejecuciones completas toman un promedio de **X minutos**. El cuello de botella principal es la construcción de la imagen de Java con Maven, lo cual fue optimizado utilizando imágenes base más ligeras (Alpine/Slim).
> 

---

## 🔒 4. Seguridad y Gestión de Secretos
Como parte de las buenas prácticas DevOps y DevSecOps implementadas en este proyecto:
* **Archivos `.env` eliminados:** Los archivos de entorno locales fueron purgados del historial de control de versiones mediante `git rm --cached` y añadidos al `.gitignore` para evitar fugas de información de la estructura interna.
* **Kubernetes Secrets & ConfigMaps:** Los datos estáticos y no confidenciales (como la URL de conexión interna) fueron separados a través de variables dinámicas, mientras que los datos críticos (como la contraseña `DB_PASSWORD`) se inyectan a los contenedores directamente a través del recurso nativo **Secret** en Kubernetes, codificados en Base64.

---

## 📊 5. Observabilidad: Logs y Métricas del Clúster
La visibilidad del comportamiento de los contenedores es esencial para la gestión de incidentes. A continuación, se presenta la evidencia del consumo de recursos de los microservicios operando bajo carga normal, y los registros de salida exitosa:

> **Métricas de Consumo (`kubectl top pods`):**

> **Análisis de Logs (`kubectl logs deployment/ventas-deployment`):**
> Los logs del backend demuestran que el ORM de Hibernate se conecta correctamente a la base de datos MySQL, validando la inyección de secretos, y levanta el servicio web en el puerto 8080 sin arrojar excepciones de memoria (OOMKilled) ni caer en estados de *CrashLoopBackOff*.

---

## ✅ 6. Validación Funcional (End-to-End)
Evidencia de la correcta comunicación de la arquitectura completa operando en la nube de AWS. El Frontend (React) enruta las peticiones de forma dinámica a través del Load Balancer hacia el Backend, el cual lee y escribe datos de forma persistente en MySQL.

