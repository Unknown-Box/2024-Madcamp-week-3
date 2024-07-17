class BalanceService {
  late double budget;
  late double balance;

  static final _instance = BalanceService._new();

  BalanceService._new() {
    budget = 0.0;
    balance = 40.0;
  }

  factory BalanceService() => _instance;

  double get value => (balance / budget).isFinite ? balance / budget : 0.0;
}