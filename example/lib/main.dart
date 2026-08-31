import 'package:flutter/cupertino.dart';
import 'package:cupertino_anchor/cupertino_anchor.dart';

void main() {
  runApp(const CupertinoDropdownDemoApp());
}

class UserItem {
  final String id;
  final String name;
  final String role;
  final IconData icon;

  const UserItem({
    required this.id,
    required this.name,
    required this.role,
    required this.icon,
  });

  @override
  String toString() => name;
}

class CupertinoDropdownDemoApp extends StatefulWidget {
  const CupertinoDropdownDemoApp({super.key});

  @override
  State<CupertinoDropdownDemoApp> createState() =>
      _CupertinoDropdownDemoAppState();
}

class _CupertinoDropdownDemoAppState extends State<CupertinoDropdownDemoApp> {
  Brightness _brightness = Brightness.light;

  void _toggleTheme() {
    setState(() {
      _brightness =
          _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Cupertino Dropdown Showcase',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: _brightness,
        primaryColor: const Color(0xFF007AFF),
      ),
      home: DemoHomePage(
        currentBrightness: _brightness,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  final Brightness currentBrightness;
  final VoidCallback onToggleTheme;

  const DemoHomePage({
    super.key,
    required this.currentBrightness,
    required this.onToggleTheme,
  });

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  // Demo State Variables
  String? _selectedState;
  String? _selectedTopState;
  String? _selectedBottomState;
  String? _selectedConstrainedState;
  String? _selectedListState;
  String? _selectedKeyboardState;
  UserItem? _selectedUser;
  int _rapidTapCount = 0;

  final CupertinoDropdownController _controller = CupertinoDropdownController();

  final List<String> _states = const [
    'California',
    'New York',
    'Texas',
    'Florida',
    'Washington',
    'Tamil Nadu',
    'Kerala',
    'Karnataka',
  ];

  final List<UserItem> _users = const [
    UserItem(
      id: '1',
      name: 'Tim Cook',
      role: 'Chief Executive Officer',
      icon: CupertinoIcons.person_crop_circle_fill,
    ),
    UserItem(
      id: '2',
      name: 'Craig Federighi',
      role: 'SVP Software Engineering',
      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
    ),
    UserItem(
      id: '3',
      name: 'Eddy Cue',
      role: 'SVP Services',
      icon: CupertinoIcons.person_crop_circle,
    ),
  ];

  Widget _buildSectionHeader(String title, String subtitle) {
    final bool isDark = widget.currentBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.0,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.currentBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Cupertino Dropdown Demos'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.onToggleTheme,
          child: Icon(
            isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Demo 1: Basic String Dropdown
            _buildSectionHeader('Demo 1 — Basic CupertinoDropdown<String>',
                'Clean iOS-styled dropdown with selection checkmark'),
            CupertinoDropdown<String>(
              items: _states,
              value: _selectedState,
              hint: 'Select a region',
              onChanged: (val) => setState(() => _selectedState = val),
            ),

            // Demo 2: Opens Below (Anchored high)
            _buildSectionHeader('Demo 2 — Automatic Placement (Opens Below)',
                'Plenty of space below, automatically resolves direction to DOWN'),
            CupertinoDropdown<String>(
              items: _states,
              value: _selectedTopState,
              hint: 'Picks DOWN direction',
              onChanged: (val) => setState(() => _selectedTopState = val),
            ),

            // Demo 3: Opens Above (Near bottom or forced)
            _buildSectionHeader('Demo 3 — Opens Above',
                'Forced or constrained to open UP with anchored origin animation'),
            CupertinoDropdown<String>(
              items: _states,
              value: _selectedBottomState,
              direction: DropdownDirection.up,
              hint: 'Forced UP direction',
              onChanged: (val) => setState(() => _selectedBottomState = val),
            ),

            // Demo 4: Constrained Space
            _buildSectionHeader('Demo 4 — Constrained Height Space',
                'Automatically adjusts height when vertical area is limited'),
            Container(
              height: 120,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: CupertinoDropdown<String>(
                items: _states,
                value: _selectedConstrainedState,
                maxHeight: 100,
                hint: 'Constrained height dropdown',
                onChanged: (val) =>
                    setState(() => _selectedConstrainedState = val),
              ),
            ),

            // Demo 5: Inside ScrollView / Anchor Tracking
            _buildSectionHeader('Demo 5 — Inside Scrollable View',
                'Scroll while open to test live anchor tracking or dismiss on scroll'),
            CupertinoDropdown<String>(
              items: _states,
              value: _selectedListState,
              hint: 'Scroll aware dropdown',
              dismissBehavior:
                  DropdownDismissBehavior.closeWhenAnchorLeavesScreen,
              onChanged: (val) => setState(() => _selectedListState = val),
            ),

            // Demo 6: Keyboard Avoidance
            _buildSectionHeader('Demo 6 — Keyboard Inset Awareness',
                'Tap the text field to raise keyboard and observe repositioning'),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: CupertinoTextField(
                placeholder: 'Tap to raise keyboard',
                padding: EdgeInsets.all(12.0),
              ),
            ),
            CupertinoDropdown<String>(
              items: _states,
              value: _selectedKeyboardState,
              hint: 'Keyboard-aware dropdown',
              onChanged: (val) => setState(() => _selectedKeyboardState = val),
            ),

            // Demo 7: Tablet / Wide Custom Width
            _buildSectionHeader('Demo 7 — Custom Width & Boundaries',
                'Specifies custom popup width and stays bounded to screen'),
            Row(
              children: [
                Expanded(
                  child: CupertinoDropdown<String>(
                    items: _states,
                    hint: 'Left item (popup width 260)',
                    popupWidth: 260,
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoDropdown<String>(
                    items: _states,
                    hint: 'Right item (popup width 260)',
                    popupWidth: 260,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),

            // Demo 8: Dark Mode & Custom Theming
            _buildSectionHeader('Demo 8 — Custom Theming & Blur Sigma',
                'Custom frosted glass, purple accent and border radius'),
            CupertinoDropdown<String>(
              items: _states,
              hint: 'Custom styled dropdown',
              theme: CupertinoDropdownTheme(
                borderRadius: BorderRadius.circular(20.0),
                checkmarkColor: CupertinoColors.systemPurple,
                backdropBlurSigma: 30.0,
                selectedItemTextStyle: const TextStyle(
                  color: CupertinoColors.systemPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
              onChanged: (_) {},
            ),

            // Demo 9: Custom Item Builder (Generic Objects)
            _buildSectionHeader('Demo 9 — Custom Generic Models & ItemBuilder',
                'Generic object binding with custom avatar, subtitle & title'),
            CupertinoDropdown<UserItem>(
              items: _users,
              value: _selectedUser,
              hint: 'Select team member',
              theme: const CupertinoDropdownTheme(itemHeight: 56.0),
              itemBuilder: (context, user) {
                return Row(
                  children: [
                    Icon(user.icon,
                        size: 28, color: CupertinoColors.activeBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user.role,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              onChanged: (user) => setState(() => _selectedUser = user),
            ),

            // Demo 10: Rapid Open / Close & Controller Stress Test
            _buildSectionHeader('Demo 10 — Controller & Rapid Tap Protection',
                'Programmatic control and stress test counter'),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text('Toggle Controller'),
                    onPressed: () {
                      _controller.toggle();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: CupertinoColors.systemGrey5,
                  child: Text('Rapid Tap: $_rapidTapCount'),
                  onPressed: () {
                    setState(() => _rapidTapCount++);
                    _controller.toggle();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            CupertinoDropdown<String>(
              controller: _controller,
              items: _states,
              hint: 'Programmatic controller dropdown',
              onChanged: (_) {},
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
