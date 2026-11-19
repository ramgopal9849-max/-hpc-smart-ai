import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart' show HpcApi;
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

  int _step = 0;

  bool _detecting = false;
  bool _ownerConfirmed = false;
  bool _verifying = false;
  bool _registered = false;

  String _platform = 'Not detected';
  String _server = 'Unknown';
  String _hosting = 'Unknown';
  String _detectionMessage = 'Enter your website URL to begin detection.';
  String _verificationMessage = '';

  bool? _websiteReachable;
  final bool _connectorLive = false;
  final bool _filesVerified = false;
  final bool _databaseAccess = false;
  bool? _httpsEnabled;

  List<Map<String, dynamic>> businesses = [];
  bool loading = true;
  String? error;

  static const Color _blue = Color(0xFF2563EB);
  static const Color _background = Color(0xFFF4F7FC);
  static const Color _border = Color(0xFFE5EAF2);
  static const Color _green = Color(0xFF16A34A);
  static const Color _orange = Color(0xFFEA8A16);

  static const List<Map<String, dynamic>> _steps = [
    {
      'title': 'Detect Platform',
      'subtitle': 'Website पहचानें',
      'icon': Icons.travel_explore_rounded,
    },
    {
      'title': 'Login & Authorize',
      'subtitle': 'सुरक्षित अनुमति',
      'icon': Icons.verified_user_rounded,
    },
    {
      'title': 'Auto Install',
      'subtitle': 'Connector Setup',
      'icon': Icons.cloud_upload_rounded,
    },
    {
      'title': 'Verify & Connect',
      'subtitle': 'जाँच और कनेक्शन',
      'icon': Icons.check_circle_rounded,
    },
  ];

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
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'वेबसाइट जोड़ने के लिए पहले Login करें।';
      });
      return;
    }

    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await HpcApi.getBusinesses();
      final enriched = <Map<String, dynamic>>[];

      for (final business in result) {
        final id = int.tryParse(
          (business['id'] ?? business['business_id'] ?? '').toString(),
        );

        if (id != null && id > 0) {
          try {
            business['website_connections'] = await HpcApi.getBusinessWebsites(
              id,
            );
          } catch (_) {
            business['website_connections'] = <Map<String, dynamic>>[];
          }
        }

        enriched.add(business);
      }

      if (!mounted) return;
      setState(() {
        businesses = enriched;
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

  Uri? _websiteUri() {
    final value = _urlController.text.trim();
    final uri = Uri.tryParse(value);

    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }

    return uri;
  }

  Future<void> _detectPlatform() async {
    if (!_formKey.currentState!.validate()) return;

    final uri = _websiteUri();

    if (uri == null) {
      _showMessage(
        'कृपया HTTPS वाला सही URL डालें। उदाहरण: https://example.com',
        isError: true,
      );
      return;
    }

    setState(() {
      _detecting = true;
      _platform = 'Detecting...';
      _server = 'Checking...';
      _hosting = 'Unknown';
      _detectionMessage = 'Website से तकनीकी जानकारी प्राप्त की जा रही है।';
    });

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'HPC-Smart-AI-Website-Detector/1.0',
              'Accept': 'text/html,application/xhtml+xml,*/*',
            },
          )
          .timeout(const Duration(seconds: 20));

      final html = response.body.toLowerCase();
      final headers = response.headers.map(
        (key, value) => MapEntry(key.toLowerCase(), value.toLowerCase()),
      );

      final server = headers['server'] ?? 'Not disclosed';
      final poweredBy = headers['x-powered-by'] ?? '';
      final generatorMatch = RegExp(
        r'''<meta[^>]+name=["']generator["'][^>]+content=["']([^"']+)''',
        caseSensitive: false,
      ).firstMatch(response.body);

      String platform = 'Custom / Unknown';
      String hosting = 'Unknown';

      if (html.contains('wp-content') ||
          html.contains('wp-includes') ||
          html.contains('wordpress')) {
        platform = 'WordPress';
      } else if (html.contains('cdn.shopify.com') ||
          html.contains('myshopify.com')) {
        platform = 'Shopify';
      } else if (html.contains('wixstatic.com') || html.contains('wix.com')) {
        platform = 'Wix';
      } else if (html.contains('joomla')) {
        platform = 'Joomla';
      } else if (html.contains('drupal')) {
        platform = 'Drupal';
      } else if (html.contains('webflow.io') || html.contains('webflow.com')) {
        platform = 'Webflow';
      } else if (poweredBy.contains('php')) {
        platform = 'PHP Website';
      } else if (poweredBy.contains('asp.net')) {
        platform = 'ASP.NET';
      }

      if (server.contains('hostinger')) {
        hosting = 'Hostinger (header indication)';
      } else if (server.contains('cloudflare')) {
        hosting = 'Cloudflare / Proxy detected';
      } else if (server.contains('nginx')) {
        hosting = 'Nginx Server (provider unknown)';
      } else if (server.contains('apache')) {
        hosting = 'Apache Server (provider unknown)';
      }

      if (generatorMatch != null) {
        final generator = generatorMatch.group(1) ?? '';
        if (generator.isNotEmpty && platform == 'Custom / Unknown') {
          platform = generator;
        }
      }

      if (!mounted) return;

      setState(() {
        _platform = platform;
        _server = server;
        _hosting = hosting;
        _httpsEnabled = true;
        _websiteReachable =
            response.statusCode >= 200 && response.statusCode < 400;

        _detectionMessage =
            'HTTP ${response.statusCode} — Website ने response दिया। '
            'यह पहचान उपलब्ध public information पर आधारित है।';

        _detecting = false;
      });

      if (_websiteReachable != true) {
        _showMessage(
          'Website ने HTTP ${response.statusCode} response दिया।',
          isError: true,
        );
      } else {
        _showMessage('Platform detection पूरी हुई।');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _platform = 'Detection incomplete';
        _server = 'Unavailable';
        _hosting = 'Unknown';
        _httpsEnabled = true;
        _websiteReachable = false;
        _detectionMessage = 'Website से response प्राप्त नहीं हुआ। कृपया URL और Internet जाँचें।';
        _detecting = false;
      });

      _showMessage(
        'Website की जाँच नहीं हो सकी: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _verifyAndRegister() async {
    final uri = _websiteUri();

    if (uri == null) {
      _showMessage('पहले सही Website URL डालें।', isError: true);
      setState(() => _step = 0);
      return;
    }

    if (!HpcApi.isLoggedIn) {
      _showMessage('कृपया पहले Login करें।', isError: true);
      return;
    }

    if (_formKey.currentState?.validate() != true) {
      setState(() => _step = 0);
      _showMessage('Business Name और Website URL सही भरें।', isError: true);
      return;
    }

    if (_websiteReachable != true) {
      setState(() => _step = 0);
      _showMessage(
        'पहले Step 1 में Website Detection सफल करें।',
        isError: true,
      );
      return;
    }

    if (!_ownerConfirmed) {
      setState(() => _step = 1);
      _showMessage('पहले Website Ownership की पुष्टि करें।', isError: true);
      return;
    }

    setState(() {
      _verifying = true;
      _verificationMessage = 'Website की दोबारा जाँच हो रही है...';
      _websiteReachable = null;
    });

    try {
      final response = await http
          .get(
            uri,
            headers: {'User-Agent': 'HPC-Smart-AI-Website-Verification/1.0'},
          )
          .timeout(const Duration(seconds: 20));

      final reachable = response.statusCode >= 200 && response.statusCode < 400;

      if (!mounted) return;

      setState(() {
        _websiteReachable = reachable;
        _httpsEnabled = uri.scheme == 'https';
        _verificationMessage =
            'HTTP ${response.statusCode} — '
            '${reachable ? 'Website reachable है।' : 'Website response सफल नहीं है।'}';
      });

      if (!reachable) {
        _showMessage(
          'Website reachable नहीं है। Registration नहीं किया गया।',
          isError: true,
        );
        return;
      }

      await HpcApi.createBusiness(
        name: _nameController.text.trim(),
        websiteUrl: uri.toString(),
      );

      if (!mounted) return;

      setState(() {
        _registered = true;
      });

      _showMessage('Website HPC Smart AI में register हो गई।');

      await _loadBusinesses();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _verificationMessage = 'Verification या registration पूरा नहीं हुआ।';
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : _green,
      ),
    );
  }

  void _nextStep() {
    if (_step == 0) {
      if (_websiteReachable != true) {
        _showMessage('पहले Website Detection सफल करें।', isError: true);
        return;
      }
    }

    if (_step == 1 && !_ownerConfirmed) {
      _showMessage(
        'आगे बढ़ने से पहले Website ownership की पुष्टि करें।',
        isError: true,
      );
      return;
    }

    if (_step < 3) {
      setState(() => _step++);
    }
  }

  void _previousStep() {
    if (_step > 0) {
      setState(() => _step--);
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
    final connections = item['website_connections'];

    if (connections is List && connections.isNotEmpty) {
      final statuses = connections
          .whereType<Map>()
          .map(
            (connection) =>
                (connection['status'] ?? '').toString().toLowerCase(),
          )
          .toList();

      if (statuses.any(
        (value) => ['connected', 'success', 'verified'].contains(value),
      )) {
        return 'Connected';
      }

      if (statuses.any(
        (value) =>
            ['failed', 'error', 'disconnected', 'rejected'].contains(value),
      )) {
        return 'Error';
      }

      if (statuses.any(
        (value) =>
            ['pending', 'processing', 'queued', 'scanning'].contains(value),
      )) {
        return 'Pending';
      }
    }

    return 'Registered';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Connected':
        return _green;
      case 'Error':
        return Colors.red;
      case 'Pending':
        return _orange;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _openBusiness(Map<String, dynamic> item) async {
    final id = int.tryParse(
      (item['id'] ?? item['business_id'] ?? '').toString(),
    );

    if (id == null || id <= 0) {
      _showMessage(
        'इस Website की सही Business ID उपलब्ध नहीं है。',
        isError: true,
      );
      return;
    }

    try {
      await HpcApi.selectBusiness(id);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebsiteDashboardScreen(business: item),
        ),
      );
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  Widget _stepProgress() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Website Connection Process',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
              Text(
                'Step ${_step + 1} of 4',
                style: const TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (index) {
              final completed = index < _step;
              final active = index == _step;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            color: index == 0
                                ? Colors.transparent
                                : (completed || active
                                      ? _blue
                                      : const Color(0xFFE5EAF2)),
                          ),
                        ),
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: completed || active
                                ? _blue
                                : const Color(0xFFEAF0F8),
                            border: Border.all(
                              color: active ? _blue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            completed
                                ? Icons.check_rounded
                                : _steps[index]['icon'] as IconData,
                            size: 17,
                            color: completed || active
                                ? Colors.white
                                : Colors.blueGrey,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 4,
                            color: index == 3
                                ? Colors.transparent
                                : (completed ? _blue : const Color(0xFFE5EAF2)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        _steps[index]['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 9.5,
                          height: 1.2,
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: active ? _blue : Colors.blueGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_step + 1) / 4,
              minHeight: 6,
              backgroundColor: const Color(0xFFEAF0F8),
              valueColor: const AlwaysStoppedAnimation<Color>(_blue),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _blue, size: 25),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String message,
    Color color = _blue,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF475467),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _blue),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
      ),
    );
  }

  Widget _stepOne() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              'Detect Platform',
              'पहले अपनी Website की जानकारी प्राप्त करें',
              Icons.travel_explore_rounded,
            ),
            const SizedBox(height: 20),
            _textField(
              controller: _nameController,
              label: 'Business Name',
              hint: 'जैसे: My Business',
              icon: Icons.business_outlined,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Business Name भरें।'
                  : null,
            ),
            const SizedBox(height: 14),
            _textField(
              controller: _urlController,
              label: 'Website URL',
              hint: 'https://example.com',
              icon: Icons.language_rounded,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Website URL भरें।';
                }

                final uri = Uri.tryParse(value.trim());
                if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
                  return 'सही HTTPS Website URL डालें।';
                }

                return null;
              },
            ),
            const SizedBox(height: 17),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton.icon(
                onPressed: _detecting ? null : _detectPlatform,
                icon: _detecting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search_rounded),
                label: Text(
                  _detecting ? 'Detecting Website...' : 'Detect Platform',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Detection Results',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            _resultRow('Website Platform', _platform),
            _resultRow('Server Information', _server),
            _resultRow('Hosting Provider', _hosting),
            const SizedBox(height: 10),
            _infoBox(
              icon: Icons.info_outline_rounded,
              title: 'Detection Information',
              message: _detectionMessage,
              color: _websiteReachable == true ? _green : _orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTwo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Login & Authorize',
            'अपनी Website के Owner होने की पुष्टि करें',
            Icons.verified_user_rounded,
          ),
          const SizedBox(height: 18),
          _infoBox(
            icon: Icons.lock_outline_rounded,
            title: 'Secure Authorization',
            message:
                'Hosting Account Authorization के लिए सुरक्षित OAuth/API '
                'Integration अभी Backend में उपलब्ध नहीं है। इस स्क्रीन पर '
                'अपना Hosting Password या API Secret दर्ज न करें।',
            color: _orange,
          ),
          const SizedBox(height: 16),
          _resultRow('Website', _urlController.text.trim()),
          _resultRow('Detected Platform', _platform),
          _resultRow('Hosting', _hosting),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _ownerConfirmed,
            onChanged: (value) {
              setState(() => _ownerConfirmed = value ?? false);
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: _blue,
            title: const Text(
              'मैं इस Website का Owner हूँ या Owner की अनुमति से इसे Connect कर रहा हूँ।',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          _infoBox(
            icon: Icons.shield_outlined,
            title: 'Your Security',
            message:
                'HPC Smart AI बिना स्पष्ट अनुमति के Website की Files, '
                'Database या Hosting Settings में बदलाव नहीं करेगा।',
            color: _green,
          ),
        ],
      ),
    );
  }

  Widget _stepThree() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Auto Install',
            'Website Connector Installation',
            Icons.cloud_upload_rounded,
          ),
          const SizedBox(height: 18),
          _infoBox(
            icon: Icons.settings_suggest_rounded,
            title: 'Installer Integration Required',
            message:
                'Automatic installation के लिए Hosting Authorization, '
                'Secure File Transfer, Backup और Connector Installer '
                'Backend अभी configure नहीं हैं। इसलिए अभी कोई File Upload '
                'या Website Modification नहीं की जाएगी।',
            color: _orange,
          ),
          const SizedBox(height: 18),
          _installStatus(
            Icons.folder_open_rounded,
            'Website Root Folder',
            'Not accessed',
          ),
          _installStatus(Icons.backup_rounded, 'Website Backup', 'Not created'),
          _installStatus(
            Icons.upload_file_rounded,
            'Connector Upload',
            'Not installed',
          ),
          _installStatus(
            Icons.storage_rounded,
            'Database Permission',
            'Not authorized',
          ),
          _installStatus(
            Icons.security_rounded,
            'Security Configuration',
            'Not configured',
          ),
          const SizedBox(height: 12),
          _infoBox(
            icon: Icons.info_outline_rounded,
            title: 'Next Step',
            message:
                'आप Step 4 में Website की Public Reachability जाँच सकते हैं '
                'और उसे HPC Smart AI में Register कर सकते हैं। इससे '
                'Connector Installation का दावा नहीं किया जाएगा।',
            color: _blue,
          ),
        ],
      ),
    );
  }

  Widget _stepFour() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Verify & Connect',
            'Final Website Verification',
            Icons.verified_rounded,
          ),
          const SizedBox(height: 18),
          _infoBox(
            icon: Icons.fact_check_outlined,
            title: 'Verification Checklist',
            message: _verificationMessage.isEmpty
                ? 'नीचे दिए गए बटन से Website की दोबारा जाँच करें।'
                : _verificationMessage,
            color: _websiteReachable == true ? _green : _blue,
          ),
          const SizedBox(height: 16),
          _verificationRow(
            'Website Reachable',
            _websiteReachable,
            'Public HTTP response check',
          ),
          _verificationRow(
            'Connector Live',
            _connectorLive,
            'Connector endpoint verification',
          ),
          _verificationRow(
            'Files Verified',
            _filesVerified,
            'Installed connector file integrity',
          ),
          _verificationRow(
            'Database Access',
            _databaseAccess,
            'Authorized database connection',
          ),
          _verificationRow(
            'HTTPS Security',
            _httpsEnabled,
            'Secure HTTPS website URL',
          ),
          const SizedBox(height: 18),
          if (_registered)
            _infoBox(
              icon: Icons.check_circle_rounded,
              title: 'Website Registered in HPC Smart AI',
              message:
                  'Website Registration सफल हुई है। Connector Installation '
                  'और Database Access अभी Verified नहीं हैं।',
              color: _green,
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _verifying || _registered ? null : _verifyAndRegister,
              icon: _verifying
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.verified_user_rounded),
              label: Text(
                _verifying
                    ? 'Verifying...'
                    : _registered
                    ? 'Website Registered'
                    : 'Verify & Register Website',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
          if (_registered) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _loadBusinesses,
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text('Refresh Website List'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value.isEmpty ? 'Not available' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _installStatus(IconData icon, String title, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationRow(String title, bool? passed, String detail) {
    final Color color;
    final IconData icon;
    final String status;

    if (passed == true) {
      color = _green;
      icon = Icons.check_circle_rounded;
      status = 'Verified';
    } else if (passed == false) {
      color = Colors.red;
      icon = Icons.error_outline_rounded;
      status = 'Failed';
    } else {
      color = Colors.blueGrey;
      icon = Icons.pending_outlined;
      status = 'Not verified';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationButtons() {
    return Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _verifying ? null : _previousStep,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                minimumSize: const Size(0, 49),
                side: const BorderSide(color: _blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        if (_step < 3)
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _verifying ? null : _nextStep,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _businessCard(Map<String, dynamic> item) {
    final name = _businessName(item);
    final url = _businessUrl(item);
    final status = _status(item);
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.language_rounded, color: _blue),
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
                        fontSize: 14,
                      ),
                    ),
                    if (url.isNotEmpty)
                      Text(
                        url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openBusiness(item),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _businessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your Businesses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
            ),
            Text(
              '${businesses.length} Websites',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'आपकी Registered Websites और उनका Status',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 13),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: CircularProgressIndicator(color: _blue),
            ),
          )
        else if (error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
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
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: _cardDecoration(),
            child: const Column(
              children: [
                Icon(Icons.language_outlined, color: _blue, size: 38),
                SizedBox(height: 9),
                Text(
                  'अभी कोई Website Register नहीं है।',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'ऊपर दिए गए चार Steps से अपनी पहली Website जोड़ें।',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...businesses.map(_businessCard),
      ],
    );
  }

  Widget _wizardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepOne(),
        const SizedBox(height: 15),
        _stepTwo(),
        const SizedBox(height: 15),
        _stepThree(),
        const SizedBox(height: 15),
        _stepFour(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Connect Website',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadBusinesses,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Websites',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBusinesses,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'HPC Smart AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Connect Your Website',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'अपनी Website को चार आसान Steps में HPC Smart AI से जोड़ें।',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _stepProgress(),
            const SizedBox(height: 16),
            _wizardContent(),
            const SizedBox(height: 15),
            _navigationButtons(),
            const SizedBox(height: 27),
            _businessSection(),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
