import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';

class InvoiceViewerScreen extends StatefulWidget {
  final String bookingId;
  final String bikeName;
  final String? invoiceUrl; // Add optional invoice URL parameter

  const InvoiceViewerScreen({
    super.key,
    required this.bookingId,
    required this.bikeName,
    this.invoiceUrl, // Optional invoice URL from booking response
  });

  @override
  State<InvoiceViewerScreen> createState() => _InvoiceViewerScreenState();
}

class _InvoiceViewerScreenState extends State<InvoiceViewerScreen> {
  String? localFilePath;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int totalPages = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndDisplayPDF();
  }

  String get invoiceUrl => widget.invoiceUrl ?? 
      'https://api.revupbikes.com/api/files/invoice/${widget.bookingId}';

  Future<void> _downloadAndDisplayPDF() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Debug: Print which invoice URL is being used
      print('Invoice URL being used: $invoiceUrl');
      print('Invoice URL from widget: ${widget.invoiceUrl}');
      print('Booking ID: ${widget.bookingId}');

      // Validate invoice URL
      if (invoiceUrl.isEmpty) {
        throw Exception('Invoice URL is empty');
      }

      // Create Dio instance for downloading
      final dio = Dio();

      // Get temporary directory
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/invoice_${widget.bookingId}.pdf';

      // Download the PDF
      final response = await dio.download(
        invoiceUrl,
        filePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          localFilePath = filePath;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _downloadPDF() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Downloading invoice...'),
            ],
          ),
        ),
      );

      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/RevUpBikes_Invoice_${widget.bookingId}.pdf';

      await dio.download(invoiceUrl, filePath);

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice downloaded to: ${filePath}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => _openFile(filePath),
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sharePDF() async {
    if (localFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not ready for sharing'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(localFilePath!)],
        text:
            'RevUp Bikes Invoice - ${widget.bikeName} (Booking: ${widget.bookingId})',
        subject: 'Bike Rental Invoice',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing failed: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openFile(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.invoiceUrl != null ? 'Invoice (API)' : 'Invoice (Fallback)',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          if (!isLoading && !hasError) ...[
            IconButton(
              onPressed: _downloadPDF,
              icon: const Icon(Icons.download),
              tooltip: 'Download',
            ),
            IconButton(
              onPressed: _sharePDF,
              icon: const Icon(Icons.share),
              tooltip: 'Share',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Header with booking info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Booking ID: ${widget.bookingId}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.bikeName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // PDF Viewer
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildContent(),
              ),
            ),
          ),

          // Bottom actions
          if (!isLoading && !hasError)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _downloadPDF,
                      icon: const Icon(Icons.download, color: AppColors.white),
                      label: const Text(
                        'Download',
                        style: TextStyle(color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sharePDF,
                      icon: const Icon(Icons.share, color: AppColors.primary),
                      label: const Text(
                        'Share',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home, color: AppColors.white),
                      label: const Text(
                        'Home',
                        style: TextStyle(color: AppColors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Loading invoice...',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Failed to load invoice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _downloadAndDisplayPDF,
                icon: const Icon(Icons.refresh, color: AppColors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (localFilePath == null) {
      return const Center(child: Text('No PDF to display'));
    }

    return PDFView(
      filePath: localFilePath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: currentPage,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        setState(() {
          totalPages = pages!;
        });
      },
      onError: (error) {
        setState(() {
          hasError = true;
          errorMessage = error.toString();
        });
      },
      onPageError: (page, error) {
        setState(() {
          hasError = true;
          errorMessage = 'Page $page: $error';
        });
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // PDF view controller can be used for additional controls
      },
      onLinkHandler: (String? uri) {
        // Handle link clicks in PDF
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          currentPage = page ?? 0;
        });
      },
    );
  }
}
