import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/study_session.dart';

/// Used for both adding (session == null) and editing (session != null).
/// Pops with `true` only after a confirmed, successful save.
class SessionFormScreen extends StatefulWidget {
  final StudySession? session;

  const SessionFormScreen({super.key, this.session});

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  static const List<String> subjects = [
    'Programming',
    'Data Structures',
    'Software Engineering',
    'Systems Analysis',
    'Statistics',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;
  String? _subject;
  bool _isSaving = false;

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _titleController = TextEditingController(text: s?.title ?? '');
    _durationController =
        TextEditingController(text: s == null ? '' : '${s.durationMinutes}');
    _notesController = TextEditingController(text: s?.notes ?? '');
    _subject = s?.subject;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ---- Validators: each returns an error message, or null if valid ----

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter a session title.';
    if (text.length < 3) return 'Title must be at least 3 characters.';
    if (text.length > 60) return 'Title must be 60 characters or fewer.';
    return null;
  }

  String? _validateSubject(String? value) =>
      value == null ? 'Please choose a subject.' : null;

  String? _validateDuration(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter the duration in minutes.';
    final minutes = int.tryParse(text);
    if (minutes == null) return 'Duration must be a whole number.';
    if (minutes <= 0) return 'Duration must be greater than 0.';
    if (minutes > 720) return 'Duration cannot exceed 720 minutes (12 hours).';
    return null;
  }

  String? _validateNotes(String? value) {
    if ((value?.length ?? 0) > 200) {
      return 'Notes must be 200 characters or fewer.';
    }
    return null;
  }

  // ---- Save flow: validate -> confirm dialog -> SQLite -> feedback ----

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return; // show errors, stop

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isEditing ? 'Update session?' : 'Save session?'),
        content: Text(_isEditing
            ? 'Save your changes to this study session?'
            : 'Add this study session to your log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return; // Cancel: nothing is saved

    setState(() => _isSaving = true);
    try {
      final entry = StudySession(
        id: widget.session?.id,
        title: _titleController.text.trim(),
        subject: _subject!,
        durationMinutes: int.parse(_durationController.text.trim()),
        notes: _notesController.text.trim(),
        createdAt: widget.session?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await DatabaseHelper.instance.update(entry);
      } else {
        await DatabaseHelper.instance.insert(entry);
      }
      if (!mounted) return;
      Navigator.pop(context, true); // home screen shows the success message
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save session: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Session' : 'Add Session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Session title *',
                  hintText: 'e.g. Revise linked lists',
                  border: OutlineInputBorder(),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _subject,
                decoration: const InputDecoration(
                  labelText: 'Subject *',
                  border: OutlineInputBorder(),
                ),
                items: subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _subject = value),
                validator: _validateSubject,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes) *',
                  hintText: 'e.g. 45',
                  border: OutlineInputBorder(),
                ),
                validator: _validateDuration,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: _validateNotes,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _onSavePressed,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEditing ? 'Update' : 'Save'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed:
                    _isSaving ? null : () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
