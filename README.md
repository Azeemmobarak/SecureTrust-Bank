\# SecureTrust Bank



SecureTrust Bank is a Java-based banking microservices project designed to demonstrate the development and evolution of a modern distributed banking application.



The project is being developed incrementally across multiple versions, with each version introducing additional microservices, cloud-native capabilities, resilience, security, messaging, and observability.



\---



\## Project Versions



| Version | Focus                            | Status    |

| ------- | -------------------------------- | --------- |

| V1      | Core Banking Microservices       | Completed |

| V2      | Cloud-Native Microservices       | Planned   |

| V3      | Advanced Production Architecture | Planned   |



\---



\# V1 – Core Microservices



V1 focuses on the fundamental building blocks of a banking microservices architecture.



\### V1 includes



\* Accounts Microservice

\* Cards Microservice

\* Loans Microservice

\* Spring Cloud Config Server

\* MySQL database per service

\* REST APIs

\* Docker containerization

\* Docker Compose

\* Health checks

\* Environment-specific configurations

\* OpenAPI / Swagger

\* Spring Boot Actuator

\* Request validation



\---



\## V1 Architecture



```text

&#x20;                        ┌──────────────────────┐

&#x20;                        │    Config Server     │

&#x20;                        │       :8071          │

&#x20;                        └──────────┬───────────┘

&#x20;                                   │

&#x20;                        Centralized Configuration

&#x20;                                   │

&#x20;             ┌─────────────────────┼─────────────────────┐

&#x20;             │                     │                     │

&#x20;             ▼                     ▼                     ▼

&#x20;     ┌───────────────┐     ┌───────────────┐     ┌───────────────┐

&#x20;     │   Accounts    │     │     Cards     │     │     Loans     │

&#x20;     │    :8080      │     │     :9000     │     │     :8090     │

&#x20;     └───────┬───────┘     └───────┬───────┘     └───────┬───────┘

&#x20;             │                     │                     │

&#x20;             ▼                     ▼                     ▼

&#x20;     ┌───────────────┐     ┌───────────────┐     ┌───────────────┐

&#x20;     │  Accounts DB  │     │   Cards DB    │     │   Loans DB    │

&#x20;     │   MySQL 8.4   │     │   MySQL 8.4   │     │   MySQL 8.4   │

&#x20;     │    :3306      │     │    :3307      │     │    :3308      │

&#x20;     └───────────────┘     └───────────────┘     └───────────────┘

```



\---



\# Microservices



\## Accounts Service



Handles account-related banking functionality.



\* Port: `8080`

\* Database: `accountsdb`

\* Spring Boot

\* Spring Data JPA

\* MySQL

\* REST APIs

\* Validation

\* Spring Boot Actuator



\## Cards Service



Handles card-related banking functionality.



\* Port: `9000`

\* Database: `cardsdb`

\* Spring Boot

\* Spring Data JPA

\* MySQL

\* REST APIs

\* Validation

\* OpenAPI / Swagger

\* Spring Boot Actuator



\## Loans Service



Handles loan-related banking functionality.



\* Port: `8090`

\* Database: `loansdb`

\* Spring Boot

\* Spring Data JPA

\* MySQL

\* REST APIs

\* Validation

\* Spring Boot Actuator



\## Config Server



Provides centralized configuration for the microservices.



\* Port: `8071`

\* Spring Cloud Config Server

\* Git-backed configuration

\* Spring Boot Actuator



\---



\# Technology Stack



| Technology             | Version / Usage           |

| ---------------------- | ------------------------- |

| Java                   | 25                        |

| Spring Boot            | 4.1.1                     |

| Spring Cloud           | 2025.1.3                  |

| Spring Data JPA        | Database access           |

| Spring Boot Actuator   | Health monitoring         |

| Spring Boot Validation | Request validation        |

| Spring Cloud Config    | Centralized configuration |

| MySQL                  | 8.4                       |

| Springdoc OpenAPI      | API documentation         |

| Maven                  | Build management          |

| Jib                    | Container image creation  |

| Docker                 | Containerization          |

| Docker Compose         | Container orchestration   |



\---



\# Database Architecture



V1 follows the \*\*database-per-service\*\* architecture.



Each microservice has its own dedicated database:



```text

Accounts Service → accountsdb

Cards Service    → cardsdb

Loans Service    → loansdb

```



This provides data isolation and allows each service to manage its own persistence independently.



\---



\# Docker Architecture



V1 uses Docker Compose to run the complete local environment.



\### Application containers



```text

configserver-ms

accounts-ms

cards-ms

loans-ms

```



\### Database containers



```text

accountsdb

cardsdb

loansdb

```



All containers communicate through the SecureTrust Docker network.



Application startup is controlled using Docker health checks.



Dependent services wait for:



1\. Their corresponding MySQL database to become healthy.

2\. Config Server to become healthy.



\---



\# Environment Configurations



V1 provides separate Docker Compose configurations for different environments:



```text

V1-Microservice/

└── docker-compose/

&#x20;   ├── common-config.yml

&#x20;   ├── default/

&#x20;   ├── qa/

&#x20;   └── prod/

```



The active Spring profile is configured according to the environment.



\---



\# Service Ports



| Service        | Port |

| -------------- | ---: |

| Config Server  | 8071 |

| Accounts       | 8080 |

| Cards          | 9000 |

| Loans          | 8090 |

| Accounts MySQL | 3306 |

| Cards MySQL    | 3307 |

| Loans MySQL    | 3308 |



\---



\# API Documentation



Services use Springdoc OpenAPI for API documentation.



Cards service Swagger UI:



```text

http://localhost:9000/swagger-ui/index.html

```



\---



\# Building Docker Images



The microservices use Jib to build Docker images without requiring individual Dockerfiles.



Example:



```powershell

mvn compile jib:dockerBuild

```



\---



\# Running V1



Navigate to the default Docker Compose environment:



```powershell

cd V1-Microservice\\docker-compose\\default

```



Start the environment:



```powershell

docker compose up -d

```



Check container status:



```powershell

docker compose ps

```



View logs:



```powershell

docker logs configserver-ms

docker logs accounts-ms

docker logs cards-ms

docker logs loans-ms

```



Stop the environment:



```powershell

docker compose down

```



> Avoid `docker compose down -v` when you want to preserve the MySQL data stored in Docker volumes.



\---



\# Project Structure



```text

SecureTrust/

│

├── README.md

├── .gitignore

│

└── V1-Microservice/

&#x20;   │

&#x20;   ├── accounts/

&#x20;   │

&#x20;   ├── cards/

&#x20;   ├── loans/

&#x20;   ├── configserver/

&#x20;   │

&#x20;   └── docker-compose/

&#x20;       ├── common-config.yml

&#x20;       ├── default/

&#x20;       ├── qa/

&#x20;       └── prod/

```



\---



\# V1 Scope



The current V1 focuses on:



\* Core banking microservices

\* Independent service deployment

\* Database-per-service architecture

\* Centralized configuration

\* REST APIs

\* MySQL

\* Docker containerization

\* Docker Compose

\* Environment-specific configuration

\* Service health checks

\* API documentation

\* Request validation

\* Maven/Jib-based container image creation



\---



\# Future Roadmap



\## V2 – Cloud Native



Planned capabilities include:



\* Eureka Service Discovery

\* API Gateway

\* Inter-service communication

\* Resilience4j

\* Kafka

\* JWT / Spring Security

\* Distributed tracing

\* Centralized logging



\## V3 – Production Architecture



Potential capabilities include:



\* Prometheus

\* Grafana

\* Kubernetes

\* CI/CD

\* Cloud deployment

\* Advanced observability

\* Additional banking microservices



\---



\# Git Versioning



The repository uses Git tags to represent major project versions.



Example:



```text

v1.0

v2.0

v3.0

```



\### Current Release



```text

v1.0 - SecureTrust Bank Core Microservices

```



\---



\# Author



\*\*Azeem Mobarak\*\*



Java Backend Developer



