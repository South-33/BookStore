import 'package:flutter/material.dart';
import 'fakeproduct_model.dart';
import 'product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Giveaway>> _futureData;

  final _productService = ProductService();

  final _pageController = PageController();
  int _currentPage = 0;


  @override
  initState() {
    super.initState();
    _futureData = _productService.getApi();

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Screen")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Center(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureData = _productService.getApi();
          });
        },
        child: FutureBuilder<List<Giveaway>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildError(snapshot.error);
            }

            if (snapshot.connectionState == ConnectionState.done) {
              return _buildData(snapshot.data);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error: $error"),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureData = _productService.getApi();
            });
          },
          child: Text("RETRY"),
        ),
      ],
    );
  }

  Widget _buildData(List<Giveaway>? data) {
    if (data == null) {
      return SizedBox();
    }

    return _buildPageView(data);
  }

  Widget _buildPageView(List<Giveaway> items) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.network(
                            item.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Page ${_currentPage + 1} of ${items.length}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}