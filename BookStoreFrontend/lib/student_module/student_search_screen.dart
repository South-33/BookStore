import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'student_form.dart';
import 'student_model.dart';
import 'student_service.dart';

class StudentSearchScreen extends StatefulWidget {
  const StudentSearchScreen({super.key});

  @override
  State<StudentSearchScreen> createState() => _StudentSearchScreenState();
}

class _StudentSearchScreenState extends State<StudentSearchScreen> {
  
  Future<StudentModel>? _futureData;

  final _studentService = StudentService();
  bool _showUpIcon = false;

  @override
  initState() {
    super.initState();
    // _futureData = _studentService.searchData("here_is_empty_and_no_search_yet");

    _scroller.addListener(() {
      if (_scroller.position.pixels < 300) {
        setState(() {
          _showUpIcon = false;
        });
      } else {
        setState(() {
          _showUpIcon = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildSearchTextField()),
      body: _buildBody(),
      floatingActionButton: _showUpIcon ? _buildFloating() : null,
    );
  }

  final _searchCtrl = TextEditingController();

  Widget _buildSearchTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchCtrl,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.grey),
          suffixIcon: IconButton(
            onPressed: () {
              _searchCtrl.clear();
            },
            icon: Icon(Icons.cancel),
          ),
        ),
        onSubmitted: (text) {
          _searchCtrl.text = text.trim();
          if (_searchCtrl.text.isNotEmpty) {
            setState(() {
              _futureData = _studentService.searchData(context, _searchCtrl.text);
            });
          }
        },
      ),
    );
  }

  Widget _buildFloating() {
    return FloatingActionButton(
      shape: CircleBorder(),
      onPressed: () {
        _scroller.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: Icon(Icons.arrow_upward),
    );
  }

  Widget _buildBody() {
    return Center(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureData = _studentService.searchData(context, _searchCtrl.text);
          });
        },
        child: FutureBuilder<StudentModel>(
          future: _futureData,
          builder: (context, snapshot) {
            if (_futureData == null) {
              return _buildNoItem();
            }

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

  Widget _buildNoItem() {
    return Center(
      child: Icon(Icons.person, size: 100, color: Colors.grey.shade300),
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
              _futureData = _studentService.searchData(context, _searchCtrl.text);
            });
          },
          child: Text("RETRY"),
        ),
      ],
    );
  }

  Widget _buildData(StudentModel? model) {
    if (model == null) {
      return SizedBox();
    }

    return _buildGridView(model.data);
  }

  final _scroller = ScrollController();

  Widget _buildGridView(List<Student> items) {
    if (items.isEmpty) {
      return _buildNoItem();
    }

    return GridView.builder(
      controller: _scroller,
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () async {
            bool saved = await Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => StudentForm(item: item)),
            );

            if (saved) {
              setState(() {
                _futureData = _studentService.searchData(context, _searchCtrl.text);
              });
            }
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
