import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notebook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.indigo),
          titleTextStyle: TextStyle(
            color: Colors.indigo,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.indigo,
          selectionColor: Colors.indigo.withOpacity(0.3),
          selectionHandleColor: Colors.indigo,
        ),
      ),
      home: NotesHomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('uk', ''),
      ],
    );
  }
}

class Note {
  String title;
  String tag;
  String content;
  DateTime date;

  Note(
      {required this.title,
      required this.tag,
      required this.content,
      required this.date});

  Map<String, dynamic> toJson() => {
        'title': title,
        'tag': tag,
        'content': content,
        'date': date.toIso8601String(),
      };

  static Note fromJson(Map<String, dynamic> json) => Note(
        title: json['title'],
        tag: json['tag'],
        content: json['content'],
        date: DateTime.parse(json['date']),
      );
}

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
    final filteredNotes = notes.where((note) {
      final matchesSearchQuery =
          note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              note.tag.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesSelectedDate = selectedDate == null ||
          note.date.toLocal().toString().split(" ")[0] ==
              selectedDate!.toLocal().toString().split(" ")[0];
      return matchesSearchQuery && matchesSelectedDate;
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.indigo, width: 2),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Електронний записник'),
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                tooltip: 'Налаштування',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(
                        resetApp: resetApp,
                      ),
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
                  color: Colors.white,
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
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
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
                                        primary: Colors.indigo,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.indigo,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.indigo,
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
                              icon: Icon(Icons.clear),
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side:
                                    BorderSide(color: Colors.indigo, width: 2),
                              ),
                              elevation: 0,
                              child: ListTile(
                                title: Text(note.title),
                                subtitle: Text(
                                    '${note.tag} | ${note.date.toLocal().toString().split(" ")[0]}'),
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
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
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
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Colors.indigo, width: 2),
                ),
              ),
              child: selectedNote == null
                  ? _buildAddNoteSection(context)
                  : _buildViewOrEditNoteSection(context, selectedNote!),
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

  Widget _buildAddNoteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Додати нотатку',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                child: Text('Додати', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
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
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.indigo, width: 2),
                        ),
                        titleTextStyle: TextStyle(
                          color: Colors.indigo,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        contentTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        title: Text('Скасувати додавання'),
                        content: Text(
                            'Всі незбережені дані будуть втрачені. Очистити поля?'),
                        actions: [
                          SizedBox(
                            width: 130,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Ні',
                                  style: TextStyle(color: Colors.indigo)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.indigo),
                                foregroundColor: Colors.indigo,
                                elevation: 0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Так',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
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
                child:
                    Text('Скасувати', style: TextStyle(color: Colors.indigo)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.indigo),
                  foregroundColor: Colors.indigo,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewOrEditNoteSection(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);
    final tagController = TextEditingController(text: note.tag);
    final contentController = TextEditingController(text: note.content);

    bool isEditing = false;
    bool hasChanges = false;

    return StatefulBuilder(
      builder: (context, setState) {
        void checkForChanges() {
          setState(() {
            hasChanges = titleController.text != note.title ||
                tagController.text != note.tag ||
                contentController.text != note.content;
          });
        }

        titleController.addListener(checkForChanges);
        tagController.addListener(checkForChanges);
        contentController.addListener(checkForChanges);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditing) ...[
              Text(
                note.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.grey),
              Text(
                note.tag,
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700]),
              ),
              Divider(color: Colors.grey),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: TextStyle(fontSize: 16),
                  ),
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
                      child: Text('Редагувати',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
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
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.indigo, width: 2),
                            ),
                            titleTextStyle: TextStyle(
                              color: Colors.indigo,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            contentTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            title: Text('Видалити нотатку'),
                            content: Text(
                                'Ви впевнені, що хочете видалити цю нотатку?'),
                            actions: [
                              SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Ні',
                                      style: TextStyle(color: Colors.indigo)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide(color: Colors.indigo),
                                    foregroundColor: Colors.indigo,
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 130,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Видалити',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          deleteNote(notes.indexOf(note));
                          setState(() {
                            selectedNote = null;
                          });
                        }
                      },
                      child: Text('Видалити',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
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
                                date: note.date,
                              );
                              editNote(
                                notes.indexOf(note),
                                updatedNote,
                              );
                              setState(() {
                                isEditing = false;
                                hasChanges = false;
                                selectedNote = updatedNote;
                              });
                            }
                          : null,
                      child: Text('Зберегти',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
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
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side:
                                    BorderSide(color: Colors.indigo, width: 2),
                              ),
                              titleTextStyle: TextStyle(
                                color: Colors.indigo,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              contentTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              title: Text('Скасувати зміни'),
                              content: Text(
                                  'Всі внесені зміни будуть скасовані. Бажаєте їх скасувати?'),
                              actions: [
                                SizedBox(
                                  width: 130,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Ні',
                                        style: TextStyle(color: Colors.indigo)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: Colors.indigo),
                                      foregroundColor: Colors.indigo,
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text('Так',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            setState(() {
                              isEditing = false;
                              titleController.text = note.title;
                              tagController.text = note.tag;
                              contentController.text = note.content;
                              hasChanges = false;
                            });
                          }
                        } else {
                          setState(() {
                            isEditing = false;
                            titleController.text = note.title;
                            tagController.text = note.tag;
                            contentController.text = note.content;
                            hasChanges = false;
                          });
                        }
                      },
                      child: Text('Скасувати',
                          style: TextStyle(color: Colors.indigo)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.indigo),
                        foregroundColor: Colors.indigo,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Future<void> Function() resetApp;

  SettingsPage({required this.resetApp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.indigo, width: 2),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Налаштування'),
            iconTheme: IconThemeData(color: Colors.indigo),
            titleTextStyle: TextStyle(
              color: Colors.indigo,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Скинути додаток'),
                subtitle: Text('Видалити всі нотатки та налаштування'),
                trailing: Icon(Icons.restore, color: Colors.indigo),
                onTap: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.indigo, width: 2),
                      ),
                      titleTextStyle: TextStyle(
                        color: Colors.indigo,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      contentTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      title: Text('Скинути додаток'),
                      content: Text('Ви впевнені, що хочете скинути додаток?'),
                      actions: [
                        SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Скасувати',
                                style: TextStyle(color: Colors.indigo)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.indigo),
                              foregroundColor: Colors.indigo,
                              elevation: 0,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Скинути',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
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
                title: Text('Довідка'),
                subtitle: Text('Дізнайтеся більше про додаток'),
                trailing: Icon(Icons.help, color: Colors.indigo),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.indigo, width: 2),
                      ),
                      title: Text('Довідка',
                          style: TextStyle(color: Colors.indigo)),
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
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Закрити',
                              style: TextStyle(color: Colors.indigo)),
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
