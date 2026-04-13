# Walkthrough: CRUD Completo + Compatibilidad Web

## Resumen

Esta serie de cambios completa la integración CRUD del backend Supabase con las pantallas de Flutter, corrige errores críticos de compatibilidad con la plataforma web, y fusiona los cambios del equipo frontend.

---

## Cambios Realizados

### 1. Merge de `origin/main` → `feature/backend-supabase`
Se integraron los cambios del PR #3 (`feature/screens`) que agregaron:
- Barra de búsqueda con filtro por título, autor y género
- UI mejorada con sombras, portadas y placeholder de imagen
- Botón eliminar (demo) en HomeScreen
- Campos `bookUrl` y `coverUrl` en formularios
- Dependencias `image_picker` y `url_launcher`
- Splash screen rediseñado
- `BookDetailScreen` con imagen grande y botón "Abrir libro"

### 2. CRUD Completo — Repositorio y Provider

**`database_repository.dart`:**
- `updateBook()` — Actualiza título, autor (re-vinculación pivote), categoría, portada, bookUrl y status
- `deleteBook()` — Elimina libro con CASCADE automático en tablas pivote

**`book_provider.dart`:**
- `updateBook()` — Delega al repo y actualiza `_publicBooks` reactivamente
- `deleteBook()` — Delega al repo y elimina de `_publicBooks` + `_filteredBooks`

### 3. Conexión UI → Backend

**`edit_book_screen.dart`:**
- Botón "Guardar cambios" ahora persiste a Supabase vía `provider.updateBook()`
- Sube imagen nueva si es seleccionada, conserva la anterior si no
- SnackBar de confirmación "Libro actualizado ✅"

**`home_screen.dart`:**
- Botón Eliminar conectado a `provider.deleteBook()` real (ya no es demo)
- SnackBar de confirmación "Libro eliminado 🗑️"

### 4. Fix: Compatibilidad Web (`dart:io` → `Uint8List`)

**Problema:** `dart:io File` no existe en la plataforma web, causando `Unsupported operation: _Namespace`.

**Solución:** Reemplazo de `File` por `Uint8List` (bytes universales) en toda la cadena:

| Capa | Antes | Después |
|---|---|---|
| `database_repository` | `upload(fileName, File)` | `uploadBinary(fileName, Uint8List)` |
| `book_provider` | `uploadImage(File)` | `uploadImage(Uint8List, String)` |
| `add_book_screen` | `File? + FileImage` | `XFile? + Uint8List? + MemoryImage` |
| `edit_book_screen` | `File? + FileImage` | `XFile? + Uint8List? + MemoryImage` |

### 5. Configuración Supabase Requerida

Los siguientes scripts SQL deben ejecutarse en el SQL Editor de Supabase:

**Migración `book_url`:**
```sql
ALTER TABLE books ADD COLUMN IF NOT EXISTS book_url TEXT;
```

**Políticas RLS (desarrollo):**
```sql
CREATE POLICY "allow_insert_books" ON books FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_update_books" ON books FOR UPDATE USING (true);
CREATE POLICY "allow_delete_books" ON books FOR DELETE USING (true);
CREATE POLICY "allow_insert_book_authors" ON book_authors FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_delete_book_authors" ON book_authors FOR DELETE USING (true);
CREATE POLICY "allow_insert_book_categories" ON book_categories FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_delete_book_categories" ON book_categories FOR DELETE USING (true);
CREATE POLICY "allow_insert_authors" ON authors FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_update_authors" ON authors FOR UPDATE USING (true);
CREATE POLICY "allow_insert_categories" ON categories FOR INSERT WITH CHECK (true);
CREATE POLICY "allow_update_categories" ON categories FOR UPDATE USING (true);
```

**Bucket de Storage:**
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('book-covers', 'book-covers', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "allow_upload_book_covers"
ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'book-covers');

CREATE POLICY "allow_read_book_covers"
ON storage.objects FOR SELECT USING (bucket_id = 'book-covers');
```

---

## Validación

- `flutter analyze` → **No issues found!**
- Agregar libro ✅
- Editar libro ✅
- Eliminar libro ✅
- Búsqueda por título/autor/género ✅
- Subida de imagen de portada ✅ (web y móvil)
