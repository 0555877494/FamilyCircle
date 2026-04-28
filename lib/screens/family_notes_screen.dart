import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_user.dart';
import '../services/file_service.dart';
import '../widgets/connection_status.dart';

enum NoteType { note, memory, milestone, gratitude, prayer, idea }

class FamilyNote {
  final String id;
  final String familyId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final NoteType type;
  final List<String> likedByIds;
  final DateTime createdAt;

  FamilyNote({
    required this.id,
    required this.familyId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.type,
    required this.likedByIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'type': type.name,
      'likedByIds': likedByIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyNote.fromMap(Map<String, dynamic> map) {
    return FamilyNote(
      id: map['id'] as String,
      familyId: map['familyId'] as String,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      type: NoteType.values.firstWhere((e) => e.name == map['type']),
      likedByIds: List<String>.from(map['likedByIds'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class FamilyNotesScreen extends StatefulWidget {
  final FamilyUser currentUser;
  
  const FamilyNotesScreen({super.key, required this.currentUser});

  @override
  State<FamilyNotesScreen> createState() => _FamilyNotesScreenState();
}

class _FamilyNotesScreenState extends State<FamilyNotesScreen> {
  List<FamilyNote> _notes = [];
  final _uuid = const Uuid();
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleNotes();
  }

  void _loadSampleNotes() {
    final now = DateTime.now();
    _notes = [
      FamilyNote(id: '1', familyId: widget.currentUser.familyId, authorId: widget.currentUser.id, authorName: widget.currentUser.firstName, title: 'First Day of School', content: 'Emma started kindergarten today! She was so brave and walked into class with a big smile. We are so proud of her!', type: NoteType.milestone, likedByIds: ['parent2', 'grandma'], createdAt: now.subtract(const Duration(days: 5))),
      FamilyNote(id: '2', familyId: widget.currentUser.familyId, authorId: 'parent2', authorName: 'Mom', title: 'Family Game Night', content: 'We played board games tonight. Lots of laughter and some friendly competition. Best night ever!', type: NoteType.memory, likedByIds: [widget.currentUser.id], createdAt: now.subtract(const Duration(days: 3))),
      FamilyNote(id: '3', familyId: widget.currentUser.familyId, authorId: 'grandma', authorName: 'Grandma Mary', title: 'Thankful for this family', content: 'I am so grateful for everyone who visited this weekend. The house was full of love and laughter.', type: NoteType.gratitude, likedByIds: [widget.currentUser.id, 'parent2'], createdAt: now.subtract(const Duration(days: 1))),
      FamilyNote(id: '4', familyId: widget.currentUser.familyId, authorId: widget.currentUser.id, authorName: widget.currentUser.firstName, title: 'New Recipe Idea', content: 'What if we make lasagna with spinach and ricotta for Thanksgiving? Will try this weekend!', type: NoteType.idea, likedByIds: [], createdAt: now),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Journal'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: ConnectionStatusIndicator()),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildNotesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Memories', 'Milestones', 'Gratitude', 'Ideas'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: List.generate(filters.length, (i) => 
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[i]),
              selected: _selectedFilter == i,
              onSelected: (s) => setState(() => _selectedFilter = i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No journal entries yet'),
            const SizedBox(height: 8),
            Text('Share memories, milestones, or gratitude'),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (ctx, i) => _buildNoteCard(_notes[i]),
    );
  }

  Widget _buildNoteCard(FamilyNote note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getTypeIcon(note.type), color: _getTypeColor(note.type)),
                const SizedBox(width: 8),
                Text(note.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(_formatDate(note.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(note.content),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(note.likedByIds.contains(widget.currentUser.id) ? Icons.favorite : Icons.favorite_border), 
                  onPressed: () => _toggleLike(note),
                  color: note.likedByIds.contains(widget.currentUser.id) ? Colors.red : Colors.grey,
                ),
                Text('${note.likedByIds.length}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteNote(note),
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(NoteType type) {
    switch (type) {
      case NoteType.note: return Colors.blue;
      case NoteType.memory: return Colors.purple;
      case NoteType.milestone: return Colors.orange;
      case NoteType.gratitude: return Colors.green;
      case NoteType.prayer: return Colors.teal;
      case NoteType.idea: return Colors.amber;
    }
  }

  IconData _getTypeIcon(NoteType type) {
    switch (type) {
      case NoteType.note: return Icons.note;
      case NoteType.memory: return Icons.memory;
      case NoteType.milestone: return Icons.emoji_events;
      case NoteType.gratitude: return Icons.favorite;
      case NoteType.prayer: return Icons.church;
      case NoteType.idea: return Icons.lightbulb;
    }
  }

  void _toggleLike(FamilyNote note) {
    setState(() {
      final liked = note.likedByIds.contains(widget.currentUser.id);
      _notes = _notes.where((n) => n.id != note.id).toList()
        ..add(FamilyNote(
          id: note.id,
          familyId: note.familyId,
          authorId: note.authorId,
          authorName: note.authorName,
          title: note.title,
          content: note.content,
          type: note.type,
          likedByIds: liked 
            ? note.likedByIds.where((id) => id != widget.currentUser.id).toList()
            : [...note.likedByIds, widget.currentUser.id],
          createdAt: note.createdAt,
        ));
    });
  }

  void _deleteNote(FamilyNote note) {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    NoteType selectedType = NoteType.note;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Journal Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 8),
                TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
                const SizedBox(height: 8),
                DropdownButtonFormField<NoteType>(
                  value: selectedType,
                  items: NoteType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 16),
                const Text('Add Photos/Memories', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () => _pickFile(ctx),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () => _pickFile(ctx),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  final note = FamilyNote(
                    id: _uuid.v4(),
                    familyId: widget.currentUser.familyId,
                    authorId: widget.currentUser.id,
                    authorName: widget.currentUser.firstName,
                    title: titleController.text,
                    content: contentController.text,
                    type: selectedType,
                    likedByIds: [],
                    createdAt: DateTime.now(),
                  );
                  setState(() => _notes.insert(0, note));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Future<void> _pickFile(BuildContext ctx) async {
    final fileService = FileService();
    final file = await fileService.pickAndUploadImage(
      widget.currentUser.familyId,
      widget.currentUser.id,
      widget.currentUser.firstName,
    );
    
    if (file != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Added: ${file.name}')),
      );
    }
  }
}