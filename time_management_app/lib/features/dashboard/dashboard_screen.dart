import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Obx(() => Text(
            'Chào, ${AuthService.to.userName.value} 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          )),
          const SizedBox(height: 4),
          Text(
            _getDateString(),
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),

          const SizedBox(height: 24),

          // Daily progress card
          _buildProgressCard(),

          const SizedBox(height: 20),

          // Quick stats
          Row(
            children: [
              Expanded(child: _buildStatCard('0', 'Task hôm nay', Icons.task_alt_rounded, const Color(0xFF6C63FF))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('0', 'Pomodoro', Icons.timer_rounded, const Color(0xFFFF6B6B))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('0h', 'Tập trung', Icons.access_time_rounded, const Color(0xFF4ECDC4))),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Sắp tới',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildEmptyState('Chưa có sự kiện nào hôm nay', Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    const days = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    return '${days[now.weekday % 7]}, ${now.day}/${now.month}/${now.year}';
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mục tiêu hôm nay', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('0 / 480 phút', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Bắt đầu ngày mới thôi! 💪', style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 36),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}