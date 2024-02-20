import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practica_04/screens/widgets/Menu.dart';
import 'package:practica_04/utils/api_endpoints.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyNewsView extends StatefulWidget {
  const MyNewsView({Key? key}) : super(key: key);

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<MyNewsView> {
  late Map<String, dynamic> _news = {};
  late List<dynamic> _comments = [];
  bool _isLoading = true;
  bool _hasNextPage = false;
  bool _hasPrevPage = false;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _getNewsAndComments();
  }

  Future<void> _getNewsAndComments() async {
    try {
      _fetchComments();
    } catch (error) {
      Get.back();
      showDialog(
        context: Get.context!,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Error'),
            contentPadding: const EdgeInsets.all(20),
            children: [Text(error.toString())],
          );
        },
      );
    }
  }

  Future<void> _fetchComments({int? page}) async {
    try {
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');
      final int requestedPage = page ?? _currentPage;
      final responseComments = await http.get(Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.crudsEndpoints.comments}/me?page=$requestedPage&limit=10&status=true'), headers: {
        'Content-type': "application/json", 'Authorization': 'Bearer $token'
      });
      if (responseComments.statusCode == 200) {
        final Map<String, dynamic> commentsData = json.decode(responseComments.body);
        setState(() {
          if (page == null) {
            _comments.clear();
          }
          _comments.addAll(commentsData['results']);
          _totalPages = commentsData['totalPages'];
          _hasNextPage = commentsData['nextPage'];
          _hasPrevPage = commentsData['prevPage'];
          _isLoading = false;
        });
      } else {
        throw Exception('No se pudieron cargar los comentarios');
      }
    } catch (error) {
      showDialog(
        context: Get.context!,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Error'),
            contentPadding: const EdgeInsets.all(20),
            children: [Text(error.toString())],
          );
        },
      );
    }
  }

  Future<void> _loadMoreComments() async {
    if (_hasNextPage) {
      setState(() {
        _isLoading = true;
        _currentPage++;
      });
      await _fetchComments();
    }
  }

  Future<void> _loadPrevComments() async {
    if (_hasPrevPage) {
      setState(() {
        _isLoading = true;
        _currentPage--;
      });
      await _fetchComments();
    }
  }

  String _getPageIndicator() {
    return 'Página $_currentPage/$_totalPages';
  }

  Widget _buildLoadMoreButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_hasPrevPage)
          ElevatedButton(
            onPressed: _loadPrevComments,
            child: Text('Anterior'),
          ),
        SizedBox(width: 8.0),
        Text(_getPageIndicator()),
        SizedBox(width: 8.0),
        if (_hasNextPage)
          ElevatedButton(
            onPressed: _loadMoreComments,
            child: Text('Siguiente'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis comentarios'),
      ),
      drawer: MenuDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comentarios:',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _comments.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _comments.length) {
                        return ListTile(
                          title: Text(_comments[index]['body'] ?? ''),
                          subtitle: Text('Escrito por: ${_comments[index]['user'] != null ? _comments[index]['user']['names'] + ' ' + _comments[index]['user']['lastnames'] : 'Desconocido'}'),
                        );
                      } else {
                        return _buildLoadMoreButton();
                      }
                    },
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
