import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// UI-only employer journey for Checkpoint 1.
/// Data is held locally for demonstration; no backend is connected.
class CorporateScreen extends StatefulWidget {
  const CorporateScreen({super.key});

  @override
  State<CorporateScreen> createState() => _CorporateScreenState();
}

class _CorporateScreenState extends State<CorporateScreen> {
  final _orgKey = GlobalKey<FormState>();
  final _employeeKey = GlobalKey<FormState>();
  final _orgName = TextEditingController(text: 'ABC Sdn Bhd');
  final _contactName = TextEditingController(text: 'Aina Rahman');
  final _workEmail = TextEditingController(text: 'aina@abc.com');
  final _employeeName = TextEditingController();
  final _employeeEmail = TextEditingController();

  int _step = 0;
  String _selectedCourse = 'Emotional Intelligence Fundamentals';
  String _deadline = '30 October 2026';
  final Set<int> _assignedEmployees = {0, 1};
  final List<_Employee> _employees = [
    _Employee('Daniel Lim', 'daniel@abc.com', 'Human Resources', 80),
    _Employee('Sarah Tan', 'sarah@abc.com', 'Finance', 100),
    _Employee('Amir Hakim', 'amir@abc.com', 'Management', 35),
  ];

  final List<String> _courses = const [
    'Emotional Intelligence Fundamentals',
    'Leadership Development',
    'Team Engagement',
    'Workplace Well-being',
  ];

  @override
  void dispose() {
    _orgName.dispose();
    _contactName.dispose();
    _workEmail.dispose();
    _employeeName.dispose();
    _employeeEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Employer Portal'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.deepBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                const SizedBox(height: 22),
                _overviewCards(),
                const SizedBox(height: 26),
                _stepNavigation(),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _step == 0
                        ? _organizationStep()
                        : _step == 1
                            ? _employeesStep()
                            : _step == 2
                                ? _assignStep()
                                : _progressStep(),
                  ),
                ),
                const SizedBox(height: 22),
                _bottomNavigation(),
                const SizedBox(height: 24),
                const Text(
                  'Prototype demo • Changes are stored locally during this session only.',
                  style: TextStyle(color: AppTheme.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppTheme.deepBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.softYellow,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'EMPLOYER JOURNEY',
              style: TextStyle(
                color: AppTheme.deepBlue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Grow your people.\nTrack your impact.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Manage your organisation, add employees, assign learning and review progress.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCards() {
    final completed = _employees.where((e) => e.progress >= 100).length;
    final average = _employees.isEmpty
        ? 0
        : (_employees.fold<int>(0, (sum, e) => sum + e.progress) /
                _employees.length)
            .round();
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 650 ? 3 : 1;
        final cards = [
          _metricCard('Employees', '${_employees.length}', Icons.groups_outlined),
          _metricCard('Employees assigned', '${_assignedEmployees.length}', Icons.school_outlined),
          _metricCard('Average progress', '$average%', Icons.trending_up_rounded),
        ];
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: count == 1 ? 4.2 : 2.0,
          children: [
            cards[0],
            cards[1],
            _metricCard('Completed learners', '$completed', Icons.verified_outlined),
          ],
        );
      },
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8EE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.purple.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: AppTheme.deepBlue, fontSize: 21, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: AppTheme.greyText, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepNavigation() {
    const labels = ['Organisation', 'Employees', 'Assign course', 'Progress'];
    const icons = [Icons.business_outlined, Icons.groups_outlined, Icons.school_outlined, Icons.insights_outlined];
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE6E8EE))),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(labels.length, (i) {
          final selected = _step == i;
          return TextButton.icon(
            onPressed: () => setState(() => _step = i),
            icon: Icon(icons[i], size: 17),
            label: Text('${i + 1}. ${labels[i]}'),
            style: TextButton.styleFrom(
              backgroundColor: selected ? AppTheme.deepBlue : Colors.transparent,
              foregroundColor: selected ? Colors.white : AppTheme.deepBlue,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }),
      ),
    );
  }

  Widget _panel(String title, String subtitle, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE6E8EE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.deepBlue, fontSize: 23, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: AppTheme.greyText, height: 1.5)),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _organizationStep() {
    return _panel(
      '1. Register organisation',
      'Set up the organisation profile for this demo.',
      Form(
        key: _orgKey,
        child: Column(
          children: [
            _field(_orgName, 'Organisation name'),
            _field(_contactName, 'Contact person'),
            _field(_workEmail, 'Work email', email: true),
            Align(
              alignment: Alignment.centerLeft,
              child: _primaryButton('Save organisation', Icons.check_rounded, () {
                if (_orgKey.currentState!.validate()) {
                  _showMessage('Organisation details saved for this demo.');
                  setState(() => _step = 1);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _employeesStep() {
    return _panel(
      '2. Add employees',
      'Add team members and review the current sample employee list.',
      Column(
        children: [
          Form(
            key: _employeeKey,
            child: Column(
              children: [
                _field(_employeeName, 'Employee name'),
                _field(_employeeEmail, 'Employee email', email: true),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _primaryButton('Add employee', Icons.person_add_alt_1_rounded, _addEmployee),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(_employees.length, (i) => _employeeTile(_employees[i], showCheckbox: false)),
        ],
      ),
    );
  }

  Widget _assignStep() {
    return _panel(
      '3. Assign a course',
      'Choose a learning programme, select employees and confirm the assignment.',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Learning programme', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.deepBlue)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCourse,
            isExpanded: true,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
            items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (value) => setState(() => _selectedCourse = value ?? _selectedCourse),
          ),
          const SizedBox(height: 16),
          const Text('Assign to employees', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.deepBlue)),
          const SizedBox(height: 8),
          ...List.generate(_employees.length, (i) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _assignedEmployees.contains(i),
                activeColor: AppTheme.purple,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(_employees[i].name),
                subtitle: Text(_employees[i].department),
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _assignedEmployees.add(i);
                  } else {
                    _assignedEmployees.remove(i);
                  }
                }),
              )),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _deadline,
            decoration: InputDecoration(labelText: 'Completion deadline', border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
            items: const ['30 October 2026', '15 November 2026', '30 November 2026'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (value) => setState(() => _deadline = value ?? _deadline),
          ),
          const SizedBox(height: 18),
          _primaryButton('Assign course', Icons.assignment_turned_in_outlined, () {
            if (_assignedEmployees.isEmpty) {
              _showMessage('Select at least one employee first.');
              return;
            }
            _showMessage('$_selectedCourse assigned to ${_assignedEmployees.length} employee(s).');
            setState(() => _step = 3);
          }),
        ],
      ),
    );
  }

  Widget _progressStep() {
    final average = _employees.isEmpty ? 0 : (_employees.fold<int>(0, (sum, e) => sum + e.progress) / _employees.length).round();
    return _panel(
      '4. View learning progress',
      'Example progress data for ${_orgName.text.trim().isEmpty ? 'your organisation' : _orgName.text.trim()}.',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFE9E0F5), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Expanded(child: Text('Average team progress', style: TextStyle(color: AppTheme.deepBlue, fontWeight: FontWeight.w700))),
                Text('$average%', style: const TextStyle(color: AppTheme.deepBlue, fontSize: 25, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._employees.map((employee) => _progressTile(employee)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _secondaryButton('Back to assignment', Icons.arrow_back_rounded, () => setState(() => _step = 2)),
              _primaryButton('Finish demo journey', Icons.check_circle_outline, () {
                _showMessage('Journey C complete: organisation → employees → course assignment → progress.');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool email = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Please enter $label';
          if (email && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) return 'Enter a valid email address';
          return null;
        },
      ),
    );
  }

  Widget _employeeTile(_Employee employee, {required bool showCheckbox}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppTheme.purple.withValues(alpha: 0.15), foregroundColor: AppTheme.purple, child: Text(employee.name.isEmpty ? '?' : employee.name[0])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(employee.name, style: const TextStyle(color: AppTheme.deepBlue, fontWeight: FontWeight.w700)), Text(employee.email, style: const TextStyle(color: AppTheme.greyText, fontSize: 12)), Text(employee.department, style: const TextStyle(color: AppTheme.greyText, fontSize: 12))])),
          if (showCheckbox) const Icon(Icons.check_box_outline_blank),
        ],
      ),
    );
  }

  Widget _progressTile(_Employee employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(employee.name, style: const TextStyle(color: AppTheme.deepBlue, fontWeight: FontWeight.w700))), Text('${employee.progress}%', style: const TextStyle(color: AppTheme.purple, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 5),
          Text('${employee.department} • ${employee.progress >= 100 ? 'Completed' : 'In progress'}', style: const TextStyle(color: AppTheme.greyText, fontSize: 12)),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: employee.progress / 100, minHeight: 8, backgroundColor: const Color(0xFFE0E3EA), color: AppTheme.purple)),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.deepBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _secondaryButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.deepBlue,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_step > 0)
          _secondaryButton('Previous', Icons.arrow_back_rounded, () => setState(() => _step--))
        else
          const SizedBox.shrink(),
        if (_step < 3)
          _primaryButton('Next step', Icons.arrow_forward_rounded, () {
            if (_step == 0 && !_orgKey.currentState!.validate()) return;
            setState(() => _step++);
          }),
      ],
    );
  }

  void _addEmployee() {
    if (!_employeeKey.currentState!.validate()) return;
    setState(() {
      _employees.add(_Employee(_employeeName.text.trim(), _employeeEmail.text.trim(), 'General', 0));
      _employeeName.clear();
      _employeeEmail.clear();
      _assignedEmployees.add(_employees.length - 1);
    });
    _showMessage('Employee added to the demo list.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Employee {
  final String name;
  final String email;
  final String department;
  final int progress;
  const _Employee(this.name, this.email, this.department, this.progress);
}
