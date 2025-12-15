import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'student_logic.dart';
import 'logged_user.dart';
import 'student_search_screen.dart';
import 'student_form.dart';
import 'student_model.dart';
import 'student_service.dart';

class StudentScreen extends StatefulWidget {
  // const StudentScreen({super.key});

  // LoggedUser user;

  // StudentScreen(this.user);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late Future<StudentModel> _futureData;

  final _studentService = StudentService();
  bool _showUpIcon = false;

  late LoggedUser _user;

  @override
  initState() {
    super.initState();

    _user = context.read<StudentLogic>().user;
    _futureData = _studentService.getData(context, _user);

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
      appBar: AppBar(
        title: Text("Student Screen"),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.of(
                context,
              ).push(CupertinoPageRoute(builder: (context) => StudentSearchScreen()));
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () async {
             _studentService.logout(context);
            },
            icon: Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () async {
              bool saved = await Navigator.of(
                context,
              ).push(CupertinoPageRoute(builder: (context) => StudentForm()));

              if (saved) {
                setState(() {
                  _futureData = _studentService.getData(context, _user);
                });
              }
            },
            icon: Icon(Icons.person_add),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _showUpIcon ? _buildFloating() : null,
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
            _futureData = _studentService.getData(context, _user);
          });
        },
        child: FutureBuilder<StudentModel>(
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
              _futureData = _studentService.getData(context, _user);
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
                _futureData = _studentService.getData(context, _user);
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
