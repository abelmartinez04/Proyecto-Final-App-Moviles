-- Migración: Añadir columna book_url a la tabla books
-- Ejecuta este script en el SQL Editor de Supabase

ALTER TABLE books
ADD COLUMN IF NOT EXISTS book_url TEXT;
