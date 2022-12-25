import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gli/newWindow.dart';
//import 'package:onesignal_flutter/onesignal_flutter.dart';
//import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GLI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GLI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //var externalUserId = '192.168.1.15';
  String userId = " ";
  String url = "https://gli.com.ng/";
  late PullToRefreshController pullToRefreshController;
  late PullToRefreshController pullToRefreshController2;
  @override
  void initState() {
    super.initState();

    requestPermissions();
    //initOneSignal();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          controllerGlobal.reload();
        } else if (Platform.isIOS) {
          controllerGlobal.loadUrl(
              urlRequest: URLRequest(url: await controllerGlobal.getUrl()));
        }
      },
    );
    pullToRefreshController2 = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          controllerGlobal2.reload();
        } else if (Platform.isIOS) {
          controllerGlobal2.loadUrl(
              urlRequest: URLRequest(url: await controllerGlobal.getUrl()));
        }
      },
    );

    // Enable virtual display.
    //if (Platform.isAndroid) WebView.platform = AndroidWebView();
    print('Attaching id');

    //requestPermissions();
    connectionCheck();
  }

  bool isConnected = true;
  var listener;
  bool initialized = false;

  connectionCheck() {
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          /* setState(() {
            isConnected = true;
          }); */
          if (initialized) {
            controllerGlobal.reload();
          }
          Future.delayed(const Duration(seconds: 5), () {
            setState(() {
              isConnected = true;
              index = 1;
            });
          });
          break;
        case InternetConnectionStatus.disconnected:
          setState(() {
            isConnected = false;
            index = 0;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  requestPermissions() async {
    await [
      //Permission.location,
      Permission.storage,
      Permission.camera,
    ].request();
  }

  int index = 0;

  late InAppWebViewController controllerGlobal;
  late InAppWebViewController controllerGlobal2;

  Future<bool> _exitApp(BuildContext context) async {
    if (await controllerGlobal.canGoBack()) {
      print("onwill goback");
      controllerGlobal.goBack();
      return false;
    } else {
      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SizedBox(
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Do you want to exit?"),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              print('yes selected');
                              exit(0);
                            },
                            child: const Text("Yes"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade800),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            print('no selected');
                            Navigator.of(context).pop();
                          },
                          child: const Text("No",
                              style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
            );
          });
    }
  }

  showpopup(id, ctx) {
    return showDialog(
        barrierDismissible: false,
        context: ctx,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(0),
            content: Builder(builder: (context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InAppWebView(
                      windowId: id,
                      onLoadStart: (controller, url) {
                        log("popup load start");
                        isLoading2 = true;
                        setState(() {});
                      },
                      onLoadStop: (controller, url) {
                        isLoading2 = false;
                        log("popup load stop");
                        pullToRefreshController2.endRefreshing();
                        setState(() {});
                      },
                      pullToRefreshController: pullToRefreshController2,
                      onWebViewCreated: (controller) {
                        controllerGlobal2 = controller;
                        initialized = true;
                      },
                      onCreateWindow: (controller, action) async {
                        log("url create: ${action.request.url}");
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: InAppWebView(
                                  // Setting the windowId property is important here!
                                  windowId: action.windowId,
                                  initialOptions: InAppWebViewGroupOptions(
                                    crossPlatform: InAppWebViewOptions(),
                                  ),
                                  onWebViewCreated:
                                      (InAppWebViewController controller) {},
                                  onLoadStart: (controller, url) {
                                    print("onLoadStart popup $url");
                                  },
                                  onLoadStop: (controller, url) {
                                    print("onLoadStop popup $url");
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        return true;
                      },
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          horizontalScrollBarEnabled: false,
                          verticalScrollBarEnabled: false,
                          supportZoom: false,
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                          supportMultipleWindows: true,
                        ),
                      ),
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                    ),
                    isLoading2
                        ? const CircularProgressIndicator()
                        : Container(),
                  ],
                ),
              );
            }),
            actions: [
              TextButton(
                onPressed: () {
                  isLoading2 = false;
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
            ],
          );
        });
  }

  bool isLoading = true;
  bool isLoading2 = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            isConnected
                ? Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: double.infinity,
                            child: Image.asset('assets/splash.png')),
                      ],
                    ),
                  )
                : Image.asset(
                    'assets/network.gif',
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill,
                  ),
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).padding.top,
                  color: const Color.fromARGB(255, 45, 91, 227),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          InAppWebView(
                            onLoadStart: (controller, url) async {
                              isLoading = true;
                              log("$url");
                              if (url.toString().contains("facebook") ||
                                  url.toString().contains("youtube") ||
                                  url.toString().contains("pinterest")) {
                                await launchUrl(url!,
                                    mode: LaunchMode.externalApplication);
                                controllerGlobal.goBack();
                              }
                              log("main Load start $isLoading");
                              setState(() {});
                            },
                            onLoadStop: (controller, url) {
                              isLoading = false;
                              pullToRefreshController.endRefreshing();
                              log("main Load start $isLoading");
                              setState(() {});
                            },
                            onCreateWindow: (controller, action) async {
                              log("url create: ${action.request.url}");
                              /* if (interstitialLoaded) {
                            _interstitialAd.show();
                          } */
                              //showpopup(action.windowId, context);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => NewWindow(
                                    windowId: action.windowId,
                                  ),
                                ),
                              );
                              return true;
                            },
                            pullToRefreshController: pullToRefreshController,
                            initialUrlRequest: URLRequest(url: Uri.parse(url)),
                            onWebViewCreated: (controller) {
                              controllerGlobal = controller;
                            },
                            initialOptions: InAppWebViewGroupOptions(
                              crossPlatform: InAppWebViewOptions(
                                horizontalScrollBarEnabled: false,
                                verticalScrollBarEnabled: false,
                                supportZoom: false,
                              ),
                              android: AndroidInAppWebViewOptions(
                                useHybridComposition: true,
                                supportMultipleWindows: true,
                              ),
                            ),
                            androidOnPermissionRequest:
                                (controller, origin, resources) async {
                              return PermissionRequestResponse(
                                  resources: resources,
                                  action:
                                      PermissionRequestResponseAction.GRANT);
                            },
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  launchUrl(
                                    Uri.parse(
                                        "https://play.google.com/store/apps/details?id=com.gli.ng"),
                                    mode: LaunchMode.externalApplication,
                                  );
                                },
                                icon: const Icon(Icons.share),
                                label: const Text(""),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  log("back pressed");
                                  await _exitApp(context);
                                  //controllerGlobal.goBack();
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text(""),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                              ),
                            ],
                          ),
                        ],
                      ),
                      isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.red,
                              backgroundColor: Colors.black,
                              strokeWidth: 10,
                            )
                          : Container(),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
