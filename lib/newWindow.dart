import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class NewWindow extends StatefulWidget {
  const NewWindow({Key? key, this.windowId}) : super(key: key);
  final windowId;

  @override
  State<NewWindow> createState() => _NewWindowState();
}

class _NewWindowState extends State<NewWindow> {
  late InAppWebViewController controllerGlobal;
  late PullToRefreshController pullToRefreshController;
  @override
  void initState() {
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
    super.initState();
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controllerGlobal.canGoBack()) {
      print("onwill goback");
      controllerGlobal.goBack();
      return false;
    } else {
      Navigator.of(context).pop();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            alignment: Alignment.bottomRight,
            children: [
              InAppWebView(
                windowId: widget.windowId,
                onLoadStart: (controller, url) {},
                onLoadStop: (controller, url) {
                  pullToRefreshController.endRefreshing();
                },
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  controllerGlobal = controller;
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                    label: Text(""),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      _exitApp(context);
                    },
                    icon: Icon(Icons.arrow_back),
                    label: Text(""),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
