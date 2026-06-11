-- ==========================================
-- Скрипт инициализации базы данных (Supabase)
-- Проект: Автономный ИИ-Контент-Завод
-- ==========================================

-- 1. ТАБЛИЦА: История запросов (тем)
CREATE TABLE IF NOT EXISTS public.content_history (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    query text NOT NULL,                 -- Сам поисковый запрос (тема)
    created_at timestamptz DEFAULT now() -- Дата создания (автоматически)
);

-- Индекс для быстрого поиска по теме
CREATE INDEX IF NOT EXISTS idx_content_history_query ON public.content_history (query);


-- 2. ТАБЛИЦА: Публикации (посты)
CREATE TABLE IF NOT EXISTS public.posts (
    id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    content text NOT NULL,               -- Сгенерированный ИИ-текст поста
    status text DEFAULT 'pending',       -- Статусы: pending, published, editing
    metadata jsonb,                      -- Данные об ИИ-модели, промптах или эмбеддингах
    type text,                           -- Тип контента/платформы
    batch_id text,                       -- Уникальный ID пакета генерации
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Индексы для оптимизации очередей и фильтрации
CREATE INDEX IF NOT EXISTS idx_posts_status ON public.posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_type ON public.posts(type);


-- 3. ПРЕДСТАВЛЕНИЯ (VIEWS)
-- Виртуальный "вид" с автоматической сортировкой истории от свежих к старым
CREATE OR REPLACE VIEW public.latest_content_history AS
SELECT * FROM public.content_history
ORDER BY created_at DESC;