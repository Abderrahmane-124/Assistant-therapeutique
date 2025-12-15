# Backend for Assistant Therapeutique

This is a Spring Boot application that will serve as the backend for the Assistant Therapeutique application.

## Prerequisites

- Java 11 or higher
- Maven
- XAMPP with Apache and MySQL running

## Getting Started

1.  **Database Setup**:
    -   Open the XAMPP control panel and start the Apache and MySQL modules.
    -   Go to `http://localhost/phpmyadmin/`.
    -   Create a new database. You can name it whatever you like.
    -   Open the `src/main/resources/application.properties` file.
    -   Update the `spring.datasource.url` property to include the name of the database you just created (e.g., `jdbc:mysql://localhost:3306/assistant_therapeutique_db`).
    -   If you have set a password for your MySQL root user, update the `spring.datasource.password` property.

2.  **Running the application**:
    -   Open a terminal in the `Backend_Assistant_therapeutique` directory.
    -   Run the command `mvn spring-boot:run`.
    -   The application will start on port 8080.

## API Endpoints

(You will add your API endpoints here as you develop the application.)
