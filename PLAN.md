# 📋 Business Manager — План редизайна (мобильный UX/UI)

## Аудит текущего UX/UI

### Что есть сейчас
- Flutter-приложение, state management через Provider, named routes (кастомный onGenerateRoute)
- Только тёмная тема (Brightness.dark), захардкожена в ThemeData
- Нижняя навигация: 4 пункта (Home, Finance, Orders, More) + центральный FAB
- Debts и Customers спрятаны за "More" — sheet-меню, не в быстром доступе
- Формы добавления — bottom sheets (транзакции, заказы, долги, клиенты)
- График доходов/расходов через fl_chart
- Локализация RU/EN через LangProvider

### Проблемы
1. **Нет светлой темы** — только тёмная, нет переключения
2. **Навигация неудобная** — "More" открывает sheet вместо полноценного экрана, Debts и Customers за extra-tap
3. **Нет safe area** в bottom nav — контент залезает под системную панель
4. **SkeletonLoader** — бесконечная анимация (нарушает требование "без бесконечных анимаций")
5. **Нет поддержки "уменьшить движение"** (reduce motion) из системы
6. **AlertDialog для подтверждений** — неудобно на телефоне, лучше bottom sheet
7. **Нет haptic feedback** на тапах и свайпах
8. **Хардкод английского текста** в DebtCard ("Owed to me", "I owe", "Overdue", "Due")
9. **Двойная дата** в TransactionCard — дата в описании и в правой колонке одновременно
10. **withOpacity** повсюду — deprecated в новых версиях Flutter
11. **Неиспользуемые зависимости**: go_router (не используется), flutter_svg (нет SVG), cached_network_image (не используется, но нужен для фото)
12. **Лишние виджеты**: app_drawer.dart и bottom_nav.dart не используются (всё inline в MainShell)
13. **Профиль клиента** грузит данные через Service напрямую, а не через Provider — несогласованно
14. **Иконка уведомлений** в Dashboard не работает (пустой onPressed)
15. **Градиенты и тени** на splash, sheet headers, profile cards — тяжёлые для слабых устройств
16. **Нет swipe-to-delete** — удаление только через иконку, нужен жест
17. **Формы** не учитывают safe area bottom при открытой клавиатуре корректно
18. **Регистрация** — Enter не переходит на следующий инпут (нет focus traversal)

---

## Дизайн-система

### Цвета

**Светлая тема:**
| Токен | Значение | Назначение |
|-------|----------|------------|
| background | `#F7F8FA` | Фон экрана |
| surface | `#FFFFFF` | Карточки, sheets, nav bar |
| surfaceVariant | `#F0F2F5` | Поля ввода, chips невыбранные |
| primary | `#6366F1` | Бренд, активные элементы |
| primaryContainer | `#E4E5FF` | Фон активного chip, subtle accent |
| onPrimary | `#FFFFFF` | Текст/иконки на primary |
| textPrimary | `#1A1B23` | Основной текст |
| textSecondary | `#6B7280` | Вторичный текст |
| textMuted | `#9CA3AF` | Подсказки, caption |
| border | `#E5E7EB` | Границы, разделители |
| income | `#10B981` | Доходы |
| expense | `#F43F5E` | Расходы |
| warning | `#F59E0B` | Предупреждения, долги |
| danger | `#EF4444` | Ошибки, удаление |

**Тёмная тема:**
| Токен | Значение | Назначение |
|-------|----------|------------|
| background | `#0F0F14` | Фон экрана |
| surface | `#1A1A24` | Карточки, sheets, nav bar |
| surfaceVariant | `#22222F` | Поля ввода, chips невыбранные |
| primary | `#818CF8` | Бренд, активные элементы (светлее для контраста) |
| primaryContainer | `#3730A3` | Фон активного chip |
| onPrimary | `#FFFFFF` | Текст/иконки на primary |
| textPrimary | `#F1F1F3` | Основной текст |
| textSecondary | `#9CA3AF` | Вторичный текст |
| textMuted | `#6B7280` | Подсказки, caption |
| border | `#2E2E3E` | Границы, разделители |
| income | `#34D399` | Доходы |
| expense | `#FB7185` | Расходы |
| warning | `#FBBF24` | Предупреждения, долги |
| danger | `#F87171` | Ошибки, удаление |

### Типографика
Системный шрифт (SF Pro на iOS, Roboto на Android) — без подключения кастомных шрифтов.

| Стиль | Размер / Высота | Вес |
|-------|-----------------|-----|
| displayLarge | 28 / 36 | w700 |
| headlineMedium | 22 / 28 | w700 |
| titleLarge | 17 / 22 | w600 |
| bodyLarge | 15 / 22 | w400 |
| bodyMedium | 14 / 20 | w400 |
| bodySmall | 13 / 18 | w400 |
| labelMedium | 13 / 18 | w500 |
| labelSmall | 11 / 14 | w500 |

### Отступы (spacing)
| Токен | Значение |
|-------|----------|
| xs | 4 |
| sm | 8 |
| md | 12 |
| lg | 16 |
| xl | 20 |
| xxl | 24 |
| xxxl | 32 |

### Радиусы
| Токен | Значение | Назначение |
|-------|----------|------------|
| small | 8 | Маленькие элементы, pills |
| medium | 12 | Поля ввода, chips |
| large | 16 | Карточки |
| xl | 20 | Большие карточки, sheets top |
| xxl | 28 | Sheets top (rounded) |

### Размеры иконок
| Токен | Значение | Назначение |
|-------|----------|------------|
| small | 16 | Inline текст, caption |
| medium | 20 | List items, tiles |
| large | 24 | AppBar actions, buttons |
| xl | 28 | Sheet headers, FAB |

### Тап-зоны
Минимум 44×44 px для всех интерактивных элементов.

---

## Библиотеки

### Добавить
| Библиотека | Версия | Причина |
|-----------|--------|---------|
| `flutter_slidable` | `^3.1.1` | Swipe-to-delete и quick actions в списках (транзакции, заказы, долги, клиенты). Стандарт в Flutter-сообществе, ~40KB, активно поддерживается |

### Использовать существующие (правильно)
| Библиотека | Действие |
|-----------|----------|
| `cached_network_image` | Начать использовать для фото в заказах (кэш, loading/error states из коробки) вместо raw Image.network |
| `provider` | Оставить для state management + добавить ThemeProvider |
| `shared_preferences` | Сохранять выбор темы (light/dark/system) |
| `fl_chart` | Оставить для графика |
| `intl` | Оставить для форматирования |

### Убрать (не используются)
| Библиотека | Причина |
|-----------|--------|
| `go_router` | Заявлен в зависимостях, но не используется — кастомный onGenerateRoute |
| `flutter_svg` | Нет ни одного SVG-ассета в проекте |

> Примечание: `go_router` и `flutter_svg` убираем только из pubspec.yaml. Кастомный роутинг в main.dart заменяем на обновлённый, но named routes оставляем как подход (не переходим на go_router).

---

## Экраны и компоненты для редизайна

### Дизайн-система (новые файлы)
- `lib/theme/app_colors.dart` — цветовые токены для light/dark через ThemeExtension
- `lib/theme/app_spacing.dart` — константы отступов, радиусов, размеров иконок
- `lib/theme/app_theme.dart` — ThemeData light + dark, общие компоненты темы
- `lib/theme/theme_provider.dart` — переключение темы (light/dark/system) + persist

### Общие компоненты (новые/переделанные)
- `lib/components/app_button.dart` — primary / secondary / danger кнопки (44+ высота)
- `lib/components/app_card.dart` — карточка-обёртка с единым стилем
- `lib/components/app_list_item.dart` — строка списка (leading icon, title, subtitle, trailing)
- `lib/components/app_search_bar.dart` — поиск с clear button
- `lib/components/app_chip.dart` — filter chip (selected/unselected)
- `lib/components/app_sheet.dart` — bottom sheet wrapper (handle + optional header + content)
- `lib/components/app_avatar.dart` — аватар с инициалами
- `lib/components/app_skeleton.dart` — skeleton loader (уважает reduce motion — статичный, без анимации)
- `lib/components/app_empty_state.dart` — empty state
- `lib/components/app_error_state.dart` — error state с retry
- `lib/components/app_confirm_sheet.dart` — подтверждение через bottom sheet (не AlertDialog)
- `lib/components/app_status_badge.dart` — status pill для заказов/долгов
- `lib/components/app_segmented_control.dart` — segmented toggle (income/expense, owed/iOwe)
- `lib/components/app_nav_bar.dart` — нижняя навигация (5 пунктов + FAB)
- `lib/components/app_fab.dart` — FAB с tap-scale анимацией
- `lib/components/app_loading_indicator.dart` — linear/circular loading (уважает reduce motion)

### Экраны
1. **Splash** — упрощённый, без тяжёлых градиентов и теней
2. **Login** — форма, переключатель темы, лёгкий логотип
3. **Register** — форма с focus traversal (Enter → следующий инпут, последний Enter → submit)
4. **MainShell** — 4 таба в bottom nav (Home, Finance, Orders, Profile) + FAB, IndexedStack, safe area
5. **Dashboard** — stat cards, debt tiles, chart, recent transactions
6. **Transactions** — список + search + filter chips + swipe-to-delete
7. **Add/Edit Transaction** — bottom sheet форма
8. **Orders** — список + search + status filter chips + swipe-to-delete
9. **Add/Edit Order** — bottom sheet форма
10. **Order Detail** — инфо + фото (cached_network_image) + аудио + смена статуса
11. **Debts** — список с табами (owed/iOwe) + search + swipe actions
12. **Add/Edit Debt** — bottom sheet форма
13. **Customers** — список + search + swipe-to-delete
14. **Add Customer** — bottom sheet форма
15. **Customer Detail** — профиль + заказы + долги
16. **Periods** — список периодов + создание нового
17. **Profile** — карточка пользователя + секции: Долги, Клиенты, Периоды, Настройки, Тема, Язык, Logout

### Удалить (устаревшие)
- `lib/widgets/app_drawer.dart` — не используется
- `lib/widgets/bottom_nav.dart` — не используется (inline в MainShell)
- `lib/widgets/sheet_widgets.dart` — разбит на отдельные компоненты

---

## Чеклист задач

### Этап 1 — Дизайн-система и тема
- [ ] Создать `lib/theme/app_colors.dart` (цветовые токены light/dark)
- [ ] Создать `lib/theme/app_spacing.dart` (spacing, radius, icon sizes)
- [ ] Создать `lib/theme/app_theme.dart` (ThemeData light + dark)
- [ ] Создать `lib/theme/theme_provider.dart` (переключение light/dark/system, persist в SharedPreferences)
- [ ] Обновить `main.dart` — подключить ThemeProvider, MaterialApp.router / MaterialApp с theme + darkTheme
- [ ] Удалить старые константы из `lib/utils/constants.dart` (AppColors, AppTextStyles, AppDecorations) — заменить на theme tokens

### Этап 2 — Общие UI-компоненты
- [ ] `app_button.dart` — primary / secondary / danger / text кнопки
- [ ] `app_card.dart` — карточка-обёртка
- [ ] `app_list_item.dart` — строка списка с tap-target 44+
- [ ] `app_search_bar.dart` — поиск с clear
- [ ] `app_chip.dart` — filter chip
- [ ] `app_sheet.dart` — bottom sheet wrapper (handle + header + close)
- [ ] `app_avatar.dart` — аватар с инициалами
- [ ] `app_skeleton.dart` — skeleton без бесконечной анимации (уважает reduce motion)
- [ ] `app_empty_state.dart` — empty state
- [ ] `app_error_state.dart` — error state с retry
- [ ] `app_confirm_sheet.dart` — подтверждение через bottom sheet
- [ ] `app_status_badge.dart` — status pill
- [ ] `app_segmented_control.dart` — segmented toggle
- [ ] `app_nav_bar.dart` — нижняя навигация (5 пунктов + FAB)
- [ ] `app_fab.dart` — FAB с tap-scale анимацией
- [ ] `app_loading_indicator.dart` — loading indicator

### Этап 3 — Навигация и app shell
- [ ] Переделать `main_shell.dart` — 4 таба (Home, Finance, Orders, Profile), FAB зависит от активного таба
- [ ] Profile заменяет "More" — полноценный экран с карточкой пользователя и секциями (Долги, Клиенты, Периоды, Настройки)
- [ ] Bottom nav с safe area (MediaQuery.padding bottom)
- [ ] IndexedStack для сохранения состояния экранов (Dashboard, Transactions, Orders, Profile)
- [ ] FAB с tap-scale анимацией (150ms, easeOut)
- [ ] Анимация переключения табов (opacity 150ms)

### Этап 4 — Экраны авторизации
- [ ] Splash — упрощённый, без тяжёлых градиентов
- [ ] Login — чистая форма, системный шрифт, переключатель темы
- [ ] Register — форма с FocusNode traversal (Enter на username → фокус на password, Enter на password → фокус на confirmPassword, Enter на confirmPassword → submit)

### Этап 5 — Dashboard
- [ ] Stat cards (3 шт) — единый стиль через app_card
- [ ] Debt tiles (3 шт) — компактные
- [ ] Chart — fl_chart, обновить цвета под тему
- [ ] Recent transactions — через app_list_item
- [ ] Notification icon — рабочая кнопка (открытие notifications)
- [ ] Pull-to-refresh

### Этап 6 — Transactions
- [ ] Список через app_list_item + swipe-to-delete (flutter_slidable)
- [ ] Search через app_search_bar
- [ ] Filter chips через app_chip
- [ ] Add/Edit sheet через app_sheet + app_segmented_control
- [ ] Empty / error / loading states через общие компоненты
- [ ] Infinite scroll pagination
- [ ] Pull-to-refresh

### Этап 7 — Orders
- [ ] Список через app_list_item + swipe-to-delete
- [ ] Status filter chips (горизонтальный скролл)
- [ ] Search
- [ ] Add/Edit sheet
- [ ] Order detail — инфо, фото (cached_network_image), аудио, смена статуса (bottom sheet)
- [ ] Empty / error / loading states
- [ ] Pull-to-refresh

### Этап 8 — Debts
- [ ] Табы (owed to me / I owe) — TabBar
- [ ] Summary tiles вверху
- [ ] Список через app_list_item + swipe actions
- [ ] Search
- [ ] Add/Edit sheet через app_sheet + app_segmented_control
- [ ] Локализовать хардкод в DebtCard (Owed to me → t.owedToMeTab и т.д.)
- [ ] Empty / error / loading states
- [ ] Pull-to-refresh

### Этап 9 — Customers
- [ ] Список через app_list_item + swipe-to-delete
- [ ] Search
- [ ] Add sheet
- [ ] Customer detail — профиль, заказы, долги (через Provider, не Service напрямую)
- [ ] Empty / error / loading states
- [ ] Pull-to-refresh

### Этап 10 — Profile (вместо Settings)
- [ ] Profile экран — карточка пользователя (аватар, имя, активный период)
- [ ] Секции: Долги, Клиенты, Периоды — навигация на соответствующие экраны
- [ ] Переключатель темы (light/dark/system) — segmented control
- [ ] Переключатель языка (RU/EN)
- [ ] About (версия, стек)
- [ ] Logout через app_confirm_sheet
- [ ] Periods — список + создание нового (bottom sheet)

### Этап 11 — Полировка и cleanup
- [ ] Удалить неиспользуемые виджеты: `app_drawer.dart`, `bottom_nav.dart`, `sheet_widgets.dart`
- [ ] Удалить `go_router` и `flutter_svg` из pubspec.yaml
- [ ] Добавить `cached_network_image` в order_detail (заменить Image.network)
- [ ] Проверить все withOpacity → withValues(alpha:) где нужно
- [ ] Проверить safe area на всех экранах (top + bottom)
- [ ] Проверить контраст текста в обеих темах
- [ ] Проверить размеры тап-зон (минимум 44×44)
- [ ] Убедиться, что все анимации уважают reduce motion
- [ ] Убедиться, что нет бесконечных анимаций (кроме loading spinner)
- [ ] Локализовать весь хардкод
- [ ] Подчистить dead code: неиспользуемые импорты, закомментированный код, legacy алиасы в constants.dart

### Этап 12 — Проверка
- [ ] flutter analyze — 0 errors
- [ ] flutter build apk — без ошибок
- [ ] Проверить light theme на всех экранах
- [ ] Проверить dark theme на всех экранах
- [ ] Проверить переключение темы
- [ ] Проверить навигацию (все 5 табов + FAB)
- [ ] Проверить формы (keyboard, safe area, focus traversal)
- [ ] Обновить plan.md — отметить выполненные задачи

---

## Анимации — правила

- **Длительность**: 150–300 мс
- **Easing**: `Curves.easeOut` для появлений, `Curves.easeInOut` для переключений
- **Свойства**: только `transform` (scale, translate) и `opacity`
- **Без**: blur, сложных теней в движении, градиентов в движении
- **Reduce motion**: проверка `MediaQuery.accessibleNavigation` / `WidgetsBinding.instance.disableAnimations` — отключаем все анимации, оставляем мгновенные переходы
- **Transition между экранами**: fade 200ms (есть в main.dart, оставить)
- **Tap feedback**: scale 0.96 → 1.0, 150ms, easeOut (на FAB, кнопках, карточках)
- **Sheet appearance**: встроенный showModalBottomSheet (системная анимация)
- **Skeleton**: статичная заливка без анимации (если reduce motion включён)

---

## Принципы работы

- Не ломать существующую логику и данные — только UI/UX
- Переиспользовать компоненты, не дублировать код
- После каждого этапа проверять сборку (`flutter analyze`)
- Тестировать в обеих темах
- Все новые тексты добавлять в l10n.dart (RU + EN)
