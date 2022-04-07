import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/file_helper.dart';

class TestPickFile extends StatefulWidget {
  TestPickFile({Key? key}) : super(key: key);

  @override
  State<TestPickFile> createState() => _TestPickFileState();
}

class _TestPickFileState extends State<TestPickFile> {
  List<PlatformFile> _pickedFiles = [];
  List<File> _pickedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Pick File'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
                onPressed: () async {
                  // check permission status
                  final statuses = await [
                    Permission.camera,
                    Permission.photos,
                  ].request();
                  print('statuses: $statuses');
                  FileHelper.chooseFiles(extensions: [
                    'jpeg',
                    'doc',
                    'pdf',
                    'xls',
                    'jpg',
                    'png'
                  ]).then((value) {
                    setState(() {
                      _pickedFiles.addAll([...value]);
                    });
                  });
                },
                child: Text('Choose file')),
            Container(
              height: 100.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _pickedFiles.length,
                itemBuilder: (context, index) => Container(
                  width: 100.0,
                ),
              ),
            ),
            TextButton(
                onPressed: () async {
                  // check permission status
                  final statuses = await [
                    Permission.camera,
                    Permission.photos,
                  ].request();

                  print('statuses: $statuses');
                  FileHelper.chooseImages().then((value) {
                    setState(() {
                      _pickedImages.addAll([...value]);
                    });
                  });
                },
                child: Text('Choose image')),
            Container(
              height: 100.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _pickedImages.length,
                itemBuilder: (context, index) => Container(
                  width: 100.0,
                  child: Image.file(
                    _pickedImages[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
