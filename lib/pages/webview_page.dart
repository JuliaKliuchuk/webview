import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum MenuOptions {
  clearCache,
  clearCookies,
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController webController;
  double progress = 0.0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webController.canGoBack()) {
          webController.goBack();
        } else {
          log('Нет записей в истории');
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('WebView'),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                if (await webController.canGoBack()) {
                  webController.goBack();
                } else {
                  _onViewSnackBar('Нет записей в истории');
                  log('Нет записей в истории');
                }
                return;
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () async {
                if (await webController.canGoForward()) {
                  webController.goForward();
                } else {
                  _onViewSnackBar('Нет записей в истории');
                  log('Нет записей в истории');
                }
                return;
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                webController.reload();
              },
            ),
            PopupMenuButton<MenuOptions>(
              onSelected: (value) {
                switch (value) {
                  case MenuOptions.clearCache:
                    _onClearCache(webController, context);
                    break;
                  case MenuOptions.clearCookies:
                    _onClearCookies(context);
                    break;
                }
              },
              itemBuilder: ((context) => <PopupMenuItem<MenuOptions>>[
                    const PopupMenuItem(
                      value: MenuOptions.clearCache,
                      child: Text('Очистить кэш'),
                    ),
                    const PopupMenuItem(
                      value: MenuOptions.clearCookies,
                      child: Text('Очистить куки'),
                    ),
                  ]),
            )
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              color: Colors.blueAccent,
              backgroundColor: Colors.grey,
            ),
            Expanded(
              child: WebView(
                onProgress: (progress) {
                  this.progress = progress / 100;
                  setState(() {});
                },
                initialUrl: 'https://flutter.dev/',
                // initialUrl: 'http://info.cern.ch',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) => webController = controller,
                onPageStarted: (url) {
                  log('Новый сайт: $url');
                },
                onPageFinished: (url) {
                  log('Страница полность загружена');
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.next_plan, size: 32),
          onPressed: () async {
            final currentUrl = await webController.currentUrl();
            log('Предыдущий сайт: $currentUrl');
            webController.loadUrl('https://dart.dev/');
          },
        ),
      ),
    );
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await webController.clearCache();
    _onViewSnackBar('Кэш очищен');
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await CookieManager().clearCookies();
    String message = 'Cookies очищены';

    if (!hadCookies) {
      message = 'Все cookies были очищены';
    }
    _onViewSnackBar(message);
  }

  void _onViewSnackBar(String message) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black54,
      ),
    );
  }
}
