import 'package:flutter/material.dart';
import 'package:moodmate/features/journal/pages/journal_list_page.dart';
import 'package:moodmate/services/journal_service.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _journalController = TextEditingController();
  final JournalService _journalService = JournalService();
  int _characterCount = 0;
  final int _maxCharacters = 500;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  void _saveJournalEntry() async {
    if (_journalController.text.trim().isEmpty) {
      _showSnackBar('Veuillez écrire quelque chose avant de sauvegarder', isError: true);
      return;
    }
    setState(() { _isSaving = true; });

    final result = await _journalService.saveJournalEntry(_journalController.text.trim());
    if (mounted) {
      if (result['success']) {
        _journalController.clear();
        _characterCount = 0;
        _showSnackBar('Journal sauvegardé avec succès !');
      } else {
        _showSnackBar(result['message'] ?? 'Une erreur est survenue.', isError: true);
      }
      setState(() { _isSaving = false; });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToJournalList() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const JournalListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mon Journal', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            onPressed: _navigateToJournalList,
            tooltip: 'Voir mes entrées',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Original UI for creating an entry
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(),
                          const SizedBox(height: 24),
                          _buildJournalInput(), // This widget has been modified
                          const SizedBox(height: 20),
                          _buildCharacterCounter(),
                          const SizedBox(height: 20),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[50]!, Colors.orange[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aujourd\'hui', style: TextStyle(fontSize: 14, color: Colors.orange[800], fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // MODIFIED: Replaced Expanded with SizedBox
  Widget _buildJournalInput() {
    return SizedBox(
      height: 250, // Fixed height for the input field
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: TextField(
          controller: _journalController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            hintText: 'Exprime ce que tu ressens aujourd\'hui...\n\nQu\'est-ce qui te rend heureux ?\nQuels sont tes défis ?\nTes objectifs pour demain ?',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 16, height: 1.5),
          onChanged: (value) {
            setState(() { _characterCount = value.length; });
          },
        ),
      ),
    );
  }

  Widget _buildCharacterCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$_characterCount/$_maxCharacters', style: TextStyle(color: _characterCount > _maxCharacters ? Colors.red : Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _journalController.text.trim().isEmpty ? Colors.grey[300] : Colors.orange[600],
          foregroundColor: _journalController.text.trim().isEmpty ? Colors.grey[500] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        onPressed: _journalController.text.trim().isEmpty || _isSaving ? null : _saveJournalEntry,
        child: _isSaving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.save, size: 20), SizedBox(width: 8), Text('SAUVEGARDER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
      ),
    );
  }
}
