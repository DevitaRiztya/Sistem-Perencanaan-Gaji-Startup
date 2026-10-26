import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Halaman Aplikasi Stopwatch dengan Start, Pause, Resume, Reset, dan Lap Tracking
class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<String> _laps = [];

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handleStart() {
    _stopwatch.start();
    _startTimer();
    setState(() {});
  }

  void _handlePause() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _handleReset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _laps.clear();
    setState(() {});
  }

  void _handleLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _formattedTime);
      });
    }
  }

  @override
  void dispose() {
    // Pastikan timer dihentikan dengan benar saat widget di-dispose agar tidak memory leak
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String get _formattedTime {
    final elapsed = _stopwatch.elapsed;
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (elapsed.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds.$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _stopwatch.isRunning;
    final isPaused = !isRunning && _stopwatch.elapsedMilliseconds > 0;
    final isInitial = !isRunning && _stopwatch.elapsedMilliseconds == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Stopwatch'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const Spacer(),

                // Display Timer Circle
                Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: isRunning
                          ? AppTheme.primary
                          : isPaused
                              ? AppTheme.secondary
                              : const Color(0xFFE2E8F0),
                      width: 6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isRunning
                            ? AppTheme.primary.withOpacity(0.15)
                            : isPaused
                                ? AppTheme.secondary.withOpacity(0.15)
                                : Colors.black.withOpacity(0.04),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRunning
                            ? Icons.timer_outlined
                            : isPaused
                                ? Icons.pause_circle_outline
                                : Icons.access_time_rounded,
                        size: 32,
                        color: isRunning
                            ? AppTheme.primary
                            : isPaused
                                ? AppTheme.secondary
                                : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formattedTime,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isRunning
                              ? AppTheme.primary
                              : isPaused
                                  ? AppTheme.secondary
                                  : AppTheme.mainText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: isRunning
                              ? AppTheme.surfaceContainer
                              : isPaused
                                  ? AppTheme.secondaryContainer
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isRunning
                              ? 'BERJALAN'
                              : isPaused
                                  ? 'DIHENTIKAN SEMENTARA'
                                  : 'SIAP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: isRunning
                                ? AppTheme.primary
                                : isPaused
                                    ? AppTheme.secondary
                                    : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset Button
                    OutlinedButton(
                      onPressed: isInitial ? null : _handleReset,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(18),
                        side: BorderSide(
                          color: isInitial ? Colors.grey.shade300 : Colors.redAccent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: isInitial ? Colors.grey.shade400 : Colors.redAccent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Primary Start / Pause / Resume Button
                    FilledButton(
                      onPressed: isRunning
                          ? _handlePause
                          : _handleStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: isRunning ? AppTheme.secondary : AppTheme.primary,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                        elevation: 4,
                      ),
                      child: Icon(
                        isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Lap Button
                    OutlinedButton(
                      onPressed: isRunning ? _handleLap : null,
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(18),
                        side: BorderSide(
                          color: isRunning ? AppTheme.primary : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.flag_outlined,
                        color: isRunning ? AppTheme.primary : Colors.grey.shade400,
                        size: 26,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Laps List
                if (_laps.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'CATATAN PUTARAN (LAPS)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      itemCount: _laps.length,
                      separatorBuilder: (context, index) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lap #${_laps.length - index}',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                              ),
                              Text(
                                _laps[index],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.mainText),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
