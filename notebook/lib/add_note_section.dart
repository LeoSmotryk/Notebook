import 'package:flutter/material.dart';
import 'note.dart';
import 'app_styles.dart';

class AddNoteSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController tagController;
  final TextEditingController contentController;
  final Function(Note) addNote;

  AddNoteSection({
    required this.titleController,
    required this.tagController,
    required this.contentController,
    required this.addNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Додати нотатку',
          style: AppTextStyles.sectionTitle,
        ),
        SizedBox(height: 16),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Назва',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: tagController,
          decoration: InputDecoration(
            hintText: 'Тег',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: TextField(
            controller: contentController,
            decoration: InputDecoration(
              hintText: 'Текст нотатки',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 130,
              child: ElevatedButton(
                onPressed: () {
                  final note = Note(
                    title: titleController.text,
                    tag: tagController.text,
                    content: contentController.text,
                    date: DateTime.now(),
                  );
                  addNote(note);
                  titleController.clear();
                  tagController.clear();
                  contentController.clear();
                },
                child: Text('Додати', style: TextStyle(color: AppColors.background)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty ||
                      tagController.text.isNotEmpty ||
                      contentController.text.isNotEmpty) {
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
                        title: Text('Скасувати додавання'),
                        content: Text(
                          'Всі незбережені дані будуть втрачені. Очистити поля?',
                        ),
                        actions: [
                          SizedBox(
                            width: 130,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Ні',
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
                                'Так',
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
                      titleController.clear();
                      tagController.clear();
                      contentController.clear();
                    }
                  }
                },
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
          ],
        ),
      ],
    );
  }
}