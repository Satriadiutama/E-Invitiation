import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:undangan_app/webservice/apiUndangan.dart';
import 'home.dart';
import 'model/Undangan.dart';
class UndanganList extends StatefulWidget {
  const UndanganList({Key? key}) : super(key: key);

  @override
  _UndanganListState createState() => _UndanganListState();
}

class _UndanganListState extends State<UndanganList> {
  ApiUndangan? apiUndangan;
  @override
  void initState() {
    super.initState();
    apiUndangan = ApiUndangan();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: FutureBuilder<List<Undangan>?>(
          future: apiUndangan!.getUndanganAll(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Undangan>?> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Center(
                child: Text("Error ${snapshot.error.toString()}"),
              );
            } else if (snapshot.hasData) {
              List<Undangan>? _undangan = snapshot.data;
              if (_undangan != null) {
                return _buildListView(_undangan);
              } else {
                return Text("Kosong");
              }
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }

  Widget _buildListView(List<Undangan> undangan) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Invitation'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: undangan.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text(undangan[index].nama),
                        subtitle: Text(undangan[index].email),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              "http://192.168.43.119:8080/apiundangan/assets/${undangan[index].foto}"),
                        ),
                        trailing: Icon(
                          Icons.star,
                          color: undangan[index].statusDatang == '1'
                              ? Colors.deepOrange
                              : Colors.black12,
                        ),
                      ),
                    );
                  }),
            ),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                child: Text("Reset Kehadiran",style: TextStyle(fontSize: 18),),
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan[900],
                ),
                onPressed: () {
                  apiUndangan!.resetKehadiran();
                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
