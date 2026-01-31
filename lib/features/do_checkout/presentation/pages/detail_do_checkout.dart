import 'package:bbs_driver/data/models/delivery_order/delivery_order_model.dart';
import 'package:bbs_driver/features/deilvery_order/presentation/providers/do_provider.dart';
import 'package:bbs_driver/features/do_checkout/presentation/pages/do_checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailDoCheckout extends StatefulWidget {
  final String doId;
  final String token;

  const DetailDoCheckout({super.key, required this.doId, required this.token});

  @override
  State<DetailDoCheckout> createState() => _DetailDoCheckoutState();
}

class _DetailDoCheckoutState extends State<DetailDoCheckout> {
  final Color orange = const Color(0xFFD35400);
  final Color yellow = const Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DoProvider>().fetchDetailDo(
        token: widget.token,
        doId: widget.doId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoProvider>(
      builder: (context, provider, _) {
        final model = provider.detailDO;
        final loading = provider.isLoading;
        final error = provider.error;

        return Scaffold(
          backgroundColor: orange,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            title: const Text(
              'Detail DO',
              style: TextStyle(
                color: Colors.white,
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
                  child: Column(
                    children: [
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      else if (model != null)
                        _buildHeader(model),

                      const SizedBox(height: 16),

                      if (loading)
                        _buildLoadingSection(model?.customer)
                      else if (model != null)
                        Column(
                          children: [
                            _animatedTruck(),
                            const SizedBox(height: 20),
                            _buildItemCard(model),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        );
      },
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(DeliveryOrderModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _infoRow('No. DO', model.code),
          _infoRow('Tanggal', model.date ?? '-'),
          _infoRow('Customer', model.customer ?? '-'),
          _infoRow('Alamat', model.shipTo ?? '-'),
          const Divider(color: Colors.white30),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          const Text(': ', style: TextStyle(color: Colors.white)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= LOADING =================

  Widget _buildLoadingSection(String? customer) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text(
          'Sedang loading barang..',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Text(
          customer ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        _animatedTruck(),
      ],
    );
  }

  Widget _animatedTruck() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _glow(220, 0.05),
        _glow(180, 0.1),
        _glow(140, 0.2),
        const CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white,
          child: Icon(Icons.local_shipping, size: 48, color: Colors.red),
        ),
      ],
    );
  }

  Widget _glow(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  // ================= CARD LIST =================

  Widget _buildItemCard(DeliveryOrderModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    model.salesOrder?.code ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
            const Divider(),
            ...model.details.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.item?.name ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            item.item?.code ?? '-',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.qty} ${item.uomUnit}'),
                        Text(
                          'Tonase : ${item.amount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON =================

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: yellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoCheckoutPage(doId: widget.doId),
              ),
            );
          },
          child: const Text(
            'Check Out',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
