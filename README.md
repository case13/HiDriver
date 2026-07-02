# HiDriver
Auto Parts Sales System

HiDriver is a Delphi demo project created to showcase the development of a commercial desktop system integrated with a REST API.

The project simulates an auto parts store, including counter sales, inventory control, daily cash register, accounts receivable, and business rules commonly found in real commercial systems.

## Purpose

This repository was created as a portfolio project to demonstrate professional software development practices using Delphi.

The main goal is to show skills in:

* Delphi desktop development
* VCL application development
* REST API development with Delphi
* Layered architecture
* Business rules implementation
* Inventory control
* Sales and cash register workflows
* Relational database usage
* Clean project organization
* GitHub documentation

## Technologies

* Delphi XE10
* VCL
* Delphi REST API
* FireDAC
* SQLite
* JSON
* Token-based authentication

## Project Structure

```text
HiDriver
│
├── docs
│   ├── architecture.md
│   ├── api-endpoints.md
│   ├── business-rules.md
│   ├── database-model.md
│   └── screenshots
│
├── database
│   ├── scripts
│   └── samples
│
└── src
    ├── HiDriver.Shared
    ├── HiDriver.Api
    └── HiDriver.Desktop
```

## Architecture

The project follows a layered architecture with a desktop application consuming a REST API.

### Desktop Flow

```text
View/Form → Desktop Service → ApiClient → REST API
```

The desktop application is responsible for the user interface and should not access the database directly.

### API Flow

```text
Controller → Application Service → Domain Service → Repository → Database
```

The API centralizes business rules, validations, transactions, persistence, and JSON responses.

### Shared Project

The `HiDriver.Shared` project contains common structures used by both the API and the Desktop application, such as:

* DTOs
* Enums
* Constants
* Contracts
* Standard API response types

## Main Features

Planned and implemented features include:

* User authentication
* Dashboard
* Product registration
* Customer registration
* Supplier registration
* Product categories
* Brands
* Vehicle applications
* Counter sales
* Sales search
* Sale cancellation
* Daily cash register
* Accounts receivable
* Inventory control
* Reports

## Business Rules

Some of the business rules demonstrated in this project:

* A sale can only be completed when the cash register is open.
* Inactive products cannot be sold.
* Products cannot be sold in quantities greater than available stock.
* Sales must update inventory.
* Sale cancellation must reverse inventory and financial movements.
* Credit sales require a customer.
* Accounts receivable are generated automatically when needed.
* Cash movements are registered according to payment methods.

## API Endpoints

Main expected endpoints:

```text
POST   /api/auth/login

GET    /api/products
GET    /api/products/{id}
POST   /api/products
PUT    /api/products/{id}
DELETE /api/products/{id}

GET    /api/customers
GET    /api/customers/{id}
POST   /api/customers
PUT    /api/customers/{id}
DELETE /api/customers/{id}

POST   /api/sales
GET    /api/sales
GET    /api/sales/{id}
POST   /api/sales/{id}/cancel

POST   /api/cash/open
POST   /api/cash/close
GET    /api/cash/current

GET    /api/accounts-receivable
POST   /api/accounts-receivable/{id}/receive

GET    /api/dashboard/summary
```

## Database

The initial database engine is SQLite to make the project easier to clone, run, and test.

Future database support may include:

* Firebird
* SQL Server
* PostgreSQL

Database scripts are located in:

```text
database/scripts
```

## Roadmap

This project is currently under development.

Planned development phases:

1. Create base project structure
2. Create shared DTOs, enums, and contracts
3. Create SQLite database scripts
4. Create Delphi REST API
5. Implement authentication
6. Implement products
7. Implement customers
8. Implement cash register
9. Implement sales
10. Implement inventory
11. Implement accounts receivable
12. Create VCL desktop application consuming the API
13. Create dashboard
14. Create reports
15. Complete documentation and screenshots

## Repository Goal

This repository is public and intended to be used as a professional portfolio project.

It demonstrates how a Delphi desktop system can be structured with a REST API, database access, business rules, and documentation following a clean and organized approach.
