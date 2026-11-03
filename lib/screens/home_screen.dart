import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/study_session.dart';
import '../widgets/pagination_bar.dart';
import 'session_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;

  List<StudySession> _sessions = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  int get _totalPages =>
      _totalCount == 0 ? 1 : (_totalCount / DatabaseHelper.pageSize).ceil();

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  /// Queries SQLite for one page. The page number is clamped to a valid range,
  /// so after a delete the list lands on the nearest valid page.
  Future<void> _loadPage(int page) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final count = await _db.countAll();
      final pages = count == 0 ? 1 : (count / DatabaseHelper.pageSize).ceil();
      if (page > pages) page = pages;
      if (page < 1) page = 1;

      final items = await _db.getPage(page);
      if (!mounted) return;
      setState(() {
        _totalCount = count;
        _currentPage = page;
        _sessions = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load sessions: $e';
        _isLoading = false;
      });
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ));
  }

  Future<void> _openAddForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SessionFormScreen()),
    );
    if (saved == true) {
      await _loadPage(1); // newest record is on page 1
      _showMessage('Study session saved.');
    }
  }

  Future<void> _openEditForm(StudySession session) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SessionFormScreen(session: session)),
    );
    if (saved == true) {
      await _loadPage(_currentPage);
      _showMessage('Study session updated.');
    }
  }

  void _showDetails(StudySession session) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(session.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Subject', session.subject),
            _detailRow('Duration', '${session.durationMinutes} minutes'),
            _detailRow('Notes', session.notes.isEmpty ? '-' : session.notes),
            _detailRow('Logged', session.formattedDate),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _openEditForm(session);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text.rich(TextSpan(children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ])),
      );

  Future<void> _confirmDelete(StudySession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text('"${session.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return; // Cancel: record stays

    try {
      await _db.delete(session.id!);
      await _loadPage(_currentPage); // clamps if the last page became empty
      _showMessage('Study session deleted.');
    } catch (e) {
      _showMessage('Failed to delete session: $e', isError: true);
    }
  }

  // ---- UI ----

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _loadPage(_currentPage),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    if (_sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_note, size: 72, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No study sessions yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text('Tap the + button to log your first session.'),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final s = _sessions[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${s.durationMinutes}')),
            title: Text(s.title),
            subtitle: Text(
              '${s.subject} • ${s.durationMinutes} min\n${s.formattedDate}',
            ),
            isThreeLine: true,
            onTap: () => _showDetails(s),
            onLongPress: () => _confirmDelete(s),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Session Log'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPage(_currentPage),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add session',
        onPressed: _openAddForm,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: PaginationBar(
        currentPage: _currentPage,
        totalPages: _totalPages,
        hasRecords: _totalCount > 0,
        onPrevious: () => _loadPage(_currentPage - 1),
        onNext: () => _loadPage(_currentPage + 1),
      ),
    );
  }
}
