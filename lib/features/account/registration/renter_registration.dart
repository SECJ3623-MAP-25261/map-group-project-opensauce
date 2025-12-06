// renter_registration.dart (simplified)
import 'package:flutter/material.dart';

enum UserMode { rentee, renter }

class RenterRegistrationPage extends StatefulWidget {
  const RenterRegistrationPage({super.key});

  @override
  State<RenterRegistrationPage> createState() => _RenterRegistrationPageState();
}

class _RenterRegistrationPageState extends State<RenterRegistrationPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form data (removed business name and address)
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  @override
  void dispose() {
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Become a Renter'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3, // Changed from 4 to 3 steps
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF800000),
            ), // Maroon
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(key: _formKey, child: _buildStep()),
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000), // Maroon
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2
                          ? 'Complete Setup'
                          : 'Next', // Updated to 2
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // White text
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

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildPaymentStep(); // Payment step comes first
      case 2:
        return _buildVerificationStep(); // Verification step last
      default:
        return Container();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.home_work_outlined,
          size: 80,
          color: Color(0xFF800000), // Maroon
        ),
        const SizedBox(height: 24),
        const Text(
          'Become a Renter',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Join thousands of renters listing their items and earning extra income.',
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 32),
        _buildBenefitTile(
          icon: Icons.attach_money,
          title: 'Earn extra income',
          subtitle: 'Set your own prices and availability',
        ),
        _buildBenefitTile(
          icon: Icons.security,
          title: 'Secure payments',
          subtitle: 'Get paid securely through our platform',
        ),
        _buildBenefitTile(
          icon: Icons.support_agent,
          title: '24/7 Support',
          subtitle: 'We\'re here to help you succeed',
        ),
      ],
    );
  }

  Widget _buildBenefitTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF800000).withOpacity(0.1), // Maroon
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF800000)), // Maroon
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Where should we send your earnings?',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: 'Bank Name',
            hintText: 'e.g., Maybank, CIMB, Public Bank',
            border: OutlineInputBorder(),
            prefixIcon: Icon(
              Icons.account_balance,
              color: Color(0xFF800000),
            ), // Maroon
          ),
          validator:
              (value) =>
                  value?.isEmpty ?? true ? 'Bank name is required' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _bankAccountController,
          decoration: const InputDecoration(
            labelText: 'Bank Account Number',
            hintText: 'Enter your account number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(
              Icons.credit_card,
              color: Color(0xFF800000),
            ), // Maroon
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Account number is required';
            }
            if (value!.length < 10) {
              return 'Please enter a valid account number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your payment information is securely encrypted and protected',
                  style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verify Your Identity',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps keep our community safe and secure',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _idNumberController,
          decoration: const InputDecoration(
            labelText: 'ID Number (IC/Passport)',
            hintText: 'Enter your identification number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(
              Icons.badge_outlined,
              color: Color(0xFF800000),
            ), // Maroon
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'ID number is required';
            }
            if (value!.length < 6) {
              return 'Please enter a valid ID number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID upload feature coming soon')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload ID Document',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Upload a clear photo of your ID (front and back)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(
              0xFF800000,
            ).withOpacity(0.1), // Maroon background
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.red[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your ID will only be used for verification purposes',
                  style: TextStyle(fontSize: 14, color: Colors.red[900]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      // Updated to 2 steps
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        _completeRegistration();
      }
    }
  }

  void _completeRegistration() {
    final registrationData = {
      'bankName': _bankNameController.text,
      'bankAccount': _bankAccountController.text,
      'idNumber': _idNumberController.text,
    };

    print('Registration Data: $registrationData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Registration successful! Welcome to renting!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }
}
