# 🚛 Truckin' Along

Truckin' Along is a comprehensive Rails application designed to revolutionize shipping and package delivery, truck management, and logistics operations. It provides an intuitive interface for managing shipments, trucks, drivers, and routes while ensuring robust functionality, real-time tracking, and enterprise-grade scalability.

[![Ruby Version](https://img.shields.io/badge/ruby-3.x-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-8.x-brightgreen.svg)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🚀 Features

### For Shippers & Customers

- **Shipment Creation & Management**: Create, edit, and manage shipments through an intuitive dashboard
- **Delivery Notifications**: Receive automated alerts at key delivery milestones
- **Historical Analytics**: Access comprehensive shipment history and performance metrics
- **Document Management**: Upload and store shipping documents securely in one place

### For Trucking Companies & Carriers

- **Shipment Marketplace**: Browse and claim available shipments based on routes and capacity
- **Fleet Management**: Comprehensive tools for truck maintenance scheduling and tracking
- **Driver Management**: Streamline driver assignments, documentation, and performance monitoring
- **Automated Status Updates**: Configure preferences for automatic shipment status reporting
- **Regulatory Compliance**: Built-in tools to ensure adherence to transportation regulations

### System Capabilities

- **API Integration**: Connect with external systems for geolocation positioning
- **Role-Based Access Control**: Granular permission settings for diverse user types
- **Multi-tenant Architecture**: Support for multiple companies with data isolation
- **Mobile Responsiveness**: Full functionality across desktop and mobile devices

---

## 📋 Prerequisites

To get started, ensure you have the following installed on your system:

- **Ruby**: `3.x` or newer
- **Rails**: `8.x` or newer
- **Node.js**: `22.x` or newer
- **pnpm**: `10.x` or newer
- **PostgreSQL** (or another supported database)
- **Docker & Docker Compose** (for containerized development)

---

## 🔧 Environment Setup

### Azure Maps API Key

Truckin' Along uses Azure Maps for geocoding services. You'll need to set up an API key:

1. **Get an Azure Maps API Key**:

   - Visit the [Azure Portal](https://portal.azure.com/#blade/Microsoft_Azure_Maps/Common/MenuBlade/Keys)
   - Create a new Azure Maps account or use an existing one
   - Copy your primary or secondary key

2. **Configure Environment Variables**:

   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` and add your Azure Maps API key:
     ```bash
     AZURE_MAPS_API_KEY=your_actual_api_key_here
     ```

3. **Security Notes**:
   - Never commit your `.env` file to version control (it's already in `.gitignore`)
   - For production, set environment variables through your hosting platform
   - The `.env.example` file serves as documentation for required variables

### Other Environment Variables

Additional environment variables can be added to your `.env` file as needed:

- `DATABASE_URL`: Database connection string
- `REDIS_URL`: Redis connection string
- `RAILS_LOG_LEVEL`: Logging level (default: info)

---

## 🛠️ Standard Installation (Local Development)

### 1. Clone the Repository

Clone the repository and navigate to the project directory:

```bash
git clone https://github.com/your-username/truckin-along.git
cd truckin-along
```

### 2. Install Ruby Gems

Install all the required JavaScript and Ruby dependencies using Make:

```bash
make install
```

### 3. Setup the Database

Create and migrate the database:

```bash
make db-setup
make db-migrate
```

### 4. Start the Rails Server

Run the Rails development server:

```bash
make dev
```

Visit the app in your browser at http://localhost:3000.

## 🐳 Docker Setup (Recommended)

For a containerized development environment, follow these steps:

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/truckin-along.git
cd truckin-along
```

### 2. Initialize Docker Environment

This will build/pull images, start the database service, drop any existing database, and create a fresh one:

```bash
make d_init
```

### 3. Start the Application

Start all containers defined in docker-compose:

```bash
make d_start
```

### 4. Run Database Migrations

Apply pending migrations to your database:

```bash
make d_migrate
```

### 5. Stop the Application

When you're done working, stop all running containers:

```bash
make d_stop
```

### Docker Make Commands Reference

| Command          | Description                                                    |
| ---------------- | -------------------------------------------------------------- |
| `make d_init`    | Initialize Docker environment (build images, prepare database) |
| `make d_start`   | Start all services defined in docker-compose                   |
| `make d_stop`    | Stop all running containers                                    |
| `make d_migrate` | Run database migrations                                        |
| `make d_console` | Open Rails console inside the application container            |
| `make d_logs`    | Follow the logs from all containers                            |
| `make d_test`    | Run the test suite in the Docker environment                   |

---

## 🧪 Testing

### Run the Test Suite

Truckin' Along uses RSpec for testing. Run the test suite with:

```bash
make b-test
make f-test
```

### Run Quality Checks

Ensure your code adheres to style/security guidelines with Rubocop:

```bash
make rubocop
make scan-ruby
make scan-js
```

---

## 📚 Architecture & Technology Stack

### Backend

- **Rails 8**: Modern MVC web framework
- **PostgreSQL**: Robust relational database
- **Sidekiq**: Background job processing
- **Redis**: In-memory data structure store

### Frontend

- **Hotwire (Turbo & Stimulus)**: Modern, minimal-JavaScript approach
- **Import Maps**: Streamlined JavaScript dependency management

### Testing & Quality

- **RSpec**: Comprehensive testing framework for Ruby
- **Vitest**: Comprehensive testing framework for JavaScript
- **WDIO Tests**: End-to-end (E2E) and browser automation testing using WebdriverIO (Cucumber)
- **Factory Bot**: Test data generation
- **Rubocop**: Code style enforcement
- **Brakeman**: Static analysis security scanner for Ruby on Rails applications
- **GitHub Actions**: CI/CD pipeline integration

### Deployment

- **Docker**: Containerization for consistent environments
- **Docker Compose**: Multi-container orchestration
- **Render**: Cloud hosting options

---

## 🌟 Contributing

We welcome contributions to Truckin' Along! To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Please ensure your code follows our style guidelines and includes appropriate tests.

---

## 🛡️ License

This project is licensed under the MIT License. See the LICENSE file for details.

---

## 🙏 Acknowledgements

- The Rails community for their invaluable resources
- Our contributors and early adopters
- All open source projects that made this possible

Happy Truckin'! 🚛💨
