# Architecture: Biblioteca Digital

Este documento define la arquitectura general e infraestructura del backend utilizada en el proyecto `biblioteca_movil`. 

## 1. Patrón de Arquitectura (Frontend + Backend)

La aplicación utiliza Flutter como UI Framework y Supabase como su Backend-as-a-Service (BaaS). Sigue una estructura en capas centrada en una separación de responsabilidades clara:

```mermaid
graph TD
    UI[UI Layer] --> Prov[State Management: Provider]
    Prov --> Repo[Repository Layer]
    Repo --> SDK[Supabase SDK]
    SDK --> Supabase_DB[(Supabase PostgreSQL)]
```

### 1.1 Modelos de Datos (`lib/models/`)
Poseen la funcionalidad de convertir mapas JSON directamente en Clases Dart y viceversa.
- `AuthorModel`: Representa un autor (`id`, `name`).
- `CategoryModel`: Representa una categoría/género literario (`id`, `name`).
- `BookModel`: Modelo principal de un libro. Contiene relaciones N:M con `List<AuthorModel>` y `List<CategoryModel>`, además de un campo `status` (read/reading/pending). Expone **getters de conveniencia** (`author`, `genre`, `statusLabel`) que aplanan las listas para facilitar la lectura desde la UI.
- `UserBookModel`: Representa la copia personal de un libro por usuario (su estado de lectura y calificación).

### 1.2 Capa de Repositorios (`lib/repositories/`)
Intermedio con la API de Supabase, maneja el CRUD puro.
- `AuthRepository`: Se encarga de operaciones como `signIn`, `signUp`, y `signOut`.
- `DatabaseRepository`: Ejecuta las queries, filtros, updates y deletes en Supabase Postgres. Incluye:
  - `getBooks()` / `getCategories()` — Lectura pública.
  - `createBook()` — Crea un libro y maneja automáticamente las tablas pivote (upsert de autores/categorías).
  - `updateBookStatus()` — Actualiza el estado de un libro.
  - `addUserBook()` / `updateUserBook()` / `deleteUserBook()` — CRUD de la biblioteca personal.

### 1.3 Capa de Proveedores o "State" (`lib/providers/`)
Mantiene el estado local de la aplicación en memoria.
- `AuthProvider`: Encapsula la reactividad sobre la sesión del usuario para redibujar la UI.
- `BookProvider`: Mantiene el caché de libros públicos (`publicBooks`) y personales (`userBooks`). Expone métodos como `addBook()`, `updateBookStatus()`, `loadPublicData()` y `loadUserBooks()`.

### 1.4 Pantallas (`lib/screens/`)
- `SplashScreen`: Pantalla de bienvenida con animación de fade-in. Navega automáticamente al Home después de 3 segundos.
- `HomeScreen`: Listado principal de libros. Muestra título, autor, género y estado con iconos visuales. Incluye botón de edición por libro y FAB para agregar.
- `BookDetailScreen`: Vista detallada de un libro individual (título, autor, género, estado traducido al español).
- `EditBookScreen`: Formulario de edición. Los campos de título, autor y género se muestran pre-llenados.
- `AddBookScreen`: Formulario para registrar un nuevo libro. Persiste a Supabase creando el libro y vinculando autor/categoría automáticamente.

---

## 2. Base de Datos (Supabase PostgreSQL)

Implementamos un diseño altamente normalizado y asegurado mediante RLS (Row Level Security).

### 2.1 Esquema SQL (ER Diagram)

- **authors**
  - `id` (UUID) [PK]
  - `name` (TEXT)

- **categories**
  - `id` (UUID) [PK]
  - `name` (TEXT)

- **books**
  - `id` (UUID) [PK]
  - `title` (TEXT)
  - `description` (TEXT)
  - `cover_url` (TEXT)
  - `status` (TEXT) ['read', 'reading', 'pending'] DEFAULT 'pending'

- **book_authors** (Pivote M:N)
  - `book_id` (UUID) [FK -> books]
  - `author_id` (UUID) [FK -> authors]

- **book_categories** (Pivote M:N)
  - `book_id` (UUID) [FK -> books]
  - `category_id` (UUID) [FK -> categories]

- **user_books** (Tabla Pivote Extensible)
  - `id` (UUID) [PK]
  - `user_id` (UUID) [FK -> auth.users]
  - `book_id` (UUID) [FK -> books]
  - `status` (TEXT) ['read', 'reading', 'pending']
  - `rating` (INTEGER) [1 - 5]
  - `added_at` (TIMESTAMP)

### 2.2 Seguridad (Row Level Security - RLS)
- Cualquier modificación a `user_books` requiere autorización estricta. El usuario solo podrá ejecutar `INSERT`, `UPDATE` o `DELETE` si la variable `auth.uid()` equivale a la columna `user_books.user_id`.
- Los libros públicos y las categorías se mantienen en "Lectura Pública", mientras se permiten inserciones de nuevos libros solo a usuarios con sesión activa (`authenticated`).

---

## 3. Evolución Arquitectónica (Normalización N:M)

Para garantizar la pureza de los datos y adaptarnos a la Tercera Forma Normal (3NF), la arquitectura original de la BD evolucionó de simples relaciones escalares a estructuras avanzadas **Muchos a Muchos (N:M)** en la versión actual:

### 3.1 Relaciones en Backend (Supabase Postgrest)
En lugar de forzar un solo autor/sección en la tabla `books`, utilizamos tablas pivote con ON DELETE CASCADE (`book_authors` y `book_categories`). Postgrest, el motor detrás de Supabase, cruza eficientemente estas llaves Foráneas; permitiendo cargar todas las subramas en un solo request mediante la sintaxis:
`select('*, authors(*), categories(*)')`.

### 3.2 Implicaciones en Frontend (Modelaje en Dart)
Gracias al empaquetamiento automático de arreglos JSON de Supabase, en Flutter se eliminan los cuellos de botella por N+1 Queries. 
El `BookModel` en su constructor `.fromJson()` atrapa directamente Listas fuertemente tipificadas (`List<AuthorModel>` y `List<CategoryModel>`). Toda la lectura visual desde listados UI toma los autores y géneros desde la memoria caché provista por Provider, manteniendo el Frontend siempre rápido y reactivo sin consultas duplicadas a la DB.

### 3.3 Getters de Conveniencia (Patrón Adapter)
Para mantener **compatibilidad total** con las pantallas diseñadas por el equipo de frontend sin necesidad de reescribirlas, `BookModel` expone getters que aplanan las relaciones N:M:

```dart
String get author => authors!.map((a) => a.name).join(', ');
String get genre  => categories!.map((c) => c.name).join(', ');
String get statusLabel => /* 'read' → 'Leído', 'reading' → 'En progreso', ... */;
```

De esta forma, la UI puede seguir usando `book.author`, `book.genre` y `book.statusLabel` como si fueran propiedades simples, mientras internamente están consultando las listas normalizadas. Esto aplica el **Patrón Adapter** de forma implícita: la interfaz pública del modelo permanece simple para el consumidor (pantallas), pero su implementación interna es relacional y normalizada.

---

## 4. Estructura de Carpetas

```
lib/
├── core/
│   └── constants/
│       └── supabase_constants.dart   # URL y Anon Key de Supabase
├── models/
│   ├── author_model.dart
│   ├── book_model.dart
│   ├── category_model.dart
│   └── user_book_model.dart
├── providers/
│   ├── auth_provider.dart
│   └── book_provider.dart
├── repositories/
│   ├── auth_repository.dart
│   └── database_repository.dart
├── routes/
│   └── app_routes.dart
├── screens/
│   ├── add_book_screen.dart
│   ├── book_detail_screen.dart
│   ├── edit_book_screen.dart
│   ├── home_screen.dart
│   └── splash_screen.dart
└── main.dart
```