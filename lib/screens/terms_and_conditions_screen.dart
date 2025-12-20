import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Agreement to Terms',
                'By accessing and using RevUp Bikes rental services, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
              ),
              _buildSection(
                'Rental Agreement',
                'The bike rental period begins at the agreed start time and ends at the agreed return time. Any extension requires prior approval and additional payment.',
              ),
              _buildSection(
                'User Responsibilities',
                '• You must be at least 18 years old with a valid driving license\n'
                    '• You are responsible for the bike during the rental period\n'
                    '• You must follow all traffic rules and regulations\n'
                    '• You must not sublet or lend the bike to anyone else\n'
                    '• You must return the bike in the same condition as received',
              ),
              _buildSection(
                'Prohibited Use',
                '• Using the bike for illegal activities\n'
                    '• Racing or off-road driving\n'
                    '• Driving under the influence of alcohol or drugs\n'
                    '• Carrying more passengers than the bike capacity\n'
                    '• Modifications to the bike without permission',
              ),
              _buildSection(
                'Damage and Loss',
                'You are liable for any damage, loss, or theft of the bike during the rental period. This includes mechanical damage, body damage, or complete loss of the vehicle.',
              ),
              _buildSection(
                'Cancellation Policy',
                '• Cancellation 24+ hours before start time: Full refund\n'
                    '• Cancellation within 24 hours: 50% refund\n'
                    '• No-show: No refund',
              ),
              _buildSection(
                'Insurance',
                'Basic insurance is included in the rental price. However, you are responsible for any damages beyond the insurance coverage limit.',
              ),
              _buildSection(
                'Fuel Policy',
                'The bike will be provided with a full tank. You must return it with a full tank, or fuel charges will be deducted from your deposit.',
              ),
              _buildSection(
                'Late Returns',
                'Late returns will incur additional charges. If you anticipate being late, please contact us immediately to avoid penalties.',
              ),
              _buildSection(
                'Modification of Terms',
                'RevUp Bikes reserves the right to modify these terms at any time. Continued use of the service constitutes acceptance of modified terms.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Text(
                  'By proceeding with the booking, you acknowledge that you have read, understood, and agree to these Terms and Conditions.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
