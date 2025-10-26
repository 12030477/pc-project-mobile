import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Build Budget Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final TextEditingController cpuController = TextEditingController();
  final TextEditingController gpuController = TextEditingController();
  final TextEditingController ramController = TextEditingController();
  final TextEditingController storageController = TextEditingController();
  final TextEditingController motherboardController = TextEditingController();
  final TextEditingController caseController = TextEditingController();
  final TextEditingController psuController = TextEditingController();
  final TextEditingController accessoriesController = TextEditingController();
  final TextEditingController cpuTdpController = TextEditingController();
  final TextEditingController gpuTdpController = TextEditingController();

  double totalCost = 0.0;
  int recommendedPsu = 0;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/pcbuilderhelper.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PC Build Helper',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.grey[900],
                                ),
                              ),
                              Text(
                                'Calculate your build budget',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            isDarkMode = !isDarkMode;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.grey[800] : Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                    const Icon(Icons.shopping_cart,
                                        color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Component Prices',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInputField('CPU', cpuController,
                                    isPrice: true),
                                _buildInputField('GPU', gpuController,
                                    isPrice: true),
                                _buildInputField('RAM', ramController,
                                    isPrice: true),
                                _buildInputField('Storage', storageController,
                                    isPrice: true),
                                _buildInputField(
                                    'Motherboard', motherboardController,
                                    isPrice: true),
                                _buildInputField('Case', caseController,
                                    isPrice: true),
                                _buildInputField('PSU', psuController,
                                    isPrice: true),
                                _buildInputField(
                                    'Accessories', accessoriesController,
                                    isPrice: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.battery_charging_full,
                                        color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PSU Calculator',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                    'CPU TDP (Watts)', cpuTdpController),
                                _buildInputField(
                                    'GPU TDP (Watts)', gpuTdpController),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isValidInput() ? calculateTotal : null,
                                icon: const Icon(Icons.calculate),
                                label: const Text('Calculate',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isValidInput() ? Colors.blue : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: resetAll,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (totalCost > 0 || recommendedPsu > 0) ...[
                          Card(
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 60, color: Colors.white),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Total Build Cost',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${totalCost.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Divider(color: Colors.white54),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Recommended PSU',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${recommendedPsu}W',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: isPrice ? '\$ ' : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          errorText: _getValidationError(controller.text, isPrice),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          LengthLimitingTextInputFormatter(isPrice ? 10 : 6),
        ],
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: (value) {
          setState(() {
            // Trigger validation on change
          });
        },
      ),
    );
  }

  String? _getValidationError(String value, bool isPrice) {
    if (value.isEmpty) return null;
    
    // Check if it's a valid number
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    // Check for reasonable ranges
    if (isPrice) {
      if (number < 0) return 'Price cannot be negative';
      if (number > 99999) return 'Price seems too high';
    } else {
      if (number < 0) return 'TDP cannot be negative';
      if (number > 1000) return 'TDP seems too high';
    }
    
    return null;
  }

  bool _isValidInput() {
    // Check if any field has validation errors
    final controllers = [
      cpuController, gpuController, ramController, storageController,
      motherboardController, caseController, psuController, accessoriesController,
      cpuTdpController, gpuTdpController
    ];
    
    for (int i = 0; i < controllers.length; i++) {
      final controller = controllers[i];
      final isPrice = i < 8; // First 8 are price fields
      if (_getValidationError(controller.text, isPrice) != null) {
        return false;
      }
    }
    
    return true;
  }

  void calculateTotal() {
    setState(() {
      totalCost = getValue(cpuController.text) +
          getValue(gpuController.text) +
          getValue(ramController.text) +
          getValue(storageController.text) +
          getValue(motherboardController.text) +
          getValue(caseController.text) +
          getValue(psuController.text) +
          getValue(accessoriesController.text);

      final int cpuTdp = int.tryParse(cpuTdpController.text) ?? 0;
      final int gpuTdp = int.tryParse(gpuTdpController.text) ?? 0;
      final int totalWattage = ((100 + cpuTdp + gpuTdp) * 1.2).round();
      recommendedPsu = ((totalWattage / 50).ceil() * 50);
    });
  }

  double getValue(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  void resetAll() {
    setState(() {
      cpuController.clear();
      gpuController.clear();
      ramController.clear();
      storageController.clear();
      motherboardController.clear();
      caseController.clear();
      psuController.clear();
      accessoriesController.clear();
      cpuTdpController.clear();
      gpuTdpController.clear();
      totalCost = 0.0;
      recommendedPsu = 0;
    });
  }

  @override
  void dispose() {
    cpuController.dispose();
    gpuController.dispose();
    ramController.dispose();
    storageController.dispose();
    motherboardController.dispose();
    caseController.dispose();
    psuController.dispose();
    accessoriesController.dispose();
    cpuTdpController.dispose();
    gpuTdpController.dispose();
    super.dispose();
  }
}
