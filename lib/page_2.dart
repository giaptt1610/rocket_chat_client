import 'package:flutter/material.dart';

class Page2 extends StatefulWidget {
  final Stream stream;
  Page2({required this.stream, Key? key}) : super(key: key);

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<String> events = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 2'),
      ),
      body: SafeArea(
        child: Center(
          child: StreamBuilder(
            stream: widget.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
      
              final temp = snapshot.data as String;
              events.insert(0, temp);
      
              return ListView.builder(
                reverse: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Text('${events[index].toString()}');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
