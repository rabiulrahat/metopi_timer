import 'package:flutter/material.dart';

class Task {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  int durationSeconds;

  Task({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.durationSeconds,
  });

  static List<Task> defaultTasks = [
    Task(
      id: '1',
      name: 'Deep Work',
      icon: Icons.psychology,
      color: const Color(0xFF6C63FF),
      durationSeconds: 2 * 60 * 60,
    ),
    Task(
      id: '2',
      name: 'Study',
      icon: Icons.menu_book,
      color: const Color(0xFFFF6B9D),
      durationSeconds: 1 * 60 * 60,
    ),
    Task(
      id: '3',
      name: 'Exercise',
      icon: Icons.fitness_center,
      color: const Color(0xFFFFB86C),
      durationSeconds: 45 * 60,
    ),
    Task(
      id: '4',
      name: 'Reading',
      icon: Icons.auto_stories,
      color: const Color(0xFF50FA7B),
      durationSeconds: 30 * 60,
    ),
    Task(
      id: '5',
      name: 'Meditation',
      icon: Icons.self_improvement,
      color: const Color(0xFF8BE9FD),
      durationSeconds: 15 * 60,
    ),
    Task(
      id: '6',
      name: 'Break',
      icon: Icons.coffee,
      color: const Color(0xFFBD93F9),
      durationSeconds: 10 * 60,
    ),
  ];
}
