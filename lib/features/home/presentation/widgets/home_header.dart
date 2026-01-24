import 'package:bbs_driver/data/services/delivery_order/do_repository.dart';
import 'package:bbs_driver/features/auth/presentation/pages/kode_otp.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/pages/do_belum_confirm_page.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/do_checkin/presentation/pages/do_sudah_confirm_page.dart';
import 'package:bbs_driver/features/do_checkout/presentation/pages/detail_do_checkout.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeHeader extends StatelessWidget {
  final String? userName;

  const HomeHeader({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFFFB703)),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Column(
              children: [
                // Baris 1: Profil & Live Tracking
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=32",
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? "Dwi Kurnia",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Surabaya",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    _buildLiveTrackingSwitch(),
                  ],
                ),
                const SizedBox(height: 20),

                // Baris 2: Kartu Status
                Row(
                  children: [
                    _buildSmallInfoCard(
                      "0",
                      "Diproses",
                      Icons.calendar_today_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildSmallInfoCard(
                      "20",
                      "Selesai",
                      Icons.check_box_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Baris 3: Notification Banner DINAMIS
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => isCheckedIn ? const DeliveryOrderPage() : const CheckoutDeliveryOrder(),
                    //   ),
                    // );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoBelumConfirmPage(),
                      ),
                    );

                    // final repo = DoRepository();
                    // final authProvider = Provider.of<AuthProvider>(
                    //   context,
                    //   listen: false,
                    // );
                    // final token = authProvider.token;
                    // final userID = authProvider.user?.id;
                    // if (token != null && userID != null) {
                    //   final result = repo.getListDOSudahConfirm(
                    //     token: token,
                    //     userId: userID,
                    //   );

                    //   print('🚀 DO Sudah Confirm: $result');
                    // }
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<DoProvider>(
                                builder: (context, doProvider, _) {
                                  if (doProvider.isLoading) {
                                    return const Text(
                                      "Memuat data DO...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  }

                                  final total = doProvider.totalDoMasuk;

                                  if (total == 0) {
                                    return const Text(
                                      "Tidak ada DO yang belum dikonfirmasi",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    );
                                  }

                                  return Text(
                                    "Ada $total DO yang belum dikonfirmasi",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                              Text(
                                "Ketuk untuk konfirmasi",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... Widget pendukung lainnya (_buildLiveTrackingSwitch & _buildSmallInfoCard) tetap sama ...
  // (Pastikan menyertakan kode widget pendukung tersebut di class ini)
}

Widget _buildLiveTrackingSwitch() {
  return Column(
    children: [
      const Text(
        "Live Tracking",
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: 55,
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              "Off",
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildSmallInfoCard(String count, String label, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
