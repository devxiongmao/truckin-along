# 🚛 Truckin' Along

Truckin' Along is a revolutionary crowdsourced shipping platform that democratizes package delivery and logistics. Built on Rails, it connects anyone who needs to ship something with anyone who has space in their vehicle - creating a community-driven marketplace that makes shipping affordable, flexible, and accessible to all.

**🌟 The Power of Crowdsourcing**: No commercial trucks required! Whether you're a professional driver, someone with a pickup truck, or just heading in the right direction with extra cargo space, you can earn money by delivering packages. Similarly, anyone can send a shipment - from individuals moving apartments to small businesses needing cost-effective delivery solutions.

[![Ruby Version](https://img.shields.io/badge/ruby-3.x-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-8.x-brightgreen.svg)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🌍 How Truckin' Along Works

### The Crowdsourced Marketplace

Truckin' Along operates on a simple yet powerful principle: **anyone can ship, anyone can deliver**. Our platform connects two groups of people:

**📦 Shippers (Anyone with something to send)**

- Individuals moving homes or selling items online
- Small businesses needing affordable delivery
- Students shipping belongings between dorms
- Families sending care packages
- Anyone who needs something transported

**🚗 Drivers/Deliverers (Anyone with transportation)**

- Professional truck drivers looking for additional loads
- People with pickup trucks, vans, or SUVs
- Commuters traveling regular routes who want to earn extra income
- Retirees with time and reliable vehicles
- College students with cars looking for side income
- **No special licenses or commercial vehicles required!**

### Getting Started is Simple

**For Shippers**: Create an account, post your shipment details (pickup location, destination, size, timeline), and wait for drivers to bid on your delivery.

**For Drivers**: Sign up, verify your identity and vehicle, browse available shipments on routes you're already taking (or willing to take), place bids, and start earning money by helping your community.

---

## 🚀 Features

### For Anyone Sending Packages (Shippers)

- **Easy Shipment Posting**: Describe what you're sending, where it needs to go, and when
- **Flexible Pricing**: Set your own budget and accept competitive bids from drivers
- **Driver Selection**: Choose from multiple driver proposals based on ratings, price, and timeline
- **Real-Time Tracking**: Follow your package every step of the way
- **Community Reviews**: Rate your delivery experience to help other users

### For Anyone with a Vehicle (Drivers/Deliverers)

- **Flexible Opportunities**: Find deliveries that match your schedule and routes
- **Earn on Your Terms**: Accept jobs that work for your vehicle size and availability
- **Route Optimization**: Find shipments along routes you're already traveling
- **Instant Earnings**: Get paid quickly after successful deliveries
- **Build Your Reputation**: Earn ratings and reviews
- **No Overhead**: Use your existing vehicle - no need for commercial licensing

### For Trucking Companies & Professional Carriers

- **Scale Your Operations**: Access a marketplace of shipments to fill empty capacity
- **Fleet Management**: Comprehensive tools for truck maintenance scheduling and tracking
- **Driver Management**: Streamline driver assignments, documentation, and performance monitoring
- **Bulk Opportunities**: Handle multiple shipments efficiently
- **Professional Tools**: Advanced analytics and route optimization for commercial operations

### System Capabilities

- **Integrated Mapping**: Powered by Azure Maps for precise geocoding and route planning
- **Mobile-First Design**: Full functionality on smartphones for drivers on the go
- **API Integration**: Connect with external logistics and tracking systems
- **Multi-tenant Architecture**: Support for both individual users and business accounts

---

## 👥 Community-Driven Benefits

### For the Community

- **Reduced Environmental Impact**: Optimize existing vehicle trips instead of creating new ones
- **Local Economy Boost**: Keep shipping dollars in local communities
- **Flexible Employment**: Create income opportunities for people with various schedules
- **Affordable Shipping**: Competition drives down costs for everyone

### For Shippers

- **Lower Costs**: Competitive bidding often results in prices below traditional shipping
- **Faster Delivery**: Direct routes without hub-and-spoke delays
- **Flexible Scheduling**: Coordinate timing that works for both parties

### For Drivers

- **Monetize Your Commute**: Turn regular trips into earning opportunities
- **Work When You Want**: Complete flexibility in choosing jobs
- **Help Your Neighbors**: Build community connections while earning money
- **Scalable Income**: Take on as many or as few deliveries as you want

---

## 📋 Prerequisites

To get started, ensure you have the following installed on your system:

- **Ruby**: `3.x` or newer
- **Rails**: `8.x` or newer
- **pnpm**: `10.x` or newer
- **PostgreSQL** (or another supported database)
- **Docker & Docker Compose** (for containerized development)

---

## 🔧 Environment Setup

### Azure Maps API Key

Truckin' Along uses Azure Maps for geocoding services. It's recommended to use this service for optimal performance. If you skip this setup, Truckin' Along will still work, you will just be using the `Nominatim` api instead. You can get your free Azure API key by performing the following steps.

1. **Get an Azure Maps API Key**:

   - Visit the [Azure Portal](https://azure.microsoft.com/en-us/products/azure-maps)
   - Create a new Azure Maps account or use an existing one
   - Copy your primary or secondary key

2. **Configure Environment Variables**:

   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` and add your Azure Maps API key or your Nominatim user agent:
     ```bash
     AZURE_MAPS_API_KEY=your_actual_api_key_here
     NOMINATIM_USER_AGENT=your_user_agent
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
git clone https://github.com/devxiongmao/truckin-along.git
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
- **PostgreSQL**: Robust relational database for handling complex relationships between users, shipments, and deliveries
- **Sidekiq**: Background job processing for notifications, matching algorithms, and payment processing
- **Redis**: In-memory data structure store for real-time features and caching

### Frontend

- **Hotwire (Turbo & Stimulus)**: Modern, minimal-JavaScript approach perfect for mobile-responsive driver interfaces
- **Import Maps**: Streamlined JavaScript dependency management

### Crowdsourcing Features

- **Bidding System**: Competitive marketplace for fair pricing
- **Real-time Notifications**: Keep users informed of shipment status changes
- **Geolocation Services**: Accurate tracking and route optimization

### Testing & Quality

- **RSpec**: Comprehensive testing framework for Ruby
- **Vitest**: Comprehensive testing framework for JavaScript
- **Cucumber Tests**: End-to-end (E2E) and browser automation testing using Cucumber
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

We welcome contributions to Truckin' Along! As a crowdsourced platform, we believe in the power of community contribution not just for deliveries, but for the platform itself. To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Please ensure your code follows our style guidelines and includes appropriate tests.

### Areas Where We Need Help

- **Advanced matching/filtering algorithms** for better driver-shipment pairing
- **Multi-language support** for diverse communities
- **Accessibility improvements** to make the platform usable by everyone

---

## 🛡️ License

This project is licensed under the MIT License. See the LICENSE file for details.

---

## 🙏 Acknowledgements

- The Rails community for their invaluable resources
- Our contributors and early adopters
- The crowdsourced economy pioneers who inspired this platform
- Every driver and shipper who makes this community possible
- All open source projects that made this possible

---

## 🚀 Join the Revolution

Ready to be part of the crowdsourced shipping revolution? Whether you have something to ship or space in your vehicle, Truckin' Along connects you with your community. **Sign up today and start truckin'!**

**For Shippers**: Post your first shipment in minutes  
**For Drivers**: Start earning on your next trip  
**For Everyone**: Help build a more connected, efficient world

Happy Truckin'! 🚛💨
