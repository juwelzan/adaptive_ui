import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';

/// Interactive showcase demonstrating Phase 9 Adaptive Layout Builder,
/// Adaptive Grid, SliverAdaptiveGrid, AdaptiveRow wrapping, and constraint-aware layouts.
class LayoutShowcaseTab extends StatefulWidget {
  const LayoutShowcaseTab({super.key, required this.layout});

  final AdaptiveLayoutData layout;

  @override
  State<LayoutShowcaseTab> createState() => _LayoutShowcaseTabState();
}

class _LayoutShowcaseTabState extends State<LayoutShowcaseTab> {
  // 1. Live layout preview width
  double _previewWidth = 420.0;
  bool _preserveState = true;
  final TextEditingController _statePreserveController = TextEditingController(
    text: 'Form data preserved across breakpoints',
  );

  // 2. Grid controls
  int _gridItemCount = 12;
  double _gridMinItemWidth = 160.0;
  int _gridMaxColumns = 4;
  int _gridMinColumns = 1;
  bool _useSliverGrid = false;

  // 3. Row & Column controls
  bool _rowAutoCollapse = true;
  bool _rowWrap = false;
  double _rowMinItemWidth = 140.0;
  Axis? _rowDirectionOverride;
  double _columnMaxWidth = 600.0;

  // 4. Accessibility & Directionality
  bool _isRtl = false;
  double _textScale = 1.0;

  @override
  void dispose() {
    _statePreserveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_textScale),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader(
              title: 'Adaptive Layout Builder (Live Constraint Simulator)',
              subtitle:
                  'Resize available width to watch slot builders transition dynamically without rebuilding unrelated subtrees.',
            ),
            const SizedBox(height: 12.0),
            _buildWidthControls(),
            const SizedBox(height: 16.0),
            _buildInteractiveLayoutPreview(),
            const SizedBox(height: 32.0),
            _buildSectionHeader(
              title: 'Responsive Grid System & Lazy Collections',
              subtitle:
                  'Calculates columns from parent constraints with configurable min/max columns and lazy virtualization.',
            ),
            const SizedBox(height: 12.0),
            _buildGridControls(),
            const SizedBox(height: 16.0),
            _buildGridPreview(),
            const SizedBox(height: 32.0),
            _buildSectionHeader(
              title: 'AdaptiveRow & AdaptiveColumn with Wrapping',
              subtitle:
                  'Automatic direction changes, minimum child width constraints, optional wrapping, and max content centering.',
            ),
            const SizedBox(height: 12.0),
            _buildRowColumnControls(),
            const SizedBox(height: 16.0),
            _buildRowColumnPreview(),
            const SizedBox(height: 32.0),
            _buildSectionHeader(
              title: 'Accessibility & Localization Diagnostics',
              subtitle:
                  'Test narrow constraints (<320dp), extreme text scaling (up to 2.5x), and right-to-left layout direction.',
            ),
            const SizedBox(height: 12.0),
            _buildAccessibilityControls(),
            const SizedBox(height: 48.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          title,
          baseFontSize: 18.0,
          maxFontSize: 22.0,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1E5BB0)),
        ),
        const SizedBox(height: 4.0),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13.0, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildWidthControls() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Preview Constraint Width: ${_previewWidth.toInt()} dp',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: _preserveState,
                  onChanged: (val) => setState(() => _preserveState = val),
                ),
                const SizedBox(width: 4.0),
                const Text('preserveState', style: TextStyle(fontSize: 12.0)),
              ],
            ),
            Slider(
              min: 280.0,
              max: 1200.0,
              value: _previewWidth.clamp(280.0, 1200.0),
              onChanged: (val) => setState(() => _previewWidth = val),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _presetButton('Phone (340dp)', 340.0),
                _presetButton('Foldable (580dp)', 580.0),
                _presetButton('Tablet (760dp)', 760.0),
                _presetButton('Desktop (1024dp)', 1024.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetButton(String label, double width) {
    final bool isSelected = (_previewWidth - width).abs() < 1.0;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        backgroundColor: isSelected ? const Color(0xFF1E5BB0) : null,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF1E5BB0),
      ),
      onPressed: () => setState(() => _previewWidth = width),
      child: Text(label, style: const TextStyle(fontSize: 12.0)),
    );
  }

  Widget _buildInteractiveLayoutPreview() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: _previewWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.blue.shade300, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: AdaptiveLayoutBuilder(
          preserveState: _preserveState,
          compact: (ctx, layout) => _buildSlotCard(
            label: 'Compact Slot (< 600dp)',
            badgeColor: Colors.amber.shade700,
            description:
                'Single-column vertical stack with optimized touch targets.',
            layout: layout,
          ),
          medium: (ctx, layout) => _buildSlotCard(
            label: 'Medium Slot (600dp - 839dp)',
            badgeColor: Colors.teal.shade700,
            description:
                'Two-column balanced split suitable for foldables and portrait tablets.',
            layout: layout,
          ),
          expanded: (ctx, layout) => _buildSlotCard(
            label: 'Expanded Slot (>= 840dp)',
            badgeColor: Colors.indigo.shade700,
            description: 'Multi-pane expanded dashboard layout with sidebars.',
            layout: layout,
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard({
    required String label,
    required Color badgeColor,
    required String description,
    required AdaptiveLayoutData layout,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
            Text(
              '${layout.constraints.maxWidth.toInt()} dp wide',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(
          description,
          style: TextStyle(fontSize: 13.0, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 12.0),
        TextField(
          controller: _statePreserveController,
          decoration: InputDecoration(
            labelText: 'Persistent State Input',
            hintText: 'Type text, then resize above to test preservation',
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: Icon(
              _preserveState ? Icons.lock_outline : Icons.lock_open,
              color: _preserveState ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridControls() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Collection: $_gridItemCount items'),
                ),
                ChoiceChip(
                  label: const Text('1 Item'),
                  selected: _gridItemCount == 1,
                  onSelected: (val) => setState(() => _gridItemCount = 1),
                ),
                const SizedBox(width: 6.0),
                ChoiceChip(
                  label: const Text('12 Items'),
                  selected: _gridItemCount == 12,
                  onSelected: (val) => setState(() => _gridItemCount = 12),
                ),
                const SizedBox(width: 6.0),
                ChoiceChip(
                  label: const Text('500 Items (Lazy)'),
                  selected: _gridItemCount == 500,
                  onSelected: (val) => setState(() => _gridItemCount = 500),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text('Max Columns: $_gridMaxColumns'),
                ),
                Slider(
                  min: 1,
                  max: 8,
                  divisions: 7,
                  value: _gridMaxColumns.toDouble(),
                  onChanged: (val) =>
                      setState(() => _gridMaxColumns = val.toInt()),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text('Min Columns: $_gridMinColumns'),
                ),
                Slider(
                  min: 1,
                  max: 4,
                  divisions: 3,
                  value: _gridMinColumns.toDouble(),
                  onChanged: (val) =>
                      setState(() => _gridMinColumns = val.toInt()),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child:
                      Text('Min Item Width: ${_gridMinItemWidth.toInt()} dp'),
                ),
                Slider(
                  min: 100,
                  max: 300,
                  value: _gridMinItemWidth,
                  onChanged: (val) => setState(() => _gridMinItemWidth = val),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Render using SliverAdaptiveGrid'),
                const Spacer(),
                Switch(
                  value: _useSliverGrid,
                  onChanged: (val) => setState(() => _useSliverGrid = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPreview() {
    if (_useSliverGrid) {
      return Container(
        height: 280.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(12.0),
              sliver: SliverAdaptiveGrid.builder(
                minItemWidth: _gridMinItemWidth,
                maxColumns: _gridMaxColumns,
                minColumns: _gridMinColumns,
                itemCount: _gridItemCount,
                childAspectRatio: 1.4,
                itemBuilder: (ctx, index) => _buildGridCell(index),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 280.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: AdaptiveGrid.builder(
        padding: const EdgeInsets.all(12.0),
        minItemWidth: _gridMinItemWidth,
        maxColumns: _gridMaxColumns,
        minColumns: _gridMinColumns,
        itemCount: _gridItemCount,
        childAspectRatio: 1.4,
        itemBuilder: (ctx, index) => _buildGridCell(index),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.widgets_outlined, size: 24.0, color: Colors.blue.shade700),
          const SizedBox(height: 4.0),
          Text(
            'Cell #$index',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
          ),
        ],
      ),
    );
  }

  Widget _buildRowColumnControls() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('autoCollapse'),
                Switch(
                  value: _rowAutoCollapse,
                  onChanged: (val) => setState(() => _rowAutoCollapse = val),
                ),
                const Spacer(),
                const Text('wrap'),
                Switch(
                  value: _rowWrap,
                  onChanged: (val) => setState(() => _rowWrap = val),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                      'minItemWidth threshold: ${_rowMinItemWidth.toInt()} dp'),
                ),
                Slider(
                  min: 80,
                  max: 220,
                  value: _rowMinItemWidth,
                  onChanged: (val) => setState(() => _rowMinItemWidth = val),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Direction Override: '),
                ChoiceChip(
                  label: const Text('Auto'),
                  selected: _rowDirectionOverride == null,
                  onSelected: (val) =>
                      setState(() => _rowDirectionOverride = null),
                ),
                const SizedBox(width: 4.0),
                ChoiceChip(
                  label: const Text('Row'),
                  selected: _rowDirectionOverride == Axis.horizontal,
                  onSelected: (val) =>
                      setState(() => _rowDirectionOverride = Axis.horizontal),
                ),
                const SizedBox(width: 4.0),
                ChoiceChip(
                  label: const Text('Column'),
                  selected: _rowDirectionOverride == Axis.vertical,
                  onSelected: (val) =>
                      setState(() => _rowDirectionOverride = Axis.vertical),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Text(
                      'AdaptiveColumn maxWidth: ${_columnMaxWidth.toInt()} dp'),
                ),
                Slider(
                  min: 300,
                  max: 1000,
                  value: _columnMaxWidth,
                  onChanged: (val) => setState(() => _columnMaxWidth = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowColumnPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AdaptiveRow Preview:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              AdaptiveRow(
                autoCollapse: _rowAutoCollapse,
                wrap: _rowWrap,
                minItemWidth: _rowMinItemWidth,
                direction: _rowDirectionOverride,
                spacing: const AdaptiveValue.fixed(8.0),
                runSpacing: 8.0,
                children: [
                  _actionChip('Action Alpha', Icons.star_outline),
                  _actionChip('Action Beta', Icons.send_outlined),
                  _actionChip('Action Gamma', Icons.share_outlined),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: AdaptiveColumn(
            maxContentWidth: _columnMaxWidth,
            spacing: const AdaptiveValue.fixed(8.0),
            children: [
              const Text('AdaptiveColumn (Centering on wide screens):',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                height: 40.0,
                color: Colors.orange.shade100,
                alignment: Alignment.center,
                child:
                    Text('Constrained Box (max ${_columnMaxWidth.toInt()} dp)'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16.0),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAccessibilityControls() {
    return Card(
      elevation: 0,
      color: Colors.amber.shade50.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Layout Direction: '),
                ChoiceChip(
                  label: const Text('LTR'),
                  selected: !_isRtl,
                  onSelected: (val) => setState(() => _isRtl = false),
                ),
                const SizedBox(width: 8.0),
                ChoiceChip(
                  label: const Text('RTL (Right to Left)'),
                  selected: _isRtl,
                  onSelected: (val) => setState(() => _isRtl = true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                      'Text Scale Factor: ${_textScale.toStringAsFixed(1)}x'),
                ),
                Slider(
                  min: 0.8,
                  max: 2.2,
                  divisions: 7,
                  value: _textScale,
                  onChanged: (val) => setState(() => _textScale = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
