# Spring Boot K8s Demo

A complete Spring Boot CRUD application designed for learning Kubernetes. This application demonstrates modern Spring Boot features with a user-friendly web interface.

## 🚀 Features

- **CRUD Operations**: Create, Read, Update, Delete users
- **Web Interface**: Beautiful Thymeleaf templates with Bootstrap
- **Database Integration**: MySQL with JPA/Hibernate
- **Health Checks**: Actuator endpoints for Kubernetes
- **Docker Ready**: Multi-stage Dockerfile for production
- **Kubernetes Ready**: Environment-based configuration

## 🛠️ Technology Stack

- **Backend**: Spring Boot 3.2.0, Java 17
- **Database**: MySQL 8.0
- **Frontend**: Thymeleaf, Bootstrap 5, Font Awesome
- **Build Tool**: Maven
- **Container**: Docker
- **Orchestration**: Kubernetes

## 📋 Prerequisites

- Java 17+
- Maven 3.6+
- MySQL 8.0+
- Docker (optional)
- Kubernetes cluster (for deployment)

## 🚀 Quick Start

### 1. Database Setup

```sql
CREATE DATABASE userdb;
CREATE USER 'springuser'@'%' IDENTIFIED BY 'springpass';
GRANT ALL PRIVILEGES ON userdb.* TO 'springuser'@'%';
FLUSH PRIVILEGES;
```

### 2. Local Development

```bash
# Clone the repository
git clone <repository-url>
cd springboot-k8s-demo

# Set environment variables
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=userdb
export DB_USERNAME=springuser
export DB_PASSWORD=springpass

# Run the application
mvn spring-boot:run
```

### 3. Docker Build & Run

```bash
# Build Docker image
docker build -t springboot-k8s-demo:latest .

# Run with Docker Compose (if you have docker-compose.yml)
docker-compose up -d

# Or run standalone
docker run -p 8080:8080 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=3306 \
  -e DB_NAME=userdb \
  -e DB_USERNAME=springuser \
  -e DB_PASSWORD=springpass \
  springboot-k8s-demo:latest
```

## 🎯 Application Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Redirects to users list |
| `/users` | GET | List all users |
| `/users/new` | GET | Show create user form |
| `/users` | POST | Create new user |
| `/users/{id}` | GET | Show user details |
| `/users/{id}/edit` | GET | Show edit user form |
| `/users/{id}` | POST | Update user |
| `/users/{id}/delete` | POST | Delete user |
| `/actuator/health` | GET | Health check endpoint |
| `/actuator/info` | GET | Application info |

## 🐳 Docker Configuration

### Dockerfile Features

- **Multi-stage build**: Optimized image size
- **Security**: Non-root user
- **Health checks**: Built-in health monitoring
- **JVM optimization**: Container-aware JVM settings

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | localhost | Database host |
| `DB_PORT` | 3306 | Database port |
| `DB_NAME` | userdb | Database name |
| `DB_USERNAME` | root | Database username |
| `DB_PASSWORD` | password | Database password |

## ☸️ Kubernetes Deployment

### 1. Create Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: springboot-demo
```

### 2. MySQL Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: springboot-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
        - name: MYSQL_DATABASE
          value: "userdb"
        - name: MYSQL_USER
          value: "springuser"
        - name: MYSQL_PASSWORD
          value: "springpass"
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: springboot-demo
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
```

### 3. Spring Boot Application

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springboot-app
  namespace: springboot-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: springboot-app
  template:
    metadata:
      labels:
        app: springboot-app
    spec:
      containers:
      - name: springboot-app
        image: springboot-k8s-demo:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          value: "mysql-service"
        - name: DB_PORT
          value: "3306"
        - name: DB_NAME
          value: "userdb"
        - name: DB_USERNAME
          value: "springuser"
        - name: DB_PASSWORD
          value: "springpass"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: springboot-service
  namespace: springboot-demo
spec:
  selector:
    app: springboot-app
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

## 🔧 Configuration

### Application Properties

The application uses environment variables for configuration:

```yaml
spring:
  datasource:
    url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:userdb}
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:password}
```

### Health Check Configuration

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
```

## 🧪 Testing

### Unit Tests

```bash
mvn test
```

### Integration Tests

```bash
mvn verify
```

### Manual Testing

1. Access the application at `http://localhost:8080`
2. Create a new user
3. View user details
4. Edit user information
5. Delete user
6. Test search functionality

## 📊 Monitoring

### Health Endpoints

- `/actuator/health` - Application health status
- `/actuator/info` - Application information
- `/actuator/metrics` - Application metrics

### Logs

```bash
# View application logs
kubectl logs -f deployment/springboot-app -n springboot-demo

# View MySQL logs
kubectl logs -f deployment/mysql -n springboot-demo
```

## 🚀 Production Considerations

1. **Database**: Use managed database service (RDS, Cloud SQL)
2. **Secrets**: Use Kubernetes secrets for sensitive data
3. **Ingress**: Configure ingress controller for external access
4. **SSL/TLS**: Enable HTTPS with cert-manager
5. **Monitoring**: Set up Prometheus and Grafana
6. **Logging**: Configure centralized logging
7. **Backup**: Set up database backups

## 📚 Learning Objectives

This application is designed to teach:

1. **Spring Boot Development**: Modern Spring Boot features
2. **Database Integration**: JPA/Hibernate with MySQL
3. **Web Development**: Thymeleaf templating
4. **Containerization**: Docker best practices
5. **Kubernetes**: Deployment and service management
6. **Microservices**: Service communication
7. **DevOps**: CI/CD pipeline integration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For questions and support:

1. Check the documentation
2. Search existing issues
3. Create a new issue
4. Contact the maintainers

---

**Happy Learning! 🎉**
