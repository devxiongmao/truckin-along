# 🚛 Truckin' Along

Truckin' Along is a Rails application designed to streamline truck management, deliveries, and logistics. It provides an intuitive interface for managing trucks, drivers, and routes while maintaining robust functionality and scalability.

---

## 🚀 Features
- Manage truck records efficiently.
- CRUD operations for trucks, drivers, and routes.
- Confirmation prompts for destructive actions.
- Modern JavaScript integration using Import Maps.

---

## 📋 Prerequisites

To get started, ensure you have the following installed on your system:
- **Ruby**: `3.x` or newer
- **Rails**: `8.x` or newer
- **Node.js**: `14.x` or newer
- **Yarn** or **npm**
- **PostgreSQL** (or another supported database)

---

## 🛠️ Installation

### 1. Clone the Repository
Clone the repository and navigate to the project directory:
```bash
git clone https://github.com/your-username/truckin-along.git
cd truckin-along
```

### 2. Install Ruby Gems
Install all the required Ruby dependencies using Bundler:
```bash
bundle install
```

### 3. Install JavaScript Dependencies
If you are using Yarn, run:
```bash
yarn install
```

If you are using npm, run:
```bash
npm install
```

### 4. Setup the Database
Create and migrate the database:
```bash
bin/rails db:create db:migrate
```

### 5. Start the Rails Server
Run the Rails development server:
```bash
bin/rails server
```
Visit the app in your browser at http://localhost:3000.

---

## 🧪 Testing

### Run the Test Suite
Truckin' Along uses RSpec for testing. Run the test suite with:
```bash
bundle exec rspec
```

### Run Linters
Ensure your code adheres to style guidelines with Rubocop:
```bash
bundle exec rubocop
```

---

## 📚 Documentation

### Application Structure
- app/: Core application code (models, controllers, views, helpers, etc.).
- config/: Configuration files for Rails and related libraries.
- db/: Database schema and migration files.
- vendor/: Third-party code not managed via Bundler or Yarn.

### Key Libraries and Tools
- Rails 8: Backend framework.
- PostgreSQL: Database management.
- RSpec: Testing framework for Ruby.
- Rubocop: Ruby code linter.
- @rails/ujs & Import Maps: Modern JavaScript management.

---

## 🌟 Contributing
We welcome contributions to Truckin' Along! To contribute:

1. Fork the repository.
2. Create a new branch (git checkout -b feature/your-feature).
3. Commit your changes (git commit -m "Add your feature").
4. Push to the branch (git push origin feature/your-feature).
5. Open a pull request.

---

## 🛡️ License
This project is licensed under the MIT License. See the LICENSE file for details.

Happy Truckin'! 🚛💨