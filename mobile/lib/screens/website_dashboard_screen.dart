import 'package:flutter/material.dart';

import '../main.dart' show HpcApi, hpcBlue;

class WebsiteDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? business;

  const WebsiteDashboardScreen({super.key, this.business});

  @override
  State<WebsiteDashboardScreen> createState() => _WebsiteDashboardScreenState();
}

class _WebsiteDashboardScreenState extends State<WebsiteDashboardScreen> {
  Map<String, dynamic> dashboard = {};
  bool loading = true;
  String? error;

  int? get _businessId {
    final item = widget.business;
    return int.tryParse(
      (item?['id'] ?? item?['business_id'] ?? HpcApi.selectedBusinessId ?? '')
          .toString(),
    );
  }

  String get _businessName =>
      (widget.business?['name'] ??
              widget.business?['business_name'] ??
              _dashboardBusiness['name'] ??
              'Website Dashboard')
          .toString();
  Map<String, dynamic> get _dashboardBusiness {
    final value = dashboard["business"];
    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  Map<String, dynamic> get _primaryWebsite {
    final value = dashboard["websites"];
    if (value is List) {
      for (final item in value) {
        if (item is Map) return Map<String, dynamic>.from(item);
      }
    }
    return <String, dynamic>{};
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final id = _businessId;

    if (!HpcApi.isLoggedIn) {
      setState(() {
        loading = false;
        error = 'कृपया पहले Login करें।';
      });
      return;
    }

    if (id == null || id <= 0) {
      setState(() {
        loading = false;
        error = 'Business ID उपलब्ध नहीं है। वापस जाकर Website चुनें।';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await HpcApi.getBusinessDashboard(id);
      if (!mounted) return;
      setState(() {
        dashboard = result['dashboard'] is Map
            ? Map<String, dynamic>.from(result['dashboard'])
            : result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        loading = false;
      });
    }
  }

  dynamic _findValue(List<String> keys) {
    dynamic search(dynamic value) {
      if (value is Map) {
        for (final entry in value.entries) {
          if (keys.contains(entry.key.toString().toLowerCase()) &&
              entry.value != null) {
            return entry.value;
          }
        }
        for (final entry in value.entries) {
          final found = search(entry.value);
          if (found != null) return found;
        }
      } else if (value is List) {
        for (final item in value) {
          final found = search(item);
          if (found != null) return found;
        }
      }
      return null;
    }

    return search(dashboard);
  }

  Widget _infoCard(String title, dynamic value, IconData icon) {
    final text = value == null || value.toString().trim().isEmpty
        ? 'अभी उपलब्ध नहीं'
        : value.toString();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: hpcBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rawData() {
    final stats = dashboard['statistics'] is Map
        ? Map<String, dynamic>.from(dashboard['statistics'])
        : <String, dynamic>{};

    Widget metric(String title, dynamic data) {
      final values = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (values.isEmpty)
            const Text(
              'अभी कोई डेटा उपलब्ध नहीं',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...values.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _infoCard(
                  e.key.replaceAll('_', ' ').toUpperCase(),
                  e.value,
                  Icons.analytics_outlined,
                ),
              ),
            ),
          const SizedBox(height: 18),
        ],
      );
    }

    Widget records(String title, dynamic data, List<String> fields) {
      final items = data is List ? data.whereType<Map>().toList() : [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text(
              'अभी कोई डेटा उपलब्ध नहीं',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...items.map(
              (item) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5EAF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fields
                      .where((key) => item[key] != null)
                      .map(
                        (key) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: SelectableText(
                            '${key.replaceAll('_', ' ').toUpperCase()}: ${item[key]}',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 18),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        metric('Website Statistics', stats['websites']),
        metric('Scan Statistics', stats['scans']),
        metric('Audit Reports', stats['audits']),
        metric('Support Tickets', stats['support_tickets']),
        metric('Other Statistics', {
          'Documents': stats['documents'] ?? 0,
          'AI Chats': stats['ai_chats'] ?? 0,
        }),
        records('Connected Websites', dashboard['websites'], [
          'website_url',
          'status',
          'access_mode',
          'last_checked_at',
        ]),
        records('Recent Activity', dashboard['recent_activity'], [
          'event_type',
          'event_details',
          'created_at',
        ]),
        _infoCard(
          'Dashboard Generated',
          dashboard['generated_at'],
          Icons.update,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Website Dashboard'),
        backgroundColor: hpcBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5EAF2)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.language, color: hpcBlue, size: 27),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _businessName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(35),
                child: Center(child: CircularProgressIndicator(color: hpcBlue)),
              )
            else if (error != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 36,
                    ),
                    const SizedBox(height: 10),
                    Text(error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _loadDashboard,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else ...[
              const Text(
                'Website Overview',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _infoCard(
                'Website URL',
                widget.business?['website_url'] ??
                    widget.business?['url'] ??
                    _primaryWebsite['website_url'] ??
                    _dashboardBusiness['website_url'],
                Icons.link,
              ),
              const SizedBox(height: 10),
              _infoCard(
                'Website Status',
                _primaryWebsite['status'],
                Icons.verified_outlined,
              ),
              const SizedBox(height: 10),
              _infoCard(
                'Last Updated',
                _primaryWebsite['last_checked_at'] ?? dashboard['generated_at'],
                Icons.update,
              ),
              const SizedBox(height: 20),
              const Text(
                'Available Website Data',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _rawData(),
              const SizedBox(height: 14),
              const Text(
                'नोट: SEO, Performance और Security की रिपोर्ट तभी दिखाई जाएगी जब Server API उनका वास्तविक डेटा उपलब्ध कराएगी।',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
