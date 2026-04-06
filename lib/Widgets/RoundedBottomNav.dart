import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';

class RoundedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const RoundedBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          /// 🔵 Bottom pill bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 68,
            decoration: BoxDecoration(
              color: AppTheme.bottomNavbarColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(Icons.grid_view, "Dashboard", 0),
                _navItem(Icons.group, "Leads", 1),
                const SizedBox(width: 60), // space for QR
                _navItem(Icons.event, "Event", 2),
                _navItem(Icons.settings, "Setting", 3),
              ],
            ),
          ),

          /// 🔵 Floating Scan QR
          Positioned(
            bottom: 15,
            child: GestureDetector(
              onTap: () => onTap(4),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                    Icon(Icons.qr_code_scanner, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      'Scan QR \nCode',textAlign: TextAlign.center,
                      style: MyStyles.boldText(size: 8, color: AppTheme.bottomBgColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white54,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? Colors.white : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
