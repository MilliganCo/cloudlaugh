import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const CloudLaughApp());
}

class CloudLaughApp extends StatelessWidget {
  const CloudLaughApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudLaugh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD700)),
        useMaterial3: true,
      ),
      home: const LaughPage(),
    );
  }
}

class LaughPage extends StatefulWidget {
  const LaughPage({super.key});

  @override
  State<LaughPage> createState() => _LaughPageState();
}

class _LaughPageState extends State<LaughPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  bool _isPlaying = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // All laugh sounds bundled in assets/sounds/
  static const List<String> _laughSounds = [
    'sounds/laugh_01.mp3',
    'sounds/laugh_02.mp3',
    'sounds/laugh_03.mp3',
    'sounds/laugh_04.mp3',
    'sounds/laugh_05.mp3',
    'sounds/laugh_06.mp3',
    'sounds/laugh_07.mp3',
    'sounds/laugh_08.mp3',
    'sounds/laugh_09.mp3',
    'sounds/laugh_10.mp3',
    'sounds/laugh_11.mp3',
    'sounds/laugh_12.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _playRandomLaugh() async {
    final sound = _laughSounds[_random.nextInt(_laughSounds.length)];
    await _player.stop();
    setState(() => _isPlaying = true);
    _shakeController
      ..reset()
      ..forward();
    await _player.play(AssetSource(sound));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final offset = _isPlaying
                      ? 12 * sin(_shakeAnimation.value * pi * 6)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: const Text(
                  '😂',
                  style: TextStyle(fontSize: 100),
                ),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: _playRandomLaugh,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _isPlaying
                          ? [const Color(0xFFFF6B35), const Color(0xFFFF1744)]
                          : [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isPlaying
                                ? const Color(0xFFFF1744)
                                : const Color(0xFFFFD700))
                            .withOpacity(0.5),
                        blurRadius: _isPlaying ? 40 : 20,
                        spreadRadius: _isPlaying ? 10 : 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPlaying
                            ? Icons.volume_up_rounded
                            : Icons.play_arrow_rounded,
                        size: 90,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isPlaying ? 'ХА-ХА-ХА!' : 'СМЕЙСЯ!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                '${_laughSounds.length} видов смеха',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
