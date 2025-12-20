import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DepositTermsScreen extends StatelessWidget {
  const DepositTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Terms'),
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
                'Security Deposit',
                'A refundable security deposit is required for all bike rentals. The deposit amount varies based on the bike model and rental duration.',
              ),
              _buildSection(
                'Deposit Amount',
                '• Standard bikes: ₹2,000 - ₹3,000\n'
                    '• Premium bikes: ₹5,000 - ₹10,000\n'
                    '• Luxury bikes: ₹15,000 - ₹25,000',
              ),
              _buildSection(
                'Payment of Deposit',
                'The security deposit must be paid at the time of booking confirmation. Payment can be made via online transfer, credit card, or debit card.',
              ),
              _buildSection(
                'Deposit Hold Period',
                'The security deposit will be held throughout the rental period and for 7 days after the bike is returned to allow for verification of any damages or violations.',
              ),
              _buildSection(
                'Refund Conditions',
                'The full deposit will be refunded if:\n'
                    '• The bike is returned on time\n'
                    '• The bike is in the same condition as provided\n'
                    '• No traffic violations or fines are incurred\n'
                    '• No fuel charges are pending\n'
                    '• All rental terms are complied with',
              ),
              _buildSection(
                'Deductions from Deposit',
                'The following may result in deductions from your security deposit:\n'
                    '• Physical damage to the bike (scratches, dents, broken parts)\n'
                    '• Missing accessories or documents\n'
                    '• Traffic fines or violations\n'
                    '• Late return charges\n'
                    '• Fuel refill charges\n'
                    '• Cleaning charges (if returned excessively dirty)\n'
                    '• Towing or recovery charges',
              ),
              _buildSection(
                'Damage Assessment',
                'Upon return, our team will inspect the bike for any damages. You will be notified of any deductions with photographic evidence and detailed breakdown of charges.',
              ),
              _buildSection(
                'Refund Processing Time',
                'After successful inspection and clearance, the refund will be processed within 7-10 business days to the original payment method.',
              ),
              _buildSection(
                'Complete Loss or Theft',
                'In case of complete loss, theft, or total damage of the bike:\n'
                    '• The security deposit will be forfeited\n'
                    '• You will be liable for the full market value of the bike\n'
                    '• Legal action may be taken as per applicable laws',
              ),
              _buildSection(
                'Dispute Resolution',
                'Any disputes regarding deposit deductions must be raised within 48 hours of notification. We will review with supporting evidence and provide a final decision within 5 business days.',
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
                  'By agreeing to these deposit terms, you acknowledge your responsibility for the bike and accept the conditions for deposit refund and potential deductions.',
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
