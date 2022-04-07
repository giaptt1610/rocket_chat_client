import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'blocs/app/app_bloc.dart';
import 'blocs/home/home_bloc.dart';
import 'widgets/channel_widget.dart';

import 'common/apis.dart';
import 'models/auth_result.dart';
import 'tests/test_down_file.dart';
import 'tests/test_pick_files.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Demo';
    return BlocProvider(
      create: (context) => AppBloc(),
      child: MaterialApp(
        title: title,
        home: MyHomePage(
          title: title,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  late StreamSubscription _wsEventSub;

  AuthResult? authResult;
  final _userName = 'giaptt_admin';
  final _pass = '576173987';

  late HomeBloc _homeBloc;

  void _onWsMessageReceived(Map<String, dynamic> map) {
    if (map['msg'] == 'changed' &&
        map['collection'] == 'stream-room-messages') {
      final fields = map['fields'] as Map;
      final eventName = fields['eventName'];

      final args = fields['args'] as List;
      print('-- args: $args');
      final rid = args[0]['rid'];

      _homeBloc.add(ChannelChangedEvent(args));
    }
  }

  @override
  void initState() {
    super.initState();
    final _appBloc = context.read<AppBloc>();
    _homeBloc = HomeBloc(_appBloc);
    _wsEventSub = _appBloc.wsEventStream.listen((event) {
      _onWsMessageReceived(event as Map<String, dynamic>);
    });

    // _appBloc.addMessageChangeListener(_onWsMessageReceived);

    Apis.login(_userName, _pass).then((value) {
      if (value != null) {
        setState(() {
          authResult = value;
        });
        context.read<AppBloc>().add(AuthenticatedEvent(value));
        context.read<AppBloc>().add(WsLoginEvent(authResult!.authToken));
        _homeBloc.add(LoadListRoomEvent(value.authToken, value.userId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('username/pass maybe wrong!')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _homeBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: BlocListener<AppBloc, AppState>(
                listener: (context, state) {},
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final _listRooms = state.listRooms;
                    final _listChannels =
                        _listRooms.where((room) => room.t != 'd').toList();

                    final _listDm =
                        _listRooms.where((room) => room.t == 'd').toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Channels'),
                        const SizedBox(height: 5.0),
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 300,
                            // minHeight: 150,
                          ),
                          child: ListView.builder(
                            itemCount: _listChannels.length,
                            itemBuilder: (context, index) {
                              final channel = _listChannels[index];
                              return ChannelWidget(
                                channel: channel,
                                unreads: state.unreadMsg[channel.id] ?? 0,
                                onTap: () {
                                  _homeBloc
                                      .add(ClearUnreadMsgEvent(channel.id));
                                },
                              );
                            },
                          ),
                        ),
                        const Text('Direct message'),
                        const SizedBox(height: 5.0),
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 300,
                            // minHeight: 150,
                          ),
                          child: ListView.builder(
                              itemCount: _listDm.length,
                              itemBuilder: (context, index) {
                                final dm = _listDm[index];
                                return Card(
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(child: Text('${dm.dmName}')),
                                      ],
                                    ),
                                    onTap: () {},
                                  ),
                                );
                              }),
                        ),
                        Wrap(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              TestPickFile()));
                                },
                                child: Text('Test Pick File')),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              TestDownloadFile()));
                                },
                                child: Text('Test Download File')),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeBloc.appBloc.add(WsUnsubscribeRoomsEvent(_homeBloc.state.listRooms));
    _controller.dispose();
    super.dispose();
  }
}
