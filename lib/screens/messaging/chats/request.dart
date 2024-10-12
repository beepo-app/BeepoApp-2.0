import 'dart:convert';

import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/screens/messaging/chats/chat_dm_screen.dart';
import 'package:Beepo/screens/messaging/chats/search_users_screen.dart';
import 'package:Beepo/utils/hooks.dart';
import 'package:Beepo/widgets/cache_memory_image_provider.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:string_to_color/string_to_color.dart';
import 'package:xmtp/xmtp.dart' as xmtp;

class RequestsTab extends StatefulHookWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HawkFabMenu(
        icon: AnimatedIcons.menu_close,
        iconColor: Colors.white,
        fabColor: const Color(0xe50d004c),
        items: [
          HawkFabMenuItem(
            label: 'New Chat',
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            color: const Color(0xe50d004c),
            labelColor: Colors.white,
            labelBackgroundColor: const Color(0xe50d004c),
          ),
          HawkFabMenuItem(
            label: 'Join Public Chat',
            ontap: () {
              showToast('Comming Soon!');
            },
            icon: const Icon(
              Iconsax.people,
              color: Colors.white,
            ),
            color: const Color(0xe50d004c),
            labelColor: Colors.white,
            labelBackgroundColor: const Color(0xe50d004c),
          ),
          HawkFabMenuItem(
            label: 'Share',
            ontap: () {
              showToast('Comming Soon!');
            },
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            color: const Color(0xe50d004c),
            labelColor: Colors.white,
            labelBackgroundColor: const Color(0xe50d004c),
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Requests",
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          color: AppColors.secondaryColor,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.more_vert_outlined,
                        color: AppColors.secondaryColor,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                child: const Chat(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chat extends HookWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    List<xmtp.Conversation>? conversations =
        context.watch<ChatProvider>().convos;
    List<xmtp.DecodedMessage>? msgs = context.watch<ChatProvider>().messages;

    // var conversations = useConversationList();
    var users = useUsers();

    // var refresher = useConversationsRefresher();
    debugPrint('conversations ${conversations?.length ?? 0}');
    debugPrint('msgs ${msgs?.length ?? 0}');

    if (conversations == null || conversations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No conversations yet')),
      );
    }

    if (msgs == null || msgs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No conversations yet')),
      );
    }

    debugPrint('conversations ${conversations.length}');

    List convos = conversations.map((d) {
      var lastMessage = msgs.where((element) {
        return element.topic == d.topic;
      }).toList();

      lastMessage.sort(
        (a, b) {
          DateTime? timeA = a.sentAt;
          DateTime? timeB = b.sentAt;
          // ignore: unnecessary_null_comparison
          if (timeB != null && timeA != null) {
            return timeB.compareTo(timeA);
          }
          return -1;
        },
      );

      if (lastMessage.isNotEmpty) {
        return {'lastMessage': lastMessage[0], 'address': d.peer.toString()};
      }
      return {'lastMessage': null, 'address': d.peer.toString()};
    }).toList();

    convos.sort(
      (a, b) {
        DateTime? timeA = a['lastMessage']?.sentAt;
        DateTime? timeB = b['lastMessage']?.sentAt;
        if (timeB != null && timeA != null) {
          return timeB.compareTo(timeA);
        }
        return -1;
      },
    );

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        if (convos[index]['lastMessage'] == null) {
          // if (msg[index]['lastMessage'].connectionState == ConnectionState.waiting) {
          //   return Shimmer.fromColors(
          //     baseColor: Colors.grey.shade300,
          //     highlightColor: Colors.grey.shade100,
          //     child: ListTile(
          //       leading: const CircleAvatar(),
          //       title: Container(
          //         height: 10,
          //         width: 100,
          //         color: Colors.white,
          //       ),
          //       subtitle: Container(
          //         height: 10,
          //         width: 100,
          //         color: Colors.white,
          //       ),
          //       contentPadding: EdgeInsets.zero,
          //     ),
          //   );
          // }

          return Container();
        }

        Map? d = users?.toList().firstWhereOrNull(
            (element) => element['ethAddress'] == convos[index]['address']);

        return ConversationListItem(
          topic: convos[index]['lastMessage'].topic,
          lastMessage: convos[index]['lastMessage'],
          sender: convos[index]['address'],
          userData: d,
        );
      },
      itemCount: convos.length,
    );
  }
}

class ConversationListItem extends HookWidget {
  final String topic;
  final String sender;
  final Map? userData;
  final xmtp.DecodedMessage? lastMessage;

  ConversationListItem(
      {Key? key,
      required this.sender,
      required this.topic,
      this.userData,
      this.lastMessage})
      : super(key: Key(topic));

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: true);

    var content = (lastMessage?.content ?? "") as String;
    var lastSentAt = lastMessage?.sentAt ?? DateTime.now();
    var senderAddress = sender;

    bool noBeepoAcct = userData == null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: noBeepoAcct
          ? Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: ColorUtils.stringToColor(senderAddress),
                  borderRadius: BorderRadius.circular(100)),
              child: Center(
                child: Text(
                  senderAddress.substring(0, 2),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image(
                  image: CacheMemoryImageProvider(
                      userData!['image'], base64Decode(userData!['image'])),
                  fit: BoxFit.cover,
                ),
              ),
            ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            noBeepoAcct
                ? '${senderAddress.substring(0, 3)}...${senderAddress.substring(senderAddress.length - 7, senderAddress.length)}'
                : userData!['displayName'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          // unreadCount > 0
          //     ? Container(
          //         width: 14.sp,
          //         height: 14.sp,
          //         decoration: const BoxDecoration(
          //           color: AppColors.secondaryColor,
          //           borderRadius: BorderRadius.all(Radius.circular(30)),
          //         ),
          //         child: Center(
          //           child: Text(
          //             style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
          //             unreadCount.toString(),
          //           ),
          //         ),
          //       )
          //     : const SizedBox(),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
              child: Text(
            content.contains("inChatTxChat-BeepoV2")
                ? "In Chat Tx"
                : content.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                _formatDate(lastSentAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        List<xmtp.DecodedMessage>? msgs = chatProvider.messages;
        if (msgs != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDmScreen(
                topic: topic,
                userData: userData,
                senderAddress: userData?['ethAdress'] ?? senderAddress,
              ),
            ),
          );
        }
      },
    );
  }
}

//  ' ${isToday ? DateFormat("jm").format(lastSentAt) : days < 1 ? 'Yesterday' : DateFormat("yMd").format(lastSentAt)}'

String _formatDate(DateTime date) {
  var ndate = date.subtract(Duration(hours: date.hour));
  final difference = DateTime.now().difference(ndate).inDays;
  if (difference < 1) return DateFormat('jm').format(date);
  if (difference < 2) return 'Yesterday';
  return DateFormat('yMd').format(date);
}
