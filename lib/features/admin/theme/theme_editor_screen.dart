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
  late TextEditingController primaryCtl;
  late TextEditingController secondaryCtl;
  late TextEditingController backgroundCtl;
  late TextEditingController surfaceCtl;
  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersInitialized) return;
    final theme = Theme.of(context).colorScheme;
    primaryCtl = TextEditingController(text: colorToHex(theme.primary));
    secondaryCtl = TextEditingController(text: colorToHex(theme.secondary));
    backgroundCtl = TextEditingController(text: colorToHex(theme.surface));
    surfaceCtl = TextEditingController(text: colorToHex(theme.surface));
    _controllersInitialized = true;
  }

  @override
  void dispose() {
    primaryCtl.dispose();
    secondaryCtl.dispose();
    backgroundCtl.dispose();
    surfaceCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    return ResponsiveScaffold(
      title: 'Theme Editor',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _colorField('Primary', primaryCtl),
          _colorField('Secondary', secondaryCtl),
          _colorField('Background', backgroundCtl),
          _colorField('Surface', surfaceCtl),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final primary = parseHexColor(primaryCtl.text);
              final secondary = parseHexColor(secondaryCtl.text);
              final background = parseHexColor(backgroundCtl.text);
              final surface = parseHexColor(surfaceCtl.text);
              if (primary == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid primary color')));
                return;
              }
              controller.updateColors(
                primary: primary,
                secondary: secondary,
                background: background,
                surface: surface,
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _colorField(String label, TextEditingController ctl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctl,
        decoration: InputDecoration(
          labelText: '$label Color (e.g. #2E7D32)',
        ),
      ),
    );
  }
}


