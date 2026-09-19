# 🏦 SecureTrust Bank

**SecureTrust Bank** is a Java-based banking microservices project designed to demonstrate the development and evolution of a modern distributed banking application.

The project is being developed incrementally across multiple versions, with each version introducing additional capabilities around **microservices, cloud-native architecture, resilience, security, messaging, observability, and deployment**.

---

## 🚀 Project Versions

| Version | Focus                            | Status       |
| ------- | -------------------------------- | -----------  |
| **V1**  | Core Banking Microservices       | ✅ Completed |
| **V2**  | Cloud-Native Microservices       | 🔄 Planned   |
| **V3**  | Advanced Production Architecture | 🔮 Planned   |

---

# 📌 V1 — Core Microservices

V1 establishes the fundamental building blocks of the SecureTrust Bank microservices architecture.

### V1 Includes

* 👤 Accounts Microservice
* 💳 Cards Microservice
* 💰 Loans Microservice
* ⚙️ Spring Cloud Config Server
* 🗄️ Database-per-service architecture
* 🌐 REST APIs
* 🐳 Docker containerization
* 🧩 Docker Compose
* ❤️ Container health checks
* 🌍 Environment-specific configuration
* 📖 OpenAPI / Swagger
* 📊 Spring Boot Actuator
* ✅ Request validation

---

# 🏗️ V1 Architecture

```text
                         ┌─────────────────────────┐
                         │      Config Server      │
                         │         :8071           │
                         └────────────┬────────────┘
                                      │
                           Centralized Configuration
                                      │
             ┌────────────────────────┼────────────────────────┐
             │                        │                        │
             ▼                        ▼                        ▼
    ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
    │    Accounts     │      │      Cards      │      │      Loans      │
    │     :8080       │      │      :9000      │      │      :8090      │
    └────────┬────────┘      └────────┬────────┘      └────────┬────────┘
             │                        │                        │
             ▼                        ▼                        ▼
    ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
    │   Accounts DB   │      │     Cards DB    │      │     Loans DB    │
    │    MySQL 8.4    │      │    MySQL 8.4    │      │    MySQL 8.4    │
    │     :3306       │      │     :3307       │      │     :3308       │
    └─────────────────┘      └─────────────────┘      └─────────────────┘
```

---

# 🧩 Microservices

## 👤 Accounts Service

Handles account-related banking functionality.

| Property        | Value                  |
| --------------- | ---------------------- |
| **Port**        | `8080`                 |
| **Database**    | `accountsdb`           |
| **Persistence** | Spring Data JPA        |
| **API**         | REST                   |
| **Validation**  | Spring Boot Validation |
| **Monitoring**  | Spring Boot Actuator   |

---

## 💳 Cards Service

Handles card-related banking functionality.

| Property          | Value                  |
| ----------------- | ---------------------- |
| **Port**          | `9000`                 |
| **Database**      | `cardsdb`              |
| **Persistence**   | Spring Data JPA        |
| **API**           | REST                   |
| **Validation**    | Spring Boot Validation |
| **Documentation** | OpenAPI / Swagger      |
| **Monitoring**    | Spring Boot Actuator   |

---

## 💰 Loans Service

Handles loan-related banking functionality.

| Property        | Value                  |
| --------------- | ---------------------- |
| **Port**        | `8090`                 |
| **Database**    | `loansdb`              |
| **Persistence** | Spring Data JPA        |
| **API**         | REST                   |
| **Validation**  | Spring Boot Validation |
| **Monitoring**  | Spring Boot Actuator   |

---

## ⚙️ Config Server

Provides centralized configuration for the microservices.

| Property                 | Value                      |
| ------------------------ | -------------------------- |
| **Port**                 | `8071`                     |
| **Technology**           | Spring Cloud Config Server |
| **Configuration Source** | Git-backed configuration   |
| **Monitoring**           | Spring Boot Actuator       |

---

# 🛠️ Technology Stack

| Technology                     | Version / Usage                 |
| ----------------------------   | ------------------------------- |
| ☕ **Java**                   | 25                              |
| 🌱 **Spring Boot**            | 4.1.1                           |
| ☁️ **Spring Cloud**           | 2025.1.3                        |
| 🗃️ **Spring Data JPA**        | Database access                 |
| 📊 **Spring Boot Actuator**   | Health & monitoring             |
| ✅ **Spring Boot Validation** | Request validation              |
| ⚙️ **Spring Cloud Config**    | Centralized configuration       |
| 🐬 **MySQL**                  | 8.4                             |
| 📖 **Springdoc OpenAPI**      | API documentation               |
| 📦 **Maven**                  | Build management                |
| 🐳 **Jib**                    | Container image creation        |
| 🐋 **Docker**                 | Containerization                |
| 🧩 **Docker Compose**         | Local environment orchestration |

---

# 🗄️ Database Architecture

V1 follows the **Database-per-Service** architecture.

Each microservice owns its own dedicated database:

```text
Accounts Service  →  accountsdb
Cards Service     →  cardsdb
Loans Service     →  loansdb
```

This provides:

* Data isolation between services
* Independent persistence management
* Service-level database ownership
* The ability to evolve services independently

---

# 🐳 Docker Architecture

V1 uses Docker Compose to run the complete local environment.

### Application Containers

```text
configserver-ms
accounts-ms
cards-ms
loans-ms
```

### Database Containers

```text
accountsdb
cardsdb
loansdb
```

All containers communicate through the **SecureTrust Docker network**.

### Startup Dependencies

Docker health checks control application startup.

Application services wait for:

1. Their corresponding MySQL database to become healthy.
2. Config Server to become healthy.

This prevents application services from starting before their required infrastructure is ready.

---

# 🌍 Environment Configurations

V1 provides separate Docker Compose configurations for:

* **Default**
* **QA**
* **Production**

### Project Structure

```text
V1-Microservice/
└── docker-compose/
    ├── default/
    │   ├── common-config.yml
    │   └── docker-compose.yml
    │
    ├── qa/
    │   ├── common-config.yml
    │   └── docker-compose.yml
    │
    └── prod/
        ├── common-config.yml
        └── docker-compose.yml
```

The active Spring profile is configured according to the selected environment.

---

# 🔌 Service Ports

| Service              |  Port  |
| ------------------   |--------|
| ⚙️ Config Server    | `8071` |
| 👤 Accounts         | `8080` |
| 💳 Cards            | `9000` |
| 💰 Loans            | `8090` |
| 🗄️ Accounts MySQL   | `3306` |
| 🗄️ Cards MySQL      | `3307` |
| 🗄️ Loans MySQL      | `3308` |

---

# 📖 API Documentation

The services use **Springdoc OpenAPI** for API documentation.

### Cards Service — Swagger UI

```text
http://localhost:9000/swagger-ui/index.html
```

Swagger UI provides an interactive interface for exploring and testing the Cards REST APIs.

---

# 📦 Building Docker Images

The microservices use **Jib** to build container images without requiring individual Dockerfiles.

### Build an image

```powershell
mvn compile jib:dockerBuild
```

Jib builds the application container image directly from the Maven project configuration.

---

# ▶️ Running V1

Navigate to the default Docker Compose environment:

```powershell
cd V1-Microservice\docker-compose\default
```

### Start the environment

```powershell
docker compose up -d
```

### Check container status

```powershell
docker compose ps
```

### View service logs

```powershell
docker logs configserver-ms
docker logs accounts-ms
docker logs cards-ms
docker logs loans-ms
```

### Stop the environment

```powershell
docker compose down
```

> **Note:** Avoid `docker compose down -v` if you want to preserve the MySQL data stored in Docker volumes.

---

# 📁 Project Structure

```text
SecureTrust/
│
├── README.md
├── .gitignore
│
└── V1-Microservice/
    │
    ├── accounts/
    │   ├── src/
    │   ├── pom.xml
    │   └── mvnw
    │
    ├── cards/
    │   ├── src/
    │   ├── pom.xml
    │   └── mvnw
    │
    ├── loans/
    │   ├── src/
    │   ├── pom.xml
    │   └── mvnw
    │
    ├── configserver/
    │   ├── src/
    │   ├── pom.xml
    │   └── mvnw
    │
    └── docker-compose/
        ├── default/
        ├── qa/
        └── prod/
```

---

# 🎯 V1 Scope

The current V1 focuses on establishing a clean foundation for the SecureTrust Bank platform.

### Core Capabilities

* Core banking microservices
* Independent service deployment
* Database-per-service architecture
* Centralized configuration
* REST APIs
* MySQL persistence
* Docker containerization
* Docker Compose orchestration
* Environment-specific configuration
* Service health checks
* API documentation
* Request validation
* Maven-based builds
* Jib-based container image creation

---

# 🛣️ Future Roadmap

SecureTrust Bank is planned to evolve through multiple architectural stages.

## V2 — Cloud-Native Microservices

Planned capabilities include:

* 🔎 Eureka Service Discovery
* 🚪 API Gateway
* 🔗 Inter-service communication
* 🛡️ Resilience4j
* 📨 Apache Kafka
* 🔐 JWT / Spring Security
* 🔍 Distributed tracing
* 📝 Centralized logging

---

## V3 — Advanced Production Architecture

Potential capabilities include:

* ☸️ Kubernetes
* 📈 Prometheus
* 📊 Grafana
* 🔄 CI/CD pipelines
* ☁️ Cloud deployment
* 🔭 Advanced observability
* 🏦 Additional banking microservices
* ⚙️ Production-oriented deployment architecture

The roadmap is intentionally incremental so that each version builds upon the previous architecture.

---

# 🌱 Project Evolution

The long-term goal is to evolve SecureTrust Bank from a Docker-based microservices application into a more complete cloud-native platform.

```text
                         ┌───────────────────────────────┐
                         │             V1                │
                         │     Core Microservices        │
                         │                               │
                         │  • Spring Boot                │
                         │  • MySQL                      │
                         │  • Config Server              │
                         │  • REST APIs                  │
                         │  • Docker Compose             │
                         └──────────────┬────────────────┘
                                        │
                                        ▼
                         ┌───────────────────────────────┐
                         │             V2                │
                         │   Cloud-Native Microservices  │
                         │                               │
                         │  • Service Discovery          │
                         │  • API Gateway                │
                         │  • Resilience                 │
                         │  • Messaging                  │
                         │  • Security                   │
                         │  • Observability              │
                         └──────────────┬────────────────┘
                                        │
                                        ▼
                         ┌───────────────────────────────┐
                         │             V3                │
                         │   Production Architecture     │
                         │                               │
                         │  • Kubernetes                 │
                         │  • Monitoring                 │
                         │  • CI/CD                      │
                         │  • Cloud Deployment           │
                         │  • Advanced Observability     │
                         └───────────────────────────────┘
```

---

# 🏷️ Git Versioning

Git tags are used to represent major project versions.

```text
v1.0
v2.0
v3.0
```

### Current Release

**`v1.0` — SecureTrust Bank Core Microservices**

---

# 👨‍💻 Author

**Azeem Mobarak**

Java Backend Developer

---

## ⭐ Project

SecureTrust Bank is a continuously evolving project focused on demonstrating practical **Java, Spring Boot, microservices, Docker, cloud-native architecture, and modern backend engineering practices**.
