import 'package:flutter/material.dart';
import 'package:moodmate/models/mood_model.dart';
import 'package:moodmate/services/mood_service.dart';
import 'package:moodmate/features/mood/pages/mood_tracking_page.dart';

class MoodHistoryPage extends StatefulWidget {
  const MoodHistoryPage({super.key});

  @override
  State<MoodHistoryPage> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  final MoodService _moodService = MoodService();
  late Future<List<Mood>> _moodsFuture;

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  void _loadMoods() {
    setState(() {
      _moodsFuture = _moodService.getMoods();
    });
  }

  void _deleteMood(int moodId) async {
    final result = await _moodService.deleteMood(moodId);
    if (result['success'] == true) {
      _loadMoods(); // Refresh the list
    } else {
      // Show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete mood.'),
          ),
        );
      }
    }
  }

  void _editMood(Mood mood) async {
    // Navigate to the tracking page in edit mode
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodTrackingPage(moodToEdit: mood),
      ),
    );
    // Refresh the list after returning from the edit page
    _loadMoods();
  }

  void _confirmDeleteMood(int moodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette humeur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Dismisses the dialog
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismisses the dialog
              _deleteMood(moodId); // Perform the delete operation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Red color for delete action
            ),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
          'Historique des Humeurs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Mood>>(
          future: _moodsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun historique d\'humeur trouvé.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final moods = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: moods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mood = moods[index];
                return _buildMoodCard(mood);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMoodCard(Mood mood) {
    final moodDetails = _parseMood(mood.mood);
    final color = _getMoodColor(moodDetails['label']);
    final icon = _getMoodIcon(moodDetails['label']);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moodDetails['label'] ?? 'Humeur',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.createdAt != null
                        ? '${mood.createdAt!.toLocal()}'.split(' ')[0]
                        : 'Pas de date',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey[600]),
              onPressed: () => _editMood(mood),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[400]),
              onPressed: () => _confirmDeleteMood(mood.id!),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String?> _parseMood(String moodString) {
    final parts = moodString.split(' (');
    final label = parts[0];
    final intensity = parts.length > 1 ? parts[1].replaceAll(')', '') : null;
    return {'label': label, 'intensity': intensity};
  }

  Color _getMoodColor(String? label) {
    switch (label) {
      case 'Triste':
        return Colors.blue;
      case 'Neutre':
        return Colors.grey;
      case 'Content':
        return Colors.orange;
      case 'Heureux':
        return Colors.green;
      case 'Épanoui':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getMoodIcon(String? label) {
    switch (label) {
      case 'Triste':
        return Icons.sentiment_very_dissatisfied;
      case 'Neutre':
        return Icons.sentiment_neutral;
      case 'Content':
        return Icons.sentiment_satisfied;
      case 'Heureux':
        return Icons.sentiment_very_satisfied;
      case 'Épanoui':
        return Icons.favorite;
      default:
        return Icons.help_outline;
    }
  }
}
