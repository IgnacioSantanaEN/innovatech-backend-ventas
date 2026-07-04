# ==========================================
# ETAPA 1: Compilación del JAR (Build)
# ==========================================
FROM maven:3.8.4-openjdk-17-slim AS builder

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn package -DskipTests

# ==========================================
# ETAPA 2: Entorno de Ejecución Ligero y Seguro
# ==========================================
FROM openjdk:17-jdk-slim

WORKDIR /app

# Requerimiento de Seguridad: Crear un usuario no-root (mínimo privilegio - Rúbrica)
RUN groupadd -r spring && useradd -r -g spring spring

# Copiar el archivo .jar generado en la etapa anterior (asumiendo el nombre estándar)
# Si el pom.xml genera otro nombre, cámbialo aquí o usa un comodín *.jar
COPY --from=builder /app/target/*.jar app.jar

# Cambiar los permisos para que el usuario 'spring' sea dueño de la app
RUN chown -R spring:spring /app

# Cambiar al usuario sin privilegios
USER spring

# Exponer el puerto por defecto de tu API 
EXPOSE 8080

# Ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]