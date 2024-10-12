import 'dart:convert';

import 'package:Beepo/components/bottom_nav.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/profile/user_profile_screen.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/functions.dart';
import 'package:Beepo/utils/target_platform.dart';
import 'package:Beepo/widgets/cache_memory_image_provider.dart';
import 'package:Beepo/widgets/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:string_to_color/string_to_color.dart';
import 'dart:ui' as ui;

import 'package:xmtp/xmtp.dart';

class ChatDmScreen extends StatefulHookWidget {
  final String topic;
  final String? senderAddress;
  final Map? userData;
  ChatDmScreen(
      {Key? key, this.senderAddress, this.userData, required this.topic})
      : super(key: Key(topic));

  @override
  State<ChatDmScreen> createState() => _ChatDmScreenState();
}

class _ChatDmScreenState extends State<ChatDmScreen> {
  final _demoBoxKey = GlobalKey();
  // The minimum height a MessageBox
  double? _singleMessageHeight;

  final _scrollController = ScrollController();

  // Whether to show the goto bottom button.
  final _gotoBottomButtonNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _singleMessageHeight = _demoBoxKey.currentContext?.size?.height;
      });
    });
    _scrollController.addListener(_scrollListener);
  }

  // Show goto bottom button if scroll offset > message box height.
  void _scrollListener() {
    // + 5 is ListView vertical padding
    if (_scrollController.offset > _singleMessageHeight! + 5) {
      _gotoBottomButtonNotifier.value = true;
    } else {
      _gotoBottomButtonNotifier.value = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _gotoBottomButtonNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_singleMessageHeight == null) {
      return Opacity(
        opacity: 0, // Not showing, only for calculate height
        child: ListView(
          children: [
            MessageBox(
              sentAt: DateTime.now(),
              key: _demoBoxKey,
              message: 'hello',
              isMe: true,
            ),
          ],
        ),
      );
    }

    var topic = widget.topic;
    var sending = useState(false);

    var input = useTextEditingController();
    var canSend = useState(false);
    var userData = widget.userData;

    input.addListener(() => canSend.value = input.text.isNotEmpty);
    submitHandler() async {
      sending.value = true;
      await session.sendMessage(topic, input.text.trim()).whenComplete(() {
        sending.value = false;
        input.text = '';
      });
    }

    bool noBeepoAcct = userData == null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.secondaryColor,
        toolbarHeight: 40.h,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const BottomNavHome();
                }));
              },
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.white,
                size: 25.sp,
              ),
            ),
            TextButton(
              onPressed: () {
                if (userData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(user: userData),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  noBeepoAcct
                      ? CircleAvatar(
                          backgroundColor:
                              ColorUtils.stringToColor(widget.senderAddress!),
                          child: Text(
                            widget.senderAddress!.substring(0, 2),
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : SizedBox(
                          height: 50,
                          width: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image(
                              image: CacheMemoryImageProvider(userData['image'],
                                  base64Decode(userData['image'])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  SizedBox(width: 10.w),
                  noBeepoAcct
                      ? Text(
                          '${widget.senderAddress!.substring(0, 3)}...${widget.senderAddress!.substring(widget.senderAddress!.length - 7, widget.senderAddress!.length)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.white,
                              fontWeight: FontWeight.w500),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['displayName'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13.sp,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              "@${userData['username']}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 8.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert_outlined,
              color: AppColors.white,
              size: 18.sp,
            ),
          ),
        ],
      ),
      body: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,

              // Using LayoutBuilder to get the maxHeight for ListView.
              child: LayoutBuilder(
                builder: (context, constrains) {
                  List<DecodedMessage>? msgs =
                      context.watch<ChatProvider>().messages;
                  if (msgs == null || msgs.isEmpty) {
                    return const Text('no messages yet');
                  }

                  List messages =
                      msgs.where((element) => element.topic == topic).toList();
                  int length = messages.length;

                  final isShrinkWrap =
                      _singleMessageHeight! * length > constrains.maxHeight
                          ? false
                          : true;

                  return ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: isShrinkWrap,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    physics: const ClampingScrollPhysics(),
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      DecodedMessage message = messages[index];
                      final isFirstInSection = index == length - 1
                          ? true
                          : message.sender != messages[index + 1].sender;
                      final isFirstInDate = index == length - 1
                          ? true
                          : !message.sentAt
                              .isSameDate(messages[index + 1].sentAt);

                      bool isMe = widget.senderAddress.toString() !=
                          message.sender.toString();

                      return Column(
                        children: [
                          // Message date
                          if (isFirstInDate)
                            _DateTimeItem(date: message.sentAt),
                          MessageBox(
                            message: message.content.toString(),
                            isMe: isMe,
                            sentAt: message.sentAt,
                            isFirstInSection: isFirstInSection || isFirstInDate,
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Goto bottom button. Placed in bottom right corner.
            // show/hide button using AnimatedSwitcher.
            ValueListenableBuilder<bool>(
              valueListenable: _gotoBottomButtonNotifier,
              builder: (context, showButton, button) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: Theme.of(context).platform.isMobile
                        ? const EdgeInsets.only(right: 10, bottom: 3)
                        : const EdgeInsets.all(15),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: showButton ? button! : null,
                    ),
                  ),
                );
              },
              child: _GotoBottomButton(
                onTap: () => _scrollController.jumpTo(0),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          // height: 45.h,
          // color: Colors.transparent,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          // width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      child: TextField(
                        onSubmitted: (value) =>
                            canSend.value ? submitHandler : null,
                        style: const TextStyle(fontSize: 16),
                        controller: input,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: const TextStyle(
                              color: Color(0xff697077), fontSize: 15),
                          prefixIcon: input.text.isEmpty
                              ? IconButton(
                                  onPressed: () {
                                    // context
                                    //     .read<ChatNotifier>()
                                    //     .cameraUploadImageChat(widget.model.uid);
                                  },
                                  icon: SvgPicture.asset('assets/camera.svg'),
                                )
                              : null,
                          suffixIcon: input.text.isEmpty
                              ? IconButton(
                                  onPressed: () {
                                    inchatTxBox(
                                        context,
                                        (userData ??
                                            {
                                              "displayName":
                                                  widget.senderAddress!,
                                              "ethAddress":
                                                  widget.senderAddress!
                                            }));
                                    // context
                                    //     .read<ChatNotifier>()
                                    //     .cameraUploadImageChat(widget.model.uid);
                                  },
                                  icon: SvgPicture.asset('assets/dollar.svg'),
                                )
                              : null,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        // expands: true,

                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ),
              ),
              // messageController.text.isEmpty
              //     ? IconButton(
              //         onPressed: () {
              //           // showModalBottomSheet(
              //           //     shape: const OutlineInputBorder(
              //           //         borderSide: BorderSide.none,
              //           //         borderRadius: BorderRadius.only(
              //           //             topLeft: Radius.circular(20),
              //           //             topRight: Radius.circular(20))),
              //           //     context: context,
              //           //     builder: (ctx) => CustomVoiceRecorderWidget(
              //           //           isGroupChat: false,
              //           //           receiverId: widget.model.uid,
              //           //         ));
              //         },
              //         icon: SvgPicture.asset(
              //           'assets/microphone.svg',
              //           width: 27,
              //           height: 27,
              //         ))
              //     :
              IconButton(
                onPressed: () async {
                  canSend.value && !sending.value ? submitHandler() : null;
                  // // var status = await OneSignal.shared.getDeviceState();
                  // //
                  // // var playerId = status.userId;
                  // await OneSignal.shared
                  //     .postNotification(OSCreateNotification(
                  //   playerIds: [player],
                  //   content: context.read<ChatNotifier>().chatText,
                  //   heading: 'Beepo',
                  //   subtitle: userM['displayName'],
                  //   sendAfter: DateTime.now(),
                  //   buttons: [
                  //     OSActionButton(text: "test1", id: "id1"),
                  //     OSActionButton(text: "test2", id: "id2"),
                  //   ],
                  //   androidSound:
                  //       'assets/mixkit-interface-hint-notification-911.wav',
                  //   androidSmallIcon: 'assets/Beepo_img.png',
                  //
                  // )
                  // );
                  // context.read<ChatNotifier>().clearText();

                  // setState(() {
                  //   isReplying = false;
                  //   replyMessage = '';
                  // });
                  // EncryptData.encryptFernet(context.read<ChatNotifier>().chatText);
                  // OneSignal.shared.
                },
                icon: SvgPicture.asset('assets/send.svg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({
    super.key,
    required this.message,
    required this.isMe,
    required this.sentAt,
    this.isFirstInSection = false,
  });

  final String message;
  final DateTime sentAt;

  /// Whether the message is first in a section of messages by same user.
  final bool isFirstInSection;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constrains) {
          final isMobile = Theme.of(context).platform.isMobile;
          final maxWidth = constrains.maxWidth;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? maxWidth - 50 : maxWidth * 0.75,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: maxWidth > 600 ? maxWidth * 0.1 : 0,
              ).copyWith(top: isFirstInSection ? 5 : 0),
              child: MessageBubble(
                message: message,
                isMe: isMe,
                showArrow: isFirstInSection,
                sentAt: DateFormat("jm").format(sentAt),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GotoBottomButton extends StatelessWidget {
  const _GotoBottomButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = Theme.of(context).platform.isMobile;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 1,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
      child: ClipOval(
        child: GestureDetector(
          onTap: onTap,
          child: ColoredBox(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : AppColors.secondaryColor,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                isMobile
                    ? Icons.keyboard_double_arrow_down
                    : Icons.keyboard_arrow_down,
                size: isMobile ? 22 : 30,
                color: AppColors.secondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.sentAt,
    required this.isMe,
    this.showArrow = false,
  });

  final String message;
  final String sentAt;
  final bool isMe;

  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final isMobile = theme.platform.isMobile;
    final messageTextStyle = textTheme.bodyMedium!.copyWith(
      fontSize: isMobile ? 14 : null,
      color: !isMe ? Colors.black : Colors.white,
    );

    final timeTextStyle = textTheme.bodySmall!.copyWith(
      fontSize: isMobile ? null : 8,
      color: !isMe ? Colors.black54 : Colors.white70,
    );

    final messageText = message;
    final timeText = sentAt;

    final timeTextWidth =
        textWidth(timeText, timeTextStyle) + (isMe ? 20.0 : 6);
    final messageTextWidth = textWidth(messageText, messageTextStyle);
    final whiteSpaceWidth = textWidth(' ', messageTextStyle);
    // More space on desktop (+8)
    final extraSpaceCount =
        ((timeTextWidth / whiteSpaceWidth).round()) + (isMobile ? 2 : 8);
    final extraSpace = '${' ' * extraSpaceCount}\u202f';
    final extraSpaceWidth = textWidth(extraSpace, messageTextStyle);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: !isMe ? const Color(0xFFC4C4C4) : const Color(0xff0E014C),
        ),
        child: LayoutBuilder(
          builder: (context, constrains) {
            const padding = 8.0;
            final maxWidth = constrains.maxWidth - (padding * 2);

            final isTimeInSameLine =
                messageTextWidth + extraSpaceWidth < maxWidth ||
                    messageTextWidth > maxWidth;

            if (messageText.contains("inChatTxChat-BeepoV2")) {
              final walletProvider =
                  Provider.of<WalletProvider>(context, listen: false);
              var decodedText = jsonDecode(messageText);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color.fromRGBO(196, 196, 196, 0.57),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          decodedText['sender'] ==
                                  walletProvider.ethAddress.toString()
                              ? "You Sent"
                              : "You Received",
                          style: messageTextStyle,
                        ),
                      ),
                    ),
                    Text(
                      '\$${decodedText['amtInUSD']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 23,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      '${decodedText['amount']} ${decodedText['ticker']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(padding).copyWith(
                    bottom: isTimeInSameLine ? padding : 25,
                  ),
                  child: Text(
                    '$messageText'
                    '${isTimeInSameLine ? extraSpace : ' '}',
                    style: messageTextStyle,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 7,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeText,
                        style: timeTextStyle,
                      ),
                      // Message status icon
                      if (isMe)
                        const Icon(
                          Icons.done_all,
                          color: Colors.white70,
                          size: 14,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Returns the width of given `text` using TextPainter
  double textWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}

class _DateTimeItem extends StatelessWidget {
  const _DateTimeItem({
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: ColoredBox(
          color: AppColors.borderGrey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    date = date.subtract(Duration(hours: date.hour));
    final difference = DateTime.now().difference(date).inDays;
    if (difference < 1) return 'Today';
    if (difference < 2) return 'Yesterday';
    return DateFormat(DateFormat.YEAR_MONTH_DAY).format(date);
  }
}
