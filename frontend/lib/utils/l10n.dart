import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Простая локализация без генерации кода
class L10n {
  final String lang; // 'ru' или 'en'
  const L10n(this.lang);

  bool get isRu => lang == 'ru';

  // ── Общее ─────────────────────────────────────────────────────────────────
  String get cancel     => isRu ? 'Отмена'    : 'Cancel';
  String get save       => isRu ? 'Сохранить' : 'Save';
  String get delete     => isRu ? 'Удалить'   : 'Delete';
  String get edit       => isRu ? 'Изменить'  : 'Edit';
  String get add        => isRu ? 'Добавить'  : 'Add';
  String get create     => isRu ? 'Создать'   : 'Create';
  String get retry      => isRu ? 'Повторить' : 'Retry';
  String get seeAll     => isRu ? 'Все'       : 'See all';
  String get loading    => isRu ? 'Загрузка...' : 'Loading...';
  String get error      => isRu ? 'Что-то пошло не так' : 'Something went wrong';
  String get noData     => isRu ? 'Нет данных' : 'No data';
  String get logout     => isRu ? 'Выйти'     : 'Logout';
  String get logoutConfirm => isRu ? 'Вы уверены что хотите выйти?' : 'Are you sure you want to logout?';
  String get optional   => isRu ? 'необязательно' : 'optional';

  // ── Навигация ─────────────────────────────────────────────────────────────
  String get home         => isRu ? 'Главная'    : 'Home';
  String get finance      => isRu ? 'Финансы'    : 'Finance';
  String get orders       => isRu ? 'Заказы'     : 'Orders';
  String get more         => isRu ? 'Ещё'        : 'More';
  String get debts        => isRu ? 'Долги'      : 'Debts';
  String get customers    => isRu ? 'Клиенты'    : 'Customers';
  String get periods      => isRu ? 'Периоды'    : 'Periods';
  String get settings     => isRu ? 'Настройки'  : 'Settings';
  String get profile      => isRu ? 'Профиль'    : 'Profile';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  String get overview       => isRu ? 'Обзор'         : 'Overview';
  String get income         => isRu ? 'Доходы'        : 'Income';
  String get expense        => isRu ? 'Расходы'       : 'Expenses';
  String get profit         => isRu ? 'Прибыль'       : 'Profit';
  String get owedToMe       => isRu ? 'Должны мне'    : 'Owed to me';
  String get iOwe           => isRu ? 'Я должен'      : 'I owe';
  String get activeOrders   => isRu ? 'Заказы'        : 'Orders';
  String get recent         => isRu ? 'Последние'     : 'Recent';
  String get sixMonths      => isRu ? '6 месяцев'     : '6 months';
  String get incomeVsExpense => isRu ? 'Доходы и расходы' : 'Income vs Expenses';

  // ── Auth ──────────────────────────────────────────────────────────────────
  String get signIn         => isRu ? 'Войти'         : 'Sign In';
  String get signInSub      => isRu ? 'Войдите в аккаунт' : 'Sign in to your account';
  String get register       => isRu ? 'Регистрация'   : 'Create Account';
  String get registerSub    => isRu ? 'Создайте бизнес профиль' : 'Set up your business profile';
  String get username       => isRu ? 'Имя пользователя' : 'Username';
  String get password       => isRu ? 'Пароль'        : 'Password';
  String get confirmPassword => isRu ? 'Подтвердите пароль' : 'Confirm Password';
  String get noAccount      => isRu ? 'Нет аккаунта? ' : "Don't have an account? ";
  String get hasAccount     => isRu ? 'Уже есть аккаунт? ' : 'Already have an account? ';
  String get passwordMismatch => isRu ? 'Пароли не совпадают' : 'Passwords do not match';

  // ── Транзакции ────────────────────────────────────────────────────────────
  String get addTransaction   => isRu ? 'Добавить транзакцию' : 'Add Transaction';
  String get editTransaction  => isRu ? 'Изменить транзакцию' : 'Edit Transaction';
  String get transactions     => isRu ? 'Транзакции'      : 'Transactions';
  String get amount           => isRu ? 'Сумма'           : 'Amount';
  String get category         => isRu ? 'Категория'       : 'Category';
  String get description      => isRu ? 'Описание'        : 'Description';
  String get date             => isRu ? 'Дата'            : 'Date';
  String get noTransactions   => isRu ? 'Нет транзакций'  : 'No transactions yet';
  String get noTransactionsSub => isRu ? 'Добавьте первый доход или расход' : 'Add your first income or expense';
  String get searchTransactions => isRu ? 'Поиск транзакций...' : 'Search transactions...';
  String get deleteTransaction  => isRu ? 'Удалить транзакцию' : 'Delete Transaction';
  String get deleteTransactionConfirm => isRu ? 'Транзакция будет удалена безвозвратно.' : 'This transaction will be permanently deleted.';

  // ── Заказы ────────────────────────────────────────────────────────────────
  String get addOrder         => isRu ? 'Новый заказ'     : 'New Order';
  String get editOrder        => isRu ? 'Изменить заказ'  : 'Edit Order';
  String get orderTitle       => isRu ? 'Название заказа' : 'Order Title';
  String get clientName       => isRu ? 'Имя клиента'     : 'Client Name';
  String get clientPhone      => isRu ? 'Телефон клиента' : 'Client Phone';
  String get deadline         => isRu ? 'Дедлайн'         : 'Deadline';
  String get noDeadline       => isRu ? 'Без дедлайна'    : 'No deadline';
  String get noOrders         => isRu ? 'Нет заказов'     : 'No orders yet';
  String get noOrdersSub      => isRu ? 'Добавьте первый заказ' : 'Add your first order';
  String get searchOrders     => isRu ? 'Поиск заказов...' : 'Search orders...';
  String get deleteOrder      => isRu ? 'Удалить заказ'   : 'Delete Order';
  String get deleteOrderConfirm => isRu ? 'Заказ и все его файлы будут удалены.' : 'This will permanently delete the order.';
  String get createOrder      => isRu ? 'Создать заказ'   : 'Create Order';
  String get status           => isRu ? 'Статус'          : 'Status';
  String get statusNew        => isRu ? 'Новый'           : 'New';
  String get statusInProgress => isRu ? 'В работе'        : 'In Progress';
  String get statusWaiting    => isRu ? 'Ожидание'        : 'Waiting';
  String get statusCompleted  => isRu ? 'Выполнен'        : 'Completed';
  String get statusCancelled  => isRu ? 'Отменён'         : 'Cancelled';

  // ── Долги ─────────────────────────────────────────────────────────────────
  String get addDebt          => isRu ? 'Добавить долг'   : 'Add Debt';
  String get editDebt         => isRu ? 'Изменить долг'   : 'Edit Debt';
  String get owedToMeTab      => isRu ? 'Мне должны'      : 'Owed to Me';
  String get iOweTab          => isRu ? 'Я должен'        : 'I Owe';
  String get personCompany    => isRu ? 'Человек / Компания' : 'Person / Company';
  String get totalAmount      => isRu ? 'Общая сумма'     : 'Total Amount';
  String get paidAmount       => isRu ? 'Оплачено'        : 'Paid Amount';
  String get dueDate          => isRu ? 'Срок'            : 'Due Date';
  String get noDueDate        => isRu ? 'Без срока'       : 'No due date';
  String get noDebts          => isRu ? 'Нет долгов'      : 'No debts here';
  String get noDebtsSub       => isRu ? 'Отслеживайте долги' : 'Track money you owe or are owed';
  String get deleteDebt       => isRu ? 'Удалить долг'    : 'Delete Debt';
  String get deleteDebtConfirm => isRu ? 'Запись о долге будет удалена.' : 'This debt record will be permanently deleted.';
  String get statusUnpaid     => isRu ? 'Не оплачен'      : 'Unpaid';
  String get statusPartial    => isRu ? 'Частично'        : 'Partial';
  String get statusPaid       => isRu ? 'Оплачен'         : 'Paid';
  String get overdue          => isRu ? 'Просрочен'       : 'Overdue';
  String get dueSoon          => isRu ? 'Скоро срок'      : 'Due soon';
  String get totalOwedToMe    => isRu ? 'Всего должны мне': 'Total owed to me';
  String get totalIOwe        => isRu ? 'Всего я должен'  : 'Total I owe';

  // ── Клиенты ───────────────────────────────────────────────────────────────
  String get addCustomer      => isRu ? 'Новый клиент'    : 'New Customer';
  String get name             => isRu ? 'Имя'             : 'Name';
  String get phone            => isRu ? 'Телефон'         : 'Phone';
  String get notes            => isRu ? 'Заметки'         : 'Notes';
  String get noCustomers      => isRu ? 'Нет клиентов'    : 'No customers yet';
  String get noCustomersSub   => isRu ? 'Добавьте первого клиента' : 'Add your first customer';
  String get searchCustomers  => isRu ? 'Поиск по имени или телефону...' : 'Search by name or phone...';
  String get recentOrdersCust => isRu ? 'Последние заказы' : 'Recent Orders';
  String get deleteCustomer   => isRu ? 'Удалить клиента' : 'Delete Customer';
  String get deleteCustomerConfirm => isRu ? 'Клиент будет удалён безвозвратно.' : 'This will permanently delete the customer.';

  // ── Периоды ───────────────────────────────────────────────────────────────
  String get businessPeriods  => isRu ? 'Бизнес периоды'  : 'Business Periods';
  String get newPeriod        => isRu ? 'Новый период'     : 'New Period';
  String get newPeriodSub     => isRu ? 'Это закроет текущий период и начнёт новый.' : 'This will close the current period and start a new one.';
  String get periodName       => isRu ? 'Название периода' : 'Period Name';
  String get periodNameHint   => isRu ? 'напр. Q4 2026'   : 'e.g. Q4 2026';
  String get active           => isRu ? 'Активный'        : 'Active';
  String get closed           => isRu ? 'Закрыт'          : 'Closed';
  String get started          => isRu ? 'Начат'           : 'Started';
  String get ended            => isRu ? 'Завершён'        : 'Ended';

  // ── Профиль / Настройки ───────────────────────────────────────────────────
  String get language         => isRu ? 'Язык'            : 'Language';
  String get currentPeriod    => isRu ? 'Текущий период'  : 'Current Period';
  String get managePeriods    => isRu ? 'Управление периодами' : 'Manage Periods';
  String get managePeriodsDesc => isRu ? 'История, новый период' : 'View history, create new period';
  String get about            => isRu ? 'О приложении'    : 'About';
  String get version          => isRu ? 'Версия'          : 'Version';
  String get quickAdd         => isRu ? 'Быстрое добавление' : 'Quick Add';

  // ── Валидация ─────────────────────────────────────────────────────────────
  String required(String field) => isRu ? '$field обязательно' : '$field is required';
  String minLength(String field, int n) => isRu
      ? '$field минимум $n символов'
      : '$field must be at least $n characters';
  String get invalidNumber    => isRu ? 'Введите корректное число' : 'Enter a valid number';
  String get mustBePositive   => isRu ? 'Сумма должна быть больше 0' : 'Amount must be greater than 0';
  String get selectCategory   => isRu ? 'Выберите категорию' : 'Select a category';

  // ── Дедлайны / даты ───────────────────────────────────────────────────────
  String get dueToday       => isRu ? 'Срок сегодня'   : 'Due today';
  String get dueTomorrow    => isRu ? 'Срок завтра'    : 'Due tomorrow';
  String dueInDays(int d)   => isRu ? 'Через $d дн.'  : 'Due in ${d}d';
  String daysOverdue(int d) => isRu ? 'Просрочен $d дн.' : '${d}d overdue';
  String get today          => isRu ? 'Сегодня'        : 'Today';
  String get yesterday      => isRu ? 'Вчера'          : 'Yesterday';
  String daysAgo(int d)     => isRu ? '$d дней назад'  : '$d days ago';
  String get photo          => isRu ? 'Фото'           : 'Photos';
  String get voiceNote      => isRu ? 'Голосовая заметка' : 'Voice Note';
  String get noPhotos       => isRu ? 'Нет фото'       : 'No photos';
  String get noRecording    => isRu ? 'Нет записи'     : 'No recording';
  String get deletePhoto    => isRu ? 'Удалить фото'   : 'Delete Photo';
  String get deletePhotoConfirm => isRu ? 'Удалить это фото из заказа?' : 'Remove this photo from the order?';
  String get deleteRecording => isRu ? 'Удалить запись' : 'Delete Recording';
  String get deleteRecordingConfirm => isRu ? 'Удалить голосовую заметку из заказа?' : 'Remove the voice note from this order?';
  String get changeStatus   => isRu ? 'Изменить статус' : 'Change Status';
  String get created        => isRu ? 'Создан'          : 'Created';
  String get client         => isRu ? 'Клиент'          : 'Client';

  // ── Уведомления ───────────────────────────────────────────────────────────
  String get notifications  => isRu ? 'Уведомления'    : 'Notifications';
  String get markAllRead    => isRu ? 'Отметить все'   : 'Mark all read';

  // ── Тема ──────────────────────────────────────────────────────────────────
  String get themeLight   => isRu ? 'Светлая'  : 'Light';
  String get themeDark    => isRu ? 'Тёмная'   : 'Dark';
  String get themeSystem  => isRu ? 'Системная' : 'System';
  String get appearance    => isRu ? 'Оформление' : 'Appearance';

  // ── Профиль-экран секции ──────────────────────────────────────────────────
  String get sections     => isRu ? 'Разделы'     : 'Sections';
  String get stack        => isRu ? 'Технологии'  : 'Stack';
}

// ─── Provider ─────────────────────────────────────────────────────────────────
class LangProvider extends ChangeNotifier {
  static const _key = 'app_lang';
  String _lang = 'ru'; // Russian by default

  String get lang => _lang;
  L10n get t => L10n(_lang);
  Locale get locale => Locale(_lang);

  LangProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString(_key) ?? 'ru';
    notifyListeners();
  }

  Future<void> setLang(String lang) async {
    _lang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang);
    notifyListeners();
  }
}
