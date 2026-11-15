import 'package:flutter/material.dart';

import '../main.dart' show HpcApi, hpcBlue;
import 'website_dashboard_screen.dart';

class ConnectWebsiteScreen extends StatefulWidget {
  const ConnectWebsiteScreen({super.key});

  @override
  State<ConnectWebsiteScreen> createState() => _ConnectWebsiteScreenState();
}

class _ConnectWebsiteScreenState extends State<ConnectWebsiteScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> businesses = [];
  bool loading = true;
  bool connecting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    if (!HpcApi.isLoggedIn) {
      setState(() {
        loading = false;
        error = 'वेबसाइट जोड़ने के लिए पहले Login करें।';
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await HpcApi.getBusinesses();
      final enrichedBusinesses = <Map<String, dynamic>>[];
      for (final business in result) {
        final id = int.tryParse(
          (business["id"] ?? business["business_id"] ?? "").toString(),
        );
        if (id != null && id > 0) {
          try {
            business["website_connections"] = await HpcApi.getBusinessWebsites(
              id,
            );
          } catch (_) {
            business["website_connections"] = <Map<String, dynamic>>[];
          }
        }
        enrichedBusinesses.add(business);
      }
      if (!mounted) return;
      setState(() {
        businesses = enrichedBusinesses;
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

  Future<void> _connectWebsite() async {
    if (!HpcApi.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("कृपया पहले Login करें।")));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        uri.scheme != 'https' ||
        uri.host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'कृपया सही Website URL डालें। उदाहरण: https://example.com',
          ),
        ),
      );
      return;
    }

    setState(() => connecting = true);

    try {
      await HpcApi.createBusiness(
        name: _nameController.text.trim(),
        websiteUrl: url,
      );

      if (!mounted) return;
      _nameController.clear();
      _urlController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Website जोड़ने की Request सफलतापूर्वक भेजी गई।'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadBusinesses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => connecting = false);
    }
  }

  String _businessName(Map<String, dynamic> item) {
    return (item['name'] ?? item['business_name'] ?? 'Unnamed Business')
        .toString();
  }

  String _businessUrl(Map<String, dynamic> item) {
    return (item['website_url'] ?? item['url'] ?? '').toString();
  }

  String _status(Map<String, dynamic> item) {
    final connections = item["website_connections"];
    if (connections is List && connections.isNotEmpty) {
      final statuses = connections
          .whereType<Map>()
          .map(
            (connection) =>
                (connection["status"] ?? "").toString().toLowerCase(),
          )
          .toList();
      if (statuses.any(
        (value) => ["connected", "success", "verified"].contains(value),
      ))
        return "Connected";
      if (statuses.any(
        (value) =>
            ["failed", "error", "disconnected", "rejected"].contains(value),
      ))
        return "Error";
      if (statuses.any(
        (value) =>
            ["pending", "processing", "queued", "scanning"].contains(value),
      ))
        return "Pending";
    }
    return "Registered";
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Connected':
        return Colors.green;
      case 'Error':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _openBusiness(Map<String, dynamic> item) async {
    final id = int.tryParse(
      (item['id'] ?? item['business_id'] ?? '').toString(),
    );

    if (id == null || id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('इस Website की सही Business ID उपलब्ध नहीं है।'),
        ),
      );
      return;
    }

    await HpcApi.selectBusiness(id);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WebsiteDashboardScreen(business: item)),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.trim().isEmpty ? '$label भरें।' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: hpcBlue),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _businessCard(Map<String, dynamic> item) {
    final name = _businessName(item);
    final url = _businessUrl(item);
    final status = _status(item);
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.language_rounded, color: hpcBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (url.isNotEmpty)
                      Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () => _openBusiness(item),
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hpcBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('HPC Smart AI'),
        backgroundColor: hpcBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadBusinesses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBusinesses,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5EAF2)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 29,
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.language, color: hpcBlue, size: 31),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Connect Your Website',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Center(
                      child: Text(
                        'अपनी Website जोड़ें और उसका Dashboard देखें',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _field(
                      controller: _nameController,
                      label: 'Business Name',
                      hint: 'जैसे: My Business',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 13),
                    _field(
                      controller: _urlController,
                      label: 'Website URL',
                      hint: 'https://example.com',
                      icon: Icons.link_rounded,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 17),
                    SizedBox(
                      width: double.infinity,
                      height: 51,
                      child: ElevatedButton.icon(
                        onPressed: connecting ? null : _connectWebsite,
                        icon: connecting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add_link),
                        label: Text(
                          connecting ? 'Connecting...' : 'Connect Website',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hpcBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Businesses',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${businesses.length} Websites',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'आपकी जुड़ी हुई Websites और उनका Status',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 14),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator(color: hpcBlue)),
              )
            else if (error != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _loadBusinesses,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (businesses.isEmpty)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.language_outlined, color: hpcBlue, size: 38),
                    SizedBox(height: 9),
                    Text('अभी कोई Website Connect नहीं है।'),
                    SizedBox(height: 4),
                    Text(
                      'ऊपर दिए गए Form से पहली Website जोड़ें।',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...businesses.map(_businessCard),
          ],
        ),
      ),
    );
  }
}
