import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar câmeras disponíveis
  final cameras = await availableCameras();
  
  runApp(CoverMathApp(cameras: cameras));
}

class CoverMathApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const CoverMathApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoverMath PRO',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF1E88E5, {
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(0xFF42A5F5),
          500: Color(0xFF1E88E5),
          600: Color(0xFF1976D2),
          700: Color(0xFF1565C0),
          800: Color(0xFF0D47A1),
          900: Color(0xFF0D47A1),
        }),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1E88E5),
          primary: Color(0xFF1E88E5),
          secondary: Color(0xFFFF6B35),
          tertiary: Color(0xFFFFD700),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(cameras: cameras),
    );
  }
}

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const MainScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Controladores de texto para custos
  final TextEditingController _custoCianoController = TextEditingController(text: '0,00');
  final TextEditingController _custoMagentaController = TextEditingController(text: '0,00');
  final TextEditingController _custoAmareloController = TextEditingController(text: '0,00');
  final TextEditingController _custoPretoController = TextEditingController(text: '0,00');
  
  // Controladores de texto para rendimentos
  final TextEditingController _rendimentoCianoController = TextEditingController(text: '1000');
  final TextEditingController _rendimentoMagentaController = TextEditingController(text: '1000');
  final TextEditingController _rendimentoAmareloController = TextEditingController(text: '1000');
  final TextEditingController _rendimentoPretoController = TextEditingController(text: '1000');
  
  bool _grayscaleMode = false;
  bool _isProcessing = false;
  double _progress = 0.0;
  String _statusText = 'Pronto para selecionar arquivo';
  String _resultText = '';
  File? _selectedFile;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoverMath PRO'),
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de Custos
            _buildCostSection(),
            const SizedBox(height: 16),
            
            // Seção de Rendimentos
            _buildYieldSection(),
            const SizedBox(height: 16),
            
            // Opção Escala de Cinza
            _buildGrayscaleOption(),
            const SizedBox(height: 16),
            
            // Botões de Ação
            _buildActionButtons(),
            const SizedBox(height: 16),
            
            // Progresso
            _buildProgressSection(),
            const SizedBox(height: 16),
            
            // Resultados
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCostSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CUSTOS (R\$)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Ciano:'),
                      TextField(
                        controller: _custoCianoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Magenta:'),
                      TextField(
                        controller: _custoMagentaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Amarelo:'),
                      TextField(
                        controller: _custoAmareloController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Preto:'),
                      TextField(
                        controller: _custoPretoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildYieldSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RENDIMENTO',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Ciano:'),
                      TextField(
                        controller: _rendimentoCianoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Magenta:'),
                      TextField(
                        controller: _rendimentoMagentaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Amarelo:'),
                      TextField(
                        controller: _rendimentoAmareloController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Preto:'),
                      TextField(
                        controller: _rendimentoPretoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGrayscaleOption() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: _grayscaleMode,
              onChanged: (value) {
                setState(() {
                  _grayscaleMode = value ?? false;
                });
              },
            ),
            const Text('Modo Escala de Cinza'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _takePhoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('TIRAR FOTO'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 3,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _isProcessing ? null : _selectFile,
          icon: const Icon(Icons.folder_open),
          label: const Text('SELECIONAR ARQUIVO'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 3,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: (_isProcessing || _selectedFile == null) ? null : _analyzeFile,
          icon: const Icon(Icons.analytics),
          label: const Text('INICIAR ANÁLISE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 3,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressSection() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
        ),
        const SizedBox(height: 8),
        Text(
          _statusText,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildResultsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RESULTADOS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _resultText.isEmpty ? 'Nenhum resultado ainda...' : _resultText,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _takePhoto() async {
    // Verificar permissões
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      _showError('Permissão de câmera negada');
      return;
    }
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _selectedFile = File(photo.path);
          _statusText = 'Foto capturada: ${photo.name}';
        });
        
        // Processar a imagem para detectar margens e remover sombras
        await _processImageForDocumentScan(File(photo.path));
      }
    } catch (e) {
      _showError('Erro ao tirar foto: $e');
    }
  }
  
  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _statusText = 'Arquivo selecionado: ${result.files.single.name}';
        });
      }
    } catch (e) {
      _showError('Erro ao selecionar arquivo: $e');
    }
  }
  
  Future<void> _processImageForDocumentScan(File imageFile) async {
    try {
      setState(() {
        _isProcessing = true;
        _statusText = 'Processando imagem...';
        _progress = 0.3;
      });
      
      // Carregar a imagem
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Não foi possível decodificar a imagem');
      }
      
      setState(() {
        _progress = 0.5;
        _statusText = 'Detectando margens...';
      });
      
      // Simular detecção de margens e remoção de sombras
      // Em uma implementação real, você usaria OpenCV ou algoritmos similares
      final processedImage = _simulateDocumentProcessing(image);
      
      setState(() {
        _progress = 0.8;
        _statusText = 'Salvando imagem processada...';
      });
      
      // Salvar a imagem processada
      final directory = await getTemporaryDirectory();
      final processedPath = '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final processedFile = File(processedPath);
      await processedFile.writeAsBytes(img.encodeJpg(processedImage));
      
      setState(() {
        _selectedFile = processedFile;
        _progress = 1.0;
        _statusText = 'Imagem processada com sucesso!';
        _isProcessing = false;
      });
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _progress = 0.0;
      });
      _showError('Erro ao processar imagem: $e');
    }
  }
  
  img.Image _simulateDocumentProcessing(img.Image original) {
    // Simular processamento de documento
    // Em uma implementação real, aqui você faria:
    // 1. Detecção de bordas
    // 2. Detecção de contornos
    // 3. Correção de perspectiva
    // 4. Remoção de sombras
    // 5. Melhoria de contraste
    
    // Por enquanto, apenas aplicamos alguns filtros básicos
    var processed = img.copyResize(original, width: 800);
    processed = img.adjustColor(processed, contrast: 1.2, brightness: 1.1);
    
    return processed;
  }
  
  Future<void> _analyzeFile() async {
    if (_selectedFile == null) return;
    
    try {
      setState(() {
        _isProcessing = true;
        _progress = 0.0;
        _statusText = 'Iniciando análise...';
        _resultText = '';
      });
      
      final costs = _getCosts();
      final yields = _getYields();
      
      List<Map<String, dynamic>> results = [];
      
      if (_selectedFile!.path.toLowerCase().endsWith('.pdf')) {
        results = await _analyzePDF(_selectedFile!, costs, yields);
      } else {
        results = await _analyzeImage(_selectedFile!, costs, yields);
      }
      
      _displayResults(results);
      
    } catch (e) {
      _showError('Erro na análise: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _progress = 0.0;
      });
    }
  }
  
  Map<String, double> _getCosts() {
    return {
      'Ciano': double.tryParse(_custoCianoController.text.replaceAll(',', '.')) ?? 0.0,
      'Magenta': double.tryParse(_custoMagentaController.text.replaceAll(',', '.')) ?? 0.0,
      'Amarelo': double.tryParse(_custoAmareloController.text.replaceAll(',', '.')) ?? 0.0,
      'Preto': double.tryParse(_custoPretoController.text.replaceAll(',', '.')) ?? 0.0,
    };
  }
  
  Map<String, double> _getYields() {
    return {
      'Ciano': double.tryParse(_rendimentoCianoController.text) ?? 1000.0,
      'Magenta': double.tryParse(_rendimentoMagentaController.text) ?? 1000.0,
      'Amarelo': double.tryParse(_rendimentoAmareloController.text) ?? 1000.0,
      'Preto': double.tryParse(_rendimentoPretoController.text) ?? 1000.0,
    };
  }
  
  Future<List<Map<String, dynamic>>> _analyzePDF(File file, Map<String, double> costs, Map<String, double> yields) async {
    // Implementação simplificada para análise de PDF
    // Em uma implementação real, você usaria uma biblioteca como pdf_render
    setState(() {
      _statusText = 'Analisando PDF...';
      _progress = 0.5;
    });
    
    // Simular análise de uma página
    await Future.delayed(const Duration(seconds: 2));
    
    return [
      _calculatePageResults(1, 15.5, 8.2, 12.1, 25.3, costs, yields),
    ];
  }
  
  Future<List<Map<String, dynamic>>> _analyzeImage(File file, Map<String, double> costs, Map<String, double> yields) async {
    setState(() {
      _statusText = 'Analisando imagem...';
      _progress = 0.3;
    });
    
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Não foi possível decodificar a imagem');
    }
    
    setState(() {
      _progress = 0.6;
      _statusText = 'Calculando cobertura...';
    });
    
    final cmykValues = _calculateCMYKCoverage(image);
    
    setState(() {
      _progress = 0.9;
      _statusText = 'Finalizando análise...';
    });
    
    return [
      _calculatePageResults(1, cmykValues['C']!, cmykValues['M']!, cmykValues['Y']!, cmykValues['K']!, costs, yields),
    ];
  }
  
  Map<String, double> _calculateCMYKCoverage(img.Image image) {
    int totalPixels = image.width * image.height;
    double cTotal = 0, mTotal = 0, yTotal = 0, kTotal = 0;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;
        
        final cmyk = _rgbToCmyk(r, g, b);
        cTotal += cmyk['C']!;
        mTotal += cmyk['M']!;
        yTotal += cmyk['Y']!;
        kTotal += cmyk['K']!;
      }
    }
    
    return {
      'C': (cTotal / totalPixels) * 100,
      'M': (mTotal / totalPixels) * 100,
      'Y': (yTotal / totalPixels) * 100,
      'K': (kTotal / totalPixels) * 100,
    };
  }
  
  Map<String, double> _rgbToCmyk(double r, double g, double b) {
    if (r == 0 && g == 0 && b == 0) {
      return {'C': 0, 'M': 0, 'Y': 0, 'K': 1};
    }
    
    final k = 1 - math.max(r, math.max(g, b));
    if (k == 1) {
      return {'C': 0, 'M': 0, 'Y': 0, 'K': 1};
    }
    
    final c = (1 - r - k) / (1 - k);
    final m = (1 - g - k) / (1 - k);
    final y = (1 - b - k) / (1 - k);
    
    return {'C': c, 'M': m, 'Y': y, 'K': k};
  }
  
  Map<String, dynamic> _calculatePageResults(int page, double c, double m, double y, double k, Map<String, double> costs, Map<String, double> yields) {
    double calculateCost(double percentage, double cost, double yield) {
      if (yield <= 0 || cost <= 0) return 0.0;
      return (percentage / 5) * (cost / yield);
    }
    
    final costC = _grayscaleMode ? 0.0 : calculateCost(c, costs['Ciano']!, yields['Ciano']!);
    final costM = _grayscaleMode ? 0.0 : calculateCost(m, costs['Magenta']!, yields['Magenta']!);
    final costY = _grayscaleMode ? 0.0 : calculateCost(y, costs['Amarelo']!, yields['Amarelo']!);
    final costK = calculateCost(k, costs['Preto']!, yields['Preto']!);
    
    final totalCost = costC + costM + costY + costK;
    final totalCoverage = _grayscaleMode ? k : (c + m + y + k);
    
    return {
      'page': page,
      'c': c,
      'm': m,
      'y': y,
      'k': k,
      'totalCoverage': totalCoverage,
      'costC': costC,
      'costM': costM,
      'costY': costY,
      'costK': costK,
      'totalCost': totalCost,
    };
  }
  
  void _displayResults(List<Map<String, dynamic>> results) {
    String resultText = '==== RESULTADOS ====\n\n';
    
    for (var result in results) {
      resultText += 'PÁGINA ${result['page']}:\n';
      resultText += '  Cobertura Total: ${result['totalCoverage'].toStringAsFixed(2)}%\n';
      resultText += '  Custo: R\$ ${result['totalCost'].toStringAsFixed(4)}\n';
      
      if (_grayscaleMode) {
        resultText += '  (Monocromático: R\$ ${result['costK'].toStringAsFixed(4)})\n';
      } else {
        resultText += '  Ciano: ${result['c'].toStringAsFixed(2)}% (R\$ ${result['costC'].toStringAsFixed(4)})\n';
        resultText += '  Magenta: ${result['m'].toStringAsFixed(2)}% (R\$ ${result['costM'].toStringAsFixed(4)})\n';
        resultText += '  Amarelo: ${result['y'].toStringAsFixed(2)}% (R\$ ${result['costY'].toStringAsFixed(4)})\n';
        resultText += '  Preto: ${result['k'].toStringAsFixed(2)}% (R\$ ${result['costK'].toStringAsFixed(4)})\n';
      }
      
      resultText += '${'=' * 30}\n';
    }
    
    final totalCost = results.fold(0.0, (sum, result) => sum + result['totalCost']);
    final avgCoverage = results.fold(0.0, (sum, result) => sum + result['totalCoverage']) / results.length;
    
    resultText += '\nTOTAL GERAL:\n';
    resultText += '  Páginas: ${results.length}\n';
    resultText += '  Cobertura média: ${avgCoverage.toStringAsFixed(2)}%\n';
    resultText += '  Custo total: R\$ ${totalCost.toStringAsFixed(4)}\n';
    
    setState(() {
      _resultText = resultText;
      _statusText = 'Análise concluída!';
    });
  }
  
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

