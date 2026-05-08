import 'package:bbs_driver/data/models/complaint/complaint_model.dart';
import 'package:bbs_driver/data/services/complaint/complaint_repository.dart';
import 'package:flutter/material.dart';

class ComplaintListProvider extends ChangeNotifier {
  final ComplainRepository _repository = ComplainRepository();

  List<ComplaintModel> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  int _page = 1;
  int _paginate = 10;
  String? _search;

  String? _token;
  String? _salesId;
  String? _unitBusinessId;

  List<ComplaintModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get page => _page;
  int get paginate => _paginate;

  Future<void> fetchComplaints({
    required String token,
    required String salesId,
    required String unitBusinessId,
    String? search,
    int paginate = 10,
  }) async {
    _token = token;
    _salesId = salesId;
    _unitBusinessId = unitBusinessId;
    _search = search;
    _page = 1;
    _paginate = paginate;
    _hasMore = true;

    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    notifyListeners();

    try {
      final results = await _repository.fetchListComplaint(
        token: token,
        salesId: salesId,
        unitBusinessId: unitBusinessId,
        search: search,
        page: _page,
        paginate: _paginate,
      );
      _items = results;
      _hasMore = results.length >= _paginate;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    if (_token == null || _salesId == null || _unitBusinessId == null) return;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final results = await _repository.fetchListComplaint(
        token: _token!,
        salesId: _salesId!,
        unitBusinessId: _unitBusinessId!,
        search: _search,
        page: nextPage,
        paginate: _paginate,
      );

      _page = nextPage;
      _items = [..._items, ...results];
      _hasMore = results.length >= _paginate;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setPaginate(int paginate) {
    if (paginate <= 0) return;
    _paginate = paginate;
    notifyListeners();
  }
}
