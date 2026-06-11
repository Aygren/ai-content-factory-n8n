# 🤖 Автономный ИИ-Контент-Завод на n8n & Supabase

[Read in English](README.md)

Полноценная production-ready система автоматизации контент-маркетинга с интеграцией ИИ-агентов (Multi-Agent System) и контуром модерации человеком (Human-in-the-loop).

Система самостоятельно ищет тренды, генерирует уникальный текстовый и графический контент, управляет стадиями публикации через базу данных и принимает правки из мессенджера.

---

## 🛠 Технологический стек
* **Оркестрация процессов:** n8n (Advanced Workflow Automation)
* **База данных и Бэкенд:** Supabase / PostgreSQL (State & Content Management)
* **Языковые модели (LLM):** GPT-4o-mini / Gemini (через OpenRouter)
* **Генерация изображений:** Replicate API (модель Imagen-3 / Flux)
* **Поиск информации:** Tavily API (ИИ-поиск в реальном времени)
* **Интерфейсы и API:** VK API, Webhooks, Callbacks

---

## 📐 Архитектура проекта (Модульная система)

Проект спроектирован по модульному принципу и разделен на 6 взаимосвязанных воркфлоу (микросервисов), которые общаются между собой через Webhooks, функции n8n (Execute Workflow) и общую базу данных Supabase:

1. **[01_CreateRow.json](workflows/01_CreateRow.json)** — Модуль инициализации. Формирует новую запись в базе данных Supabase, запускает ИИ-генерацию контента и подготавливает первичные данные.
<details>
  <summary>🔍 Посмотреть схему воркфлоу</summary>
  <br>
  <img src="images/01_create_row.png" alt="CreateRow Workflow" width="100%">
</details>

2. **[02_Edit Content.json](workflows/02_Edit%20Content.json)** — ИИ-модуль корректировки. Отвечает за обработку правок от пользователя, локальный рерайтинг текста языковой моделью и обновление контента.
<details>
  <summary>🔍 Посмотреть схему воркфлоу</summary>
  <br>
  <img src="images/02_edit_content.png" alt="Edit Content Workflow" width="100%">
</details>

3. **[03_Callbacks.json](workflows/03_Callbacks.json)** — Обработчик callback-вебхуков. Перехватывает сигналы от интерактивных кнопок интерфейса модерации и маршрутизирует процессы в зависимости от решения администратора.
<details>
  <summary>🔍 Посмотреть схему воркфлоу</summary>
  <br>
  <img src="images/03_callbacks.png" alt="Callbacks Workflow" width="100%">
</details>

4. **[04_VK button press processing.json](workflows/04_VK%20button%20press%20processing.json)** — Контур интерактивного взаимодействия с VK API. Отвечает за отправку контента на модерацию с Inline-кнопками управления и обработку нажатий в интерфейсе ВКонтакте.
<details>
  <summary>🔍 Посмотреть схему воркфлоу</summary>
  <br>
  <img src="images/04_vk_buttons.png" alt="VK button press processing Workflow" width="100%">
</details>

5. **[05_Publication.json](workflows/05_Publication.json)** — Модуль дистрибуции контента. Срабатывает автоматически при смене статуса поста на финальный и публикует готовый пакет (текст + медиафайлы) на целевую платформу.
<details>
  <summary>🔍 Посмотреть схему воркфлоу</summary>
  <br>
  <img src="images/05_publication.png" alt="Publication Workflow" width="100%">
</details>

6. **[06_Error Handler WF.json](workflows/06_Error%20Handler%20WF.json)** — Системный перехватчик ошибок. Служебный воркфлоу для логирования сбоев API, отправки алертов разработчику в VK и предотвращения зависания транзакций в БД.

---

## 📊 Структура базы данных (Supabase)
Система использует реляционную структуру для контроля состояний:
* `posts` — хранение сгенерированного текста, ссылок на медиафайлы, `batch_id` и текущего статуса (`pending`, `approved`, `editing`).
* `history_topics` — лог задействованных тем для предотвращения повторений в контенте.

---

## 🚀 Как запустить проект локально
1. Установите и запустите **n8n** (локально или в облаке).
2. Создайте проект в **Supabase**.
3. Перейдите в SQL Editor в панели Supabase и выполните скрипт инициализации таблиц из файла **[supabase/migrations.sql](supabase/migrations.sql)**.
4. Импортируйте необходимые сценарии из папки `workflows/` данного репозитория в ваш n8n.
5. Настройте переменные окружения и учетные данные (Credentials) для OpenRouter, Replicate, Tavily и VK.