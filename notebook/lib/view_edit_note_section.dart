import 'package:flutter/material.dart';
import 'note.dart';
import 'app_styles.dart';

class ViewEditNoteSection extends StatefulWidget {
  final Note note;
  final List<Note> notes;
  final Function(int, Note) editNote;
  final Function(int) deleteNote;
  final Function(Note?) setSelectedNote;

  ViewEditNoteSection({
    required this.note,
    required this.notes,
    required this.editNote,
    required this.deleteNote,
    required this.setSelectedNote,
  });

  @override
  _ViewEditNoteSectionState createState() => _ViewEditNoteSectionState();
}

class _ViewEditNoteSectionState extends State<ViewEditNoteSection> {
  late TextEditingController titleController;
  late TextEditingController tagController;
  late TextEditingController contentController;
  bool isEditing = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    tagController = TextEditingController(text: widget.note.tag);
    contentController = TextEditingController(text: widget.note.content);

    titleController.addListener(checkForChanges);
    tagController.addListener(checkForChanges);
    contentController.addListener(checkForChanges);
  }

  void checkForChanges() {
    setState(() {
      hasChanges =
          titleController.text != widget.note.title ||
          tagController.text != widget.note.tag ||
          contentController.text != widget.note.content;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    tagController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.note.title,
            style: AppTextStyles.sectionTitle,
          ),
          Divider(color: Colors.grey),
          Text(
            widget.note.tag,
            style: AppTextStyles.noteTag.copyWith(color: Colors.grey[700]),
          ),
          Divider(color: Colors.grey),
          Expanded(
            child: SingleChildScrollView(
              child: Text(widget.note.content, style: TextStyle(fontSize: 16)),
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
                    setState(() {
                      isEditing = true;
                      hasChanges = false;
                    });
                  },
                  child: Text(
                    'Редагувати',
                    style: TextStyle(color: AppColors.background),
                  ),
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
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        titleTextStyle: AppTextStyles.dialogTitle,
                        contentTextStyle: AppTextStyles.dialogContent,
                        title: Text('Видалити нотатку'),
                        content: Text(
                          'Ви впевнені, що хочете видалити цю нотатку?',
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
                                'Видалити',
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
                      widget.deleteNote(widget.notes.indexOf(widget.note));
                      widget.setSelectedNote(null);
                    }
                  },
                  child: Text(
                    'Видалити',
                    style: TextStyle(color: AppColors.background),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.background,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  onPressed: hasChanges
                      ? () {
                          final updatedNote = Note(
                            title: titleController.text,
                            tag: tagController.text,
                            content: contentController.text,
                            date: widget.note.date,
                          );
                          widget.editNote(widget.notes.indexOf(widget.note), updatedNote);
                          setState(() {
                            isEditing = false;
                            hasChanges = false;
                          });
                          widget.setSelectedNote(updatedNote);
                        }
                      : null,
                  child: Text(
                    'Зберегти',
                    style: TextStyle(color: AppColors.background),
                  ),
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
                    if (hasChanges) {
                      final confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          titleTextStyle: AppTextStyles.dialogTitle,
                          contentTextStyle: AppTextStyles.dialogContent,
                          title: Text('Скасувати зміни'),
                          content: Text(
                            'Всі внесені зміни будуть скасовані. Бажаєте їх скасувати?',
                          ),
                          actions: [
                            SizedBox(
                              width: 130,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Ні',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.background,
                                  side: BorderSide(
                                    color: AppColors.primary,
                                  ),
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
                        setState(() {
                          isEditing = false;
                          titleController.text = widget.note.title;
                          tagController.text = widget.note.tag;
                          contentController.text = widget.note.content;
                          hasChanges = false;
                        });
                      }
                    } else {
                      setState(() {
                        isEditing = false;
                        titleController.text = widget.note.title;
                        tagController.text = widget.note.tag;
                        contentController.text = widget.note.content;
                        hasChanges = false;
                      });
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
}