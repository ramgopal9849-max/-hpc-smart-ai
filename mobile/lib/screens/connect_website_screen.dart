import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int? _selectedBusinessId;
  bool _authorizing = false;
  bool _authorizationVerified = false;
  String? _authorizationRequestId;
  String? _verificationFilePath;
  String? _verificationFileContent;
  int? _websiteConnectionId;
  String _authorizationMessage = '';


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
      final via = headers['via'] ?? '';

      String platform = 'Custom / Unknown';
      String hosting = 'Unknown';

      // Platform detection
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
        final version = RegExp(r'php[/ ]([0-9.]+)').firstMatch(poweredBy);
        platform = version == null
            ? 'PHP Website'
            : 'PHP Website (${version.group(1)})';
      } else if (poweredBy.contains('asp.net')) {
        platform = 'ASP.NET';
      }

      // Hosting and CDN indicators
      if (server.contains('hcdn') ||
          server.contains('hostinger') ||
          via.contains('hostinger')) {
        hosting = 'Hostinger (HCDN indication)';
      } else if (headers.containsKey('cf-ray') ||
          server.contains('cloudflare')) {
        hosting = 'Cloudflare (CDN / Proxy indication)';
      } else if (headers.containsKey('x-amz-cf-id') ||
          headers.containsKey('x-amz-cf-pop') ||
          server.contains('cloudfront') ||
          via.contains('cloudfront')) {
        hosting = 'Amazon CloudFront (CDN indication)';
      } else if (headers.containsKey('x-azure-ref') ||
          headers.containsKey('x-ms-request-id')) {
        hosting = 'Microsoft Azure (header indication)';
      } else if (headers.keys.any((key) => key.startsWith('x-goog-')) ||
          server.contains('google')) {
        hosting = 'Google infrastructure (header indication)';
      } else if (headers.containsKey('x-vercel-id') ||
          server.contains('vercel')) {
        hosting = 'Vercel (header indication)';
      } else if (headers.containsKey('x-nf-request-id') ||
          server.contains('netlify')) {
        hosting = 'Netlify (header indication)';
      } else if (headers.containsKey('akamai-grn') ||
          headers.containsKey('x-akamai-transformed') ||
          server.contains('akamai')) {
        hosting = 'Akamai (CDN indication)';
      } else if (server.contains('fastly')) {
        hosting = 'Fastly (CDN indication)';
      } else if (server.contains('nginx')) {
        hosting = 'Unknown provider (Nginx server)';
      } else if (server.contains('apache')) {
        hosting = 'Unknown provider (Apache server)';
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


  String _authorizationPlatformKey() {
    final value = _platform.toLowerCase();

    if (value.contains('wordpress')) return 'wordpress';
    if (value.contains('shopify')) return 'shopify';
    if (value.contains('wix')) return 'wix';
    if (value.contains('squarespace')) return 'squarespace';
    if (value.contains('joomla')) return 'joomla';
    if (value.contains('drupal')) return 'drupal';
    if (value.contains('magento')) return 'magento';
    if (value.contains('webflow')) return 'webflow';
    if (value.contains('blogger')) return 'blogger';
    if (value.contains('generator')) return 'generator_detected';

    return 'custom_or_unknown';
  }

  Future<void> _startManualVerification() async {
    final uri = _websiteUri();

    if (uri == null) {
      _showMessage('पहले सही HTTPS Website URL डालें।', isError: true);
      return;
    }
    if (!HpcApi.isLoggedIn) {
      _showMessage('कृपया पहले Login करें।', isError: true);
      return;
    }
    if (!_ownerConfirmed) {
      _showMessage('पहले Website Ownership की पुष्टि करें।', isError: true);
      return;
    }
    if (_selectedBusinessId == null || _selectedBusinessId! <= 0) {
      _showMessage('पहले अपना मौजूदा Business चुनें।', isError: true);
      return;
    }

    setState(() {
      _authorizing = true;
      _authorizationMessage = 'Verification challenge बनाया जा रहा है...';
      _authorizationRequestId = null;
      _verificationFilePath = null;
      _verificationFileContent = null;
      _authorizationVerified = false;
    });

    try {
      final response = await HpcApi.request(
        'connect/authorize',
        method: 'POST',
        authenticated: true,
        body: {
          'business_id': _selectedBusinessId,
          'website_url': uri.toString(),
          'platform': _authorizationPlatformKey(),
          'platform_name': _platform,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Challenge नहीं बन पाया।');
      }

      if (!mounted) return;
      setState(() {
        _authorizationRequestId =
            (response['request_id'] ?? '').toString();
        _verificationFilePath =
            (response['file_path'] ?? '').toString();
        _verificationFileContent =
            (response['file_content'] ?? '').toString();
        _authorizationMessage =
            'Challenge तैयार है। इसे Website के root में दिए गए path पर upload करें।';
      });

      if (_authorizationRequestId!.isEmpty ||
          _verificationFilePath!.isEmpty ||
          _verificationFileContent!.isEmpty) {
        throw Exception('Backend से verification file की पूरी जानकारी नहीं मिली।');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authorizationMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
      _showMessage(_authorizationMessage, isError: true);
    } finally {
      if (mounted) setState(() => _authorizing = false);
    }
  }

  Future<void> _verifyManualAuthorization() async {
    final requestId = _authorizationRequestId;

    if (requestId == null || requestId.isEmpty) {
      _showMessage('पहले Verification File बनाइए।', isError: true);
      return;
    }

    setState(() {
      _authorizing = true;
      _authorizationMessage = 'Website पर verification file जाँची जा रही है...';
    });

    try {
      final response = await HpcApi.request(
        'connect/verify',
        method: 'POST',
        authenticated: true,
        body: {'request_id': requestId},
      );

      if (response['success'] != true ||
          response['authorization_status'] != 'verified') {
        throw Exception(
          response['message'] ?? 'Website ownership verify नहीं हुई।'
        );
      }

      final connectionId = int.tryParse(
        (response['website_connection_id'] ?? '').toString(),
      );

      if (connectionId == null || connectionId <= 0) {
        throw Exception('Verified connection ID backend से नहीं मिली।');
      }

      if (!mounted) return;
      setState(() {
        _authorizationVerified = true;
        _websiteConnectionId = connectionId;
        _authorizationMessage =
            'Ownership Verified. Website connection अभी Pending है।';
        _verificationMessage = _authorizationMessage;
        _step = 2;
      });

      _showMessage('Website Ownership सफलतापूर्वक Verify हुई।');
      await _loadBusinesses();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authorizationMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
      _showMessage(_authorizationMessage, isError: true);
    } finally {
      if (mounted) setState(() => _authorizing = false);
    }
  }

  Future<void> _copyVerificationText(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    _showMessage('Copy हो गया।');
  }

  Future<void> _refreshConnectionStatus() async {
    if (!_authorizationVerified ||
        _websiteConnectionId == null ||
        _selectedBusinessId == null) {
      _showMessage(
        'पहले Step 2 में Website Ownership Verify करें।',
        isError: true,
      );
      return;
    }

    setState(() {
      _verifying = true;
      _verificationMessage = 'Connection status refresh हो रहा है...';
    });

    try {
      final connections =
          await HpcApi.getBusinessWebsites(_selectedBusinessId!);

      Map<String, dynamic>? matched;
      for (final item in connections) {
        final id = int.tryParse(
          (item['id'] ?? item['website_connection_id'] ?? '').toString(),
        );
        if (id == _websiteConnectionId) {
          matched = item;
          break;
        }
      }

      if (!mounted) return;

      if (matched == null) {
        setState(() {
          _verificationMessage =
              'Verified connection record अभी इस Business में नहीं मिला।';
        });
        _showMessage(_verificationMessage, isError: true);
        return;
      }

      final status =
          (matched['status'] ?? 'pending').toString().toLowerCase();

      setState(() {
        _verificationMessage =
            'Ownership Verified. Connection ID: $_websiteConnectionId. '
            'Server Status: $status. Connector installation और final '
            'verification अभी बाकी हैं।';
      });

      _showMessage('Connection status refresh हो गया।');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verificationMessage =
            'Status refresh नहीं हुआ: ${e.toString().replaceFirst('Exception: ', '')}';
      });
      _showMessage(_verificationMessage, isError: true);
    } finally {
      if (mounted) setState(() => _verifying = false);
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
    if (_step == 0 && _websiteReachable != true) {
      _showMessage('पहले Website Detection सफल करें।', isError: true);
      return;
    }

    if (_step == 1) {
      if (!_ownerConfirmed) {
        _showMessage(
          'आगे बढ़ने से पहले Website ownership की पुष्टि करें।',
          isError: true,
        );
        return;
      }
      if (!_authorizationVerified) {
        _showMessage(
          'पहले Manual Verification File Upload करके Verify करें।',
          isError: true,
        );
        return;
      }
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
    final availableBusinesses = <Map<String, dynamic>>[];
    final seenBusinessIds = <int>{};

    for (final business in businesses) {
      final id = int.tryParse(
        (business['id'] ?? business['business_id'] ?? '').toString(),
      );
      if (id != null && id > 0 && seenBusinessIds.add(id)) {
        availableBusinesses.add(business);
      }
    }

    final selectedBusinessExists = availableBusinesses.any((business) {
      final id = int.tryParse(
        (business['id'] ?? business['business_id'] ?? '').toString(),
      );
      return id == _selectedBusinessId;
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Login & Authorize',
            'अपनी Website का सुरक्षित Ownership Verification करें',
            Icons.verified_user_rounded,
          ),
          const SizedBox(height: 18),

          const Text(
            'Select Existing Business',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: selectedBusinessExists ? _selectedBusinessId : null,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: loading ? 'Businesses लोड हो रहे हैं...' : 'अपना Business चुनें',
              prefixIcon: const Icon(Icons.business_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            items: availableBusinesses.map((business) {
              final id = int.parse(
                (business['id'] ?? business['business_id']).toString(),
              );
              return DropdownMenuItem<int>(
                value: id,
                child: Text(
                  _businessName(business),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: _authorizing || loading
                ? null
                : (id) {
                    setState(() {
                      _selectedBusinessId = id;
                      final selected = availableBusinesses.firstWhere(
                        (business) => int.tryParse(
                          (business['id'] ?? business['business_id'] ?? '')
                              .toString(),
                        ) == id,
                      );
                      _nameController.text = _businessName(selected);
                      _authorizationRequestId = null;
                      _verificationFilePath = null;
                      _verificationFileContent = null;
                      _authorizationVerified = false;
                      _authorizationMessage = '';
                    });
                  },
          ),
          if (!loading && availableBusinesses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _infoBox(
                icon: Icons.info_outline_rounded,
                title: 'Business उपलब्ध नहीं है',
                message:
                    'पहले अपने HPC Smart AI account में Business बनाएँ। '
                    'यह स्क्रीन नया duplicate Business नहीं बनाएगी।',
                color: _orange,
              ),
            ),

          const SizedBox(height: 18),
          _resultRow('Website', _urlController.text.trim()),
          _resultRow('Detected Platform', _platform),
          _resultRow('Hosting', _hosting),

          const SizedBox(height: 16),
          _infoBox(
            icon: Icons.lock_outline_rounded,
            title: 'Automatic Authorization',
            message:
                'इस platform के लिए वास्तविक OAuth/Hosting API integration '
                'अभी उपलब्ध नहीं है। Automatic Authorization अभी चालू नहीं है। '
                'Hosting Password या API Secret यहाँ दर्ज न करें।',
            color: _orange,
          ),

          const SizedBox(height: 16),
          CheckboxListTile(
            value: _ownerConfirmed,
            onChanged: _authorizing
                ? null
                : (value) {
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
            title: 'Manual File Verification',
            message:
                'HPC Smart AI एक सुरक्षित verification file बनाएगा। '
                'आप इसे स्वयं Website के बताए गए path पर upload करेंगे। '
                'बिना आपकी कार्रवाई के Website की कोई File नहीं बदली जाएगी।',
            color: _green,
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton.icon(
              onPressed: _authorizing ||
                      _authorizationRequestId != null
                  ? null
                  : _startManualVerification,
              icon: _authorizing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.verified_user_outlined),
              label: Text(
                _authorizing
                    ? 'Please wait...'
                    : 'Create Verification File',
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

          if (_verificationFilePath != null &&
              _verificationFileContent != null) ...[
            const SizedBox(height: 18),
            _infoBox(
              icon: Icons.upload_file_rounded,
              title: 'Upload This Verification File',
              message:
                  'अपने Hosting File Manager या FTP से नीचे दी गई file '
                  'Website के root में बनाएँ। File का नाम और content बिल्कुल '
                  'वैसा ही रखें। Challenge लगभग 30 मिनट में expire होगा।',
              color: _blue,
            ),
            const SizedBox(height: 12),
            const Text(
              'File Path',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            SelectableText(_verificationFilePath!),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _copyVerificationText(_verificationFilePath!),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy File Path'),
              ),
            ),
            const Text(
              'File Content',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border),
              ),
              child: SelectableText(
                _verificationFileContent!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _copyVerificationText(_verificationFileContent!),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy File Content'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton.icon(
                onPressed: _authorizing || _authorizationVerified
                    ? null
                    : _verifyManualAuthorization,
                icon: const Icon(Icons.fact_check_rounded),
                label: Text(
                  _authorizationVerified
                      ? 'Ownership Verified'
                      : 'Verify Uploaded File',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],

          if (_authorizationMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoBox(
              icon: _authorizationVerified
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              title: 'Authorization Status',
              message: _authorizationMessage,
              color: _authorizationVerified ? _green : _blue,
            ),
          ],
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
                'Ownership verify होने के बाद Step 4 में Connection Status refresh कर सकते हैं। '
                'Connector install और final verification अभी बाकी रहेंगे। इससे '
                'Connector Installation का दावा नहीं किया जाएगा।',
            color: _blue,
          ),
        ],
      ),
    );
  }

  Widget _stepFour() {
    final connectionId = _websiteConnectionId;

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
            title: _authorizationVerified
                ? 'Website Ownership Verified'
                : 'Ownership Verification Pending',
            message: _authorizationVerified
                ? 'Website ownership verify हो चुकी है। Connection अभी '
                    'Pending है; Connector Installation और final checks '
                    'पूरे होने के बाद ही Connected माना जाएगा।'
                : 'Step 2 में पहले Website Ownership Verify करें।',
            color: _authorizationVerified ? _green : _orange,
          ),
          const SizedBox(height: 16),
          _verificationRow(
            'Website Reachable',
            _websiteReachable,
            'Public HTTP response check',
          ),
          _verificationRow(
            'Ownership Authorization',
            _authorizationVerified,
            'Manual website file challenge',
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
          const SizedBox(height: 14),
          _installStatus(
            Icons.link_rounded,
            'Website Connection ID',
            connectionId?.toString() ?? 'Not created',
          ),
          _infoBox(
            icon: Icons.info_outline_rounded,
            title: 'Connection Status',
            message: _verificationMessage.isNotEmpty
                ? _verificationMessage
                : 'अभी Connector install नहीं हुआ है। इसलिए Website '
                    'को Connected घोषित नहीं किया गया है।',
            color: _blue,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _verifying ? null : _refreshConnectionStatus,
              icon: _verifying
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text(
                _verifying ? 'Refreshing...' : 'Refresh Connection Status',
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
    switch (_step) {
      case 0:
        return _stepOne();
      case 1:
        return _stepTwo();
      case 2:
        return _stepThree();
      default:
        return _stepFour();
    }
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
