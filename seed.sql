DO $$ 
DECLARE 
  cat_ficcion UUID;
  cat_ciencia UUID;
  cat_desarrollo UUID;
  cat_fantasia UUID;

  auth_antoine UUID;
  auth_isaac UUID;
  auth_james UUID;
  auth_brandon UUID;

  book_1 UUID;
  book_2 UUID;
  book_3 UUID;
  book_4 UUID;
BEGIN
  -- Insertar Categorías y guardar sus IDs
  INSERT INTO categories (name) VALUES ('Ficción') RETURNING id INTO cat_ficcion;
  INSERT INTO categories (name) VALUES ('Ciencia Ficción') RETURNING id INTO cat_ciencia;
  INSERT INTO categories (name) VALUES ('Desarrollo Personal') RETURNING id INTO cat_desarrollo;
  INSERT INTO categories (name) VALUES ('Fantasía Épica') RETURNING id INTO cat_fantasia;

  -- Insertar Autores y guardar sus IDs
  INSERT INTO authors (name) VALUES ('Antoine de Saint-Exupéry') RETURNING id INTO auth_antoine;
  INSERT INTO authors (name) VALUES ('Isaac Asimov') RETURNING id INTO auth_isaac;
  INSERT INTO authors (name) VALUES ('James Clear') RETURNING id INTO auth_james;
  INSERT INTO authors (name) VALUES ('Brandon Sanderson') RETURNING id INTO auth_brandon;

  -- Insertar Libros y guardar sus IDs (usando fotos dummy de Picsum para las portadas)
  INSERT INTO books (title, description, cover_url) VALUES 
  ('El Principito', 'Una historia clásica y poética sobre un pequeño príncipe.', 'https://picsum.photos/seed/principito/200/300') RETURNING id INTO book_1;
  
  INSERT INTO books (title, description, cover_url) VALUES 
  ('Fundación', 'El primer libro de la épica e icónica saga de ciencia ficción.', 'https://picsum.photos/seed/fundacion/200/300') RETURNING id INTO book_2;
  
  INSERT INTO books (title, description, cover_url) VALUES 
  ('Hábitos Atómicos', 'Un método comprobado para desarrollar buenos hábitos y eliminar malos.', 'https://picsum.photos/seed/habitos/200/300') RETURNING id INTO book_3;

  INSERT INTO books (title, description, cover_url) VALUES 
  ('El Imperio Final', 'Primer libro de la saga literaria Nacidos de la Bruma (Mistborn).', 'https://picsum.photos/seed/mistborn/200/300') RETURNING id INTO book_4;

  -- Asociar Libros con sus Categorías en la tabla pivote
  INSERT INTO book_categories (book_id, category_id) VALUES (book_1, cat_ficcion);
  INSERT INTO book_categories (book_id, category_id) VALUES (book_2, cat_ciencia);
  INSERT INTO book_categories (book_id, category_id) VALUES (book_3, cat_desarrollo);
  INSERT INTO book_categories (book_id, category_id) VALUES (book_4, cat_fantasia);

  -- Asociar Libros con Autores en la tabla pivote
  INSERT INTO book_authors (book_id, author_id) VALUES (book_1, auth_antoine);
  INSERT INTO book_authors (book_id, author_id) VALUES (book_2, auth_isaac);
  INSERT INTO book_authors (book_id, author_id) VALUES (book_3, auth_james);
  INSERT INTO book_authors (book_id, author_id) VALUES (book_4, auth_brandon);

END $$;
