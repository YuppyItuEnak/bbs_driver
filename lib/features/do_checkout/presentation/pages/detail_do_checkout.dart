// Import widget baru Anda
// import 'package:bbs_driver/features/do_checkin/presentation/widgets/do_checkout_item.dart';
import 'package:bbs_driver/features/do_checkin/presentation/widgets/checkin_item.dart';
import 'package:bbs_driver/features/do_checkout/presentation/pages/do_checkout_page.dart';
import 'package:bbs_driver/features/do_checkout/presentation/widgets/do_checkout_item.dart';
import 'package:flutter/material.dart';

class DetailDoCheckout extends StatefulWidget {
  const DetailDoCheckout({super.key});

  @override
  State<DetailDoCheckout> createState() => _DetailDoCheckoutState();
}

class _DetailDoCheckoutState extends State<DetailDoCheckout> {
  final Color darkOrange = const Color(0xFFD35400);
  final Color yellowButton = const Color(0xFFFFC107);
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isLoading ? darkOrange : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isLoading ? Colors.white : const Color(0xFFFAAD14),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail DO",
          style: TextStyle(
            color: isLoading ? Colors.white : const Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  if (!isLoading)
                    const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                  isLoading ? _buildLoadingContent() : _buildListContent(),
                ],
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  // Header Info Area
  Widget _buildHeaderInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        children: [
          _buildRowInfo("No. DO", "DO-05N-2304-0001"),
          const SizedBox(height: 8),
          _buildRowInfo("Tanggal", "04/04/2023"),
          const SizedBox(height: 8),
          _buildRowInfo("Customer", "PT. HUTAMA KARYA"),
          const SizedBox(height: 8),
          _buildRowInfo("Alamat", "Jl. Candi Lontar II No. 48 B"),
        ],
      ),
    );
  }

  // Bagian Tengah saat Loading
  Widget _buildLoadingContent() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "Sedang loading barang..",
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        const Text(
          "PT. HUTAMA KARYA",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedTruck(),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: DoCheckoutItem(isCondensed: true), // Memanggil widget baru
        ),
      ],
    );
  }

  // Bagian Tengah saat Data Ready
  Widget _buildListContent() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: DoCheckoutItem(isCondensed: false), // Memanggil widget baru
    );
  }

  // Action Button di bawah
  Widget _buildBottomAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      color: darkOrange,
      child: _buildCheckOutButton(),
    );
  }

  // Helper UI kecil lainnya
  Widget _buildRowInfo(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: isLoading ? Colors.white70 : Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          ":",
          style: TextStyle(color: isLoading ? Colors.white : Colors.black),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isLoading ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTruck() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildGlowCircle(220, 0.05),
          _buildGlowCircle(180, 0.1),
          _buildGlowCircle(140, 0.2),
          const CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: Icon(Icons.local_shipping, size: 50, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildCheckOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        // Navigasi ke halaman DoCheckoutPage saat ditekan
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoCheckoutPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: yellowButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        child: const Text(
          "Check Out",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
