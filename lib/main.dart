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
    return MaterialApp(
      title: '우리의 기록',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9B38C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFCF8),
        fontFamily: 'Pretendard',
      ),
      home: const InviteLoginScreen(),
    );
  }
}

class AppState {
  final List<PhotoMemory> photos = [];
  final List<ScheduleItem> schedules = [];
  final List<LetterItem> letters = [];
  final List<DdayItem> ddayItems = [
    DdayItem(title: '우리 100일', date: DateTime.now().add(const Duration(days: 48))),
    DdayItem(title: '우리 200일', date: DateTime.now().add(const Duration(days: 148))),
    DdayItem(title: '내 생일', date: DateTime(DateTime.now().year, 12, 4)),
    DdayItem(title: '상대 생일', date: DateTime(DateTime.now().year, 8, 22)),
  ];
}

class PhotoMemory {
  PhotoMemory({required this.bytes, required this.note, required this.createdAt});

  final Uint8List bytes;
  final String note;
  final DateTime createdAt;
}

class ScheduleItem {
  ScheduleItem({required this.title, required this.date, required this.memo});

  final String title;
  final DateTime date;
  final String memo;
}

class LetterItem {
  LetterItem({
    required this.title,
    required this.content,
    required this.openDate,
    required this.createdAt,
  });

  final String title;
  final String content;
  final DateTime openDate;
  final DateTime createdAt;

  bool get isOpen => DateTime.now().isAfter(openDate) || _isSameDay(openDate, DateTime.now());
}

class DdayItem {
  DdayItem({required this.title, required this.date});

  final String title;
  final DateTime date;

  int get daysLeft => date.difference(DateTime.now()).inDays + 1;
}

class InviteLoginScreen extends StatefulWidget {
  const InviteLoginScreen({super.key});

  @override
  State<InviteLoginScreen> createState() => _InviteLoginScreenState();
}

class _InviteLoginScreenState extends State<InviteLoginScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  // 초대코드 원문 대신 해시만 보관
  static const String _inviteCodeHash =
      'b641b99a392e98d7f911ea2bdc3efae4bc1573cf6e009abdebd53e0a40509ac8';

  void _login() {
    final input = _controller.text.trim();
    final hash = sha256.convert(utf8.encode(input)).toString();

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
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              color: const Color(0xFFFFF7F0),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💌', style: TextStyle(fontSize: 42)),
                    const SizedBox(height: 10),
                    const Text(
                      '우리의 다이어리',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '커플 전용 비밀 공간 · 소규모(최대 5명) 테스트 MVP',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: '초대코드 입력',
                        hintText: '코드를 입력하면 입장할 수 있어요',
                        errorText: _error,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      obscureText: true,
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _login,
                        child: const Text('입장하기'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '※ 현재는 테스트용 초대코드 로그인입니다.\n추후 Apple/Google 로그인 연동을 권장해요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
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
    final now = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('우리의 기록', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(now, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('사랑한 지 52일째 🧸', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text('오늘도 서로의 하루를 다정하게 기록해봐요.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('디데이', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...appState.ddayItems.map(
              (item) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(DateFormat('yyyy.MM.dd').format(item.date)),
                  trailing: Text('D-${item.daysLeft}'),
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
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    final note = await showDialog<String>(
      context: context,
      builder: (_) => const _PhotoNoteDialog(),
    );

    if (note == null) return;
    setState(() {
      widget.appState.photos.insert(
        0,
        PhotoMemory(bytes: bytes, note: note, createdAt: DateTime.now()),
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
                const Text('포토 앨범', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('사진 추가'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.appState.photos.isEmpty
                  ? const Center(child: Text('아직 사진이 없어요. 첫 추억을 업로드해보세요.'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: widget.appState.photos.length,
                      itemBuilder: (context, index) {
                        final item = widget.appState.photos[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.memory(item.bytes, fit: BoxFit.cover, width: double.infinity),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(item.note, maxLines: 2, overflow: TextOverflow.ellipsis),
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

class _PhotoNoteDialog extends StatefulWidget {
  const _PhotoNoteDialog();

  @override
  State<_PhotoNoteDialog> createState() => _PhotoNoteDialogState();
}

class _PhotoNoteDialogState extends State<_PhotoNoteDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('사진 메모'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: '이 순간을 한 줄로 남겨주세요'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim().isEmpty ? '우리의 소중한 하루' : controller.text.trim()),
          child: const Text('저장'),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final daySchedules = widget.appState.schedules.where((e) => _isSameDay(e.date, _selectedDay)).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('커플 일정 캘린더', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                IconButton(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) => widget.appState.schedules.where((e) => _isSameDay(e.date, day)).toList(),
            ),
            const SizedBox(height: 8),
            Text('선택한 날짜: ${DateFormat('yyyy.MM.dd').format(_selectedDay)}'),
            const SizedBox(height: 8),
            Expanded(
              child: daySchedules.isEmpty
                  ? const Center(child: Text('등록된 약속이 없어요.'))
                  : ListView.builder(
                      itemCount: daySchedules.length,
                      itemBuilder: (_, index) {
                        final item = daySchedules[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text(item.memo),
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

  Future<void> _addSchedule() async {
    final result = await showDialog<ScheduleItem>(
      context: context,
      builder: (_) => _ScheduleDialog(initialDate: _selectedDay),
    );

    if (result == null) return;
    setState(() => widget.appState.schedules.add(result));
  }
}

class _ScheduleDialog extends StatefulWidget {
  const _ScheduleDialog({required this.initialDate});
  final DateTime initialDate;

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  final titleController = TextEditingController();
  final memoController = TextEditingController();
  late DateTime date;

  @override
  void initState() {
    super.initState();
    date = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('일정 추가'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: '일정 제목')),
            TextField(controller: memoController, decoration: const InputDecoration(labelText: '메모')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => date = picked);
                }
              },
              child: Text('날짜: ${DateFormat('yyyy.MM.dd').format(date)}'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: () {
            if (titleController.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              ScheduleItem(
                title: titleController.text.trim(),
                date: date,
                memo: memoController.text.trim().isEmpty ? '우리의 약속' : memoController.text.trim(),
              ),
            );
          },
          child: const Text('저장'),
        ),
      ],
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
                const Text('편지 보관함', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                FilledButton.icon(
                  onPressed: _writeLetter,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('편지 쓰기'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: widget.appState.letters.isEmpty
                  ? const Center(child: Text('아직 작성한 편지가 없어요.'))
                  : ListView.builder(
                      itemCount: widget.appState.letters.length,
                      itemBuilder: (_, index) {
                        final letter = widget.appState.letters[index];
                        return Card(
                          child: ListTile(
                            title: Text(letter.title),
                            subtitle: Text('열람일: ${DateFormat('yyyy.MM.dd').format(letter.openDate)}'),
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

  Future<void> _writeLetter() async {
    final letter = await Navigator.of(context).push<LetterItem>(
      MaterialPageRoute(builder: (_) => const WriteLetterScreen()),
    );
    if (letter == null) return;
    setState(() => widget.appState.letters.insert(0, letter));
  }

  void _openLetter(LetterItem letter) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LetterDetailScreen(letter: letter)),
    );
  }
}

class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  DateTime openDate = DateTime.now();

  static const List<String> starterLines = [
    '너와 걷던 저녁 바람은 오늘도 내 마음을 부드럽게 흔들어.',
    '우리의 하루는 작은 별처럼 반짝여서 오래 기억하고 싶어.',
    '네가 웃을 때마다 내 계절은 한 톤 더 따뜻해져.',
    '사소한 오늘이 너와 함께라서 가장 특별한 날이 되었어.',
    '시간이 흘러도 너를 향한 마음은 첫 장면처럼 선명해.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('편지 쓰기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '편지 제목'),
            ),
            const SizedBox(height: 8),
            const Text('예쁜 문장 자동완성'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: starterLines
                  .map(
                    (line) => ActionChip(
                      label: Text(line, overflow: TextOverflow.ellipsis),
                      onPressed: () {
                        final prev = contentController.text.trim();
                        contentController.text = prev.isEmpty ? '$line\n' : '$prev\n$line\n';
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              minLines: 7,
              maxLines: 12,
              decoration: const InputDecoration(labelText: '편지 내용'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: openDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => openDate = picked);
              },
              child: Text('열람 날짜: ${DateFormat('yyyy.MM.dd').format(openDate)}'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) return;
                  Navigator.pop(
                    context,
                    LetterItem(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      openDate: openDate,
                      createdAt: DateTime.now(),
                    ),
                  );
                },
                child: const Text('편지 저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LetterDetailScreen extends StatelessWidget {
  const LetterDetailScreen({required this.letter, super.key});
  final LetterItem letter;

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
                      Text(letter.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('작성일: ${DateFormat('yyyy.MM.dd').format(letter.createdAt)}'),
                      Text('열람일: ${DateFormat('yyyy.MM.dd').format(letter.openDate)}'),
                      const Divider(height: 24),
                      Text(letter.content, style: const TextStyle(height: 1.6)),
                    ],
                  )
                : Center(
                    child: Text('🔒 이 편지는 ${DateFormat('yyyy.MM.dd').format(letter.openDate)}에 열려요.'),
                  ),
          ),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
