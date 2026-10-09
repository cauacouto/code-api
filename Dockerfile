FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /application

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

COPY src src

RUN chmod +x mvnw
RUN ./mvnw package -DskipTests

RUN mkdir -p extracted
RUN java -Djarmode=layertools -jar target/codechella-api-1.0.jar extract --destination extracted


FROM eclipse-temurin:17-jre-alpine

WORKDIR /application

COPY --from=builder /application/extracted/dependencies/ ./
COPY --from=builder /application/extracted/spring-boot-loader/ ./
COPY --from=builder /application/extracted/snapshot-dependencies/ ./
COPY --from=builder /application/extracted/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]