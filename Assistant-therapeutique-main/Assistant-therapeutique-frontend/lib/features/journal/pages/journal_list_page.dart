import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodmate/models/journal_model.dart';
import 'package:moodmate/services/journal_service.dart';
import 'package:collection/collection.dart';
import 'package:moodmate/features/journal/pages/journal_entry_detail_page.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> with TickerProviderStateMixin {
  late Future<List<JournalEntry>> _journalEntriesFuture;
  final JournalService _journalService = JournalService();
  
  AnimationController? _headerController;
  AnimationController? _listController;
  Animation<double>? _headerAnimation;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
    
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerController!,
      curve: Curves.easeOutCubic,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _listController!,
      curve: Curves.easeInOut,
    );
    
    _headerController!.forward();
    _listController!.forward();
  }

  @override
  void dispose() {
    _headerController?.dispose();
    _listController?.dispose();
    super.dispose();
  }

  void _loadJournalEntries() {
    setState(() {
      _journalEntriesFuture = _journalService.getJournalEntries();
    });
  }

  void _deleteJournalEntry(int id) async {
    final result = await _journalService.deleteJournalEntry(id);
    if (mounted) {
      if (result['success']) {
        _loadJournalEntries();
        _showCustomSnackBar('Entrée supprimée avec succès', true);
      } else {
        _showCustomSnackBar(result['message'] ?? 'Erreur lors de la suppression', false);
      }
    }
  }

  void _showCustomSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette entrée ? Cette action est irréversible.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Annuler', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteJournalEntry(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text('Supprimer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _navigateToDetailPage(JournalEntry entry) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => JournalEntryDetailPage(entry: entry),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
    _loadJournalEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAnimatedHeader(),
              Expanded(child: _buildJournalList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    if (_headerAnimation == null) {
      return _buildHeaderContent();
    }
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_headerAnimation!),
      child: FadeTransition(
        opacity: _headerAnimation!,
        child: _buildHeaderContent(),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade300.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mes Journaux',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explorez vos pensées',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_stories, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    return FutureBuilder<List<JournalEntry>>(
      future: _journalEntriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 4,
                  backgroundColor: Colors.orange.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chargement de vos journaux...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                ),
                const SizedBox(height: 20),
                Text(
                  'Erreur: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade100, Colors.orange.shade50],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade200.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.book_outlined, size: 80, color: Colors.orange.shade400),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Aucune entrée de journal',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Commencez à écrire vos pensées',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        final entries = snapshot.data!;
        final groupedEntries = groupBy(
          entries,
          (JournalEntry entry) => DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day),
        );

        final sortedKeys = groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

        Widget listView = ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final date = sortedKeys[index];
            final entriesForDate = groupedEntries[date]!;
            
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade300.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy', 'fr_FR').format(date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...entriesForDate.asMap().entries.map((mapEntry) {
                    final entryIndex = mapEntry.key;
                    final entry = mapEntry.value;
                    
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 500 + (entryIndex * 80)),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: (0.9 + (0.1 * value)).clamp(0.9, 1.0),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: _buildJournalCard(entry),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );

        if (_fadeAnimation == null) {
          return listView;
        }

        return FadeTransition(
          opacity: _fadeAnimation!,
          child: listView,
        );
      },
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetailPage(entry),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade300, Colors.orange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('HH:mm').format(entry.createdAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: Colors.blue.shade400,
                      onPressed: () => _navigateToDetailPage(entry),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: Colors.red.shade400,
                      onPressed: () => _showDeleteConfirmation(entry.id!),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  entry.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        'Lire plus',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
}