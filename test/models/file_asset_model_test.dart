import 'package:flutter_test/flutter_test.dart';
import 'package:capsule_time/features/capsules/data/models/file_asset_model.dart';

void main() {
  group('FileAsset', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'file123',
        'fileName': 'test.jpg',
        'mimeType': 'image/jpeg',
        'size': 1024000,
        'storageKey': 'abc123',
        'url': 'https://example.com/file.jpg',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final file = FileAsset.fromJson(json);

      expect(file.id, 'file123');
      expect(file.fileName, 'test.jpg');
      expect(file.mimeType, 'image/jpeg');
      expect(file.size, 1024000);
      expect(file.storageKey, 'abc123');
      expect(file.url, 'https://example.com/file.jpg');
    });

    test('formattedSize returns correct format for bytes', () {
      final file = FileAsset(
        id: '1',
        fileName: 'test.txt',
        mimeType: 'text/plain',
        size: 500,
        storageKey: 'key',
        createdAt: DateTime(2024),
      );
      expect(file.formattedSize, '500 B');
    });

    test('formattedSize returns correct format for KB', () {
      final file = FileAsset(
        id: '1',
        fileName: 'test.txt',
        mimeType: 'text/plain',
        size: 1536,
        storageKey: 'key',
        createdAt: DateTime(2024),
      );
      expect(file.formattedSize, '1.5 KB');
    });

    test('formattedSize returns correct format for MB', () {
      final file = FileAsset(
        id: '1',
        fileName: 'test.jpg',
        mimeType: 'image/jpeg',
        size: 2097152,
        storageKey: 'key',
        createdAt: DateTime(2024),
      );
      expect(file.formattedSize, '2.0 MB');
    });

    test('formattedSize returns correct format for GB', () {
      final file = FileAsset(
        id: '1',
        fileName: 'test.mp4',
        mimeType: 'video/mp4',
        size: 3221225472,
        storageKey: 'key',
        createdAt: DateTime(2024),
      );
      expect(file.formattedSize, '3.0 GB');
    });

    test('isImage returns true for image types', () {
      final jpegFile = FileAsset(id: '1', fileName: 'a.jpg', mimeType: 'image/jpeg', size: 0, storageKey: 'k', createdAt: DateTime(2024));
      final pngFile = FileAsset(id: '2', fileName: 'a.png', mimeType: 'image/png', size: 0, storageKey: 'k', createdAt: DateTime(2024));
      final gifFile = FileAsset(id: '3', fileName: 'a.gif', mimeType: 'image/gif', size: 0, storageKey: 'k', createdAt: DateTime(2024));

      expect(jpegFile.isImage, true);
      expect(pngFile.isImage, true);
      expect(gifFile.isImage, true);
    });

    test('isVideo returns true for video types', () {
      final mp4File = FileAsset(id: '1', fileName: 'a.mp4', mimeType: 'video/mp4', size: 0, storageKey: 'k', createdAt: DateTime(2024));
      final movFile = FileAsset(id: '2', fileName: 'a.mov', mimeType: 'video/quicktime', size: 0, storageKey: 'k', createdAt: DateTime(2024));

      expect(mp4File.isVideo, true);
      expect(movFile.isVideo, true);
    });

    test('isPdf returns true for PDF', () {
      final pdfFile = FileAsset(id: '1', fileName: 'a.pdf', mimeType: 'application/pdf', size: 0, storageKey: 'k', createdAt: DateTime(2024));
      expect(pdfFile.isPdf, true);
    });

    test('isDocument returns true for document types', () {
      final docFile = FileAsset(id: '1', fileName: 'a.doc', mimeType: 'application/msword', size: 0, storageKey: 'k', createdAt: DateTime(2024));
      final txtFile = FileAsset(id: '2', fileName: 'a.txt', mimeType: 'text/plain', size: 0, storageKey: 'k', createdAt: DateTime(2024));

      expect(docFile.isDocument, true);
      expect(txtFile.isDocument, true);
    });
  });
}
