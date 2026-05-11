import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD600),
          surface: Color(0xFF080808),
        ),
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
  static const _channel = MethodChannel('com.milliganco.cloudlaugh/widget');

  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  bool _isPlaying = false;

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
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playRandomLaugh() async {
    final sound = _laughSounds[_random.nextInt(_laughSounds.length)];
    await _player.stop();
    setState(() => _isPlaying = true);
    await _player.play(AssetSource(sound));
  }

  Future<void> _requestAddWidget() async {
    try {
      final supported = await _channel.invokeMethod<bool>('pinWidget');
      if (supported == false && mounted) {
        _showSnack('Зажми рабочий стол → Виджеты → CloudLaugh');
      }
    } on PlatformException {
      if (mounted) _showSnack('Зажми рабочий стол → Виджеты → CloudLaugh');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Color(0xFFFFD600))),
        backgroundColor: const Color(0xFF161616),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTapDown: (_) => _playRandomLaugh(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPlaying
                          ? const Color(0xFFFFD600)
                          : Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFFFFD600),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'HA',
                        style: TextStyle(
                          color: _isPlaying
                              ? const Color(0xFF080808)
                              : const Color(0xFFFFD600),
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 44),
              child: GestureDetector(
                onTap: _requestAddWidget,
                child: const Text(
                  '+ добавить виджет',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
