import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'note.dart';
import 'add_note_section.dart';
import 'view_edit_note_section.dart';
import 'settings_page.dart';
import 'app_styles.dart';

class NotesHomePage extends StatefulWidget {
  NotesHomePage();

  @override
  _NotesHomePageState createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  List<Note> notes = [];
  String searchQuery = '';
  DateTime? selectedDate;
  Note? selectedNote;
  late TextEditingController titleController;
  late TextEditingController tagController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    loadNotes();
    titleController = TextEditingController();
    tagController = TextEditingController();
    contentController = TextEditingController();
  }

  Future<File> getNotesFile() async {
    final projectDir = Directory.current.path;
    return File('$projectDir/notes.json');
  }

  Future<void> loadNotes() async {
    final file = await getNotesFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List decoded = json.decode(contents);
      setState(() {
        notes = decoded.map((e) => Note.fromJson(e)).toList();
      });
    } else {
      await file.writeAsString(json.encode([]));
      setState(() {
        notes = [];
      });
    }
  }

  Future<void> saveNotes() async {
    final file = await getNotesFile();
    await file.writeAsString(json.encode(notes));
  }

  Future<void> resetApp() async {
    final file = await getNotesFile();
    if (await file.exists()) {
      await file.delete();
    }
    setState(() {
      notes = [];
      selectedDate = null;
      searchQuery = '';
    });
  }

  void addNote(Note note) {
    setState(() {
      notes.add(note);
      saveNotes();
    });
  }

  void editNote(int index, Note newNote) {
    setState(() {
      notes[index] = newNote;
      saveNotes();
    });
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      saveNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes =
        notes.where((note) {
          final matchesSearchQuery =
              note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              note.tag.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesSelectedDate =
              selectedDate == null ||
              note.date.toLocal().toString().split(" ")[0] ==
                  selectedDate!.toLocal().toString().split(" ")[0];
          return matchesSearchQuery && matchesSelectedDate;
        }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: AppDecorations.borderBottom,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Електронний записник', style: AppTextStyles.appBarTitle),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: AppColors.primary),
                tooltip: 'Налаштування',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(resetApp: resetApp),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      selectedNote = null;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Container(
                  color: AppColors.background,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Пошук за назвою або тегом...',
                                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          IconButton(
                            icon: Icon(Icons.calendar_today, color: AppColors.primary),
                            tooltip: 'Вибрати дату',
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: AppColors.background,
                                        onSurface: AppColors.primary,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                          ),
                          if (selectedDate != null)
                            IconButton(
                              icon: Icon(Icons.clear, color: AppColors.primary),
                              tooltip: 'Очистити вибір дати',
                              onPressed: () {
                                setState(() {
                                  selectedDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (selectedDate != null)
                        Text(
                          'Вибрана дата: ${selectedDate!.toLocal().toString().split(" ")[0]}',
                          style: AppTextStyles.sectionTitle,
                        ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: AppColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              elevation: 0,
                              child: ListTile(
                                title: Text(note.title, style: AppTextStyles.sectionTitle),
                                subtitle: Text(
                                  '${note.tag} | ${note.date.toLocal().toString().split(" ")[0]}',
                                  style: AppTextStyles.noteTag,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedNote = note;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    onPressed: () {
                      setState(() {
                        selectedNote = null;
                      });
                    },
                    tooltip: 'Додати нотатку',
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: AppDecorations.borderLeft,
              child:
                  selectedNote == null
                      ? AddNoteSection(
                          titleController: titleController,
                          tagController: tagController,
                          contentController: contentController,
                          addNote: addNote,
                        )
                      : ViewEditNoteSection(
                          note: selectedNote!,
                          notes: notes,
                          editNote: editNote,
                          deleteNote: deleteNote,
                          setSelectedNote: (n) => setState(() => selectedNote = n),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    tagController.dispose();
    contentController.dispose();
    super.dispose();
  }
}