import 'package:flutter/material.dart';

class AppMenu extends StatelessWidget {
  final String selectedItem;
  final ValueChanged<String> onItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const AppMenu({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: isCollapsed ? 76 : 250,
      color: const Color(0xFF12324A),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
              isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onToggleCollapse,
                  icon: Icon(
                    isCollapsed ? Icons.menu_open : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Image.asset(
                'assets/imagens/EnterDoc.png',
                width: isCollapsed ? 42 : 140,
                height: isCollapsed ? 42 : 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  MenuItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    selected: selectedItem == 'dashboard',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('dashboard'),
                  ),
                  MenuItem(
                    icon: Icons.task_alt,
                    label: 'Tarefas',
                    selected: selectedItem == 'tarefas',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('tarefas'),
                  ),
                  MenuItem(
                    icon: Icons.timeline_rounded,
                    label: 'Cronograma',
                    selected: selectedItem == 'cronograma',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('cronograma'),
                  ),
                  MenuItem(
                    icon: Icons.view_timeline_outlined,
                    label: 'Timeline',
                    selected: selectedItem == 'timeline',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('timeline'),
                  ),
                  MenuItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Agenda',
                    selected: selectedItem == 'agenda',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('agenda'),
                  ),
                  MenuItem(
                    icon: Icons.assignment_outlined,
                    label: 'Chamados MO',
                    selected: selectedItem == 'chamados',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('chamados'),
                  ),
                  MenuItem(
                    icon: Icons.schema_outlined,
                    label: 'SIPOC',
                    selected: selectedItem == 'sipoc',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('sipoc'),
                  ),
                  MenuItem(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Prototipador IA',
                    selected: selectedItem == 'prototipador_ia',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('prototipador_ia'),
                  ),
                  MenuItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Manual IA',
                    selected: selectedItem == 'manual_ia',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('manual_ia'),
                  ),
                  MenuItem(
                    icon: Icons.analytics_outlined,
                    label: 'Insights IA',
                    selected: selectedItem == 'insights',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('insights'),
                  ),
                  MenuItem(
                    icon: Icons.business_outlined,
                    label: 'Clientes',
                    selected: selectedItem == 'clientes',
                    isCollapsed: isCollapsed,
                    onTap: () => onItemSelected('clientes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? Colors.white.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 14,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : Colors.white70,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}