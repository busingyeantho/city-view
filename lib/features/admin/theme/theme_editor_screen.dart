import 'package:flutter/material.dart';
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
  late final TextEditingController primaryCtl;
  late final TextEditingController secondaryCtl;
  late final TextEditingController backgroundCtl;
  late final TextEditingController surfaceCtl;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    primaryCtl = TextEditingController();
    secondaryCtl = TextEditingController();
    backgroundCtl = TextEditingController();
    surfaceCtl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    if (_isInitialized) return;

    final theme = Theme.of(context).colorScheme;
    primaryCtl.text = colorToHex(theme.primary);
    secondaryCtl.text = colorToHex(theme.secondary);
    backgroundCtl.text = colorToHex(theme.background);
    surfaceCtl.text = colorToHex(theme.surface);

    _isInitialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    primaryCtl.dispose();
    secondaryCtl.dispose();
    backgroundCtl.dispose();
    surfaceCtl.dispose();
    super.dispose();
  }

  Future<void> _applyTheme() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final primary = parseHexColor(primaryCtl.text);
      final secondary = parseHexColor(secondaryCtl.text);
      final background = parseHexColor(backgroundCtl.text);
      final surface = parseHexColor(surfaceCtl.text);

      if (primary == null) {
        throw Exception('Please enter a valid primary color');
      }

      final controller = context.read<ThemeController>();
      controller.updateColors(
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
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Theme Editor',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _buildColorField('Primary', primaryCtl, isRequired: true),
          const SizedBox(height: 12),
          _buildColorField('Secondary', secondaryCtl),
          const SizedBox(height: 12),
          _buildColorField('Background', backgroundCtl),
          const SizedBox(height: 12),
          _buildColorField('Surface', surfaceCtl),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _applyTheme,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isLoading ? 'Applying...' : 'Apply Theme'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: '$label Color${isRequired ? ' *' : ''}',
        hintText: 'e.g. #2E7D32',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.color_lens),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        errorMaxLines: 2,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.isNotEmpty && parseHexColor(value) == null) {
          return 'Please enter a valid color code (e.g., #2E7D32)';
        }
        return null;
      },
    );
  }
}
