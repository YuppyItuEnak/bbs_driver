import 'package:bbs_driver/data/models/reimburse/reimburse_model.dart';
import 'package:bbs_driver/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_driver/features/reimburse/presentation/pages/add_reimburse_page.dart';
import 'package:bbs_driver/features/reimburse/presentation/pages/detail_reimburse_page.dart';
import 'package:bbs_driver/features/reimburse/presentation/providers/reimburse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReimburseListPage extends StatelessWidget {
  const ReimburseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReimburseProvider(),
      child: const _ReimburseListContent(),
    );
  }
}

class _ReimburseListContent extends StatefulWidget {
  const _ReimburseListContent({super.key});

  @override
  State<_ReimburseListContent> createState() => _ReimburseListContentState();
}

class _ReimburseListContentState extends State<_ReimburseListContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchTerm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = context.read<ReimburseProvider>();
      if (!provider.isLoading && !provider.isFetchingMore && provider.hasMore) {
        _fetchData();
      }
    }
  }

  void _fetchData({bool refresh = false}) {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ReimburseProvider>();

    if (auth.token != null && auth.user!.id != null) {
      provider.setSearch(_currentSearchTerm);
      provider.fetch(
        token: auth.token!,
        salesId: auth.user!.id,
        refresh: refresh,
      );
      provider.checkReimburseToday(token: auth.token!, salesId: auth.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(
          color: Color(0xFFF6C652),
        ), // Warna kuning sesuai gambar
        title: const Text(
          'List Reimburse',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<ReimburseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.items.isEmpty) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                provider.items.length + (provider.isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.items.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final item = provider.items[index];
              return _buildReimburseTile(context, item);
            },
          );
        },
      ),
      // Tombol bawah yang lebar sesuai gambar
      bottomNavigationBar: Consumer<ReimburseProvider>(
        builder: (context, provider, child) {
          final reimburseCheck = provider.reimburseCheck;
          bool buttonDisabled = false;
          VoidCallback? onPressedAction = () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddReimbursePage(isEdit: false),
            ),
          );

          if (reimburseCheck != null) {
            if (reimburseCheck.kmAwal != null && reimburseCheck.kmAkhir != 0) {
              buttonDisabled = true;
              onPressedAction = null;
            } else if (reimburseCheck.kmAwal != null &&
                reimburseCheck.kmAkhir == 0) {
              onPressedAction = () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddReimbursePage(
                    reimburseId: reimburseCheck.id,
                    isEdit: true,
                  ),
                ),
              );
            }
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: ElevatedButton(
              onPressed: onPressedAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonDisabled
                    ? Colors.grey
                    : const Color(0xFFF6C652),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ajukan Reimburse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReimburseTile(BuildContext context, ReimburseModel item) {
    final dateStr = item.date != null
        ? DateFormat('dd Des yyyy').format(item.date!)
        : '-';

    // Warna status sesuai gambar
    Color statusColor;
    switch (item.status?.toUpperCase()) {
      case 'POSTED':
        statusColor = const Color(0xFF7B8DFF);
        break;
      case 'LUNAS':
        statusColor = const Color(0xFF81C784);
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (item.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailReimbursePage(reimburseId: item.id!),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sisi Kiri
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.totalKm != null ? '${item.totalKm} KM' : '-',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            // Sisi Kanan
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.status ?? '-',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
