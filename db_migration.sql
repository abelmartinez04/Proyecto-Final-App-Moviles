-- 1. Crear nueva tabla de Autores
CREATE TABLE authors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE
);

-- 2. Crear tabla intermedia para Libros <-> Autores
CREATE TABLE book_authors (
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  author_id UUID REFERENCES authors(id) ON DELETE CASCADE,
  PRIMARY KEY (book_id, author_id)
);

-- 3. Crear tabla intermedia para Libros <-> Categorías
CREATE TABLE book_categories (
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (book_id, category_id)
);

-- 4. Normalizar la tabla books
-- Nota: En un sistema de producción primero migraríamos los datos existentes, 
-- pero al ser un proyecto local en etapas iniciales simplemente podemos dropear las columnas.
ALTER TABLE books
  DROP COLUMN author,
  DROP COLUMN category_id;

-- 5. Configurar RLS (Row Level Security) para las nuevas tablas
ALTER TABLE authors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authors are viewable by everyone" ON authors FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert authors" ON authors FOR INSERT TO authenticated WITH CHECK (true);

ALTER TABLE book_authors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Book authors are viewable by everyone" ON book_authors FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage book_authors" ON book_authors FOR ALL TO authenticated USING (true);

ALTER TABLE book_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Book categories are viewable by everyone" ON book_categories FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage book_categories" ON book_categories FOR ALL TO authenticated USING (true);
