import 'package:Beepo/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key}) : super(key: key);

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  late TextEditingController textEditingController;
  late WebViewController webViewController;
  String searchEngineUrl = "https://www.google.com/";
  bool isLoading = false;
  bool isHome = true;

  // bool comingSoon = true;

  @override
  void initState() {
    textEditingController = TextEditingController(text: searchEngineUrl);
    webViewController = WebViewController();
    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) {
        textEditingController.text = url;
        setState(() {
          isLoading = true;
        });
      },
      onPageFinished: (url) {
        setState(() {
          isLoading = false;
        });
      },
    ));
    loadUrl(textEditingController.text);
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  loadUrl(String value) {
    Uri uri = Uri.parse(value);
    if (!uri.isAbsolute) {
      uri = Uri.parse("${searchEngineUrl}search?q=$value");
    }
    webViewController.loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.h,
        centerTitle: true,
        backgroundColor: AppColors.secondaryColor,
        title: Padding(
          padding: EdgeInsets.only(top: 15.h, right: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "DAPP Browser",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/Celo.png',
                    height: 13,
                    width: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Celo Network",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.white,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.white,
                    size: 16.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              isHome = true;
            });
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
      ),
      body: SizedBox(
        // padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            SizedBox(
              height: 25.h,
              child: Expanded(
                child: TextFormField(
                  controller: textEditingController,
                  onFieldSubmitted: (value) {
                    setState(() {
                      isHome = false;
                    });
                    textEditingController.clear();
                    loadUrl(value);
                  },
                  cursorColor: const Color(0xff0e014c),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                    fillColor: AppColors.backgroundGrey,
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.r),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.r),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.r),
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: AppColors.dividerGrey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Expanded(
              child: WebViewWidget(controller: webViewController),
            ),
            // Expanded(
            //   child: Column(
            //     children: [
            //       SizedBox(
            //         height: MediaQuery.of(context).size.height / 6,
            //         child: GridView.builder(
            //           itemCount: 8,
            //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //             crossAxisCount: 4,
            //           ),
            //           itemBuilder: (BuildContext context, index) {
            //             return const BrowserContainer(
            //               image: 'assets/mobius.png',
            //               title: 'mobius',
            //             );
            //           },
            //         ),
            //       ),
            //       SizedBox(height: 15.h),
            //       Align(
            //         alignment: Alignment.topLeft,
            //         child: Text(
            //           "NEWS",
            //           style: TextStyle(
            //             color: secondaryColor,
            //             fontSize: 14.sp,
            //           ),
            //         ),
            //       ),
            //       SizedBox(height: 10.h),
            //       Expanded(
            //         child: SingleChildScrollView(
            //           child: ListView.separated(
            //             padding: EdgeInsets.zero,
            //             shrinkWrap: true,
            //             physics: const NeverScrollableScrollPhysics(),
            //             itemCount: 5,
            //             separatorBuilder: (ctx, i) => const SizedBox(height: 20),
            //             itemBuilder: (ctx, i) {
            //               return Container(
            //                 padding: EdgeInsets.only(left: 10.w, right: 10.w),
            //                 width: double.infinity,
            //                 height: 70.h,
            //                 decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(15),
            //                   color: secondaryColor,
            //                 ),
            //                 child: Row(
            //                   children: [
            //                     ClipRRect(
            //                       borderRadius: BorderRadius.circular(15),
            //                       child: Image.asset(
            //                         'assets/news.png',
            //                         height: 87,
            //                         width: 104,
            //                         fit: BoxFit.cover,
            //                       ),
            //                     ),
            //                     SizedBox(width: 15.w),
            //                     Expanded(
            //                       child: Column(
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         crossAxisAlignment: CrossAxisAlignment.start,
            //                         children: [
            //                           Text(
            //                             "Here's Why Blockchain is the Technology For The Future Here's Why Blockchain is the Technology For The Future",
            //                             maxLines: 3,
            //                             style: TextStyle(
            //                               overflow: TextOverflow.ellipsis,
            //                               color: Colors.white,
            //                               fontSize: 11.sp,
            //                               fontWeight: FontWeight.w600,
            //                             ),
            //                           ),
            //                           const SizedBox(height: 27),
            //                           Text(
            //                             "technology.com",
            //                             style: TextStyle(
            //                               color: Colors.white,
            //                               fontSize: 8.sp,
            //                               fontWeight: FontWeight.w600,
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               );
            //             },
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
