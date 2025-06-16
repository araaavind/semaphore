import 'package:app/core/services/analytics_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/url_launcher.dart';
import 'package:app/features/feed/presentation/widgets/web_view_draggable_bottom.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebView extends StatefulWidget {
  final String url;
  final int itemId;
  final bool isSaved;
  final bool isLiked;
  const WebView({
    super.key,
    required this.url,
    required this.itemId,
    this.isSaved = false,
    this.isLiked = false,
  });

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  double progress = 0;

  // list of Ad URL filters to be used to block ads loading.
  final adUrlFilters = [
    ".*.doubleclick.net/.*",
    ".*.ads.pubmatic.com/.*",
    ".*.googlesyndication.com/.*",
    ".*.google-analytics.com/.*",
    ".*.adservice.google.*/.*",
  ];

  final List<ContentBlocker> contentBlockers = [];

  @override
  void initState() {
    super.initState();

    // Track item opened event
    AnalyticsService.logItemOpened('${widget.itemId}');

    // for each Ad URL filter, add a Content Blocker to block its loading.
    for (final adUrlFilter in adUrlFilters) {
      contentBlockers.add(
        ContentBlocker(
          trigger: ContentBlockerTrigger(
            urlFilter: adUrlFilter,
          ),
          action: ContentBlockerAction(
            type: ContentBlockerActionType.BLOCK,
          ),
        ),
      );
    }

    // apply the "display: none" style to some HTML elements
    contentBlockers.add(
      ContentBlocker(
        trigger: ContentBlockerTrigger(
          urlFilter: ".*",
        ),
        action: ContentBlockerAction(
          type: ContentBlockerActionType.CSS_DISPLAY_NONE,
          selector:
              ".banner, .banners, .ads, .ad, .advert, .widget-ads, .ad-unit",
        ),
      ),
    );

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              distanceToTriggerSync: 100,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void didChangeDependencies() {
    if (pullToRefreshController != null) {
      pullToRefreshController!.settings.color =
          context.theme.colorScheme.onPrimary;
      pullToRefreshController!.settings.backgroundColor =
          context.theme.colorScheme.primary;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // WebView content
            Positioned.fill(
              child: Column(
                children: [
                  progress < 1.0
                      ? LinearProgressIndicator(
                          value: progress,
                          color: context.theme.colorScheme.primary,
                        )
                      : Container(),
                  Expanded(
                    child: InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                      initialSettings: InAppWebViewSettings(
                        // contentBlockers: contentBlockers,
                        algorithmicDarkeningAllowed: true,
                        useHybridComposition: true,
                      ),
                      shouldOverrideUrlLoading: (controller, request) async {
                        await launchUrlInBrowser(
                            request.request.url.toString());
                        return NavigationActionPolicy.CANCEL;
                      },
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStop: (controller, url) {
                        pullToRefreshController?.endRefreshing();
                      },
                      onReceivedError: (controller, request, error) {
                        pullToRefreshController?.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: kBottomNavigationBarHeight),
                ],
              ),
            ),

            // Draggable bottom drawer
            WebViewDraggableBottom(
              webViewController: webViewController,
              itemId: widget.itemId,
              isSaved: widget.isSaved,
              isLiked: widget.isLiked,
            ),
          ],
        ),
      ),
    );
  }
}
