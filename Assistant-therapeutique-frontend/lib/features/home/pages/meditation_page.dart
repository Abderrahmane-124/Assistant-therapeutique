import 'dart:async';
import 'package:flutter/material.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  Timer? _timer;

  // 2 minutes = 120 secondes
  final int totalSeconds = 120;
  int remainingSeconds = 120;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true); // animation douce du cercle
  }

  void _startOrPause() {
    if (isRunning) {
      _timer?.cancel();
      setState(() => isRunning = false);
      return;
    }

    setState(() => isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 1) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        // fin de la méditation
        timer.cancel();
        _breathController.stop();
        setState(() {
          isRunning = false;
          remainingSeconds = 0;
        });
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = totalSeconds;
    });
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int minutes = remainingSeconds ~/ 60;
    final int seconds = remainingSeconds % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2A4A)),
        centerTitle: true,
        title: const Text(
          "Méditation 2 min",
          style: TextStyle(
            color: Color(0xFF1A2A4A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F9FF),
              Color(0xFFE8F7FA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              const Text(
                "Relaxation guidée",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2A4A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Installe-toi confortablement et respire calmement.",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // cercle animé zen + timer
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, child) {
                      final double scale = 1 + (_breathController.value * 0.20);

                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFF89D4C9),
                                Color(0xFF5BB9A8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF53B6A1).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "$minutes:${seconds.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _startOrPause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D62F0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      isRunning ? "Pause" : "Démarrer",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4D62F0),
                      side: const BorderSide(color: Color(0xFFBFC8FF)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      "Réinitialiser",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // conseils
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Conseils",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2A4A),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "• Garde ton dos droit et détendu.\n"
                  "• Inspire profondément par le nez.\n"
                  "• Détends tes épaules.\n"
                  "• Laisse tes pensées passer sans t’y accrocher.",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF6B7A99),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
