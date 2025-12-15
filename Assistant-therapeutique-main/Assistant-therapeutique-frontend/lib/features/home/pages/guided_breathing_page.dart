import 'dart:async';
import 'package:flutter/material.dart';

class GuidedBreathingPage extends StatefulWidget {
  const GuidedBreathingPage({super.key});

  @override
  State<GuidedBreathingPage> createState() => _GuidedBreathingPageState();
}

class _GuidedBreathingPageState extends State<GuidedBreathingPage> {
  final List<_BreathPhase> phases = const [
    _BreathPhase(label: "Inspirez doucement", seconds: 4),
    _BreathPhase(label: "Bloquez votre respiration", seconds: 4),
    _BreathPhase(label: "Expirez lentement", seconds: 6),
  ];

  int currentPhaseIndex = 0;
  int remainingSeconds = 0;
  Timer? _timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    remainingSeconds = phases.first.seconds;
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
        setState(() => remainingSeconds--);
      } else {
        if (currentPhaseIndex < phases.length - 1) {
          setState(() {
            currentPhaseIndex++;
            remainingSeconds = phases[currentPhaseIndex].seconds;
          });
        } else {
          setState(() {
            currentPhaseIndex = 0;
            remainingSeconds = phases[0].seconds;
            isRunning = false;
          });
          timer.cancel();
        }
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
      currentPhaseIndex = 0;
      remainingSeconds = phases[0].seconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhase = phases[currentPhaseIndex];
    final totalSeconds = currentPhase.seconds;
    final progress = 1 - (remainingSeconds / totalSeconds);

    final double baseSize = 190;
    final double size =
        currentPhaseIndex == 0
            ? baseSize + 32 * progress
            : currentPhaseIndex == 2
            ? baseSize + 32 * (1 - progress)
            : baseSize;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2A4A)),
        centerTitle: true,
        title: const Text(
          "Respiration guidée",
          style: TextStyle(
            color: Color(0xFF1A2A4A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7FAFF), Color(0xFFE6F7F6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Exercice 4–4–6",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2A4A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Suis le rythme pour apaiser ton corps et ton esprit.",
                style: TextStyle(color: Color(0xFF6B7A99), fontSize: 13),
              ),
              const SizedBox(height: 30),

              // cercle animé
              Expanded(
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    height: size,
                    width: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF7BE7C7), // vert menthe clair
                          Color(0xFF32BFA6), // vert turquoise
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF32BFA6).withOpacity(0.45),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.spa_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${remainingSeconds}s",
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  currentPhase.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2A4A),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: Colors.white.withOpacity(0.6),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF32BFA6)),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _startOrPause,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D62F0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 4,
                    ),
                    child: Text(isRunning ? "Pause" : "Démarrer"),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4D62F0),
                      side: const BorderSide(color: Color(0xFFBFC8FF)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text("Réinitialiser"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "Conseils",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2A4A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "• Assieds-toi confortablement, le dos détendu.\n"
                "• Relâche tes épaules et ta mâchoire.\n"
                "• Inspire par le nez, expire doucement par la bouche.\n"
                "• Si tu veux, ferme les yeux et concentre-toi sur l’air qui entre et qui sort.",
                style: TextStyle(
                  color: Color(0xFF6B7A99),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathPhase {
  final String label;
  final int seconds;

  const _BreathPhase({required this.label, required this.seconds});
}
