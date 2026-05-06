import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/saved/controller/saved_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SaveCollectionBottomSheet extends StatelessWidget {
  final String itemId;
  final Function(String collectionId) onSaveToCollection;

  const SaveCollectionBottomSheet({
    super.key,
    required this.itemId,
    required this.onSaveToCollection,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SavedController>()) {
      Get.put(SavedController());
    }
    final controller = Get.find<SavedController>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Save to...",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Obx(() {
              final collections = controller.customCollections;
              if (collections.isEmpty) {
                return const Center(child: Text("No collections found."));
              }
              return ListView.separated(
                itemCount: collections.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  final isSavedInCollection = collection.itemIds.contains(
                    itemId,
                  );

                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: collection.coverImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: collection.coverImage!.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: collection.coverImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : File(collection.coverImage!).existsSync()
                                  ? Image.file(
                                      File(collection.coverImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            )
                          : const Icon(Icons.bookmark, color: Colors.grey),
                    ),
                    title: Text(
                      collection.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: isSavedInCollection
                        ? const Icon(Icons.check_circle, color: Colors.orange)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      controller.saveItemToCollection(collection.id, itemId);
                      onSaveToCollection(
                        collection.id,
                      ); // Trigger actual backend save API here or handle externally
                      Get.back();
                    },
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _showCreateCollectionDialog(controller);
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Create New Collection",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCollectionDialog(SavedController controller) {
    final nameController = TextEditingController();
    final selectedImagePath = Rx<String?>(null);

    Get.dialog(
      AlertDialog(
        title: const Text("Create New Collection"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final path = await controller.pickImage();
                if (path != null) {
                  selectedImagePath.value = path;
                }
              },
              child: Obx(() {
                final path = selectedImagePath.value;
                return Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: path != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(path), fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Pick Cover Image (Optional)",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                );
              }),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Collection Name"),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.createCollection(
                  nameController.text,
                  selectedImagePath.value,
                );
                Get.back(); // close dialog
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
