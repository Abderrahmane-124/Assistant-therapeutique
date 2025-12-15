import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodmate/models/journal_model.dart';
import 'package:moodmate/services/journal_service.dart';

class JournalEntryDetailPage extends StatefulWidget {
  final JournalEntry entry;

  const JournalEntryDetailPage({super.key, required this.entry});

  @override
  State<JournalEntryDetailPage> createState() => _JournalEntryDetailPageState();
}

class _JournalEntryDetailPageState extends State<JournalEntryDetailPage> with SingleTickerProviderStateMixin {
  late TextEditingController _contentController;
  late bool _isEditing;
  final JournalService _journalService = JournalService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry.content);
    _isEditing = false;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _contentController.text = widget.entry.content;
      }
    });
  }

  void _saveChanges() async {
    if (_contentController.text.trim().isEmpty) {
      _showCustomSnackBar('Le contenu ne peut pas être vide.', false);
      return;
    }
    
    setState(() { _isSaving = true; });
    
    final result = await _journalService.updateJournalEntry(
      widget.entry.id!,
      _contentController.text.trim(),
    );
    
    if (mounted) {
      setState(() { _isSaving = false; });
      
      if (result['success']) {
        setState(() {
          _isEditing = false;
          widget.entry.content = _contentController.text.trim();
        });
        _showCustomSnackBar('Entrée mise à jour avec succès !', true);
      } else {
        _showCustomSnackBar(result['message'] ?? 'Erreur lors de la mise à jour.', false);
      }
    }
  }

  void _deleteEntry() async {
    final result = await _journalService.deleteJournalEntry(widget.entry.id!);
    if (mounted) {
      if (result['success']) {
        _showCustomSnackBar('Entrée supprimée avec succès.', true);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.of(context).pop(true);
      } else {
        _showCustomSnackBar(result['message'] ?? 'Erreur lors de la suppression.', false);
      }
    }
  }

  void _showDeleteConfirmation() {
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
              _deleteEntry();
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
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade300.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Expanded(
                child: Text(
                  'Détail',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (!_isEditing) ...[
                _buildHeaderButton(
                  icon: Icons.edit_rounded,
                  onPressed: _toggleEdit,
                  tooltip: 'Modifier',
                ),
                const SizedBox(width: 8),
              ],
              if (_isEditing) ...[
                _buildHeaderButton(
                  icon: Icons.close_rounded,
                  onPressed: _toggleEdit,
                  tooltip: 'Annuler',
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.check_rounded,
                  onPressed: _isSaving ? null : _saveChanges,
                  tooltip: 'Sauvegarder',
                  isLoading: _isSaving,
                ),
                const SizedBox(width: 8),
              ],
              if (!_isEditing)
                _buildHeaderButton(
                  icon: Icons.delete_rounded,
                  onPressed: _showDeleteConfirmation,
                  tooltip: 'Supprimer',
                  isDanger: true,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(widget.entry.createdAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(widget.entry.createdAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isDanger = false,
    bool isLoading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: isDanger 
              ? Colors.red.shade400.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(icon, color: Colors.white, size: 22),
          onPressed: onPressed,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade300, Colors.orange.shade500],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_stories, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEditing ? 'Mode édition' : 'Contenu du journal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                if (_isEditing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Édition',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _isEditing ? _buildEditMode() : _buildReadMode(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadMode() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: SelectableText(
        widget.entry.content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.8,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        minLines: 10,
        decoration: InputDecoration(
          hintText: 'Exprimez vos pensées...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        style: const TextStyle(
          fontSize: 16,
          height: 1.8,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}