import 'package:bbs_driver/features/deilvery_order/presentation/pages/riwayat_do_page.dart';
import 'package:bbs_driver/features/do_checkin/presentation/pages/do_checkin_page.dart';
import 'package:bbs_driver/features/do_checkin/presentation/pages/do_sudah_confirm_page.dart';
import 'package:bbs_driver/features/do_checkout/presentation/pages/detail_do_checkout.dart';
import 'package:bbs_driver/features/home/presentation/pages/order_page.dart';
import 'package:bbs_driver/features/notification/presentation/pages/notification_page.dart';
import 'package:bbs_driver/features/reimburse/presentation/pages/reimburse_page.dart';
import 'package:bbs_driver/features/home/presentation/pages/visit_plan_page.dart';
import 'package:bbs_driver/features/home/presentation/widgets/action_menu_card.dart';
import 'package:bbs_driver/features/home/presentation/widgets/reimburse_card.dart';
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
  final bool startAsCheckedIn;
  const HomePage({super.key, this.startAsCheckedIn = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    isCheckedIn = widget.startAsCheckedIn;
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
      extendBody: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB703),
        shape: const CircleBorder(),
        onPressed: () {
          // Aksi untuk tombol tengah
        },
        child: const Icon(Icons.location_on, color: Colors.white, size: 30),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 3. Pindahkan SafeArea ke DALAM Consumer dan atur agar tidak memotong bagian bawah
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading && auth.user?.name == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(bottom: true, child: _buildBodyContent(auth));
        },
      ),
    );
  }

  // Fungsi pembantu untuk merapikan switch case body
  Widget _buildBodyContent(AuthProvider auth) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(auth);
      case 1:
        return const RiwayatDoPage();
      case 2:
        return const NotificationPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildHomeContent(auth);
    }
  }

  // Di dalam State class Anda (misal _HomePageState)
  late bool isCheckedIn; // Status lokal untuk contoh sederhana

  Widget _buildHomeContent(AuthProvider auth) {
    return RefreshIndicator(
      onRefresh: () => auth.fetchUserDetails(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            HomeHeader(userName: auth.user?.name),

            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 35, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row Check In & Out
                      Row(
                        children: [
                          // TOMBOL CHECK IN
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // Tunggu hasil dari halaman check in
                                 setState(() {
                                  isCheckedIn =
                                      true; // Ubah status jadi non-aktif
                                });

                                Navigator.push(context, MaterialPageRoute(builder: (context) => const DoSudahConfirmPage()));
                              },
                              child: ActionMenuCard(
                                label: "Check In",
                                icon: Icons.login_rounded,
                                bgColor: !isCheckedIn
                                    ? const Color(0xFFE8F9EE)
                                    : const Color(0xFFF5F5F5),
                                iconColor: !isCheckedIn
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFBDBDBD),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // TOMBOL CHECK OUT
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isCheckedIn =
                                      false; // Ubah status jadi non-aktif
                                });

                                Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailDoCheckout()));
                              },
                              child: ActionMenuCard(
                                label: "Check Out",
                                icon: Icons.logout_rounded,
                                // BERUBAH JADI MERAH JIKA AKTIF (isCheckedIn == false)
                                bgColor: isCheckedIn
                                    ? const Color(0xFFFFEBEE)
                                    : const Color(0xFFF5F5F5),
                                iconColor: isCheckedIn
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFFBDBDBD),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Label Reimburse & Sisanya...
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Reimburse",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Aksi ketika tombol "Lihat Semua" ditekan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReimbursePage(), // Pastikan nama class halaman register Anda sesuai
                                ),
                              );
                            },
                            child: const Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const ReimburseCard(),
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
}
