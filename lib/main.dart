import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  runApp(const CoupleMemoryApp());
}

class CoupleMemoryApp extends StatelessWidget {
  const CoupleMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFE5B8A8);

    return MaterialApp(
      title: '우리의 기록',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const InviteLoginScreen(),
    );
  }
}

class ProfileInfo {
  ProfileInfo({
    this.myName = '나',
    this.partnerName = '상대',
    DateTime? firstMetDate,
    DateTime? myBirthday,
    DateTime? partnerBirthday,
  })  : firstMetDate = firstMetDate ?? DateTime.now(),
        myBirthday = myBirthday ?? DateTime(DateTime.now().year, 12, 4),
        partnerBirthday =
            partnerBirthday ?? DateTime(DateTime.now().year, 8, 22);

  String myName;
  String partnerName;
  DateTime firstMetDate;
  DateTime myBirthday;
  DateTime partnerBirthday;
}

class AppState {
  final ProfileInfo profile = ProfileInfo();
  final List<PhotoMemory> photos = [];
  final List<ScheduleItem> schedules = [];
  final List<LetterItem> letters = [];

  List<DdayItem> get ddayItems {
    final met = _trimDate(profile.firstMetDate);
    final togetherDays = DateTime.now().difference(met).inDays + 1;

    return [
      DdayItem(title: '처음 만난 날', date: profile.firstMetDate),
      DdayItem(title: '우리 100일', date: met.add(const Duration(days: 99))),
      DdayItem(title: '우리 200일', date: met.add(const Duration(days: 199))),
      DdayItem(title: '${profile.myName} 생일', date: _nextBirthday(profile.myBirthday)),
      DdayItem(
        title: '${profile.partnerName} 생일',
        date: _nextBirthday(profile.partnerBirthday),
      ),
      DdayItem(title: '함께한 날', date: DateTime.now(), fixedLabel: '$togetherDays일째'),
    ];
  }
}

class PhotoMemory {
  PhotoMemory({
    required this.bytes,
    required this.note,
    required this.createdAt,
    required this.author,
  });

  final Uint8List bytes;
  final String note;
  final DateTime createdAt;
  final WriterType author;
}

class ScheduleItem {
  ScheduleItem({
    required this.title,
    required this.date,
    required this.memo,
    required this.createdBy,
  });

  final String title;
  final DateTime date;
  final String memo;
  final WriterType createdBy;
}

class LetterItem {
  LetterItem({
    required this.title,
    required this.content,
    required this.openDate,
    required this.createdAt,
    required this.author,
  });

  final String title;
  final String content;
  final DateTime openDate;
  final DateTime createdAt;
  final WriterType author;

  bool get isOpen =>
      DateTime.now().isAfter(openDate) || _isSameDay(openDate, DateTime.now());
}

class DdayItem {
  DdayItem({required this.title, required this.date, this.fixedLabel});

  final String title;
  final DateTime date;
  final String? fixedLabel;

  String label() {
    if (fixedLabel != null) return fixedLabel!;

    final diff = _trimDate(date).difference(_trimDate(DateTime.now())).inDays;
    if (diff > 0) return 'D-$diff';
    if (diff == 0) return 'D-Day';
    return 'D+${diff.abs()}';
  }
}

enum WriterType { me, partner }

extension WriterTypeLabel on WriterType {
  String label(ProfileInfo profile) {
    return switch (this) {
      WriterType.me => profile.myName,
      WriterType.partner => profile.partnerName,
    };
  }

  IconData get icon {
    return switch (this) {
      WriterType.me => Icons.face_rounded,
      WriterType.partner => Icons.favorite_rounded,
    };
  }
}

class InviteLoginScreen extends StatefulWidget {
  const InviteLoginScreen({super.key});

  @override
  State<InviteLoginScreen> createState() => _InviteLoginScreenState();
}

class _InviteLoginScreenState extends State<InviteLoginScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  static const String _inviteCodeHash =
      'b641b99a392e98d7f911ea2bdc3efae4bc1573cf6e009abdebd53e0a40509ac8';

  void _login() {
    final hash = sha256.convert(utf8.encode(_controller.text.trim())).toString();

    if (hash != _inviteCodeHash) {
      setState(() {
        _error = '초대코드가 올바르지 않아요.';
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainShell(appState: AppState())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: const Color(0xFFFFF2EC),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🐰💌', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    const Text(
                      '우리의 기록',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '아기자기한 둘만의 공간으로 입장해요',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _controller,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '초대코드',
                        hintText: '코드를 입력해주세요',
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _login,
                        child: const Text('입장하기'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '※ 현재 테스트 로그인입니다. 추후 Apple/Google 로그인 권장',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({required this.appState, super.key});

  final AppState appState;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(appState: widget.appState),
      AlbumScreen(appState: widget.appState),
      CalendarScreen(appState: widget.appState),
      LetterScreen(appState: widget.appState),
      ProfileSettingsScreen(
        appState: widget.appState,
        onChanged: () => setState(() {}),
      ),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(icon: Icon(Icons.photo_library_rounded), label: '앨범'),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: '일정'),
          NavigationDestination(icon: Icon(Icons.mail_rounded), label: '편지'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: '내 정보'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final profile = appState.profile;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕, ${profile.myName} 💛',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now()),
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE7D9), Color(0xFFFFF4EC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧸 오늘의 우리'),
                  const SizedBox(height: 6),
                  Text(
                    '${profile.myName} & ${profile.partnerName}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '처음 만난 날부터 ${DateTime.now().difference(_trimDate(profile.firstMetDate)).inDays + 1}일째 함께하고 있어요.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '디데이',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...appState.ddayItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEEE5),
                      child: Text('🎀'),
                    ),
                    title: Text(item.title),
                    subtitle: Text(DateFormat('yyyy.MM.dd').format(item.date)),
                    trailing: Text(
                      item.label(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (image == null || !mounted) return;

    final noteController = TextEditingController();
    WriterType selectedAuthor = WriterType.me;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('사진 메모 저장'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<WriterType>(
                    value: selectedAuthor,
                    items: WriterType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label(widget.appState.profile)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedAuthor = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: '작성자'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '한 줄 메모',
                      hintText: '예: 같이 먹은 딸기 케이크 🍓',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final bytes = await image.readAsBytes();
    setState(() {
      widget.appState.photos.insert(
        0,
        PhotoMemory(
          bytes: bytes,
          note: noteController.text.trim().isEmpty
              ? '소중한 하루 기록'
              : noteController.text.trim(),
          createdAt: DateTime.now(),
          author: selectedAuthor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '포토 앨범',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('사진 추가'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: widget.appState.photos.isEmpty
                  ? const Center(
                      child: Text('아직 사진이 없어요.\n첫 추억을 올려볼까요? 📸', textAlign: TextAlign.center),
                    )
                  : GridView.builder(
                      itemCount: widget.appState.photos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final item = widget.appState.photos[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.memory(
                                  item.bytes,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.note,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.author.label(widget.appState.profile)} · ${DateFormat('MM.dd').format(item.createdAt)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
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

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Future<void> _addSchedule() async {
    final titleController = TextEditingController();
    final memoController = TextEditingController();
    var selectedWriter = WriterType.me;
    var pickedDate = _selectedDay;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('일정 추가'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<WriterType>(
                      value: selectedWriter,
                      items: WriterType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label(widget.appState.profile)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedWriter = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: '작성자'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '일정 제목'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: memoController,
                      decoration: const InputDecoration(labelText: '메모'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: pickedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() => pickedDate = date);
                        }
                      },
                      child:
                          Text('날짜: ${DateFormat('yyyy.MM.dd').format(pickedDate)}'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    setState(() {
      widget.appState.schedules.add(
        ScheduleItem(
          title: titleController.text.trim(),
          date: pickedDate,
          memo: memoController.text.trim().isEmpty
              ? '우리의 약속'
              : memoController.text.trim(),
          createdBy: selectedWriter,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.appState.schedules
        .where((item) => _isSameDay(item.date, _selectedDay))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '커플 일정 캘린더',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add_circle_rounded),
                ),
              ],
            ),
            Card(
              color: const Color(0xFFFFF7F2),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  eventLoader: (day) => widget.appState.schedules
                      .where((item) => _isSameDay(item.date, day))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('선택한 날짜: ${DateFormat('yyyy.MM.dd').format(_selectedDay)}'),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('등록된 일정이 없어요.'))
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final item = list[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(item.createdBy.icon),
                            title: Text(item.title),
                            subtitle: Text(
                              '${item.createdBy.label(widget.appState.profile)} · ${item.memo}',
                            ),
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

class LetterScreen extends StatefulWidget {
  const LetterScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  Future<void> _writeLetter() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    var selectedWriter = WriterType.me;
    var openDate = DateTime.now();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('편지 쓰기'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<WriterType>(
                      value: selectedWriter,
                      items: WriterType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label(widget.appState.profile)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedWriter = value);
                        }
                      },
                      decoration: const InputDecoration(labelText: '작성자'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '편지 제목'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      minLines: 5,
                      maxLines: 8,
                      decoration: const InputDecoration(labelText: '편지 내용'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: openDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() => openDate = date);
                        }
                      },
                      child: Text('열람 날짜: ${DateFormat('yyyy.MM.dd').format(openDate)}'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        contentController.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.pop(context, true);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    setState(() {
      widget.appState.letters.insert(
        0,
        LetterItem(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          openDate: openDate,
          createdAt: DateTime.now(),
          author: selectedWriter,
        ),
      );
    });
  }

  void _openLetter(LetterItem letter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LetterDetailScreen(
          letter: letter,
          profile: widget.appState.profile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '편지 보관함',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                FilledButton.icon(
                  onPressed: _writeLetter,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('편지 작성'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: widget.appState.letters.isEmpty
                  ? const Center(child: Text('아직 편지가 없어요.'))
                  : ListView.separated(
                      itemCount: widget.appState.letters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final letter = widget.appState.letters[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(letter.author.icon),
                            title: Text(letter.title),
                            subtitle: Text(
                              '${letter.author.label(widget.appState.profile)} · 열람일 ${DateFormat('yyyy.MM.dd').format(letter.openDate)}',
                            ),
                            trailing: letter.isOpen
                                ? const Chip(label: Text('열람 가능'))
                                : const Chip(label: Text('비밀 편지')),
                            onTap: () => _openLetter(letter),
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

class LetterDetailScreen extends StatelessWidget {
  const LetterDetailScreen({
    required this.letter,
    required this.profile,
    super.key,
  });

  final LetterItem letter;
  final ProfileInfo profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('편지 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: letter.isOpen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        letter.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('작성자: ${letter.author.label(profile)}'),
                      Text('작성일: ${DateFormat('yyyy.MM.dd').format(letter.createdAt)}'),
                      Text('열람일: ${DateFormat('yyyy.MM.dd').format(letter.openDate)}'),
                      const Divider(height: 24),
                      Text(
                        letter.content,
                        style: const TextStyle(height: 1.6, fontSize: 16),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      '🔒 이 편지는 ${DateFormat('yyyy.MM.dd').format(letter.openDate)}에 열려요.',
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    required this.appState,
    required this.onChanged,
    super.key,
  });

  final AppState appState;
  final VoidCallback onChanged;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final TextEditingController _myNameController;
  late final TextEditingController _partnerNameController;

  @override
  void initState() {
    super.initState();
    _myNameController = TextEditingController(text: widget.appState.profile.myName);
    _partnerNameController =
        TextEditingController(text: widget.appState.profile.partnerName);
  }

  @override
  void dispose() {
    _myNameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      onSelected(date);
      setState(() {});
      widget.onChanged();
    }
  }

  void _saveNames() {
    widget.appState.profile.myName =
        _myNameController.text.trim().isEmpty ? '나' : _myNameController.text.trim();
    widget.appState.profile.partnerName = _partnerNameController.text.trim().isEmpty
        ? '상대'
        : _partnerNameController.text.trim();

    widget.onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('내 정보가 저장되었어요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.appState.profile;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내 정보 설정',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFFF5EE),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _myNameController,
                      decoration: const InputDecoration(labelText: '내 이름'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _partnerNameController,
                      decoration: const InputDecoration(labelText: '상대 이름'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saveNames,
                        child: const Text('이름 저장'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('처음 만난 날'),
                subtitle: Text(DateFormat('yyyy.MM.dd').format(profile.firstMetDate)),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () => _pickDate(
                  initialDate: profile.firstMetDate,
                  onSelected: (date) => profile.firstMetDate = date,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text('${profile.myName} 생일'),
                subtitle: Text(DateFormat('yyyy.MM.dd').format(profile.myBirthday)),
                trailing: const Icon(Icons.cake_rounded),
                onTap: () => _pickDate(
                  initialDate: profile.myBirthday,
                  onSelected: (date) => profile.myBirthday = date,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text('${profile.partnerName} 생일'),
                subtitle: Text(DateFormat('yyyy.MM.dd').format(profile.partnerBirthday)),
                trailing: const Icon(Icons.cake_rounded),
                onTap: () => _pickDate(
                  initialDate: profile.partnerBirthday,
                  onSelected: (date) => profile.partnerBirthday = date,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '설정한 날짜는 홈 디데이에 즉시 반영됩니다.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime _nextBirthday(DateTime birthday) {
  final now = DateTime.now();
  var date = DateTime(now.year, birthday.month, birthday.day);

  if (_trimDate(date).isBefore(_trimDate(now))) {
    date = DateTime(now.year + 1, birthday.month, birthday.day);
  }

  return date;
}

DateTime _trimDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
