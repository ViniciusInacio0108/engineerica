# Engineerica_app

This flutter project is design to deliver the technical assessment sent by Engineerica.

The idea is to have an application that handles user tasks with some features, such as: filtering, sorting, pagination, CRUD for tasks and also check complete and incomplete tasks.

## Getting Started

### Requirements

You will need to install and have setup in your machine the following softwares:

1. Java 21+ (Recommend OpenJDK)
2. Flutter 3.24.0 (You can use FVM for the project)
3. Dart SDK 3.5.0
4. FVM (Flutter Version Management)
5. Android Studio (Latest better)
6. XCode (Latest better) for iOS development
7. Physical/Emulator device to run the app
8. VSCode IDE (If you don't like Android Studio)

### Check Flutter SDK

First, garantee you Flutter is all okay with the command: 

```fvm flutter doctor```

This command above should be run in your terminal at root folder project and it will show if you have any problems with Flutter SDK setup.

### Setup and Run project

Open your terminal and run the following commands in the project root folder:

1. ```fvm flutter clean``` (Clean Cached Builds)
2. ```fvm flutter pub get``` (Get packages)
3. ```fvm flutter run``` (Run app)
4. Select desired device to run and that's it!

## Architecture decisions

This project follows a **feature-based Clean Architecture** pattern to ensure scalability, testability, and clear separation of concerns.

```
lib/
│
├── core/
│   ├── database/
│   ├── injection/
│   └── routing/
│
├── features/
│   └── tasks/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

### **`core/`**
Contains the shared infrastructure and setup used across all features.

- **`database/`** → Handles local persistence, database setup, and data access configuration (`Hive`).
- **`injection/`** → Dependency injection setup (`get_it`) used to register services, repositories, and blocs.
- **`routing/`** → Centralized route management.

---

### **`features/`**
Each feature is self-contained, following the **Clean Architecture** principle.  
A feature includes its own **data**, **domain**, and **presentation** layers.

- #### **`data/`**
  Implements the data layer:
- **Repositories implementations** that fulfill contracts defined in the domain layer.
- **Datasources** (e.g., local or remote) for handling raw data access.
- **Models (DTOs)** for mapping between raw data (JSON, database).

- #### **`domain/`**
  Defines the business logic layer — independent of any external framework:
- **Repositories contracts** → Abstract interfaces for data operations.
- **Use cases** → Contain the application’s core logic and orchestrate interactions between entities and repositories.
- **Entities** → Core business models used internally throughout the domain.

- #### **`presentation/`**
  Holds all UI and state management logic:
- **Screens** → Complete UI pages (widgets that represent a full screen or route).
- **Widgets** → Reusable UI components specific to this feature.
- **Bloc** → State management (using the BLoC pattern) for handling user interactions and coordinating with use cases.

---

### **`main.dart`**
Entry point of the application — responsible for initializing dependencies, setting up routing, and launching the root widget.

## Libraries/Dependencies

Our Application need the following dependencies:

**Dependencies:**

1.  `uuid: ^4.5.1` -> Generate UUIDs

2.  `result_dart: ^2.1.1` -> Using for the Result pattern. Where we can have a failure and success return out of our methods.

3.  `hive_flutter: ^1.1.0` -> Hive database

4.  `json_annotation: ^4.9.0` -> Json Annotation fro Freezed

5.  `freezed_annotation: ^2.4.4` -> Generating Json annotation for Freezed using json_annotation package

6.  `hive: ^2.2.3` -> Hive Database

7.  `flutter_bloc: ^9.1.1` -> Bloc helper for state management

8.  `get_it: ^8.2.0` -> Dependency injection 

**Dev dependencies:**
1.  `freezed: ^2.5.7`-> Freezed for generating boiler plate code of our DTOs

2.  `flutter_lints: ^4.0.0` -> Standard lint installed

3.  `json_serializable: ^6.9.0` -> Json serialization used for Freezed

4.  `build_runner: ^2.4.13` -> Building generated code for other dependencies

## Technical Observations

### 1. In Memory filtering and sorting

For this project we are using **Hive** and it has **limitations for been NoSQL DB and a simpler solution**. Because of that, we can't do complex queries and such needed to be done in memory. ***This is a problem because is not scalable and affects performance**. The solution would be to use a **better SQL DB such as SQFlite or a backend**.