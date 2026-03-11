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
    const seed = Color(0xFFE8B8A6);

    return MaterialApp(
      title: '우리의 기록',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
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
  }) : firstMetDate = firstMetDate ?? DateTime.now();

  String myName;
  String partnerName;
  DateTime firstMetDate;
}

enum WriterType { me, partner }

enum DiaryMood { 설렘, 행복, 평온, 고마움, 보고싶음 }

extension WriterTypeLabel on WriterType {
  String label(ProfileInfo profile) =>
      this == WriterType.me ? profile.myName : profile.partnerName;

  IconData get icon =>
      this == WriterType.me ? Icons.face_rounded : Icons.favorite_rounded;
}

extension DiaryMoodUi on DiaryMood {
  String get emoji {
    switch (this) {
      case DiaryMood.설렘:
        return '💞';
      case DiaryMood.행복:
        return '😊';
      case DiaryMood.평온:
        return '🌿';
      case DiaryMood.고마움:
        return '🙏';
      case DiaryMood.보고싶음:
        return '🥹';
    }
  }

  String get label => name;

  IconData get icon {
    switch (this) {
      case DiaryMood.설렘:
        return Icons.favorite_rounded;
      case DiaryMood.행복:
        return Icons.sentiment_very_satisfied_rounded;
      case DiaryMood.평온:
        return Icons.spa_rounded;
      case DiaryMood.고마움:
        return Icons.volunteer_activism_rounded;
      case DiaryMood.보고싶음:
        return Icons.auto_awesome_rounded;
    }
  }
}

class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.content,
    required this.mood,
    required this.author,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime date;
  final String content;
  final DiaryMood mood;
  final WriterType author;
  final DateTime createdAt;

  String get preview =>
      content.length <= 60 ? content : '${content.substring(0, 60)}...';
}

class PhotoMemory {
  PhotoMemory({
    required this.bytes,
    required this.note,
    required this.author,
    required this.createdAt,
  });

  final Uint8List bytes;
  final String note;
  final WriterType author;
  final DateTime createdAt;
}

class ScheduleItem {
  ScheduleItem({
    required this.title,
    required this.date,
    required this.memo,
    required this.author,
  });

  final String title;
  final DateTime date;
  final String memo;
  final WriterType author;
}

class LetterItem {
  LetterItem({
    required this.title,
    required this.content,
    required this.openDate,
    required this.author,
    required this.createdAt,
  });

  final String title;
  final String content;
  final DateTime openDate;
  final WriterType author;
  final DateTime createdAt;

  bool get isOpen => DateTime.now().isAfter(openDate) || _isSameDay(openDate, DateTime.now());
}

class AppState {
  final ProfileInfo profile = ProfileInfo();
  final List<DiaryEntry> diaries = [];
  final List<PhotoMemory> photos = [];
  final List<ScheduleItem> schedules = [];
  final List<LetterItem> letters = [];

  int get togetherDays => DateTime.now().difference(_trimDate(profile.firstMetDate)).inDays + 1;

  DateTime get day100 => _trimDate(profile.firstMetDate).add(const Duration(days: 99));

  DateTime get day200 => _trimDate(profile.firstMetDate).add(const Duration(days: 199));
}

class InviteLoginScreen extends StatefulWidget {
  const InviteLoginScreen({super.key});

  @override
  State<InviteLoginScreen> createState() => _InviteLoginScreenState();
}

class _InviteLoginScreenState extends State<InviteLoginScreen> {
  final _controller = TextEditingController();
  String? _error;

  static const String _inviteCodeHash =
      'b641b99a392e98d7f911ea2bdc3efae4bc1573cf6e009abdebd53e0a40509ac8';

  void _login() {
    final hash = sha256.convert(utf8.encode(_controller.text.trim())).toString();
    if (hash != _inviteCodeHash) {
      setState(() => _error = '초대코드가 맞지 않아요.');
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
              color: const Color(0xFFFFF1EA),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🐰💌', style: TextStyle(fontSize: 42)),
                    const SizedBox(height: 8),
                    const Text(
                      '우리의 기록',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '둘만의 감정과 추억을 따뜻하게 남겨요',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
                      child: FilledButton(onPressed: _login, child: const Text('입장하기')),
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

  void _openDiaryWrite() async {
    final entry = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(
        builder: (_) => DiaryWriteScreen(
          profile: widget.appState.profile,
        ),
      ),
    );

    if (entry == null) return;
    setState(() => widget.appState.diaries.insert(0, entry));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('오늘의 다이어리가 저장되었어요 💖')),
    );
  }

  void _openDiaryList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiaryListScreen(
          profile: widget.appState.profile,
          entries: widget.appState.diaries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        appState: widget.appState,
        onOpenDiaryWrite: _openDiaryWrite,
        onOpenDiaryList: _openDiaryList,
        onGoTab: (value) => setState(() => _index = value),
      ),
      DiaryListScreen(
        profile: widget.appState.profile,
        entries: widget.appState.diaries,
      ),
      AlbumScreen(appState: widget.appState),
      CalendarScreen(appState: widget.appState),
      LetterScreen(appState: widget.appState),
      ProfileSettingsScreen(
        appState: widget.appState,
        onUpdated: () => setState(() {}),
      ),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: '다이어리'),
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
  const HomeScreen({
    required this.appState,
    required this.onOpenDiaryWrite,
    required this.onOpenDiaryList,
    required this.onGoTab,
    super.key,
  });

  final AppState appState;
  final VoidCallback onOpenDiaryWrite;
  final VoidCallback onOpenDiaryList;
  final ValueChanged<int> onGoTab;

  @override
  Widget build(BuildContext context) {
    final profile = appState.profile;
    final today = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now());
    final latest = appState.diaries.isEmpty ? null : appState.diaries.first;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕, ${profile.myName}님 ☀️',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(today, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE7DB), Color(0xFFFFF4EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💗 오늘의 환영 카드', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    '${profile.myName} · ${profile.partnerName}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text('처음 만난 날부터 ${appState.togetherDays}일째 함께하는 중이에요.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: '감정 요약',
                    subtitle: latest == null
                        ? '아직 감정 기록이 없어요'
                        : '최근 감정: ${latest.mood.emoji} ${latest.mood.label}',
                    icon: Icons.favorite_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    title: '기념일 디데이',
                    subtitle: '100일 ${_ddayText(appState.day100)}',
                    icon: Icons.cake_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFFF7F3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('🧸', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        latest == null
                            ? '오늘의 한 문장: 서로에게 고마웠던 순간을 적어보세요.'
                            : '오늘의 메시지: “${latest.preview}”',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('바로가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _NavCard(
                    title: '다이어리 작성',
                    subtitle: '오늘 마음을 남겨요',
                    icon: Icons.edit_note_rounded,
                    onTap: onOpenDiaryWrite,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NavCard(
                    title: '다이어리 목록',
                    subtitle: '함께 쓴 기록 보기',
                    icon: Icons.list_alt_rounded,
                    onTap: onOpenDiaryList,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _NavCard(
                    title: '포토 앨범',
                    subtitle: '귀여운 순간 저장',
                    icon: Icons.photo_rounded,
                    onTap: () => onGoTab(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NavCard(
                    title: '커플 일정',
                    subtitle: '다음 약속 잡기',
                    icon: Icons.event_rounded,
                    onTap: () => onGoTab(3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({required this.profile, super.key});

  final ProfileInfo profile;

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _date = DateTime.now();
  DiaryMood _mood = DiaryMood.설렘;
  WriterType _author = WriterType.me;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('다이어리 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('오늘의 감정을 예쁘게 남겨볼까요?', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<WriterType>(
                        initialValue: _author,
                        decoration: const InputDecoration(labelText: '작성자'),
                        items: WriterType.values
                            .map((e) => DropdownMenuItem(value: e, child: Text(e.label(widget.profile))))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _author = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: '제목'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? '제목을 입력해주세요.' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('날짜', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _date = picked);
                            },
                            icon: const Icon(Icons.calendar_today_rounded),
                            label: Text(DateFormat('yyyy.MM.dd').format(_date)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text('기분', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: DiaryMood.values
                            .map(
                              (mood) => ChoiceChip(
                                selected: mood == _mood,
                                label: Text('${mood.emoji} ${mood.label}'),
                                onSelected: (_) => setState(() => _mood = mood),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _contentController,
                        minLines: 6,
                        maxLines: 10,
                        decoration: const InputDecoration(labelText: '내용'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? '내용을 입력해주세요.' : null,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            Navigator.of(context).pop(
                              DiaryEntry(
                                id: DateTime.now().microsecondsSinceEpoch.toString(),
                                title: _titleController.text.trim(),
                                date: _date,
                                content: _contentController.text.trim(),
                                mood: _mood,
                                author: _author,
                                createdAt: DateTime.now(),
                              ),
                            );
                          },
                          child: const Text('저장하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DiaryListScreen extends StatelessWidget {
  const DiaryListScreen({required this.profile, required this.entries, super.key});

  final ProfileInfo profile;
  final List<DiaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('다이어리 목록')),
      body: entries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '아직 다이어리 기록이 없어요.\n오늘의 마음을 첫 페이지에 남겨보세요 💖',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFFEEE6),
                      child: Text(entry.mood.emoji),
                    ),
                    title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.author.label(profile)} · ${DateFormat('yyyy.MM.dd').format(entry.date)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(entry.preview),
                        ],
                      ),
                    ),
                    trailing: Icon(entry.mood.icon, size: 18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiaryDetailScreen(profile: profile, entry: entry),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class DiaryDetailScreen extends StatelessWidget {
  const DiaryDetailScreen({required this.profile, required this.entry, super.key});

  final ProfileInfo profile;
  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('다이어리 상세')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(entry.date),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(entry.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(entry.mood.icon, size: 18),
                        const SizedBox(width: 6),
                        Text('${entry.mood.emoji} ${entry.mood.label}'),
                        const SizedBox(width: 12),
                        Text('작성자: ${entry.author.label(profile)}'),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(entry.content, style: const TextStyle(fontSize: 16, height: 1.65)),
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

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null || !mounted) return;

    final noteController = TextEditingController();
    WriterType selectedAuthor = WriterType.me;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('사진 메모 저장'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<WriterType>(
                initialValue: selectedAuthor,
                items: WriterType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.label(widget.appState.profile))))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selectedAuthor = value);
                },
                decoration: const InputDecoration(labelText: '작성자'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: '한 줄 메모'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('저장')),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final bytes = await image.readAsBytes();
    setState(() {
      widget.appState.photos.insert(
        0,
        PhotoMemory(
          bytes: bytes,
          note: noteController.text.trim().isEmpty ? '소중한 하루 기록' : noteController.text.trim(),
          author: selectedAuthor,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포토 앨범')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('사진 추가'),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: widget.appState.photos.isEmpty
                  ? const Center(child: Text('아직 사진이 없어요.'))
                  : GridView.builder(
                      itemCount: widget.appState.photos.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (_, index) {
                        final item = widget.appState.photos[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Image.memory(item.bytes, width: double.infinity, fit: BoxFit.cover)),
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
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('일정 추가'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<WriterType>(
                  initialValue: selectedWriter,
                  items: WriterType.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.label(widget.appState.profile))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedWriter = value);
                  },
                  decoration: const InputDecoration(labelText: '작성자'),
                ),
                const SizedBox(height: 8),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: '일정 제목')),
                const SizedBox(height: 8),
                TextField(controller: memoController, decoration: const InputDecoration(labelText: '메모')),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: pickedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setDialogState(() => pickedDate = date);
                  },
                  child: Text('날짜: ${DateFormat('yyyy.MM.dd').format(pickedDate)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    setState(() {
      widget.appState.schedules.add(
        ScheduleItem(
          title: titleController.text.trim(),
          date: pickedDate,
          memo: memoController.text.trim().isEmpty ? '우리의 약속' : memoController.text.trim(),
          author: selectedWriter,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.appState.schedules.where((e) => _isSameDay(e.date, _selectedDay)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('커플 일정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(onPressed: _addSchedule, icon: const Icon(Icons.add_circle_rounded)),
            ),
            Card(
              color: const Color(0xFFFFF6F1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
                  onDaySelected: (selected, focused) => setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  }),
                  eventLoader: (day) => widget.appState.schedules.where((e) => _isSameDay(e.date, day)).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('등록된 일정이 없어요.'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final item = list[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(item.author.icon),
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
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('편지 작성'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<WriterType>(
                  initialValue: selectedWriter,
                  items: WriterType.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.label(widget.appState.profile))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedWriter = value);
                  },
                  decoration: const InputDecoration(labelText: '작성자'),
                ),
                const SizedBox(height: 8),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: '제목')),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: '내용'),
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
                    if (date != null) setDialogState(() => openDate = date);
                  },
                  child: Text('열람 날짜: ${DateFormat('yyyy.MM.dd').format(openDate)}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;
    setState(() {
      widget.appState.letters.insert(
        0,
        LetterItem(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          openDate: openDate,
          author: selectedWriter,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('편지 보관함')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _writeLetter,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('편지 작성'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: widget.appState.letters.isEmpty
                  ? const Center(child: Text('아직 편지가 없어요.'))
                  : ListView.builder(
                      itemCount: widget.appState.letters.length,
                      itemBuilder: (_, index) {
                        final letter = widget.appState.letters[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(letter.author.icon),
                            title: Text(letter.title),
                            subtitle: Text('열람일 ${DateFormat('yyyy.MM.dd').format(letter.openDate)}'),
                            trailing: letter.isOpen
                                ? const Chip(label: Text('열람 가능'))
                                : const Chip(label: Text('비밀 편지')),
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

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({required this.appState, required this.onUpdated, super.key});

  final AppState appState;
  final VoidCallback onUpdated;

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
    _partnerNameController = TextEditingController(text: widget.appState.profile.partnerName);
  }

  @override
  void dispose() {
    _myNameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.appState.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('내 정보 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: const Color(0xFFFFF4EE),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(controller: _myNameController, decoration: const InputDecoration(labelText: '내 이름')),
                    const SizedBox(height: 8),
                    TextField(controller: _partnerNameController, decoration: const InputDecoration(labelText: '상대 이름')),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          widget.appState.profile.myName = _myNameController.text.trim().isEmpty ? '나' : _myNameController.text.trim();
                          widget.appState.profile.partnerName = _partnerNameController.text.trim().isEmpty ? '상대' : _partnerNameController.text.trim();
                          widget.onUpdated();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이름이 저장되었어요.')));
                        },
                        child: const Text('저장'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('처음 만난 날'),
                subtitle: Text(DateFormat('yyyy.MM.dd').format(profile.firstMetDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: profile.firstMetDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date == null) return;
                  setState(() => profile.firstMetDate = date);
                  widget.onUpdated();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _ddayText(DateTime date) {
  final diff = _trimDate(date).difference(_trimDate(DateTime.now())).inDays;
  if (diff > 0) return 'D-$diff';
  if (diff == 0) return 'D-Day';
  return 'D+${diff.abs()}';
}

DateTime _trimDate(DateTime value) => DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
