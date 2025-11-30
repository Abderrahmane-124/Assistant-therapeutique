import 'package:flutter/material.dart';

class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});

  @override
  State<MoodTrackingPage> createState() => _MoodTrackingPageState();
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
  });
}

class _MoodTrackingPageState extends State<MoodTrackingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<MoodOption> _moodOptions = [
    MoodOption(emoji: '😢', label: 'Triste', color: Colors.blue),
    MoodOption(emoji: '😐', label: 'Neutre', color: Colors.grey),
    MoodOption(emoji: '😊', label: 'Content', color: Colors.orange),
    MoodOption(emoji: '😄', label: 'Heureux', color: Colors.green),
    MoodOption(emoji: '😍', label: 'Épanoui', color: Colors.pink),
  ];

  MoodOption? _selectedMood;
  int _selectedIntensity = 3;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitMood() {
    if (_selectedMood == null) {
      _showErrorDialog('Sélectionnez votre humeur', 'Veuillez choisir une émotion pour continuer.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulation de sauvegarde
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSubmitting = false;
      });
      _showSuccessDialog();
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.orange[600],
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Compris'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Humeur enregistrée !',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Vous vous sentez ${_selectedMood!.label.toLowerCase()} aujourd\'hui.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Retour à l\'accueil'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        title: const Text(
          'Mon Humeur du Jour',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSection(),
                    const SizedBox(height: 32),
                    _buildMoodSelection(),
                    const SizedBox(height: 32),
                    _buildIntensitySection(),
                    const SizedBox(height: 32),
                    _buildNoteSection(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[50]!, Colors.blue[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comment vous sentez-vous aujourd\'hui ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_getWeekday()}, ${DateTime.now().day} ${_getMonth()} ${DateTime.now().year}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre humeur',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _moodOptions.map((mood) {
            return _buildMoodOption(mood);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodOption(MoodOption mood) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? mood.color.withOpacity(0.2) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? mood.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: mood.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              mood.label,
              style: TextStyle(
                color: isSelected ? mood.color : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensité de l\'émotion',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                _getIntensityLabel(_selectedIntensity),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _selectedIntensity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  setState(() {
                    _selectedIntensity = value.round();
                  });
                },
                activeColor: _selectedMood?.color ?? Colors.blue,
                inactiveColor: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Faible', style: TextStyle(color: Colors.grey[600])),
                  Text('Moyenne', style: TextStyle(color: Colors.grey[600])),
                  Text('Forte', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajouter une note (optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Pourquoi vous sentez-vous ainsi ? Qu\'est-ce qui influence votre humeur aujourd\'hui ?',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedMood?.color ?? Colors.grey[300],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: _isSubmitting ? null : _submitMood,
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_emotions, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'ENREGISTRER MON HUMEUR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getWeekday() {
    final weekdays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return weekdays[DateTime.now().weekday - 1];
  }

  String _getMonth() {
    final months = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return months[DateTime.now().month - 1];
  }

  String _getIntensityLabel(int intensity) {
    switch (intensity) {
      case 1: return 'Très légère';
      case 2: return 'Légère';
      case 3: return 'Moyenne';
      case 4: return 'Intense';
      case 5: return 'Très intense';
      default: return 'Moyenne';
    }
  }
}