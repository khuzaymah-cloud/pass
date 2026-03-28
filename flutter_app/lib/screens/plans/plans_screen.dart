import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../models/plan.dart';
import '../../models/gym.dart';
import '../../providers/plan_provider.dart';
import '../../services/subscription_service.dart';
import '../../services/gym_service.dart';

const _kBlue = AppColors.accent;
const _kTiers = ['silver', 'gold', 'platinum', 'diamond'];
const _kTierLabels = {
  'silver': 'Silver',
  'gold': 'Gold',
  'platinum': 'Platinum',
  'diamond': 'Diamond',
};
const _kTierColors = {
  'silver': Color(0xFFA0A0B0),
  'gold': Color(0xFFD4A843),
  'platinum': Color(0xFF7B68EE),
  'diamond': Color(0xFF00BFFF),
};

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  String _selectedTier = 'silver';
  int _selectedDuration = 1;

  @override
  Widget build(BuildContext context) {
    final allPlans = ref.watch(allPlansProvider);
    final gymCounts = ref.watch(gymCountsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: allPlans.when(
        data: (plans) => _buildBody(plans, gymCounts.valueOrNull ?? {}),
        loading: () => const Center(child: CircularProgressIndicator(color: _kBlue)),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Widget _buildBody(List<Plan> allPlans, Map<String, int> gymCounts) {
    final plansByTier = <String, List<Plan>>{};
    for (final t in _kTiers) {
      plansByTier[t] = allPlans.where((p) => p.tier == t).toList()
        ..sort((a, b) => a.durationMonths.compareTo(b.durationMonths));
    }

    final selectedPlans = plansByTier[_selectedTier] ?? [];
    final selectedPlan = selectedPlans.firstWhere(
      (p) => p.durationMonths == _selectedDuration,
      orElse: () => selectedPlans.isNotEmpty ? selectedPlans.first : allPlans.first,
    );

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader()),
              // Plan cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tier = _kTiers[index];
                      final isSelected = tier == _selectedTier;
                      final plans = plansByTier[tier] ?? [];
                      final gymCount = gymCounts[tier] ?? 0;
                      final basePlan = plans.isNotEmpty ? plans.first : null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlanTierCard(
                          tier: tier,
                          isSelected: isSelected,
                          plans: plans,
                          selectedDuration: _selectedDuration,
                          gymCount: gymCount,
                          basePrice: basePlan?.priceLocal ?? 0,
                          onSelectTier: () => setState(() {
                            _selectedTier = tier;
                            if (!plans.any((p) => p.durationMonths == _selectedDuration)) {
                              _selectedDuration = 1;
                            }
                          }),
                          onSelectDuration: (d) => setState(() => _selectedDuration = d),
                          onTapGyms: () => _showGymNetwork(tier),
                        ),
                      );
                    },
                    childCount: _kTiers.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Continue button
        _buildContinueButton(selectedPlan),
      ],
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'خطط الأندية',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/subscription'),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('السجل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.bgElevated),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✦ ', style: TextStyle(color: _kBlue, fontSize: 16)),
                Expanded(
                  child: Text(
                    'وصول غير محدود للأندية شهرياً برسوم ثابتة مع تجديد تلقائي',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CustomPaint(
                painter: _DashedLinePainter(color: AppColors.bgElevated),
                size: const Size(double.infinity, 1),
              ),
            ),
            const Text(
              'اختر الاشتراك الأنسب لك',
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(Plan plan) {
    final durLabel = _selectedDuration == 12 ? 'سنة' : '$_selectedDuration ${_selectedDuration > 1 ? 'أشهر' : 'شهر'}';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        boxShadow: [BoxShadow(color: AppColors.bgPrimary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _subscribe(plan.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text(
              'متابعة مع ${_kTierLabels[_selectedTier]} Plan ($durLabel)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe(String planId) async {
    try {
      final sub = await SubscriptionService().create(planId);
      if (mounted) context.go('/payment-stub?sub_id=${sub.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showGymNetwork(String tier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _GymNetworkSheet(tier: tier),
    );
  }
}

// ─── Plan Tier Card ───

class _PlanTierCard extends StatelessWidget {
  final String tier;
  final bool isSelected;
  final List<Plan> plans;
  final int selectedDuration;
  final int gymCount;
  final double basePrice;
  final VoidCallback onSelectTier;
  final ValueChanged<int> onSelectDuration;
  final VoidCallback onTapGyms;

  const _PlanTierCard({
    required this.tier,
    required this.isSelected,
    required this.plans,
    required this.selectedDuration,
    required this.gymCount,
    required this.basePrice,
    required this.onSelectTier,
    required this.onSelectDuration,
    required this.onTapGyms,
  });

  @override
  Widget build(BuildContext context) {
    final color = _kTierColors[tier]!;
    final label = _kTierLabels[tier]!;

    return GestureDetector(
      onTap: onSelectTier,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _kBlue.withValues(alpha: 0.04) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _kBlue : AppColors.bgElevated,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: badge + name + radio
            Row(
              children: [
                // Tier badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.8), color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('1', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$label Plan',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      // Gym count badge
                      GestureDetector(
                        onTap: onTapGyms,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fitness_center, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '+$gymCount أندية',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                              const Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio indicator
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _kBlue : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _kBlue : AppColors.bgElevated,
                      width: isSelected ? 0 : 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Validity info
            const Row(
              children: [
                Icon(Icons.check_circle_outline, size: 14, color: AppColors.textHint),
                SizedBox(width: 4),
                Text('صالح لمدة شهر', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                Text('  |  ', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                Icon(Icons.autorenew, size: 14, color: AppColors.textHint),
                SizedBox(width: 4),
                Text('تجديد تلقائي', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              ],
            ),
            // Expanded: duration picker / Collapsed: starts from
            if (isSelected && plans.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final plan = plans[i];
                    final isActive = plan.durationMonths == selectedDuration;
                    final originalPrice = basePrice * plan.durationMonths;
                    final hasDiscount = plan.durationMonths > 1;
                    final perMonth = plan.priceLocal / plan.durationMonths;
                    final durLabel = plan.durationMonths == 12
                        ? 'سنة'
                        : '${plan.durationMonths} ${plan.durationMonths > 1 ? 'أشهر' : 'شهر'}';

                    return _DurationOption(
                      durLabel: durLabel,
                      price: plan.priceLocal,
                      originalPrice: hasDiscount ? originalPrice : null,
                      perMonth: hasDiscount ? perMonth : null,
                      isSelected: isActive,
                      onTap: () => onSelectDuration(plan.durationMonths),
                    );
                  },
                ),
              ),
            ] else if (!isSelected && plans.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'يبدأ من ${basePrice.toStringAsFixed(0)} د.أ/شهر',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Duration Option Card ───

class _DurationOption extends StatelessWidget {
  final String durLabel;
  final double price;
  final double? originalPrice;
  final double? perMonth;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationOption({
    required this.durLabel,
    required this.price,
    this.originalPrice,
    this.perMonth,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _kBlue : AppColors.bgElevated,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              durLabel.split(' ').first,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isSelected ? _kBlue : AppColors.textPrimary,
              ),
            ),
            Text(
              durLabel.split(' ').last,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            if (originalPrice != null)
              Text(
                '${originalPrice!.toStringAsFixed(0)} د.أ',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Text(
              '${price.toStringAsFixed(0)} د.أ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isSelected ? _kBlue : AppColors.textPrimary,
              ),
            ),
            if (perMonth != null)
              Text(
                '${perMonth!.toStringAsFixed(0)}/شهر',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashed Line Painter ───

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Gym Network Bottom Sheet ───

class _GymNetworkSheet extends StatefulWidget {
  final String tier;
  const _GymNetworkSheet({required this.tier});

  @override
  State<_GymNetworkSheet> createState() => _GymNetworkSheetState();
}

class _GymNetworkSheetState extends State<_GymNetworkSheet> {
  List<Gym>? _gyms;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    try {
      final gyms = await GymService().getNetworkGyms(widget.tier);
      if (mounted) setState(() { _gyms = gyms; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _kTierLabels[widget.tier] ?? widget.tier;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.textHint, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              children: [
                Text(
                  'أندية شبكة خطة $label',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'استكشف جميع أندية شبكة خطة $label...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _kBlue))
                : _gyms == null || _gyms!.isEmpty
                    ? const Center(
                        child: Text('لا توجد أندية متاحة بعد', style: TextStyle(color: AppColors.textHint, fontSize: 15)),
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _gyms!.length,
                        separatorBuilder: (_, __) => const Divider(color: AppColors.bgElevated, height: 1),
                        itemBuilder: (_, i) {
                          final gym = _gyms![i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                // Gym logo placeholder
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgElevated,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: gym.logoUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(gym.logoUrl!, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppColors.textHint)),
                                        )
                                      : const Icon(Icons.fitness_center, color: AppColors.textHint),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gym.nameEn,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      ),
                                      if (gym.categories != null && gym.categories!.isNotEmpty)
                                        Text(
                                          gym.categories!.join(', '),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _kBlue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '30 زيارة',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kBlue),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          // Got it button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('فهمت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
