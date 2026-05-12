import 'package:bbs_driver/features/deilvery_order/presentation/pages/riwayat_do_page.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/do_checkin/presentation/pages/dp_checkin_page.dart';
import 'package:bbs_driver/features/do_checkin/presentation/pages/do_sudah_confirm_page.dart';
import 'package:bbs_driver/features/do_checkout/presentation/pages/dp_checkout_page.dart';
import 'package:bbs_driver/features/complaint/presentation/pages/list_complaint_page.dart';
import 'package:bbs_driver/features/notification/presentation/pages/notification_page.dart';
import 'package:bbs_driver/features/reimburse/presentation/pages/reimburse_page.dart';
import 'package:bbs_driver/features/home/presentation/widgets/action_menu_card.dart';
import 'package:bbs_driver/features/home/presentation/widgets/reimburse_card.dart';
import 'package:bbs_driver/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_header.dart';

// Tambahkan RouteObserverProvider di main.dart
// final routeObserver = RouteObserver<ModalRoute<void>>();
// MaterialApp( navigatorObservers: [routeObserver], ... )

final routeObserver = RouteObserver<ModalRoute<void>>();

class HomePage extends StatefulWidget {
  final bool startAsCheckedIn;
  const HomePage({super.key, this.startAsCheckedIn = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Dipanggil saat pengguna kembali ke halaman ini
    print("Kembali ke Home, me-refresh state...");
    _refreshHomeState();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHomeState();
    });
  }

  Future<void> _refreshHomeState() async {
    final auth = context.read<AuthProvider>();
    await auth.fetchUserDetails();
    final token = auth.token;
    final userId = auth.user?.id;

    if (token != null && userId != null && context.mounted) {
      final doProvider = context.read<DoProvider>();
      await doProvider.checkOpenTimeIn(token: token, userId: userId);
      await doProvider.refreshHasOutstandingDo(token: token, userId: userId);
      await doProvider.refreshDoMasukTotal(token: token);
      await doProvider.fetchDoMasuk(token: token, userId: userId);

      // === LOG DIAGNOSTIK ===
      print("--- Home State Refresh ---");
      final dpRealisasi = doProvider.getDpRealisasi();
      print(
        "1. DP Realisasi Tersimpan? ${dpRealisasi != null ? 'YA (ID: ${dpRealisasi.id})' : 'TIDAK'}",
      );
      print("2. Home Action State: '${doProvider.homeActionState}'");
      print("3. Ada DO Outstanding? ${doProvider.hasOutstandingDo}");
      print("---");
      print("Tombol Check-In Aktif? ${doProvider.homeCheckInEnabled}");
      print("Tombol Check-Out Aktif? ${doProvider.homeCheckOutEnabled}");
      print("--------------------------");
      // ========================
    }
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoSudahConfirmPage()),
          );
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

  Widget _buildHomeContent(AuthProvider auth) {
    return RefreshIndicator(
      onRefresh: _refreshHomeState,
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
                      Consumer<DoProvider>(
                        builder: (context, doProvider, child) {
                          final canCheckIn = doProvider.homeCheckInEnabled;
                          final hasOpen = doProvider.homeCheckOutEnabled;
                          return Row(
                            children: [
                              // TOMBOL CHECK IN
                              Expanded(
                                child: GestureDetector(
                                  onTap: canCheckIn
                                      ? () {
                                          final auth = context
                                              .read<AuthProvider>();
                                          final token = auth.token;
                                          final userId = auth.user?.id;
                                          if (token == null || userId == null)
                                            return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DpCheckinPage(),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: ActionMenuCard(
                                    label: "Check In",
                                    sublabel:
                                        'Sisa DO: ${doProvider.doMasukTotal}',
                                    icon: Icons.login_rounded,
                                    bgColor: canCheckIn
                                        ? const Color(0xFFE8F9EE)
                                        : const Color(0xFFF5F5F5),
                                    iconColor: canCheckIn
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFBDBDBD),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // TOMBOL CHECK OUT
                              Expanded(
                                child: GestureDetector(
                                  onTap: hasOpen
                                      ? () {
                                          final auth = context
                                              .read<AuthProvider>();
                                          final token = auth.token;
                                          final userId = auth.user?.id;
                                          if (token == null || userId == null)
                                            return;

                                          final data =
                                              doProvider.checkInStatus['data']
                                                  as List? ??
                                              const [];
                                          final open = data
                                              .cast<dynamic>()
                                              .firstWhere(
                                                (e) =>
                                                    e is Map &&
                                                    e['time_in'] != null &&
                                                    e['time_out'] == null,
                                                orElse: () => null,
                                              );

                                          final realisasiId = (open is Map)
                                              ? open['id']?.toString()
                                              : null;

                                          // delivery_plan_id bisa tidak ada di payload open.
                                          final cachedDpId = doProvider
                                              .getDpRealisasi()
                                              ?.id;
                                          final deliveryPlanId = (open is Map)
                                              ? (open['delivery_plan_id']
                                                        ?.toString() ??
                                                    cachedDpId)
                                              : cachedDpId;

                                          if (realisasiId == null ||
                                              realisasiId.isEmpty ||
                                              deliveryPlanId == null ||
                                              deliveryPlanId.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Data check-in tidak ditemukan',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DpCheckoutPage(
                                                deliveryPlanId: deliveryPlanId,
                                                realisasiId: realisasiId,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: ActionMenuCard(
                                    label: "Check Out",
                                    icon: Icons.logout_rounded,
                                    bgColor: hasOpen
                                        ? const Color(0xFFFFEBEE)
                                        : const Color(0xFFF5F5F5),
                                    iconColor: hasOpen
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFFBDBDBD),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // Complaint shortcut
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const KomplainListPage(),
                                  ),
                                );
                              },
                              child: const ActionMenuCard(
                                label: "Komplain",
                                icon: Icons.report_gmailerrorred_rounded,
                                bgColor: Color(0xFFF8FAFF),
                                iconColor: Color(0xFF6366F1),
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
                                      const ReimburseListPage(),
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
