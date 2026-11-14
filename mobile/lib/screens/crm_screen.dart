import 'package:flutter/material.dart';

class CrmScreen extends StatelessWidget {
  const CrmScreen({super.key});

  static const Color blue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('CRM', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.people_alt_rounded, color: Colors.white, size: 35),
                  SizedBox(height: 12),
                  Text(
                    'Customer Relationship Management',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Manage your customers, leads, bookings and follow-ups in one place.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'CRM Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: const [
                _CrmCard(icon: Icons.people_outline, title: 'Customers', description: 'Manage customers'),
                _CrmCard(icon: Icons.person_search_rounded, title: 'Leads', description: 'Track new leads'),
                _CrmCard(icon: Icons.event_note_rounded, title: 'Follow-ups', description: 'Manage reminders'),
                _CrmCard(icon: Icons.calendar_month_rounded, title: 'Bookings', description: 'Track bookings'),
                _CrmCard(icon: Icons.check_circle_outline, title: 'Converted', description: 'Successful leads'),
                _CrmCard(icon: Icons.query_stats_rounded, title: 'Reports', description: 'View CRM reports'),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'CRM Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 38, color: Color(0xFF98A2B3)),
                  SizedBox(height: 10),
                  Text(
                    'No CRM activity yet',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054)),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Your customer and lead activity will appear here when CRM data is connected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF667085), height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrmCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CrmCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CrmScreen.blue, size: 25),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 11, color: Color(0xFF667085))),
        ],
      ),
    );
  }
}
