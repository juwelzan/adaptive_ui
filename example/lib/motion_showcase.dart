import 'package:adaptive_ui/adaptive_ui.dart';
import 'package:flutter/material.dart';

/// Interactive showcase demonstrating Phase 4 Motion, Navigation & Skeleton systems.
class MotionShowcaseTab extends StatefulWidget {
  const MotionShowcaseTab({
    super.key,
    required this.layout,
  });

  final AdaptiveLayoutData layout;

  @override
  State<MotionShowcaseTab> createState() => _MotionShowcaseTabState();
}

class _MotionShowcaseTabState extends State<MotionShowcaseTab> {
  // Skeleton / Shimmer state
  bool _isLoading = true;

  // AdaptiveContainer animation state
  bool _containerExpanded = false;

  // Sidebar preview state
  int _sidebarIndex = 0;
  bool _sidebarExpanded = true;

  // Bottom Navigation preview state
  int _bottomNavIndex = 0;

  // AdaptiveText replay trigger
  int _textReplayKey = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScrollView(
      padding: const EdgeInsets.all(16.0),
      centerContent: true,
      maxContentWidth: 1080.0,
      child: AdaptiveColumn(
        spacing: const AdaptiveValue.fixed(24.0),
        children: [
          // Section 1: AdaptiveText Motion & Marquee
          _buildTextMotionSection(context),

          // Section 2: AdaptiveContainer Animated Properties
          _buildContainerMotionSection(context),

          // Section 3: AdaptiveShimmer & Skeleton Loading
          _buildSkeletonLoadingSection(context),

          // Section 4: AdaptiveSidebar Component Preview
          _buildSidebarSection(context),

          // Section 5: AdaptiveBottomNavigationBar Component Preview
          _buildBottomNavSection(context),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. AdaptiveText Animations
  // ---------------------------------------------------------------------------
  Widget _buildTextMotionSection(BuildContext context) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const AdaptiveText(
                    '1. AdaptiveText Motion & Marquee',
                    baseFontSize: 18.0,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _textReplayKey++),
                  icon: const Icon(Icons.replay, size: 16),
                  label: const Text('Replay Entrance'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text(
              'AdaptiveText auto-detects true constraint overflow for marquee scrolling '
              'and supports entrance motion (Fade, Slide, Typewriter) with reduced-motion awareness.',
              style: TextStyle(color: Colors.black54, fontSize: 13.0),
            ),
            const SizedBox(height: 16.0),

            // Marquee Demo (bounded container that forces overflow)
            const Text('Marquee (Constrained width auto-scroller):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6.0),
            Container(
              width: 260.0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: AdaptiveText(
                'Department of Advanced Artificial Intelligence and Autonomous Cybernetics Laboratory',
                animation: AdaptiveTextAnimation.marquee,
                scrollSpeed: 38.0,
                pauseDuration: Duration(milliseconds: 1200),
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF1E5BB0)),
              ),
            ),
            const SizedBox(height: 16.0),

            // Entrance Animations (Keyed for replay)
            KeyedSubtree(
              key: ValueKey('text_entrance_$_textReplayKey'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Typewriter Effect:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4.0),
                  const AdaptiveText(
                    'Building responsive, motion-rich Flutter user interfaces automatically.',
                    animation: AdaptiveTextAnimation.typewriter,
                    animationDuration: Duration(milliseconds: 1400),
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                  const SizedBox(height: 12.0),
                  const Text('Slide In & Fade In Effects:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4.0),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const AdaptiveText(
                          'Slide Entrance',
                          animation: AdaptiveTextAnimation.slideIn,
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const AdaptiveText(
                          'Fade Entrance',
                          animation: AdaptiveTextAnimation.fadeIn,
                          style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. AdaptiveContainer Animated Properties
  // ---------------------------------------------------------------------------
  Widget _buildContainerMotionSection(BuildContext context) {
    final theme = Theme.of(context);

    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const AdaptiveText(
                    '2. AdaptiveContainer Implicit Animations',
                    baseFontSize: 18.0,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      setState(() => _containerExpanded = !_containerExpanded),
                  icon: Icon(_containerExpanded
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen),
                  label: Text(_containerExpanded ? 'Contract' : 'Expand'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Supports smooth implicit animations for decoration, radii, padding, margin, '
              'constraints, and opacity without controller boilerplate. Hover/press interactive styling enabled.',
              style: TextStyle(color: Colors.black54, fontSize: 13.0),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: AdaptiveContainer(
                animateChanges: true,
                animationDuration: const Duration(milliseconds: 350),
                animationCurve: Curves.easeOutCubic,
                width: AdaptiveValue.fixed(_containerExpanded ? 340.0 : 220.0),
                height: AdaptiveValue.fixed(_containerExpanded ? 130.0 : 90.0),
                padding: AdaptiveInsets.all(_containerExpanded ? 20.0 : 12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _containerExpanded
                        ? [Colors.deepPurple, Colors.indigo]
                        : [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary
                          ],
                  ),
                  borderRadius:
                      BorderRadius.circular(_containerExpanded ? 24.0 : 8.0),
                  boxShadow: [
                    BoxShadow(
                      color: (_containerExpanded ? Colors.indigo : Colors.blue)
                          .withValues(alpha: 0.3),
                      blurRadius: _containerExpanded ? 16.0 : 6.0,
                      offset: Offset(0, _containerExpanded ? 8 : 3),
                    ),
                  ],
                ),
                hoverDecoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _containerExpanded
                            ? Icons.auto_awesome
                            : Icons.touch_app,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _containerExpanded
                            ? 'Expanded (Animated)'
                            : 'Compact (Tap Expand or Hover)',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. AdaptiveShimmer & Skeleton Loading
  // ---------------------------------------------------------------------------
  Widget _buildSkeletonLoadingSection(BuildContext context) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const AdaptiveText(
                    '3. Shimmer & Skeleton System',
                    baseFontSize: 18.0,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                FilterChip(
                  label: Text(_isLoading ? 'Loading: ON' : 'Loading: OFF'),
                  selected: _isLoading,
                  onSelected: (val) => setState(() => _isLoading = val),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text(
              'GPU-accelerated linear gradient shimmer mask with cross-fade content switching '
              'and composable skeleton primitives (Text, Container, List).',
              style: TextStyle(color: Colors.black54, fontSize: 13.0),
            ),
            const SizedBox(height: 16.0),

            // AdaptiveSkeleton conditional switcher
            AdaptiveSkeleton(
              loading: _isLoading,
              placeholder: AdaptiveCard(
                elevation: 0,
                color: Colors.grey.withValues(alpha: 0.08),
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      AdaptiveSkeleton.circle(size: 52),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AdaptiveSkeletonText(lines: 1, lineHeight: 16),
                            SizedBox(height: 8),
                            AdaptiveSkeletonText(lines: 2, lineHeight: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: AdaptiveCard(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFF1E5BB0),
                        child:
                            Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dr. Evelyn Vance',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chair of Distributed Systems & Real-time Robotics Lab',
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Skeleton Repeated List Preview (when loading is true)
            if (_isLoading) ...[
              const Text('AdaptiveSkeletonList Preview:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8.0),
              const SizedBox(
                height: 140.0,
                child: AdaptiveSkeletonList(
                  itemCount: 2,
                  spacing: 8.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. AdaptiveSidebar Component Preview
  // ---------------------------------------------------------------------------
  Widget _buildSidebarSection(BuildContext context) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: const AdaptiveText(
                    '4. AdaptiveSidebar Navigation',
                    baseFontSize: 18.0,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _sidebarExpanded = !_sidebarExpanded),
                  icon: Icon(_sidebarExpanded
                      ? Icons.arrow_back_ios_new
                      : Icons.arrow_forward_ios),
                  label: Text(_sidebarExpanded ? 'Collapse' : 'Expand'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Responsive sidebar supporting expanded & compact rail modes with animated '
              'width transitions, animated selection pill, badges, tooltips, and overflow safety.',
              style: TextStyle(color: Colors.black54, fontSize: 13.0),
            ),
            const SizedBox(height: 16.0),

            // Constrained frame containing the sidebar
            Container(
              height: 280.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AdaptiveSidebar(
                    selectedIndex: _sidebarIndex,
                    isExpanded: _sidebarExpanded,
                    onDestinationSelected: (idx) =>
                        setState(() => _sidebarIndex = idx),
                    header: ClipRect(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.layers, color: Color(0xFF1E5BB0)),
                            if (_sidebarExpanded) ...[
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'Studio Rail',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    items: const [
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.analytics_outlined),
                        selectedIcon: Icon(Icons.analytics),
                        label: Text('Analytics'),
                        badge: Text('3',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.dataset_outlined),
                        selectedIcon: Icon(Icons.dataset),
                        label: Text('Datasets'),
                      ),
                      AdaptiveSidebarItem(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Selected Page: item #$_sidebarIndex',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. AdaptiveBottomNavigationBar Component Preview
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavSection(BuildContext context) {
    return AdaptiveCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdaptiveText(
              '5. AdaptiveBottomNavigationBar',
              baseFontSize: 18.0,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Material 3 aligned compact bottom navigation bar with animated indicator pills, '
              'label visibility policies, safe area padding, and accessible touch targets >= 48dp.',
              style: TextStyle(color: Colors.black54, fontSize: 13.0),
            ),
            const SizedBox(height: 16.0),

            // Embedded preview
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      color: Colors.grey.shade50,
                      alignment: Alignment.center,
                      child: Text(
                        'Active Bottom Nav Tab: #$_bottomNavIndex',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    AdaptiveBottomNavigationBar(
                      selectedIndex: _bottomNavIndex,
                      onDestinationSelected: (idx) =>
                          setState(() => _bottomNavIndex = idx),
                      destinations: const [
                        AdaptiveBottomNavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        AdaptiveBottomNavigationDestination(
                          icon: Icon(Icons.search_outlined),
                          selectedIcon: Icon(Icons.search),
                          label: 'Search',
                        ),
                        AdaptiveBottomNavigationDestination(
                          icon: Icon(Icons.notifications_outlined),
                          selectedIcon: Icon(Icons.notifications),
                          label: 'Alerts',
                          badge: Text('9+',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 9)),
                        ),
                        AdaptiveBottomNavigationDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
