import 'package:flutter/material.dart';
import 'app_styles.dart';

class SettingsPage extends StatelessWidget {
  final Future<void> Function() resetApp;

  SettingsPage({required this.resetApp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: AppDecorations.borderBottom,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Налаштування', style: AppTextStyles.appBarTitle),
            iconTheme: IconThemeData(color: AppColors.primary),
            titleTextStyle: AppTextStyles.appBarTitle,
          ),
        ),
      ),
      body: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Скинути додаток', style: AppTextStyles.sectionTitle),
                subtitle: Text('Видалити всі нотатки та налаштування'),
                trailing: Icon(Icons.restore, color: AppColors.primary),
                onTap: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      titleTextStyle: AppTextStyles.dialogTitle,
                      contentTextStyle: AppTextStyles.dialogContent,
                      title: Text('Скинути додаток'),
                      content: Text(
                        'Ви впевнені, що хочете скинути додаток?',
                      ),
                      actions: [
                        SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Скасувати',
                              style: TextStyle(color: AppColors.primary),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.background,
                              side: BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'Скинути',
                              style: TextStyle(color: AppColors.background),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await resetApp();
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Довідка', style: AppTextStyles.sectionTitle),
                subtitle: Text('Дізнайтеся більше про додаток'),
                trailing: Icon(Icons.help, color: AppColors.primary),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      title: Text(
                        'Довідка',
                        style: AppTextStyles.dialogTitle,
                      ),
                      content: SingleChildScrollView(
                        child: Text(
                          '''
Електронний записник — це додаток для збереження, перегляду, редагування та видалення ваших нотаток.

Інструкція з використання:

• Додавання нотатки:  
  Натисніть кнопку "+" або відкрийте праву панель, заповніть поля "Назва", "Тег", "Текст нотатки" та натисніть "Додати".

• Перегляд нотатки:  
  Виберіть нотатку зі списку ліворуч — її зміст зʼявиться у правій панелі.

• Редагування нотатки:  
  Відкрийте потрібну нотатку, натисніть "Редагувати", внесіть зміни та натисніть "Зберегти".

• Видалення нотатки:  
  Відкрийте нотатку, натисніть "Видалити" та підтвердьте дію.

• Пошук:  
  Введіть текст у полі пошуку — список нотаток автоматично відфільтрується.

• Фільтр за датою:  
  Натисніть іконку календаря, оберіть дату — відобразяться нотатки лише за цю дату. Щоб скинути фільтр, натисніть іконку "очистити".

• Скидання додатку:  
  У меню "Налаштування" натисніть "Скинути додаток", щоб видалити всі нотатки та повернути налаштування за замовчуванням.

Зберігайте свої ідеї та важливу інформацію зручно!
                          ''',
                          style: AppTextStyles.dialogContent,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Закрити',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}