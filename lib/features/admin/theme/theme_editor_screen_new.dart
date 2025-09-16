import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/ui/responsive_scaffold.dart';
import '../../../shared/utils/color_utils.dart';

class ThemeEditorScreen extends StatefulWidget {
  const ThemeEditorScreen({super.key});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  late final TextEditingController _primaryCtl;
  late final TextEditingController _secondaryCtl;
  late final TextEditingController _backgroundCtl;
  late final TextEditingController _surfaceCtl;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _primaryCtl = TextEditingController();
    _secondaryCtl = TextEditingController();
    _backgroundCtl = TextEditingController();
    _surfaceCtl = TextEditingController();
    
    // Initialize controllers after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeControllers();
      }
    });
  }

  void _initializeControllers() {
    if (_isInitialized) return;
    final theme = Theme.of(context).colorScheme;
    
    setState(() {
      _primaryCtl.text = colorToHex(theme.primary);
      _secondaryCtl.text = colorToHex(theme.secondary);
      _backgroundCtl.text = colorToHex(theme.background);
      _surfaceCtl.text = colorToHex(theme.surface);
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _primaryCtl.dispose();
    _secondaryCtl.dispose();
    _backgroundCtl.dispose();
    _surfaceCtl.dispose();
    super.dispose();
  }

  Widget _buildColorField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        suffixIcon: IconButton(
          icon: const Icon(Icons.colorize, size: 20),
          tooltip: 'Pick color',
          onPressed: () => _showColorPicker(controller),
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
        LengthLimitingTextInputFormatter(6),
      ],
      onChanged: (value) {
        if (value.length == 6) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _showColorPicker(TextEditingController controller) async {
    final color = await showDialog<String>(
      context: context,
      builder: (context) {
        final textController = TextEditingController(text: controller.text);
        return AlertDialog(
          title: const Text('Enter Color Code'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Hex Color (e.g., 2E7D32)',
              prefixText: '#',
              border: OutlineInputBorder(),
            ),
            maxLength: 6,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: const Text('APPLY'),
            ),
          ],
        );
      },
    );
    
    if (color != null) {
      setState(() {
        controller.text = color.toUpperCase();
      });
    }
  }

  Widget _buildThemePreview() {
    final primary = parseHexColor(_primaryCtl.text) ?? Colors.blue;
    final secondary = parseHexColor(_secondaryCtl.text) ?? Colors.blueGrey;
    final background = parseHexColor(_backgroundCtl.text) ?? Colors.white;
    final surface = parseHexColor(_surfaceCtl.text) ?? Colors.grey[200]!;
    
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 200,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primary.withOpacity(0.3)),
                ),
                child: Text(
                  'This is a preview of your theme colors. Changes will be applied to the entire app.',
                  style: TextStyle(color: primary),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Primary Button'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Secondary Action'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyTheme() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final primary = parseHexColor(_primaryCtl.text);
      final secondary = parseHexColor(_secondaryCtl.text) ?? Colors.blueGrey;
      final background = parseHexColor(_backgroundCtl.text) ?? Colors.white;
      final surface = parseHexColor(_surfaceCtl.text) ?? Colors.grey[200]!;
      
      if (primary == null) {
        throw Exception('Please enter a valid primary color');
      }
      
      final controller = context.read<ThemeController>();
      await controller.updateColors(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ResponsiveScaffold(
      title: 'Theme Editor',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Theme Colors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildColorField('Primary Color', _primaryCtl, Icons.color_lens),
                            const SizedBox(height: 16),
                            _buildColorField('Secondary Color', _secondaryCtl, Icons.color_lens_outlined),
                            const SizedBox(height: 16),
                            _buildColorField('Background Color', _backgroundCtl, Icons.brush),
                            const SizedBox(height: 16),
                            _buildColorField('Surface Color', _surfaceCtl, Icons.texture),
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: colorScheme.onErrorContainer, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(color: colorScheme.onErrorContainer),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: _isLoading 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.check_circle, size: 20),
                                onPressed: _isLoading ? null : _applyTheme,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                ),
                                label: Text(
                                  _isLoading ? 'Applying...' : 'Apply Theme',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Theme Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildThemePreview(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Add bottom padding
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
