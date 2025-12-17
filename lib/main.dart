import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/task.dart';
import 'widgets/flip_clock.dart';
import 'widgets/full_screen_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metopi Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TaskTimerScreen(),
    );
  }
}

class TaskTimerScreen extends StatefulWidget {
  const TaskTimerScreen({super.key});

  @override
  State<TaskTimerScreen> createState() => _TaskTimerScreenState();
}

class _TaskTimerScreenState extends State<TaskTimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFullScreen = false;
  Task? _selectedTask;

  final List<Task> _tasks = Task.defaultTasks;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectTask(Task task) {
    if (_isRunning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTask = task;
      _remainingSeconds = task.durationSeconds;
    });
  }

  void _startTimer() {
    if (_selectedTask == null || _remainingSeconds <= 0) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      if (_selectedTask != null) {
        _remainingSeconds = _selectedTask!.durationSeconds;
      }
    });
  }

  void _completeTimer() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    _showCompletionDialog();
  }

  void _toggleFullScreen() {
    if (_selectedTask == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedTask?.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.celebration,
                  color: _selectedTask?.color ?? Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Task Complete!',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
        content: Text(
          '${_selectedTask?.name ?? "Timer"} session finished!\nGreat job staying focused.',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
              if (_isFullScreen) {
                setState(() => _isFullScreen = false);
              }
            },
            child: Text('DONE',
                style: TextStyle(
                    color: _selectedTask?.color ?? const Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker() {
    if (_isRunning || _selectedTask == null) return;

    int hours = _remainingSeconds ~/ 3600;
    int minutes = (_remainingSeconds % 3600) ~/ 60;
    int seconds = _remainingSeconds % 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final size = MediaQuery.of(context).size;
          return Container(
            height: size.height * 0.55,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Set Duration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedTask?.name ?? '',
                  style: TextStyle(
                    color: _selectedTask?.color ?? Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPickerColumn('Hours', hours, 24, (val) {
                      setModalState(() => hours = val);
                    }),
                    const SizedBox(width: 16),
                    const Text(':',
                        style: TextStyle(color: Colors.white54, fontSize: 40)),
                    const SizedBox(width: 16),
                    _buildPickerColumn('Minutes', minutes, 60, (val) {
                      setModalState(() => minutes = val);
                    }),
                    const SizedBox(width: 16),
                    const Text(':',
                        style: TextStyle(color: Colors.white54, fontSize: 40)),
                    const SizedBox(width: 16),
                    _buildPickerColumn('Seconds', seconds, 60, (val) {
                      setModalState(() => seconds = val);
                    }),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final totalSeconds =
                            hours * 3600 + minutes * 60 + seconds;
                        if (totalSeconds > 0) {
                          setState(() {
                            _remainingSeconds = totalSeconds;
                            _selectedTask!.durationSeconds = totalSeconds;
                          });
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTask?.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Set Duration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPickerColumn(
      String label, int value, int maxValue, Function(int) onChanged) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: maxValue,
              builder: (context, index) => Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: index == value ? Colors.white : Colors.white38,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show full screen timer
    if (_isFullScreen && _selectedTask != null) {
      return FullScreenTimer(
        remainingSeconds: _remainingSeconds,
        totalSeconds: _selectedTask!.durationSeconds,
        taskName: _selectedTask!.name,
        accentColor: _selectedTask!.color,
        isRunning: _isRunning,
        isPaused: _isPaused,
        onPlay: _startTimer,
        onPause: _pauseTimer,
        onReset: _resetTimer,
        onClose: () => setState(() => _isFullScreen = false),
      );
    }

    return _buildNormalView();
  }

  Widget _buildNormalView() {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(hours, minutes, seconds, size)
            : _buildPortraitLayout(hours, minutes, seconds, size),
      ),
    );
  }

  Widget _buildPortraitLayout(int hours, int minutes, int seconds, Size size) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height - MediaQuery.of(context).padding.vertical,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              _buildHeader(size),
              SizedBox(height: size.height * 0.02),
              _buildTaskList(size, Axis.horizontal),
              const Spacer(),
              _buildTimerDisplay(hours, minutes, seconds, size),
              const Spacer(),
              if (_selectedTask != null) _buildProgressBar(size),
              SizedBox(height: size.height * 0.02),
              _buildControlButtons(size),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(int hours, int minutes, int seconds, Size size) {
    return Row(
      children: [
        // Left panel - Tasks
        Container(
          width: size.width * 0.25,
          padding: EdgeInsets.all(size.width * 0.015),
          child: Column(
            children: [
              _buildHeader(size, compact: true),
              SizedBox(height: size.height * 0.02),
              Expanded(child: _buildTaskList(size, Axis.vertical)),
            ],
          ),
        ),
        // Right panel - Timer
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimerDisplay(hours, minutes, seconds, size,
                      isLandscape: true),
                  SizedBox(height: size.height * 0.03),
                  if (_selectedTask != null)
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: _buildProgressBar(size),
                    ),
                  SizedBox(height: size.height * 0.03),
                  _buildControlButtons(size, isLandscape: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Size size, {bool compact = false}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: compact ? 8 : size.width * 0.05),
      child: Row(
        children: [
          Flexible(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
              ).createShader(bounds),
              child: Text(
                compact ? 'METOPI' : 'METOPI',
                style: TextStyle(
                  fontSize: compact ? 18 : size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: compact ? 1 : 3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _showAddTaskDialog,
            icon: Icon(Icons.add_circle_outline,
                color: Colors.white54, size: compact ? 20 : 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(Size size, Axis direction) {
    final isHorizontal = direction == Axis.horizontal;
    final itemSize = isHorizontal ? size.width * 0.22 : size.height * 0.12;

    return SizedBox(
      height: isHorizontal ? size.height * 0.13 : null,
      child: ListView.builder(
        scrollDirection: direction,
        padding: EdgeInsets.symmetric(
          horizontal: isHorizontal ? size.width * 0.04 : 0,
          vertical: isHorizontal ? 0 : size.height * 0.01,
        ),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final isSelected = _selectedTask?.id == task.id;
          return GestureDetector(
            onTap: () => _selectTask(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isHorizontal ? itemSize : null,
              height: isHorizontal ? null : itemSize * 0.7,
              margin: EdgeInsets.symmetric(
                horizontal: isHorizontal ? size.width * 0.015 : 0,
                vertical: isHorizontal ? 0 : size.height * 0.008,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isHorizontal ? 20 : 16),
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [task.color, task.color.withOpacity(0.6)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF1E1E2E),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : task.color.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: task.color.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: isHorizontal
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          task.icon,
                          color: isSelected ? Colors.white : task.color,
                          size: itemSize * 0.35,
                        ),
                        SizedBox(height: size.height * 0.008),
                        Text(
                          task.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: itemSize * 0.12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Icon(
                            task.icon,
                            color: isSelected ? Colors.white : task.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.name,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerDisplay(int hours, int minutes, int seconds, Size size,
      {bool isLandscape = false}) {
    final textScale = isLandscape ? size.height * 0.05 : size.width * 0.04;
    final statusScale = isLandscape ? size.height * 0.03 : size.width * 0.028;
    final iconScale = isLandscape ? size.height * 0.05 : size.width * 0.05;

    return GestureDetector(
      onTap: _showDurationPicker,
      onDoubleTap: _toggleFullScreen,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedTask != null) ...[
            Text(
              _selectedTask!.name.toUpperCase(),
              style: TextStyle(
                color: _selectedTask!.color,
                fontSize: textScale,
                fontWeight: FontWeight.bold,
                letterSpacing: isLandscape ? 2 : 4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.008),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _isRunning
                        ? 'RUNNING'
                        : (_isPaused ? 'PAUSED' : 'TAP TO SET TIME'),
                    style: TextStyle(
                      color: _isRunning ? _selectedTask!.color : Colors.white38,
                      fontSize: statusScale,
                      letterSpacing: isLandscape ? 1 : 2,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleFullScreen,
                  child: Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white38,
                    size: iconScale,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'SELECT A TASK',
              style: TextStyle(
                color: Colors.white38,
                fontSize: textScale,
                fontWeight: FontWeight.bold,
                letterSpacing: isLandscape ? 2 : 4,
              ),
            ),
          ],
          SizedBox(height: size.height * 0.02),
          FlipClock(
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            accentColor: _selectedTask?.color ?? const Color(0xFF6C63FF),
            isRunning: _isRunning,
            isLandscape: isLandscape,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Size size) {
    final progress = _selectedTask!.durationSeconds > 0
        ? _remainingSeconds / _selectedTask!.durationSeconds
        : 0.0;
    final isLandscape = size.width > size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? size.width * 0.05 : size.width * 0.1),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF2A2A3E),
              valueColor: AlwaysStoppedAnimation<Color>(_selectedTask!.color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% remaining',
            style: TextStyle(
              color: Colors.white38,
              fontSize: isLandscape ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(Size size, {bool isLandscape = false}) {
    final buttonSize = isLandscape ? size.height * 0.1 : size.width * 0.14;
    final mainButtonSize = isLandscape ? size.height * 0.14 : size.width * 0.2;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? size.width * 0.05 : size.width * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.refresh_rounded,
            onPressed: _resetTimer,
            size: buttonSize,
          ),
          SizedBox(width: isLandscape ? 24 : 16),
          _buildMainButton(size: mainButtonSize),
          SizedBox(width: isLandscape ? 24 : 16),
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            onPressed: () {
              if (_selectedTask != null) {
                final currentIndex = _tasks.indexOf(_selectedTask!);
                final nextIndex = (currentIndex + 1) % _tasks.length;
                _selectTask(_tasks[nextIndex]);
              }
            },
            size: buttonSize,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2A3E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white70, size: size * 0.45),
      ),
    );
  }

  Widget _buildMainButton({required double size}) {
    final color = _selectedTask?.color ?? const Color(0xFF6C63FF);
    final isDisabled = _selectedTask == null;

    return GestureDetector(
      onTap: isDisabled ? null : (_isRunning ? _pauseTimer : _startTimer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isDisabled
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
          color: isDisabled ? const Color(0xFF2A2A3E) : null,
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Icon(
          _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: isDisabled ? Colors.white38 : Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.work;
    Color selectedColor = const Color(0xFF6C63FF);

    final icons = [
      Icons.work,
      Icons.code,
      Icons.brush,
      Icons.music_note,
      Icons.sports_esports,
      Icons.restaurant,
      Icons.flight,
      Icons.shopping_cart,
      Icons.pets,
      Icons.favorite,
    ];

    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B9D),
      const Color(0xFFFFB86C),
      const Color(0xFF50FA7B),
      const Color(0xFF8BE9FD),
      const Color(0xFFBD93F9),
      const Color(0xFFFF5555),
      const Color(0xFFF1FA8C),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'New Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Task name',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF2A2A3E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(selectedIcon, color: selectedColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Icon', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: icons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedColor
                                : const Color(0xFF2A2A3E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon,
                              color:
                                  isSelected ? Colors.white : Colors.white54),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Color', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: colors.map((color) {
                      final isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          setState(() {
                            _tasks.add(Task(
                              id: DateTime.now().toString(),
                              name: nameController.text,
                              icon: selectedIcon,
                              color: selectedColor,
                              durationSeconds: 25 * 60,
                            ));
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create Task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
