import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// Reusable compliance document upload card supporting preview, upload state, and removal.
class NGODocumentUploadTile extends StatelessWidget {
  final bool isGovtId;
  final String govtIdType;
  final Uint8List? bytes;
  final bool isAttached;
  final bool isUploading;
  final String fileName;
  final String fileSize;
  final VoidCallback onUploadPressed;
  final VoidCallback onRemovePressed;

  const NGODocumentUploadTile({
    super.key,
    required this.isGovtId,
    required this.govtIdType,
    this.bytes,
    required this.isAttached,
    required this.isUploading,
    required this.fileName,
    required this.fileSize,
    required this.onUploadPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final title = isGovtId
        ? 'Official $govtIdType Proof'
        : 'Official FSSAI Food Safety Certificate';
    final subtitle = isGovtId
        ? 'Upload official Aadhaar or PAN document proof'
        : 'Upload state food safety authority certificate';

    if (isUploading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.warmIvoryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.emerald),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.forestGreen,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Uploading document to Supabase secure compliance vault...',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isAttached) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.emeraldLight.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.emerald, width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (bytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      bytes!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.forestGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vault Upload Verified • $fileSize',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.forestGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ATTACHED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppTheme.statusCritical,
                  ),
                  label: const Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.statusCritical,
                    ),
                  ),
                  onPressed: onRemovePressed,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.change_circle_rounded, size: 16),
                  label: const Text(
                    'Change File',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  onPressed: onUploadPressed,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warmIvoryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: AppTheme.forestGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.charcoalMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.upload_rounded, size: 16),
            label: const Text(
              'Upload',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            onPressed: onUploadPressed,
          ),
        ],
      ),
    );
  }
}
