import 'package:bbs_driver/features/home/presentation/pages/order_page.dart';
import 'package:bbs_driver/features/home/presentation/pages/visit_plan_page.dart';
import 'package:bbs_driver/features/profile/presentation/pages/profile_page.dart';
// import 'package:bbs_sales_app/features/home/presentation/pages/order_page.dart';
// import 'package:bbs_sales_app/features/home/presentation/pages/visit_plan_page.dart';
// import 'package:bbs_sales_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/activity_section.dart';
import '../widgets/announcement_section.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/info_card.dart';
import '../widgets/menu_grid.dart';
import '../widgets/route_section.dart';
import '../widgets/target_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchUserDetails();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isLoading && auth.user?.name == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // if (auth.error != null) {}

            switch (_selectedIndex) {
              case 0:
                return _buildHomeContent(auth);
              case 1:
                return const OrderPage();
              case 2:
                return const VisitPlanPage();
              case 3:
                return const ProfilePage();
              default:
                return _buildHomeContent(auth);
            }
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(AuthProvider auth) {
    return RefreshIndicator(
      onRefresh: () => auth.fetchUserDetails(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(userName: auth.user?.name),
            const SizedBox(height: 16),
            const TargetCard(),
            const SizedBox(height: 16),
            const InfoCard(),
            const SizedBox(height: 20),
            const MenuGrid(),
            const SizedBox(height: 24),
            const ActivitySection(),
            const SizedBox(height: 24),
            const RouteSection(),
            const SizedBox(height: 24),
            const AnnouncementSection(),
          ],
        ),
      ),
    );
  }
}
