import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/app/presentation/widgets/buttons/bottom_bar_button.dart';

@RoutePage()
class BottomBarPage extends StatefulWidget {
  const BottomBarPage({super.key});

  @override
  State<BottomBarPage> createState() => _BottomBarPageState();
}

class _BottomBarPageState extends State<BottomBarPage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          Center(child: Text('Каталог')),
          Center(child: Text('Карта')),
          Center(child: Text('Ассистент')),
          Center(child: Text('Избранное')),
          Center(child: Text('Профиль')),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 80,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // Bottom bar row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // First two items
                      BottomBarButton(
                        icon: 'assets/icons/home.png',
                        selectedIcon: 'assets/icons/home_filled.png',
                        label: 'Башкы бет',
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onItemTapped(0),
                      ),
                      BottomBarButton(
                        icon: 'assets/icons/users.png',
                        selectedIcon: 'assets/icons/users_filled.png',
                        label: 'Жайдемчилер',
                        isSelected: _selectedIndex == 1,
                        onTap: () => _onItemTapped(1),
                      ),

                      // Empty space for assistant
                      Opacity(
                        opacity: 0.0,
                        child: SizedBox(
                          width: 70,
                        ),
                      ),

                      // Last two items
                      BottomBarButton(
                        icon: 'assets/icons/events.png',
                        selectedIcon: 'assets/icons/events_filled.png',
                        label: 'Мероприятия',
                        isSelected: _selectedIndex == 3,
                        onTap: () => _onItemTapped(3),
                      ),
                      BottomBarButton(
                        icon: 'assets/icons/profile.png',
                        selectedIcon: 'assets/icons/profile_filled.png',
                        label: 'Профиль',
                        isSelected: _selectedIndex == 4,
                        onTap: () => _onItemTapped(4),
                      ),
                    ],
                  ),
                ),
                // Floating action button (Goal button)
                Positioned(
                  top: 5,
                  child: GestureDetector(
                    onTap: () => _onItemTapped(2),
                    child: Image.asset(
                      _selectedIndex == 2
                          ? 'assets/icons/goal_filled.png'
                          : 'assets/icons/goal.png',
                      width: 70,
                      height: 70,
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
}
