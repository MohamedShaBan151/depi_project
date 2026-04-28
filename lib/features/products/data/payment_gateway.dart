abstract class PaymentGateway {
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethod,
  });
  
  Future<RefundResult> processRefund({
    required String transactionId,
    required double amount,
  });
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
  });
}

class RefundResult {
  final bool success;
  final String? refundId;
  final String? errorMessage;

  RefundResult({
    required this.success,
    this.refundId,
    this.errorMessage,
  });
}

class PaymobGateway implements PaymentGateway {
  static const String _apiKey = 'YOUR_PAYMOB_API_KEY';
  static const String _frameId = 'YOUR_FRAME_ID';
  static const String _integrationId = 'YOUR_INTEGRATION_ID';

  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      final billingData = {
        'first_name': paymentMethod['firstName'] ?? 'Customer',
        'last_name': paymentMethod['lastName'] ?? 'User',
        'email': paymentMethod['email'] ?? 'customer@noon.sa',
        'phone': paymentMethod['phone'] ?? '+966501234567',
        'country': 'SAU',
        'city': paymentMethod['city'] ?? 'Riyadh',
        'street': paymentMethod['address'] ?? 'Default St',
        'building': paymentMethod['building'] ?? '1',
        'floor': paymentMethod['floor'] ?? '1',
        'apartment': paymentMethod['apartment'] ?? '1',
      };

      final amountCents = (amount * 100).toInt();
      
      await Future.delayed(const Duration(seconds: 1));

      return PaymentResult(
        success: true,
        transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<RefundResult> processRefund({
    required String transactionId,
    required double amount,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      return RefundResult(
        success: true,
        refundId: 'REF${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return RefundResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}

class StripeGateway implements PaymentGateway {
  static const String _publicKey = 'YOUR_STRIPE_KEY';

  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return PaymentResult(
        success: true,
        transactionId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<RefundResult> processRefund({
    required String transactionId,
    required double amount,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return RefundResult(
        success: true,
        refundId: 'stripe_ref_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return RefundResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}

enum PaymentProvider {
  paymob,
  stripe,
  cod,
  applePay,
}

class PaymentService {
  PaymentGateway _gateway = _MockGateway();

  PaymentService({PaymentProvider provider = PaymentProvider.paymob}) {
    _gateway = _getGateway(provider);
  }

  PaymentGateway _getGateway(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.paymob:
        return PaymobGateway();
      case PaymentProvider.stripe:
        return StripeGateway();
      case PaymentProvider.cod:
      case PaymentProvider.applePay:
        return _MockGateway();
    }
  }

  void setProvider(PaymentProvider provider) {
    _gateway = _getGateway(provider);
  }

  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethod,
    PaymentProvider provider = PaymentProvider.paymob,
  }) async {
    if (provider == PaymentProvider.cod) {
      return PaymentResult(
        success: true,
        transactionId: 'COD_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    return _gateway.processPayment(
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
    );
  }
}

class _MockGateway implements PaymentGateway {
  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required Map<String, dynamic> paymentMethod,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PaymentResult(
      success: true,
      transactionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<RefundResult> processRefund({
    required String transactionId,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return RefundResult(
      success: true,
      refundId: 'refund_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}