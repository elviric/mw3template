import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/infrastructures/service/cubit/web3_cubit.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sophon/configs/themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.session,
    required this.connector,
    required this.uri,
    Key? key,
  }) : super(key: key);

  final dynamic session;
  final WalletConnect connector;
  final String uri;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String accountAddress = '';
  String networkName = '';
  TextEditingController greetingTextController = TextEditingController();

  ButtonStyle buttonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all(
      Colors.white.withAlpha(60),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );

  void updateGreeting() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<Web3Cubit>().updateGreeting(greetingTextController.text);
    greetingTextController.text = '';
  }

  @override
  void initState() {
    super.initState();

    /// Execute after frame is rendered to get the emit state of InitializeProviderSuccess
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<Web3Cubit>().initializeProvider(
            connector: widget.connector,
            session: widget.session,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<Web3Cubit, Web3State>(
      listener: (BuildContext context, Web3State state) {
        if (state is SessionTerminated) {
          Future<void>.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const AuthenticationScreen(),
              ),
            );
          });
        } else if (state is UpdateGreetingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is FetchGreetingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is InitializeProviderSuccess) {
          setState(() {
            accountAddress = state.accountAddress;
            networkName = state.networkName;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          // ignore: use_decorated_box
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: flirtGradient),
            ),
          ),
          toolbarHeight: 0,
          automaticallyImplyLeading: false,
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.1,
                    vertical: width * 0.05,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    gradient: const LinearGradient(colors: flirtGradient),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 13),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(60),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Account Address: ',
                              style: theme.textTheme.subtitle2,
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: width * 0.6,
                                child: Text(
                                  accountAddress,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.subtitle2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(60),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Chain: ',
                              style: theme.textTheme.subtitle2,
                            ),
                            Text(
                              networkName,
                              style: theme.textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07,
                        vertical: height * 0.03,
                      ),
                      margin: EdgeInsets.only(
                        left: width * 0.03,
                        right: width * 0.03,
                        bottom: height * 0.03,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: flirtGradient),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                          top: Radius.circular(10),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 13), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(60),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            width: width,
                            child: BlocBuilder<Web3Cubit, Web3State>(
                              buildWhen:
                                  (Web3State previous, Web3State current) =>
                                      current is FetchGreetingSuccess ||
                                      current is UpdateGreetingLoading,
                              builder: (BuildContext context, Web3State state) {
                                if (state is FetchGreetingSuccess) {
                                  return Text(
                                    '"${state.message}"',
                                    style: theme.textTheme.headline6?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                }
                                return LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  color: Colors.white.withOpacity(0.5),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.07,
                        vertical: height * 0.03,
                      ),
                      margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: flirtGradient),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                          top: Radius.circular(10),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                              0,
                              13,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: greetingTextController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              hintText: 'What\'s in your head?',
                              fillColor: Colors.white.withAlpha(60),
                              filled: true,
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: BlocBuilder<Web3Cubit, Web3State>(
                              buildWhen:
                                  (Web3State previous, Web3State current) =>
                                      current is UpdateGreetingLoading ||
                                      current is UpdateGreetingSuccess ||
                                      current is UpdateGreetingFailed,
                              builder: (BuildContext context, Web3State state) {
                                if (state is UpdateGreetingLoading) {
                                  return ElevatedButton.icon(
                                    onPressed: () {},
                                    style: buttonStyle,
                                    icon: SizedBox(
                                      height: height * 0.03,
                                      width: height * 0.03,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    label: const Text(''),
                                  );
                                }
                                return ElevatedButton.icon(
                                  onPressed: updateGreeting,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Update Greeting'),
                                  style: buttonStyle,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    gradient: const LinearGradient(colors: flirtGradient),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: width,
                        child: ElevatedButton.icon(
                          onPressed: context.read<Web3Cubit>().closeConnection,
                          icon: const Icon(
                            Icons.power_settings_new,
                          ),
                          label: Text('Disconnect',
                              style: theme.textTheme.subtitle1),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white.withAlpha(60),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
