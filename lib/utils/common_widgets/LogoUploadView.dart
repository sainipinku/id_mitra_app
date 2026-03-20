import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';


class LogoUploadView extends StatelessWidget {
  final VoidCallback onAddPhoto;
  final VoidCallback onRemove;
  final File? imageUrl;

  const LogoUploadView({
    super.key,
    required this.onAddPhoto,
    required this.onRemove,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Add Photo Card
        GestureDetector(
          onTap: onAddPhoto,
          child: DottedBorder(
            options: RectDottedBorderOptions(
              dashPattern: const [6, 4],
              strokeWidth: 1,
            ),

            child: Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(

                borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, color: Colors.grey),
                  SizedBox(height: 6),
                  Text(
                    "Add Photo",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        /// Uploaded Logo Preview
        if (imageUrl != null)
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),


              /// Close Button
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
