import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../common/file_helper.dart';

class TestDownloadFile extends StatefulWidget {
  TestDownloadFile({Key? key}) : super(key: key);

  @override
  State<TestDownloadFile> createState() => _TestDownloadFileState();
}

class _TestDownloadFileState extends State<TestDownloadFile> {
  static const _imageUrl =
      'https://file-examples.com/storage/fe6011afaa624cd00a160ee/2017/10/file_example_PNG_3MB.png';

  static const _pdfUrl =
      'https://juventudedesporto.cplp.org/files/sample-pdf_9359.pdf';

  int? _total;
  int _received = 0;
  File? _imageFile;
  File? _pdfFile;

  void _onDownloadProgress(int received, int? total) {
    print('-- on download progress');
    setState(() {
      _total = total;
      _received = received;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test download file'),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Wrap(
              children: [
                TextButton(
                    onPressed: () {
                      FileHelper.downloadFile(
                        _imageUrl,
                        onByteReceived: _onDownloadProgress,
                      ).then((value) {
                        print('-- filePath: $value');
                        setState(() {
                          _imageFile = value;
                        });
                      });
                    },
                    child: Text('Download image')),
                TextButton(
                    onPressed: () {
                      FileHelper.downloadFile(
                        _pdfUrl,
                        onByteReceived: _onDownloadProgress,
                      ).then((value) {
                        print('-- filePath: $value');
                        setState(() {
                          _pdfFile = value;
                        });
                      });
                    },
                    child: Text('Download pdf')),
              ],
            ),
            if (_total != null && _total! > 0)
              Container(
                child: Text('$_received / ${_total!} bytes '),
              ),
            if (_imageFile != null) ...[
              Text('-- download success'),
              Image.file(_imageFile!),
              TextButton(
                  onPressed: () async {
                    final result = await OpenFile.open(_imageFile!.path);
                    print('-- open result: ${result.message}, ${result.type}');
                  },
                  child: Text('open image')),
            ],
            if (_pdfFile != null) ...[
              TextButton(
                  onPressed: () async {
                    final result = await OpenFile.open(_pdfFile!.path);
                    print('-- open result: ${result.message}, ${result.type}');
                  },
                  child: Text('open pdf')),
            ],
          ],
        ),
      )),
    );
  }
}
