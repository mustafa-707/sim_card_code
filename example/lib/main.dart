import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_code/sim_card_code.dart';

void main() {
  runApp(const SimCardManagerApp());
}

class SimCardManagerApp extends StatelessWidget {
  const SimCardManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIM Card Manager',
      home: const SimCardDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimCardDashboard extends StatefulWidget {
  const SimCardDashboard({super.key});

  @override
  State<SimCardDashboard> createState() => _SimCardDashboardState();
}

class _SimCardDashboardState extends State<SimCardDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // SIM Information
  SimCardInfo? _basicSimInfo;
  List<SimCardInfo> _allSimInfo = [];
  NetworkInfo? _networkInfo;

  // Device Information
  String? _deviceId;
  bool _hasSimCard = false;
  bool _isDualSim = false;
  int _simCount = 0;

  // UI State
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SimCardManager.clearCache();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllInformation();
    requestPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    if (await Permission.phone.isDenied) {
      if (Platform.isAndroid) await Permission.phone.request();
    }
  }

  Future<void> _loadAllInformation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all information concurrently
      final results = await Future.wait([
        SimCardManager.basicSimInfo,
        SimCardManager.allSimInfo,
        SimCardManager.networkInfo,
        SimCardManager.deviceId,
        SimCardManager.hasSimCard,
        SimCardManager.isDualSim,
        SimCardManager.simCount,
      ]);

      if (mounted) {
        setState(() {
          _basicSimInfo = results[0] as SimCardInfo?;
          _allSimInfo = results[1] as List<SimCardInfo>;
          _networkInfo = results[2] as NetworkInfo;
          _deviceId = results[3] as String?;
          _hasSimCard = results[4] as bool;
          _isDualSim = results[5] as bool;
          _simCount = results[6] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading SIM information: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM Card Manager'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllInformation,
            tooltip: 'Refresh Information',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.sim_card), text: 'SIM Cards'),
            Tab(icon: Icon(Icons.network_cell), text: 'Network'),
            Tab(icon: Icon(Icons.phone_android), text: 'Device'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSimCardsTab(),
                _buildNetworkTab(),
                _buildDeviceTab(),
              ],
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error Loading Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllInformation,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimCardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          if (_hasSimCard) ...[
            if (!_isDualSim && _basicSimInfo != null)
              _buildSingleSimCard(_basicSimInfo!)
            else if (_isDualSim && _allSimInfo.isNotEmpty)
              ..._allSimInfo.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildDualSimCard(entry.value, entry.key),
                ),
              )
            else
              _buildNoSimDataCard(),
          ] else
            _buildNoSimCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIM Status Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(
                  'SIM Cards',
                  _simCount.toString(),
                  _hasSimCard ? Colors.green : Colors.red,
                ),

                _buildStatusChip(
                  'Dual SIM',
                  _isDualSim ? 'Yes' : 'No',
                  _isDualSim ? Colors.blue : Colors.grey,
                ),
                _buildStatusChip(
                  'Active',
                  _hasSimCard ? 'Yes' : 'No',
                  _hasSimCard ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: .1),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSingleSimCard(SimCardInfo simInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sim_card, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Primary SIM Card',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildSimInfoRows(simInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildDualSimCard(SimCardInfo simInfo, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sim_card,
                  color: index == 0 ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'SIM ${index + 1} (Slot ${simInfo.slotIndex ?? index})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildSimInfoRows(simInfo),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSimInfoRows(SimCardInfo simInfo) {
    return [
      _buildInfoRow('Country Code', simInfo.countryCode ?? 'N/A'),
      _buildInfoRow('Operator', simInfo.operatorName ?? 'N/A'),
      _buildInfoRow('Operator Code', simInfo.operatorCode ?? 'N/A'),
      _buildInfoRow('Phone Number', simInfo.phoneNumber ?? 'N/A'),
      _buildInfoRow('SIM State', simInfo.simState?.name ?? 'Unknown'),
      if (simInfo.isRoaming != null)
        _buildInfoRow('Roaming', simInfo.isRoaming! ? 'Yes' : 'No'),
    ];
  }

  Widget _buildNoSimCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.sim_card_alert, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No SIM Card Detected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please insert a SIM card to view information.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSimDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Limited SIM Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'SIM card detected but detailed information is not available. This may require additional permissions.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.network_cell, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Network Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Operator',
                    _networkInfo?.operatorName ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Country Code',
                    _networkInfo?.countryCode ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Network Type',
                    _networkInfo?.networkType ?? 'N/A',
                  ),
                  _buildInfoRow(
                    'Roaming Status',
                    _networkInfo?.isRoaming == true
                        ? 'Roaming'
                        : 'Home Network',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildNetworkStatusCard(),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    final isRoaming = _networkInfo?.isRoaming ?? false;
    final networkType = _networkInfo?.networkType ?? 'Unknown';

    return Card(
      color: isRoaming ? Colors.orange.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              isRoaming ? Icons.radar_rounded : Icons.home,
              size: 48,
              color: isRoaming ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 12),
            Text(
              isRoaming ? 'Roaming Active' : 'Home Network',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isRoaming
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connected via $networkType',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_android, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Device Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Device ID (IMEI)', _deviceId ?? 'N/A'),
                  _buildInfoRow('SIM Slots', _simCount.toString()),
                  _buildInfoRow('Dual SIM Support', _isDualSim ? 'Yes' : 'No'),
                  _buildInfoRow('SIM Card Present', _hasSimCard ? 'Yes' : 'No'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPermissionNoticeCard(),
        ],
      ),
    );
  }

  Widget _buildPermissionNoticeCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.security, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              'Privacy Notice',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Some information may require READ_PHONE_STATE permission. '
              'Device ID, phone numbers, and detailed SIM information are '
              'only accessible with proper permissions.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
