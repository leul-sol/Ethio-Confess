import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/vent.dart';
import '../../providers/vent_provider.dart';
import '../../screens/vent/vent_detail_screen.dart';
import '../../utils/avatar_utils.dart';

class GuestRecentVentScreen extends ConsumerWidget {
  const GuestRecentVentScreen({super.key});

  // Helper function to trim text
  String trimText(String text, {int maxLength = 100}) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventAsyncValue = ref.watch(ventProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recent Vent"),
      ),
      body: Column(
        children: [
          // Scrollable Recent Vents Cards Only
          Expanded(
            child: ventAsyncValue.when(
              data: (vents) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: vents.length,
                  itemBuilder: (context, index) {
                    final Vent vent = vents[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VentDetailScreen(
                              ventId: vent.id ?? '',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: AvatarUtils.getProfileImage(vent.user?.profile_image),
                                backgroundColor: Colors.grey.shade200,
                                child: AvatarUtils.getProfileImage(vent.user?.profile_image) == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                trimText(
                                    vent.content ?? 'No content available'),
                                style: const TextStyle(
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    timeago.format(vent.updatedAt ??
                                        DateTime.now()), // Format the time
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.repeat,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        vent.replyCount.toString(),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Column(
                children: [
                  Center(
                      child: SizedBox(
                    height: 150,
                    child: SizedBox(
                      height: 70,
                      width: 70,
                      child: Image.asset("assets/images/no-results.png"),
                    ),
                  )),
                  const Text(
                    "An error occurred, go back again please",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ) // Return empty widget
              ,
            ),
          ),
        ],
      ),
    );
  }
}
